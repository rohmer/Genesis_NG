Shader "Hidden/Genesis/FlowEffectSuite"
{
    Properties
    {
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        _Distance("Distance", Range(0, 64)) = 18
        _Samples("Samples", Range(4, 32)) = 12
        _Strength("Strength", Range(0, 4)) = 1
        _GravityAngle("Gravity Angle", Range(-180, 180)) = -90
        _Breakup("Breakup", Range(0, 1)) = 0.35
        _Pooling("Pooling", Range(0, 1)) = 0.5
        _Darkening("Darkening", Range(0, 1)) = 0.2
        _Highlight("Highlight", Range(0, 1)) = 0.15
        _Seed("Seed", Float) = 0

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

            TEXTURE_SAMPLER_X(_Source);

            float _Distance;
            float _Samples;
            float _Strength;
            float _GravityAngle;
            float _Breakup;
            float _Pooling;
            float _Darkening;
            float _Highlight;
            float _Seed;
            int _Mode;

            struct FlowData
            {
                float mask;
                float pool;
                float3 smearColor;
            };

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

            float3 SampleSourceAt(v2f_customrendertexture i, float2 offset)
            {
                float3 coord = GetSampleCoord(i, offset);
                float3 dir = GetSampleDirection(i, offset);
                return SAMPLE_X(_Source, coord, dir).rgb;
            }

            float SampleDriveAt(v2f_customrendertexture i, float2 offset)
            {
                float3 color = SampleSourceAt(i, offset);
                return dot(color, float3(0.2126, 0.7152, 0.0722));
            }

            float Hash21(float2 p)
            {
                p = frac(p * float2(123.34, 345.45));
                p += dot(p, p + 34.345);
                return frac(p.x * p.y);
            }

            float2 GetGravityDirection()
            {
                float radiansAngle = radians(_GravityAngle);
                return normalize(float2(cos(radiansAngle), sin(radiansAngle)));
            }

            float2 GetFlowDirection(v2f_customrendertexture i, float3 texel)
            {
                float dx = SampleDriveAt(i, float2(texel.x, 0.0)) - SampleDriveAt(i, float2(-texel.x, 0.0));
                float dy = SampleDriveAt(i, float2(0.0, texel.y)) - SampleDriveAt(i, float2(0.0, -texel.y));

                float2 downhill = -float2(dx, dy);
                float downhillLength = length(downhill);
                if (downhillLength > 1e-5)
                    downhill /= downhillLength;
                else
                    downhill = 0.0.xx;

                float2 gravity = GetGravityDirection();
                float2 blended = gravity + downhill;
                float blendedLength = length(blended);
                if (blendedLength <= 1e-5)
                    return gravity;

                return blended / blendedLength;
            }

            FlowData GatherFlow(v2f_customrendertexture i)
            {
                FlowData flow;
                float3 texel = GetTexelSize();
                float2 flowDirection = GetFlowDirection(i, texel);
                float2 tangent = float2(-flowDirection.y, flowDirection.x);
                int sampleCount = min(max((int)_Samples, 4), 32);
                float distance = max(_Distance, 0.0);
                float center = SampleDriveAt(i, 0.0.xx);

                float flowAccum = 0.0;
                float poolAccum = 0.0;
                float weightSum = 0.0;
                float smearWeight = 0.0;
                float3 smearAccum = 0.0.xxx;

                [loop]
                for (int sampleIndex = 0; sampleIndex < 32; sampleIndex++)
                {
                    if (sampleIndex >= sampleCount)
                        break;

                    float t = (sampleIndex + 1.0) / sampleCount;
                    float stepDistance = distance * t;
                    float jitter = (Hash21(i.globalTexcoord.xy * 251.0 + float2(sampleIndex * 3.13, _Seed * 1.37)) - 0.5) * _Breakup;
                    float2 offset = flowDirection * stepDistance + tangent * (stepDistance * jitter * 0.35);
                    float2 sampleOffset = offset * texel.xy;
                    float upstream = SampleDriveAt(i, -sampleOffset);
                    float downstream = SampleDriveAt(i, sampleOffset);
                    float weight = 1.0 - (0.65 * t);

                    float flowSample = saturate((upstream - center - 0.01) * 4.0);
                    float poolSample = saturate((upstream - downstream - 0.01) * 4.0);

                    flowAccum += flowSample * weight;
                    poolAccum += poolSample * lerp(0.25, 1.0, t);
                    weightSum += weight;

                    smearAccum += SampleSourceAt(i, -sampleOffset) * flowSample * weight;
                    smearWeight += flowSample * weight;
                }

                flow.mask = saturate((flowAccum / max(weightSum, 1e-5)) * _Strength);
                flow.pool = saturate((poolAccum / max(weightSum, 1e-5)) * (_Strength * lerp(0.5, 1.0, _Pooling)));
                flow.smearColor = (smearWeight > 1e-5) ? (smearAccum / smearWeight) : SampleSourceAt(i, 0.0.xx);

                return flow;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 source = SampleSourceAt(i, 0.0.xx);
                FlowData flow = GatherFlow(i);

                if (_Mode == 1)
                {
                    float accumulation = saturate(max(flow.mask, flow.pool));
                    return float4(accumulation.xxx, 1.0);
                }

                if (_Mode == 2)
                {
                    float wetMask = saturate(lerp(flow.mask, max(flow.mask, flow.pool), _Pooling));
                    float3 wetColor = lerp(source, flow.smearColor, wetMask * 0.2);
                    wetColor *= 1.0 - (wetMask * _Darkening);
                    wetColor += wetMask * (0.1 + flow.pool * 0.9) * _Highlight;
                    return float4(saturate(wetColor), 1.0);
                }

                float dripBlend = saturate(flow.mask * (0.75 + (_Pooling * 0.25)));
                float3 dripColor = lerp(source, flow.smearColor, dripBlend);
                dripColor *= 1.0 - (flow.pool * _Darkening * 0.35);
                dripColor += flow.pool * _Highlight * 0.25;

                return float4(saturate(dripColor), 1.0);
            }

            ENDHLSL
        }
    }
}
