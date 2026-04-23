Shader "Hidden/Genesis/ThermalErosion"
{
    Properties
    {
        _MainTex("Source Heightmap", 2D) = "white" {}
        _Strength("Thermal Strength", Range(0,1)) = 0.35
        _TransferRate("Transfer Rate", Range(0,1)) = 0.5
        _Talus("Talus Threshold", Range(0,0.5)) = 0.03
        _SampleRadius("Sample Radius (px)", Range(1,8)) = 1
        _Bias("Height Bias", Range(-1,1)) = 0.0
        _Contrast("Height Contrast", Range(0.1,4.0)) = 1.0
        [Enum(ErodedHeight,0,RemovedMaterial,1,DepositedMaterial,2,LocalSlope,3)] _OutputMode("Output Mode", Float) = 0
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
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            float _Strength;
            float _TransferRate;
            float _Talus;
            float _SampleRadius;
            float _Bias;
            float _Contrast;
            float _OutputMode;

            static const int NeighborCount = 8;
            static const float2 NeighborOffsets[8] =
            {
                float2(-1.0, -1.0),
                float2( 0.0, -1.0),
                float2( 1.0, -1.0),
                float2(-1.0,  0.0),
                float2( 1.0,  0.0),
                float2(-1.0,  1.0),
                float2( 0.0,  1.0),
                float2( 1.0,  1.0)
            };

            float2 SampleStep()
            {
                return _MainTex_TexelSize.xy * max(1.0, _SampleRadius);
            }

            float SampleHeight(float2 uv)
            {
                float h = tex2D(_MainTex, saturate(uv)).r;
                h = saturate(h + _Bias);
                h = pow(max(h, 0.0), max(_Contrast, 0.0001));
                return h;
            }

            float ComputeTotalExcess(float2 uv, float centerHeight)
            {
                float2 stepUv = SampleStep();
                float totalExcess = 0.0;

                [unroll]
                for (int i = 0; i < NeighborCount; i++)
                {
                    float neighborHeight = SampleHeight(uv + NeighborOffsets[i] * stepUv);
                    totalExcess += max(0.0, centerHeight - neighborHeight - _Talus);
                }

                return totalExcess;
            }

            float ComputeOutgoing(float2 uv, float centerHeight)
            {
                float totalExcess = ComputeTotalExcess(uv, centerHeight);
                return min(centerHeight, totalExcess * _Strength * _TransferRate);
            }

            float ComputeIncoming(float2 centerUv, float centerHeight)
            {
                float2 stepUv = SampleStep();
                float incoming = 0.0;

                [unroll]
                for (int i = 0; i < NeighborCount; i++)
                {
                    float2 neighborUv = centerUv + NeighborOffsets[i] * stepUv;
                    float neighborHeight = SampleHeight(neighborUv);
                    float excessToCenter = max(0.0, neighborHeight - centerHeight - _Talus);

                    if (excessToCenter <= 0.0)
                        continue;

                    float neighborTotalExcess = max(ComputeTotalExcess(neighborUv, neighborHeight), 0.000001);
                    float neighborOutgoing = min(neighborHeight, neighborTotalExcess * _Strength * _TransferRate);
                    incoming += neighborOutgoing * saturate(excessToCenter / neighborTotalExcess);
                }

                return incoming;
            }

            float ComputeSlope(float2 uv, float centerHeight)
            {
                float2 stepUv = SampleStep();
                float maxSlope = 0.0;

                [unroll]
                for (int i = 0; i < NeighborCount; i++)
                {
                    float neighborHeight = SampleHeight(uv + NeighborOffsets[i] * stepUv);
                    maxSlope = max(maxSlope, abs(centerHeight - neighborHeight));
                }

                return saturate(maxSlope / max(_Talus, 0.0001));
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;
                float centerHeight = SampleHeight(uv);
                float outgoing = ComputeOutgoing(uv, centerHeight);
                float incoming = ComputeIncoming(uv, centerHeight);
                float erodedHeight = saturate(centerHeight - outgoing + incoming);

                float value = erodedHeight;

                if (_OutputMode > 0.5 && _OutputMode < 1.5)
                    value = saturate(outgoing * 8.0);
                else if (_OutputMode > 1.5 && _OutputMode < 2.5)
                    value = saturate(incoming * 8.0);
                else if (_OutputMode > 2.5)
                    value = ComputeSlope(uv, centerHeight);

                return float4(value, value, value, 1.0);
            }

            ENDHLSL
        }
    }
}
