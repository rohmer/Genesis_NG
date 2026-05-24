Shader "Hidden/Genesis/Smearing"
{
    Properties
    {
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Slope_2D("Slope Map", 2D) = "gray" {}

        _Intensity("Intensity", Range(0, 16)) = 4
        [IntRange]_Samples("Samples", Range(2, 32)) = 12
        [GenesisSlopeBlurBlend]_Mode("Blend Mode", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET_API
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0
            #pragma shader_feature CRT_2D

            sampler2D _Source_2D;
            sampler2D _Slope_2D;

            float _Intensity;
            float _Samples;
            float _Mode;

            float2 GetTexelSize()
            {
                return float2(
                    rcp(max(_CustomRenderTextureWidth, 1.0)),
                    rcp(max(_CustomRenderTextureHeight, 1.0)));
            }

            float4 SampleSource(float2 uv)
            {
                return tex2Dlod(_Source_2D, float4(uv, 0.0, 0.0));
            }

            float SampleSlope(float2 uv)
            {
                return tex2Dlod(_Slope_2D, float4(uv, 0.0, 0.0)).r;
            }

            float Luminance(float3 color)
            {
                return dot(color, float3(0.2126, 0.7152, 0.0722));
            }

            float2 GetSlopeDirection(float2 uv)
            {
                float2 texel = GetTexelSize();

                float sL = SampleSlope(uv - float2(texel.x, 0.0));
                float sR = SampleSlope(uv + float2(texel.x, 0.0));
                float sD = SampleSlope(uv - float2(0.0, texel.y));
                float sU = SampleSlope(uv + float2(0.0, texel.y));

                float2 gradient = float2(sR - sL, sU - sD);
                float gradientLength = length(gradient);

                if (gradientLength <= 1e-5)
                    return 0.0.xx;

                return gradient / gradientLength;
            }

            void UpdateExtrema(inout float4 bestSample, inout float bestScore, float4 candidate, bool useMaximum)
            {
                float candidateScore = Luminance(candidate.rgb);

                if (useMaximum)
                {
                    if (candidateScore > bestScore)
                    {
                        bestScore = candidateScore;
                        bestSample = candidate;
                    }
                }
                else if (candidateScore < bestScore)
                {
                    bestScore = candidateScore;
                    bestSample = candidate;
                }
            }

            float4 AverageSmear(float2 uv, float2 direction, int sampleCount)
            {
                float4 accum = SampleSource(uv);
                float weightSum = 1.0;
                float2 texel = GetTexelSize();

                [loop]
                for (int sampleIndex = 0; sampleIndex < 32; sampleIndex++)
                {
                    if (sampleIndex >= sampleCount)
                        break;

                    float t = (sampleIndex + 1.0) / sampleCount;
                    float weight = 1.0 - (0.75 * t);
                    float2 sampleOffset = direction * texel * (_Intensity * t);

                    accum += SampleSource(uv + sampleOffset) * weight;
                    accum += SampleSource(uv - sampleOffset) * weight;
                    weightSum += weight * 2.0;
                }

                return accum / max(weightSum, 1e-5);
            }

            float4 ExtremumSmear(float2 uv, float2 direction, int sampleCount, bool useMaximum)
            {
                float4 bestSample = SampleSource(uv);
                float bestScore = Luminance(bestSample.rgb);
                float2 texel = GetTexelSize();

                [loop]
                for (int sampleIndex = 0; sampleIndex < 32; sampleIndex++)
                {
                    if (sampleIndex >= sampleCount)
                        break;

                    float t = (sampleIndex + 1.0) / sampleCount;
                    float2 sampleOffset = direction * texel * (_Intensity * t);

                    UpdateExtrema(bestSample, bestScore, SampleSource(uv + sampleOffset), useMaximum);
                    UpdateExtrema(bestSample, bestScore, SampleSource(uv - sampleOffset), useMaximum);
                }

                return bestSample;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;
                int sampleCount = min(max((int)_Samples, 2), 32);
                float4 source = SampleSource(uv);

                if (_Intensity <= 0.0)
                    return source;

                float2 direction = GetSlopeDirection(uv);
                if (dot(direction, direction) <= 1e-5)
                    return source;

                if (_Mode > 1.5)
                    return AverageSmear(uv, direction, sampleCount);

                return ExtremumSmear(uv, direction, sampleCount, _Mode > 0.5);
            }

            ENDHLSL
        }
    }
}
