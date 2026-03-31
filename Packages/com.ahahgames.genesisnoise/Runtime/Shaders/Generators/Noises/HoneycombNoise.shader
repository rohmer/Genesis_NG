Shader "Hidden/Genesis/Honeycomb"
{
    Properties
    {
        [InlineTexture]_UV_2D("UV", 2D) = "white" {}
        [InlineTexture]_UV_3D("UV", 3D) = "white" {}
        [InlineTexture]_UV_Cube("UV", Cube) = "white" {}

        [Tooltip(Scale of the honeycomb pattern)]
        _Zoom("Zoom", Range(0.5, 16)) = 10

        [Tooltip(Animation speed)]
        _TimeScale("Time Scale", Float) = 0.0

        [Enum(Hex,0, Star,1)]
        _Variant("Comb Style", Int) = 0        
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
            #pragma target 3.0

            TEXTURE_SAMPLER_X(_UV);

            float _Zoom;
            float _TimeScale;
            int   _Variant;
            int   _Seed;
            float _Time;

            // ---------------------------------------------------------
            // Hash helpers
            float hash1(float x)
            {
                float f1 = frac(x * 0.31830988618379);
                float f2 = frac(x * 0.15915494309189);
                return frac(f1 * f2 * 265871.1723);
            }

            float hash2(float2 x)
            {
                return hash1(dot(fmod(x, 100.0), float2(127.1, 311.7)));
            }

            float3 hash3(float3 x)
            {
                float3 f1 = frac(x * 0.31830988618379);
                float3 f2 = frac(x * 0.15915494309189);
                return frac(f1 * f2 * 265871.1723);
            }

            float3 hash3x2(float2 a, float2 b, float2 c)
            {
                return hash3(float3(
                    dot(fmod(a, 100.0), float2(127.1, 311.7)),
                    dot(fmod(b, 100.0), float2(127.1, 311.7)),
                    dot(fmod(c, 100.0), float2(127.1, 311.7))
                ));
            }

            // ---------------------------------------------------------
            // Hex honeycomb
            float noiseHoneycomb(float2 i)
            {
                i.x *= 1.15470053838;

                float2 c3;
                c3.x = floor(i.x) + 1.0;

                float2 b = float2(i.y + i.x * 0.5, i.y - i.x * 0.5);
                c3.y = floor(b.x) + floor(b.y);

                float3 o = frac(float3(i.x, b));

                float3 m1 = hash3x2(c3 + float2(1, 0),  c3 + float2(-1, -1), c3 + float2(-1, 1));
                float3 m2 = hash3x2(c3,                c3 + float2(0, 1),   c3 + float2(0, -1));
                float3 m3 = hash3x2(c3 + float2(-1, 0),c3 + float2(1, 1),   c3 + float2(1, -1));
                float3 m4 = float3(m2.x, m2.z, m2.y);

                float3 w1 = float3(o.x, 1.0 - o.y, o.z);
                float3 w2 = float3(1.0 - o.x, o.y, 1.0 - o.z);

                float2 d = frac(c3 * 0.5) * 2.0;

                float4 s = frac(float4(
                    dot(m1, w1),
                    dot(m2, w2),
                    dot(m3, w2),
                    dot(m4, w1)
                ));

                return frac(lerp(lerp(s.z, s.w, d.x), lerp(s.x, s.y, d.x), d.y));
            }

            // ---------------------------------------------------------
            // Star honeycomb
            float noiseHoneycombStar(float2 i)
            {
                i.x *= 1.15470053838;

                float2 c3;
                c3.x = floor(i.x) + 1.0;

                float2 b = float2(i.y + i.x * 0.5, i.y - i.x * 0.5);
                c3.y = floor(b.x) + floor(b.y);

                float3 o = frac(float3(i.x, b));

                float3 m1 = float3(
                    hash2(c3 + float2(1, 0)),
                    hash2(c3 + float2(-1, -1)),
                    hash2(c3 + float2(-1, 1))
                );

                float3 m2 = float3(
                    hash2(c3),
                    hash2(c3 + float2(0, 1)),
                    hash2(c3 + float2(0, -1))
                );

                float3 m3 = float3(
                    hash2(c3 + float2(-1, 0)),
                    hash2(c3 + float2(1, 1)),
                    hash2(c3 + float2(1, -1))
                );

                float3 m4 = float3(m2.x, m2.z, m2.y);

                float3 w1 = float3(o.x, 1.0 - o.y, o.z);
                float3 w2 = float3(1.0 - o.x, o.y, 1.0 - o.z);

                w1 = w1 * w1 * (3.0 - 2.0 * w1);
                w2 = w2 * w2 * (3.0 - 2.0 * w2);

                float2 d = frac(c3 * 0.5) * 2.0;

                float4 s = frac(float4(
                    dot(m1, w1),
                    dot(m2, w2),
                    dot(m3, w2),
                    dot(m4, w1)
                ));

                return frac(lerp(lerp(s.z, s.w, d.x), lerp(s.x, s.y, d.x), d.y));
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv;
                _Seed=1;
                _Time=1;
                #ifdef USE_CUSTOM_UV
                    float3 uvs = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);
                    uv = uvs.xy / _Zoom;
                #else
                    uv = GetDefaultUVs(i) / _Zoom;
                #endif

                float t = _Time * _TimeScale;

                float2 p = uv * 10.0 + float2(t, t * 0.5);

                float v = (_Variant == 0)
                    ? noiseHoneycomb(p)
                    : noiseHoneycombStar(p);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}