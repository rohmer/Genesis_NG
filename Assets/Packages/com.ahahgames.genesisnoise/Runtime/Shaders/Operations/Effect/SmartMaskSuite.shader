Shader "Hidden/Genesis/SmartMaskSuite"
{
    Properties
    {
        [InlineTexture]_Height_2D("Height", 2D) = "black" {}
        [InlineTexture]_Height_3D("Height", 3D) = "black" {}
        [InlineTexture]_Height_Cube("Height", Cube) = "black" {}

        _Radius("Radius", Range(1, 64)) = 16
        _Samples("Samples", Range(4, 32)) = 16
        _Strength("Strength", Range(0, 4)) = 1
        _Bias("Bias", Range(0, 1)) = 0.02
        _Contrast("Contrast", Range(0.25, 4)) = 1
        _Invert("Invert Height", Int) = 0

        _OcclusionWeight("AO Weight", Range(0, 4)) = 1
        _CavityWeight("Cavity Weight", Range(0, 4)) = 1
        _ThicknessWeight("Thickness Weight", Range(0, 4)) = 1
        _SlopeWeight("Slope Weight", Range(0, 4)) = 0.5

        [HideInInspector]_Mode("Mode", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_Height);

            float _Radius;
            float _Samples;
            float _Strength;
            float _Bias;
            float _Contrast;
            int _Invert;
            float _OcclusionWeight;
            float _CavityWeight;
            float _ThicknessWeight;
            float _SlopeWeight;
            int _Mode;

            float3 GetTexelSize()
            {
                return float3(
                    rcp(max(_CustomRenderTextureWidth, 1.0)),
                    rcp(max(_CustomRenderTextureHeight, 1.0)),
                    (_CustomRenderTextureDepth > 1.0) ? rcp(_CustomRenderTextureDepth) : 0.0);
            }

            float3 GetSampleCoord(v2f_customrendertexture i, float2 offset)
            {
#ifdef CRT_CUBE
                return float3(saturate(i.globalTexcoord.xy + offset), i.localTexcoord.z);
#else
                return i.localTexcoord.xyz + float3(offset, 0.0);
#endif
            }

            float3 GetSampleDirection(v2f_customrendertexture i, float2 offset)
            {
#ifdef CRT_CUBE
                return ComputeCubemapDirectionFromUV(saturate(i.globalTexcoord.xy + offset), _CustomRenderTextureCubeFace);
#else
                return i.direction;
#endif
            }

            float SampleHeightAt(v2f_customrendertexture i, float2 offset)
            {
                float3 coord = GetSampleCoord(i, offset);
                float3 dir = GetSampleDirection(i, offset);
                float height = SAMPLE_X(_Height, coord, dir).r;
                return (_Invert != 0) ? (1.0 - height) : height;
            }

            float ApplyResponse(float value)
            {
                value = saturate((value - 0.5) * _Contrast + 0.5);
                return saturate(value * _Strength);
            }

            void GatherMetrics(v2f_customrendertexture i, out float ao, out float cavity, out float thickness, out float slope)
            {
                float center = SampleHeightAt(i, 0.0.xx);
                float3 texel = GetTexelSize();
                int sampleCount = min(max((int)_Samples, 4), 32);
                float radius = max(_Radius, 1.0);

                float aoAccum = 0.0;
                float cavityAccum = 0.0;
                float thicknessAccum = 0.0;
                float weightSum = 0.0;

                [loop]
                for (int sampleIndex = 0; sampleIndex < 32; sampleIndex++)
                {
                    if (sampleIndex >= sampleCount)
                        break;

                    float radialT = sqrt((sampleIndex + 0.5) / sampleCount);
                    float angle = (sampleIndex + 1.0) * 2.39996323;
                    float2 direction = float2(cos(angle), sin(angle));
                    float2 offset = direction * texel.xy * radius * radialT;
                    float hA = SampleHeightAt(i, offset);
                    float hB = SampleHeightAt(i, -offset);
                    float neighborAverage = (hA + hB) * 0.5;
                    float weight = 1.0 - (0.5 * radialT);

                    float occlusionSample = 0.5 * (saturate(hA - center - _Bias) + saturate(hB - center - _Bias));
                    float cavitySample = saturate(neighborAverage - center - _Bias);
                    float thicknessSample = saturate(min(hA, hB) - center - _Bias);

                    aoAccum += occlusionSample * weight;
                    cavityAccum += cavitySample * weight;
                    thicknessAccum += thicknessSample * weight;
                    weightSum += weight;
                }

                ao = aoAccum / max(weightSum, 1e-5);
                cavity = cavityAccum / max(weightSum, 1e-5);
                thickness = thicknessAccum / max(weightSum, 1e-5);

                float2 normalStep = texel.xy * max(radius * 0.25, 1.0);
                float dx = SampleHeightAt(i, float2(normalStep.x, 0.0)) - SampleHeightAt(i, float2(-normalStep.x, 0.0));
                float dy = SampleHeightAt(i, float2(0.0, normalStep.y)) - SampleHeightAt(i, float2(0.0, -normalStep.y));
                float3 normal = normalize(float3(-dx * 4.0, -dy * 4.0, 1.0));
                slope = saturate(1.0 - normal.z);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float ao;
                float cavity;
                float thickness;
                float slope;

                GatherMetrics(i, ao, cavity, thickness, slope);

                float totalWeight = max(_OcclusionWeight + _CavityWeight + _ThicknessWeight + _SlopeWeight, 1e-5);
                float smartMask = (
                    ao * _OcclusionWeight +
                    cavity * _CavityWeight +
                    thickness * _ThicknessWeight +
                    slope * _SlopeWeight) / totalWeight;

                float outputValue;
                if (_Mode == 0)
                    outputValue = ApplyResponse(ao);
                else if (_Mode == 1)
                    outputValue = ApplyResponse(cavity);
                else if (_Mode == 2)
                    outputValue = ApplyResponse(thickness);
                else
                    outputValue = ApplyResponse(smartMask);

                return float4(outputValue.xxx, 1.0);
            }

            ENDHLSL
        }
    }
}
