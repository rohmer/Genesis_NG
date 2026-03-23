Shader "Hidden/Genesis/Worley"
{
    Properties
    {
        [Tooltip(Frequency and tiling)] _Scale("Scale", Vector) = (4,4,4,0)
        [Tooltip(Offset in noise space)] _Offset("Offset", Vector) = (0,0,0,0)

        [Tooltip(Amplitude)] _Amplitude("Amplitude", Range(0,4)) = 1.0
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.0
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

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            float3 _Scale;
            float3 _Offset;
            float  _Amplitude;
            float  _Contrast;

            // ---------------------------------------------------------
            // r() — 1D and 2D hash (converted from GLSL)
            float r1(float n)
            {
                return frac(cos(n * 89.42) * 343.42);
            }

            float2 r2(float2 n)
            {
                return float2(
                    r1(n.x * 23.62 - 300.0 + n.y * 34.35),
                    r1(n.x * 45.13 + 256.0 + n.y * 38.89)
                );
            }

            // ---------------------------------------------------------
            // Worley 2D (converted from GLSL)
            float worley2D(float2 n, float s)
            {
                float dis = 2.0;

                float2 base = floor(n / s);
                float2 f = frac(n / s);

                [unroll]
                for (int x = -1; x <= 1; x++)
                {
                    [unroll]
                    for (int y = -1; y <= 1; y++)
                    {
                        float2 p = base + float2(x, y);
                        float d = length(r2(p) + float2(x, y) - f);
                        dis = min(dis, d);
                    }
                }

                return 1.0 - dis;
            }

            // ---------------------------------------------------------
            // Perlin 3D (hash33 version)
            static const float3 MOD3 = float3(0.1031, 0.11369, 0.13787);

            float3 hash33(float3 p3)
            {
                p3 = frac(p3 * MOD3);
                p3 += dot(p3, p3.yxz + 19.19);
                return -1.0 + 2.0 * frac(float3(
                    (p3.x + p3.y) * p3.z,
                    (p3.x + p3.z) * p3.y,
                    (p3.y + p3.z) * p3.x
                ));
            }

            float perlin3D(float3 p)
            {
                float3 pi = floor(p);
                float3 pf = p - pi;

                float3 w = pf * pf * (3.0 - 2.0 * pf);

                float3 c000 = hash33(pi + float3(0,0,0));
                float3 c100 = hash33(pi + float3(1,0,0));
                float3 c001 = hash33(pi + float3(0,0,1));
                float3 c101 = hash33(pi + float3(1,0,1));

                float3 c010 = hash33(pi + float3(0,1,0));
                float3 c110 = hash33(pi + float3(1,1,0));
                float3 c011 = hash33(pi + float3(0,1,1));
                float3 c111 = hash33(pi + float3(1,1,1));

                float x00 = lerp(dot(pf - float3(0,0,0), c000),
                                 dot(pf - float3(1,0,0), c100), w.x);

                float x01 = lerp(dot(pf - float3(0,0,1), c001),
                                 dot(pf - float3(1,0,1), c101), w.x);

                float x10 = lerp(dot(pf - float3(0,1,0), c010),
                                 dot(pf - float3(1,1,0), c110), w.x);

                float x11 = lerp(dot(pf - float3(0,1,1), c011),
                                 dot(pf - float3(1,1,1), c111), w.x);

                float y0 = lerp(x00, x01, w.z);
                float y1 = lerp(x10, x11, w.z);

                return lerp(y0, y1, w.y);
            }

            // ---------------------------------------------------------
            float evaluateNoise(float3 uv)
            {
                float3 p = uv * _Scale + _Offset;

                // Perlin 3D
                float perlin = perlin3D(p * 8.0);

                // Worley FBM (3 octaves)
                float2 xy = uv.xy * _Scale.xy;

                float w =
                    worley2D(xy, 32.0) +
                    0.5 * worley2D(xy * 2.0, 32.0) +
                    0.25 * worley2D(xy * 4.0, 32.0);

                float dis = (1.0 + perlin) * (1.0 + w);

                return dis / 4.0;
            }

            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float v = evaluateNoise(i.localTexcoord);

                v *= _Amplitude;
                v = saturate(pow(v, _Contrast));

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}