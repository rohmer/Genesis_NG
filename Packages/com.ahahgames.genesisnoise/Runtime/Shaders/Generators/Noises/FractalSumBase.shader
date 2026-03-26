Shader "Hidden/Genesis/FractalSumBase"
{
    Properties
    {
        [Tooltip(Global scale of the noise)]
        _Scale("Scale", Float) = 4.0

        [Tooltip(Number of octaves (1 to 8))]
        _Octaves("Octaves", Range(1,8)) = 5

        [Tooltip(Frequency multiplier per octave)]
        _Lacunarity("Lacunarity", Float) = 2.0

        [Tooltip(Amplitude multiplier per octave)]
        _Gain("Gain", Float) = 0.5

        [Tooltip(Offset added to each octave)]
        _Offset("Offset", Float) = 0.0

        [Tooltip(Roughness shaping)]
        _Roughness("Roughness", Float) = 1.0

        [Tooltip(Random seed)]
        _Seed("Seed", Float) = 1.0
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

            float _Scale;
            int _Octaves;
            float _Lacunarity;
            float _Gain;
            float _Offset;
            float _Roughness;
            float _Seed;

            // ---------------------------------------------------------
            // Hash
            // ---------------------------------------------------------
            float hash(float2 p)
            {
                p = frac(p * 0.3183099 + _Seed * 0.1234);
                p *= 17.0;
                return frac(p.x * p.y * (p.x + p.y));
            }

            // ---------------------------------------------------------
            // Value Noise
            // ---------------------------------------------------------
            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                float a = hash(i);
                float b = hash(i + float2(1,0));
                float c = hash(i + float2(0,1));
                float d = hash(i + float2(1,1));

                float2 u = f*f*(3.0 - 2.0*f);

                return lerp(lerp(a,b,u.x), lerp(c,d,u.x), u.y);
            }

            // ---------------------------------------------------------
            // Fractal Sum Base
            // ---------------------------------------------------------
            float fractalSum(float2 p)
            {
                float v = 0.0;
                float amp = 1.0;
                float freq = 1.0;

                for (int i = 0; i < _Octaves; i++)
                {
                    float n = noise(p * freq + _Offset);

                    // Roughness shaping (optional)
                    n = pow(n, _Roughness);

                    v += n * amp;

                    freq *= _Lacunarity;
                    amp *= _Gain;
                }

                return saturate(v);
            }

            // ---------------------------------------------------------
            // Final CRT fragment
            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture IN) : SV_Target
            {
                float3 uv = IN.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float v = fractalSum(uv.xy * _Scale);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
