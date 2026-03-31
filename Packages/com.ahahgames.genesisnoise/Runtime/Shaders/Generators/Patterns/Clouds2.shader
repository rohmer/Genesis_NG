Shader "Hidden/Genesis/Clouds2"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (4,4,0,0)

        _Sharpness("Sharpness", Range(1,8)) = 2.5
        _Detail("Detail Amount", Range(0,1)) = 0.75
        _Contrast("Contrast", Range(0.5,4.0)) = 1.6
        _Offset("Value Offset", Range(-1,1)) = 0.0
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

            float _Sharpness;
            float _Detail;
            float _Contrast;
            float _Offset;

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

            // ---------------------------------------------------------
            // FBM (Clouds 2 style)
            // Stronger mid frequencies, sharper shaping
            // ---------------------------------------------------------
            float fbm_clouds2(float2 p)
            {
                float v = 0.0;

                // Clouds 2 has stronger mid‑octaves
                float amps[5] = {
                    0.55,
                    lerp(0.45, 0.60, _Detail),
                    lerp(0.30, 0.50, _Detail),
                    lerp(0.15, 0.35, _Detail),
                    lerp(0.08, 0.20, _Detail)
                };

                float freq = 1.0;

                [unroll]
                for (int i = 0; i < 5; i++)
                {
                    v += noise(p * freq) * amps[i];
                    freq *= 2.0;
                }

                return v;
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy * _Scale;

                float n = fbm_clouds2(uv);

                // Sharper shaping than Clouds 1
                n = pow(n, _Sharpness);

                // Offset + contrast
                n = saturate(n + _Offset);
                n = pow(n, _Contrast);

                return float4(n, n, n, 1.0);
            }

            ENDHLSL
        }
    }
}