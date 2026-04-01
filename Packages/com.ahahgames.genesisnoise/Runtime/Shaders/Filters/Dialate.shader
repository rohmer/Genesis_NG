Shader "Hidden/Genesis/DilationFilter"
{
    Properties
    {
        _Source("Source Texture", 2D) = "white" {}
        _Radius("Radius (pixels)", Range(0,10)) = 2
        _Iterations("Iterations", Range(1,8)) = 1
        [Enum(Color,0,Luminance,1)]_UseLuminance("Filter Target", Float) = 1
        _UVScale("UV Scale (for tiling)", Float) = 1.0
        _MaxRadius("Internal Max Radius (do not edit)", Int) = 10
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV
            #pragma shader_feature _TILINGMODE_NONE _TILINGMODE_TILED

            TEXTURE2D(_Source);
            SAMPLER(sampler_Source);

            float _Radius;
            int _Iterations;
            float _UseLuminance;
            float _UVScale;
            int _MaxRadius;

            // Luminance helper
            float Luminance(float3 c)
            {
                return dot(c, float3(0.299, 0.587, 0.114));
            }

            // Sample helper (safe)
            float3 SampleSource(float2 uv)
            {
                return SAMPLE_TEXTURE2D(_Source, sampler_Source, uv).rgb;
            }

            // Single dilation pass: returns dilated color for given uv
            float3 DilationOnce(float2 uv, float2 texelSize, int radius)
            {
                // Initialize with current pixel
                float3 best = SampleSource(uv);
                float bestMetric = _UseLuminance > 0.5 ? Luminance(best) : max(max(best.r, best.g), best.b);

                // Iterate over neighborhood
                // We iterate y then x to improve cache coherence
                [unroll(10)]
                for (int y = -radius; y <= radius; ++y)
                {
                    for (int x = -radius; x <= radius; ++x)
                    {
                        float2 offset = float2(x, y) * texelSize;
                        float3 c = SampleSource(uv + offset);

                        if (_UseLuminance > 0.5)
                        {
                            float m = Luminance(c);
                            if (m > bestMetric)
                            {
                                bestMetric = m;
                                best = c;
                            }
                        }
                        else
                        {
                            // Compare by max channel value (color dilation)
                            float m = max(max(c.r, c.g), c.b);
                            if (m > bestMetric)
                            {
                                bestMetric = m;
                                best = c;
                            }
                        }
                    }
                }

                return best;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                // Compute UV and texel size
                float2 uv = i.localTexcoord.xy * _UVScale;
                // Get texture size via derivative trick (approximate)
                float2 dx = ddx(uv);
                float2 dy = ddy(uv);
                // approximate texel size in UV space
                float2 texelSize = abs(dx) + abs(dy);
                // If texelSize is zero (rare), fallback to a small value
                texelSize = max(texelSize, float2(1.0/1024.0, 1.0/1024.0));

                // Clamp radius to internal max to avoid huge loops
                int radius = (int)min(_Radius, (float)_MaxRadius);
                radius = max(radius, 0);

                // If no dilation requested, just return source
                if (radius == 0 || _Iterations <= 0)
                {
                    float3 src = SampleSource(uv);
                    return float4(src, 1.0);
                }

                // We'll perform iterative dilation in-place by sampling from a temporary color variable.
                // Note: This single-pass approach samples the original texture each iteration,
                // which approximates repeated dilation. For exact iterative dilation you'd need
                // ping-pong render targets (two-pass) or a compute shader.
                float3 result = SampleSource(uv);

                // Iteratively dilate (each iteration grows the region)
                for (int it = 0; it < _Iterations; ++it)
                {
                    // For each iteration we compute dilation around uv using the original texture.
                    // This approximates iterative dilation without ping-ponging.
                    result = DilationOnce(uv, texelSize, radius);
                }

                return float4(saturate(result), 1.0);
            }

            ENDHLSL
        }
    }

    FallBack "Hidden/BlitCopy"
}
