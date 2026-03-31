Shader "Hidden/Genesis/FXAA"
{
    Properties
    {
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        _EdgeThreshold("Edge Threshold", Range(0.01, 0.5)) = 0.125
        _EdgeThresholdMin("Edge Threshold Min", Range(0.0, 0.1)) = 0.0312
        _SubpixelQuality("Subpixel Quality", Range(0.0, 1.0)) = 0.75
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

            float _EdgeThreshold;
            float _EdgeThresholdMin;
            float _SubpixelQuality;

            float Luma(float3 c)
            {
                return dot(c, float3(0.299, 0.587, 0.114));
            }

            float3 SampleColor(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float3 cM = SampleColor(uv, i.direction);
                float3 cN = SampleColor(uv + float3(0, -texel.y,0), i.direction);
                float3 cS = SampleColor(uv + float3(0,  texel.y,0), i.direction);
                float3 cW = SampleColor(uv + float3(-texel.x, 0,0), i.direction);
                float3 cE = SampleColor(uv + float3( texel.x, 0,0), i.direction);

                float lM = Luma(cM);
                float lN = Luma(cN);
                float lS = Luma(cS);
                float lW = Luma(cW);
                float lE = Luma(cE);

                float lMin = min(lM, min(min(lN, lS), min(lW, lE)));
                float lMax = max(lM, max(max(lN, lS), max(lW, lE)));
                float lRange = lMax - lMin;

                // Early exit: no edge
                if (lRange < max(_EdgeThresholdMin, lMax * _EdgeThreshold))
                    return float4(cM, 1);

                // Subpixel AA
                float lAvg = (lN + lS + lW + lE) * 0.25;
                float subpix = saturate((lAvg - lMin) / (lMax - lMin + 1e-5));
                subpix = subpix * subpix * _SubpixelQuality;

                // Edge orientation
                float edgeH = abs(lN + lS - 2.0 * lM);
                float edgeV = abs(lW + lE - 2.0 * lM);
                bool horz = edgeH >= edgeV;

                float3 stepDir = horz ? float3(texel.x, 0,0) : float3(0, texel.y,0);

                // Sample along edge normal
                float3 cA = SampleColor(uv - stepDir * 0.5, i.direction);
                float3 cB = SampleColor(uv + stepDir * 0.5, i.direction);

                float3 cEdge = (cA + cB) * 0.5;

                // Blend between center and edge color
                float3 result = lerp(cM, cEdge, subpix);

                return float4(result, 1);
            }

            ENDHLSL
        }
    }
}