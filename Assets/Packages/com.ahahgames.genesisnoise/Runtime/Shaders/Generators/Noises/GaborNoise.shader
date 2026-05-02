Shader "Hidden/Genesis/GaborNoise"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        _Scale("Scale", Vector) = (8,8,0,0)
        _Offset("Offset", Vector) = (0,0,0,0)
        _Frequency("Kernel Frequency", Range(0.1,8)) = 2
        _Bandwidth("Bandwidth", Range(0.1,4)) = 1
        [IntRange] _ImpulsesPerCell("Impulses Per Cell", Range(1,8)) = 3
        _Direction("Direction", Range(0, 6.2831853)) = 0
        _AngleRandomness("Angle Randomness", Range(0,1)) = 1
        _Jitter("Impulse Jitter", Range(0,1)) = 1
        _Amplitude("Amplitude", Range(0,2)) = 1
        _Contrast("Contrast", Range(0.5,4)) = 1
        _Seed("Seed", Int) = 0
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
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            TEXTURE_SAMPLER_X(_UV);

            float4 _Scale;
            float4 _Offset;
            float _Frequency;
            float _Bandwidth;
            float _ImpulsesPerCell;
            float _Direction;
            float _AngleRandomness;
            float _Jitter;
            float _Amplitude;
            float _Contrast;
            int _Seed;

            float Hash11(float n)
            {
                return frac(sin(n) * 43758.5453123);
            }

            float Hash21(float2 p)
            {
                return Hash11(dot(p, float2(127.1, 311.7)));
            }

            float2 Hash22(float2 p)
            {
                return frac(sin(float2(
                    dot(p, float2(127.1, 311.7)),
                    dot(p, float2(269.5, 183.3))
                )) * 43758.5453123);
            }

            float GaborKernel(float2 d, float2 direction, float frequency, float bandwidth, float phase)
            {
                const float pi = 3.14159265359;
                const float tau = 6.28318530718;

                float gaussian = exp(-pi * bandwidth * bandwidth * dot(d, d));
                float harmonic = cos(tau * frequency * dot(direction, d) + phase);
                return gaussian * harmonic;
            }

            float EvaluateGabor(float2 coordinate)
            {
                float2 p = coordinate * _Scale.xy + _Offset.xy;
                float2 cell = floor(p);
                float response = 0.0;
                float totalWeight = 0.0;

                [unroll]
                for (int y = -1; y <= 1; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 neighbor = cell + float2(x, y);

                        [unroll]
                        for (int impulseIndex = 0; impulseIndex < 8; impulseIndex++)
                        {
                            if (impulseIndex >= (int)_ImpulsesPerCell)
                                break;

                            float2 key = neighbor + float2(_Seed * 0.173 + impulseIndex * 13.37, _Seed * 0.271 + impulseIndex * 29.11);
                            float2 impulseUv = neighbor + lerp(float2(0.5, 0.5), Hash22(key), _Jitter);
                            float angle = _Direction + (Hash21(key + 7.1) * 2.0 - 1.0) * (_AngleRandomness * 3.14159265359);
                            float2 direction = float2(cos(angle), sin(angle));
                            float phase = Hash21(key + 19.7) * 6.28318530718;
                            float signedAmplitude = Hash21(key + 37.9) * 2.0 - 1.0;
                            float2 d = p - impulseUv;

                            response += GaborKernel(d, direction, _Frequency, _Bandwidth, phase) * signedAmplitude;
                            totalWeight += abs(signedAmplitude);
                        }
                    }
                }

                if (totalWeight > 0.0)
                    response /= totalWeight;

                return response;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                int localSeed = _Seed;
                float3 baseUv;

                #ifdef USE_CUSTOM_UV
                    baseUv = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), localSeed);
                #else
                    baseUv = GetDefaultUVs(i);
                #endif

                float value = EvaluateGabor(baseUv.xy);
                value = saturate(0.5 + 0.5 * value * _Amplitude);
                value = saturate(pow(value, _Contrast));

                return float4(value, value, value, 1.0);
            }

            ENDHLSL
        }
    }
}
