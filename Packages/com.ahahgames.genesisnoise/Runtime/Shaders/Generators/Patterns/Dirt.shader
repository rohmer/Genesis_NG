Shader "Hidden/Genesis/GrungeDirt"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (1,1,0,0)

        _BlotchDensity("Blotch Density", Range(0,1)) = 0.55
        _BlotchRadius("Blotch Radius", Range(0.1,4.0)) = 1.4
        _BlotchSoftness("Blotch Softness", Range(0.5,10.0)) = 3.0

        _MicroDust("Micro Dust", Range(0,1)) = 0.45
        _MicroDustScale("Micro Dust Scale", Range(4,40)) = 18.0

        _OcclusionStrength("Occlusion Strength", Range(0,1)) = 0.5
        _OcclusionScale("Occlusion Scale", Range(0.5,8.0)) = 2.0

        _Breakup("Breakup Strength", Range(0,1)) = 0.7
        _Contrast("Contrast", Range(0.5,4.0)) = 1.35
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

            float _BlotchDensity;
            float _BlotchRadius;
            float _BlotchSoftness;

            float _MicroDust;
            float _MicroDustScale;

            float _OcclusionStrength;
            float _OcclusionScale;

            float _Breakup;
            float _Contrast;

            // ---------------------------------------------------------
            // Hash helpers
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

            // ---------------------------------------------------------
            // Noise
            // ---------------------------------------------------------
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
            // Gaussian falloff
            // ---------------------------------------------------------
            float gaussian(float d, float r, float softness)
            {
                float x = d / r;
                return exp(-softness * x * x);
            }

            // ---------------------------------------------------------
            // Blotch generator (large dirt clusters)
            // ---------------------------------------------------------
            float blotch(float2 uv)
            {
                float2 p = uv * _Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);

                float result = 0.0;

                [unroll]
                for (int y = -1; y <= 1; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 cell = ip + float2(x, y);
                        float2 rnd = hash21(cell);

                        if (rnd.x > _BlotchDensity)
                            continue;

                        float2 center = rnd;
                        float2 fp2 = fp + float2(x, y);

                        float d = distance(fp2, center);
                        float g = gaussian(d, _BlotchRadius, _BlotchSoftness);

                        result = max(result, g);
                    }
                }

                return result;
            }

            // ---------------------------------------------------------
            // Micro dust (tiny specks)
            // ---------------------------------------------------------
            float microDust(float2 uv)
            {
                float n = fbm(uv * _MicroDustScale);
                float m = smoothstep(0.65, 0.85, n);
                return m * _MicroDust;
            }

            // ---------------------------------------------------------
            // Occlusion-like dirt (broad, soft)
            // ---------------------------------------------------------
            float occlusion(float2 uv)
            {
                float d = fbm(uv * _OcclusionScale);
                return pow(d, 2.0) * _OcclusionStrength;
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
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float b = blotch(uv);
                float d = occlusion(uv);
                float m = microDust(uv);
                float br = breakup(uv);

                float v = b + d + m;

                v *= br;
                v = pow(saturate(v), _Contrast);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}