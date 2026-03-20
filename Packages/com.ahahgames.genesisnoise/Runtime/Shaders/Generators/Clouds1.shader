Shader "Hidden/Genesis/Clouds1"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (4,4,0,0)

        _Detail("Detail Amount", Range(0,1)) = 0.65
        _Softness("Softness", Range(1,8)) = 3.0
        _Contrast("Contrast", Range(0.5,4.0)) = 1.2
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

            float _Detail;
            float _Softness;
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
            // FBM (Substance Clouds 1 style)
            // ---------------------------------------------------------
            float fbm_clouds(float2 p)
            {
                float v = 0.0;
                float a = 0.55;     // amplitude
                float f = 1.0;      // frequency

                [unroll]
                for (int i = 0; i < 5; i++)
                {
                    v += noise(p * f) * a;
                    f *= 2.0;
                    a *= lerp(0.55, 0.35, _Detail); // detail reduces amplitude falloff
                }

                return v;
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy * _Scale;

                float n = fbm_clouds(uv);

                // Soft shaping
                n = pow(n, _Softness);

                // Offset + contrast
                n = saturate(n + _Offset);
                n = pow(n, _Contrast);

                return float4(n, n, n, 1.0);
            }

            ENDHLSL
        }
    }
}