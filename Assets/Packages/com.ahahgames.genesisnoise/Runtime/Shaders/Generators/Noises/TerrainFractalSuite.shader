Shader "Hidden/Genesis/TerrainFractalSuite"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        [HideInInspector] _Mode("Mode", Float) = 0
        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 0
        [Enum(2D,0,3D,1)] _Dim("Noise Dimension", Float) = 0
        _Frequency("Frequency", Float) = 4
        _Offset("Offset", Vector) = (0,0,0,0)
        [IntRange] _Octaves("Octaves", Range(1,10)) = 6
        _Lacunarity("Lacunarity", Float) = 2
        _Gain("Gain", Range(0,1)) = 0.5
        _FractalOffset("Fractal Offset", Range(0,2)) = 1
        _Weight("Weight Multiplier", Range(0,2)) = 1
        _PingPongStrength("Ping Pong Strength", Range(1,8)) = 2
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
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/PerlinNoise.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV
            #pragma shader_feature _TILINGMODE_NONE _TILINGMODE_TILED

            TEXTURE_SAMPLER_X(_UV);

            float _Mode;
            float _Dim;
            float _Frequency;
            float4 _Offset;
            float _Octaves;
            float _Lacunarity;
            float _Gain;
            float _FractalOffset;
            float _Weight;
            float _PingPongStrength;
            float _Amplitude;
            float _Contrast;
            int _Seed;

            float BaseNoiseValue(float3 coordinate, float frequency, int seed)
            {
                if (_Dim < 0.5)
                    return perlinNoise2D(coordinate.xy * frequency, seed).x;

                return perlinNoise3D(coordinate * frequency, seed).x;
            }

            float BaseNoise01(float3 coordinate, float frequency, int seed)
            {
                return saturate(0.5 + 0.5 * BaseNoiseValue(coordinate, frequency, seed));
            }

            float PingPong(float value)
            {
                value = frac(value * 0.5) * 2.0;
                return 1.0 - abs(value - 1.0);
            }

            float EvaluateHybrid(float3 coordinate, float frequency, float lacunarity)
            {
                float result = _FractalOffset + BaseNoise01(coordinate, frequency, _Seed);
                float weight = saturate(result * _Weight);
                float amplitude = 1.0;

                [loop]
                for (int octave = 1; octave < 10; octave++)
                {
                    if (octave >= (int)_Octaves)
                        break;

                    frequency *= lacunarity;
                    amplitude *= _Gain;

                    float signal = (_FractalOffset + BaseNoise01(coordinate, frequency, _Seed + octave * 37)) * amplitude;
                    result += weight * signal;
                    weight = saturate(weight * signal * _Weight);
                }

                return result / max(1.0 + (max((int)_Octaves, 1) - 1) * _Gain, 0.0001);
            }

            float EvaluateHetero(float3 coordinate, float frequency, float lacunarity)
            {
                float result = _FractalOffset + BaseNoise01(coordinate, frequency, _Seed);
                float amplitude = _Gain;

                [loop]
                for (int octave = 1; octave < 10; octave++)
                {
                    if (octave >= (int)_Octaves)
                        break;

                    frequency *= lacunarity;
                    float signal = (_FractalOffset + BaseNoise01(coordinate, frequency, _Seed + octave * 41)) * amplitude * result;
                    result += signal;
                    amplitude *= _Gain;
                }

                return result / max(1.0 + (max((int)_Octaves, 1) - 1) * _Gain, 0.0001);
            }

            float EvaluatePingPong(float3 coordinate, float frequency, float lacunarity)
            {
                float result = 0.0;
                float amplitude = 1.0;
                float totalAmplitude = 0.0;

                [loop]
                for (int octave = 0; octave < 10; octave++)
                {
                    if (octave >= (int)_Octaves)
                        break;

                    float signal = PingPong(BaseNoise01(coordinate, frequency, _Seed + octave * 53) * _PingPongStrength);
                    result += signal * amplitude;
                    totalAmplitude += amplitude;

                    amplitude *= _Gain;
                    frequency *= lacunarity;
                }

                return result / max(totalAmplitude, 0.0001);
            }

            float EvaluateRidged(float3 coordinate, float frequency, float lacunarity)
            {
                float result = 0.0;
                float amplitude = 0.5;
                float weight = 1.0;
                float totalAmplitude = 0.0;

                [loop]
                for (int octave = 0; octave < 10; octave++)
                {
                    if (octave >= (int)_Octaves)
                        break;

                    float signal = _FractalOffset - abs(BaseNoiseValue(coordinate, frequency, _Seed + octave * 59));
                    signal = max(signal, 0.0);
                    signal *= signal;
                    signal *= weight;

                    result += signal * amplitude;
                    totalAmplitude += amplitude;

                    weight = saturate(signal * _Weight);
                    amplitude *= _Gain;
                    frequency *= lacunarity;
                }

                return result / max(totalAmplitude, 0.0001);
            }

            float EvaluateTerrainFractal(float3 coordinate)
            {
                float localFrequency = _Frequency;
                float localLacunarity = _Lacunarity;
                SetupNoiseTiling(localLacunarity, localFrequency);

                if (_Mode < 0.5)
                    return EvaluateHybrid(coordinate, localFrequency, localLacunarity);
                if (_Mode < 1.5)
                    return EvaluateHetero(coordinate, localFrequency, localLacunarity);
                if (_Mode < 2.5)
                    return EvaluatePingPong(coordinate, localFrequency, localLacunarity);

                return EvaluateRidged(coordinate, localFrequency, localLacunarity);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                int localSeed = _Seed;
                float3 coordinate;

                #ifdef USE_CUSTOM_UV
                    coordinate = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), localSeed);
                #else
                    coordinate = GetDefaultUVs(i);
                #endif

                coordinate += _Offset.xyz;

                float value = saturate(EvaluateTerrainFractal(coordinate) * _Amplitude);
                value = saturate(pow(value, _Contrast));

                return float4(value, value, value, 1.0);
            }

            ENDHLSL
        }
    }
}
