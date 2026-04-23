Shader "Hidden/Genesis/SymmetricNearestNeighbor"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        _Source("Source Texture", 2D) = "white" {}
        _Radius("Radius (texels)", Range(1,8)) = 2
        _Blend("Blend with original", Range(0,1)) = 1.0
        _LumaWeight("Luminance weight (0..1)", Range(0,1)) = 1.0
        _Seed("Seed", Int) = 42
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment genesis
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
	        #pragma vertex CustomRenderTextureVertexShader
	        #pragma fragment GenesisFragment
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"

            TEXTURE_SAMPLER_X(_UV);
            TEXTURE2D(_Source);
            SAMPLER(sampler_Source);

            float4 _TexelSize;
            float _Radius;
            float _Blend;
            float _LumaWeight;
            int _Seed;

            // luminance
            float Luma(float3 c) { return dot(c, float3(0.2126, 0.7152, 0.0722)); }

            // Sample source using Genesis UV helpers so CRTs and 3D UVs work
            float3 SampleSourceUV(float2 uv)
            {
                return SAMPLE_TEXTURE2D(_Source, sampler_Source, uv).rgb;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                // Resolve UVs using Genesis helper
                float3 raw = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);
                float2 uv = raw.xy;

                float3 center = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv).rgb;
                float centerL = Luma(center);

                int r = max(1, (int)(_Radius + 0.5));

                float3 accum = center;
                float wsum = 1.0;

                // Symmetric nearest neighbor in a cross pattern (left/right and up/down)
                // For each distance d = 1..r, pick the sample (pos or neg) whose luminance is closer to center
                for (int d = 1; d <= r; d++)
                {
                    // horizontal pair
                    float2 offH = float2(d, 0) * _TexelSize.xy;
                    float3 sPosH = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + offH).rgb;
                    float3 sNegH = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv - offH).rgb;
                    float diffPosH = abs(Luma(sPosH) - centerL);
                    float diffNegH = abs(Luma(sNegH) - centerL);
                    float3 chosenH = diffPosH <= diffNegH ? sPosH : sNegH;

                    // vertical pair
                    float2 offV = float2(0, d) * _TexelSize.xy;
                    float3 sPosV = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + offV).rgb;
                    float3 sNegV = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv - offV).rgb;
                    float diffPosV = abs(Luma(sPosV) - centerL);
                    float diffNegV = abs(Luma(sNegV) - centerL);
                    float3 chosenV = diffPosV <= diffNegV ? sPosV : sNegV;

                    // weight by distance (closer samples stronger) and optionally by luminance similarity
                    float w = 1.0 / (float)d;
                    if (_LumaWeight > 0.0)
                    {
                        // boost weight for closer luminance match
                        float matchH = 1.0 - saturate(min(diffPosH, diffNegH) / 0.5);
                        float matchV = 1.0 - saturate(min(diffPosV, diffNegV) / 0.5);
                        w *= lerp(1.0, (matchH + matchV) * 0.5 * 2.0, _LumaWeight);
                    }

                    accum += chosenH * w;
                    accum += chosenV * w;
                    wsum += 2.0 * w;
                }

                float3 filtered = accum / max(1e-6, wsum);

                // Blend with original to allow partial filtering
                float3 outColor = lerp(center, filtered, _Blend);

                return float4(saturate(outColor), 1.0);
            }

            ENDHLSL
        }
    }
}
