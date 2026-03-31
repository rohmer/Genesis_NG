Shader "Hidden/Genesis/Grunge005"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (1,1,0,0)

        _CloudAmount("Cloud Amount", Range(0,1)) = 0.55
        _CloudScale("Cloud Scale", Range(2,20)) = 6.0
        _CloudSoftness("Cloud Softness", Range(1,10)) = 3.0

        _FineDust("Fine Dust", Range(0,1)) = 0.65
        _FineDustScale("Fine Dust Scale", Range(10,60)) = 28.0
        _FineDustSharpness("Fine Dust Sharpness", Range(1,8)) = 3.2

        _MicroSpecks("Micro Specks", Range(0,1)) = 0.55
        _MicroSpeckScale("Micro Speck Scale", Range(40,200)) = 100.0

        _HighFreqNoise("High Frequency Noise", Range(0,1)) = 0.45
        _HighFreqScale("High Frequency Scale", Range(20,120)) = 60.0

        _Breakup("Breakup Strength", Range(0,1)) = 0.55
        _Contrast("Contrast", Range(0.5,6.0)) = 4.5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET_API
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            float2 _Scale;

            float _CloudAmount;
            float _CloudScale;
            float _CloudSoftness;

            float _FineDust;
            float _FineDustScale;
            float _FineDustSharpness;

            float _MicroSpecks;
            float _MicroSpeckScale;

            float _HighFreqNoise;
            float _HighFreqScale;

            float _Breakup;
            float _Contrast;

            // ---------------------------------------------------------
            // Hash + Noise
            // ---------------------------------------------------------
            float hash11(float n)
            {
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7));
                return frac(sin(float2(n, n + 1.234)) * 43758.5453);
            }

            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                float2 u = f * f * (3.0 - 2.0 * f);

                float a = hash11(i.x + i.y * 57.0);
                float b = hash11(i.x + 1.0 + i.y * 57.0);
                float c = hash11(i.x + (i.y + 1.0) * 57.0);
                float d = hash11(i.x + 1.0 + (i.y + 1.0) * 57.0);

                return lerp(lerp(a,b,u.x), lerp(c,d,u.x), u.y);
            }

            float fbm(float2 p)
            {
                float v = 0.0;
                float a = 0.5;

                [unroll]
                for (int i = 0; i < 5; i++)
                {
                    v += noise(p) * a;
                    p *= 2.0;
                    a *= 0.55;
                }
                return v;
            }

            // ---------------------------------------------------------
            // Soft cloud breakup (broad, subtle)
            // ---------------------------------------------------------
            float cloud(float2 uv)
            {
                float n = fbm(uv * _CloudScale);
                n = pow(n, _CloudSoftness);
                return n * _CloudAmount;
            }

            // ---------------------------------------------------------
            // Fine dust (signature of Grunge 005)
            // ---------------------------------------------------------
            float fineDust(float2 uv)
            {
                float n = fbm(uv * _FineDustScale);
                n = pow(n, _FineDustSharpness);
                return n * _FineDust;
            }

            // ---------------------------------------------------------
            // Micro specks (high-frequency detail)
            // ---------------------------------------------------------
            float microSpecks(float2 uv)
            {
                float n = fbm(uv * _MicroSpeckScale);
                float m = smoothstep(0.7, 0.9, n);
                return m * _MicroSpecks;
            }

            // ---------------------------------------------------------
            // High-frequency noise (powdery texture)
            // ---------------------------------------------------------
            float highFreq(float2 uv)
            {
                float n = fbm(uv * _HighFreqScale);
                return n * _HighFreqNoise;
            }

            // ---------------------------------------------------------
            // Breakup modulation
            // ---------------------------------------------------------
            float breakup(float2 uv)
            {
                float b = fbm(uv * 3.0);
                return lerp(1.0, b, _Breakup);
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float C  = cloud(uv);
                float F  = fineDust(uv);
                float S  = microSpecks(uv);
                float H  = highFreq(uv);
                float BR = breakup(uv);

                float v = C + F + S + H;

                v *= BR;
                v = pow(saturate(v), _Contrast);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}