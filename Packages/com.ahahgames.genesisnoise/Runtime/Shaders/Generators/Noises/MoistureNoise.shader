Shader "Hidden/Genesis/MoistureNoise"
{
    Properties
    {
        [Tooltip(Global scale of the moisture pattern)]
        _Scale("Scale", Float) = 4.0

        [Tooltip(Cellular (Worley) influence)]
        _Cellular("Cellular Strength", Float) = 1.0

        [Tooltip(FBM breakup influence)]
        _FBM("FBM Strength", Float) = 0.5

        [Tooltip(Spread and wetness falloff)]
        _Spread("Spread", Float) = 1.0

        [Tooltip(Directional smear amount)]
        _Smear("Smear", Float) = 0.25

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
            float _Cellular;
            float _FBM;
            float _Spread;
            float _Smear;
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

            float2 hash2(float2 p)
            {
                return float2(hash(p), hash(p + 13.37));
            }

            // ---------------------------------------------------------
            // Worley (Cellular) Noise
            // ---------------------------------------------------------
            float worley(float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);

                float d = 1e6;

                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 g = float2(x, y);
                        float2 o = hash2(i + g);
                        float2 p = g + o - f;
                        d = min(d, dot(p, p));
                    }
                }

                return sqrt(d);
            }

            // ---------------------------------------------------------
            // FBM (soft breakup)
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

            float fbm(float2 p)
            {
                float v = 0.0;
                float a = 0.5;

                for (int i = 0; i < 4; i++)
                {
                    v += noise(p) * a;
                    p *= 2.0;
                    a *= 0.5;
                }

                return v;
            }

            // ---------------------------------------------------------
            // Moisture Noise Core
            // ---------------------------------------------------------
            float moisture(float2 uv)
            {
                // Slight directional smear
                uv += float2(uv.y * _Smear, 0.0);

                float2 p = uv * _Scale;

                float c = worley(p);
                float f = fbm(p * 0.75);

                // Moisture spread falloff
                float spread = exp(-c * _Spread);

                // Combine
                float m = 
                    _Cellular * (1.0 - c) +
                    _FBM * f;

                m *= spread;

                return saturate(m);
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

                float m = moisture(uv.xy);

                return float4(m, m, m, 1.0);
            }

            ENDHLSL
        }
    }
}
