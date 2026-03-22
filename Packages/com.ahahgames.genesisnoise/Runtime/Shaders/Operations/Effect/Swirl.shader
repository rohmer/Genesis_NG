Shader "Hidden/Genesis/Swirl"
{
    Properties
    {
        // Source image to swirl
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        _Amount("Swirl Amount", Range(-2, 2)) = 0.5       // turns (±2 = 720°)
        _Radius("Radius", Range(0, 1)) = 0.5              // normalized radius
        _Softness("Softness", Range(0, 1)) = 0.35         // falloff shaping
        _Center("Center", Vector) = (0.5, 0.5, 0, 0)       // UV center
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_Source);

            float _Amount;
            float _Radius;
            float _Softness;
            float4 _Center;

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            // Substance-like falloff curve
            float Falloff(float x)
            {
                float smooth = smoothstep(0, 1, x);
                float sharp  = pow(x, 0.35);
                return lerp(smooth, sharp, _Softness);
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float2 center = _Center.xy;
                float2 d = uv - center;

                float dist = length(d);
                float r = max(_Radius, 1e-5);

                // Outside radius → no swirl
                if (dist > r)
                    return float4(SampleSource(uv, i.direction), 1);

                // Normalized distance 0–1
                float t = dist / r;

                // Falloff: center rotates most, edge rotates least
                float f = Falloff(1.0 - t);

                // Rotation angle in radians
                float angle = _Amount * 6.2831853 * f;

                float s = sin(angle);
                float c = cos(angle);

                float2 rot = float2(
                    d.x * c - d.y * s,
                    d.x * s + d.y * c
                );

                float2 suv = center + rot;

                float3 col = SampleSource(float3(suv,0), i.direction);

                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}