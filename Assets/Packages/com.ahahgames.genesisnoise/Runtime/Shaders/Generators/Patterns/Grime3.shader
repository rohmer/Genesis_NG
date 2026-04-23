Shader "Hidden/Genesis/Grunge003"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (1,1,0,0)

        _BlotchDensity("Blotch Density", Range(0,1)) = 0.40
        _BlotchRadius("Blotch Radius", Range(0.1,2.0)) = 0.85
        _BlotchSoftness("Blotch Softness", Range(0.5,10.0)) = 3.2

        _DirectionalStrength("Directional Strength", Range(0,1)) = 0.45
        _DirectionalStretch("Directional Stretch", Range(1,20)) = 8.0
        _DirectionalChaos("Directional Chaos", Range(0,2)) = 0.6

        _MidNoise("Mid Noise Amount", Range(0,1)) = 0.65
        _MidNoiseScale("Mid Noise Scale", Range(4,30)) = 10.0

        _FineDust("Fine Dust", Range(0,1)) = 0.55
        _FineDustScale("Fine Dust Scale", Range(8,50)) = 20.0
        _FineDustSharpness("Fine Dust Sharpness", Range(1,8)) = 3.0

        _MicroSpecks("Micro Specks", Range(0,1)) = 0.45
        _MicroSpeckScale("Micro Speck Scale", Range(30,160)) = 80.0

        _OcclusionStrength("Occlusion Strength", Range(0,1)) = 0.35
        _OcclusionScale("Occlusion Scale", Range(0.5,8.0)) = 2.0

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
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            float2 _Scale;

            float _BlotchDensity;
            float _BlotchRadius;
            float _BlotchSoftness;

            float _DirectionalStrength;
            float _DirectionalStretch;
            float _DirectionalChaos;

            float _MidNoise;
            float _MidNoiseScale;

            float _FineDust;
            float _FineDustScale;
            float _FineDustSharpness;

            float _MicroSpecks;
            float _MicroSpeckScale;

            float _OcclusionStrength;
            float _OcclusionScale;

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
            // Small blotches (similar to Grunge 002)
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
                        float g = exp(-_BlotchSoftness * (d / _BlotchRadius) * (d / _BlotchRadius));

                        result = max(result, g);
                    }
                }

                return result;
            }

            // ---------------------------------------------------------
            // Directional breakup (signature of Grunge 003)
            // ---------------------------------------------------------
            float directional(float2 uv)
            {
                float2 p = uv;
                p.y *= _DirectionalStretch;

                float2 ip = floor(p);
                float2 fp = frac(p);

                float a = hash11(ip.x + ip.y * 31.0);
                float b = hash11(ip.x + (ip.y + 1.0) * 31.0);

                float v = lerp(a, b, fp.y);

                float chaos = hash11(ip.x * 17.0 + ip.y * 13.0);
                v += (chaos - 0.5) * _DirectionalChaos;

                v = abs(v);
                v = pow(v, 1.6);

                return v * _DirectionalStrength;
            }

            // ---------------------------------------------------------
            // Mid-scale breakup
            // ---------------------------------------------------------
            float midNoise(float2 uv)
            {
                float n = fbm(uv * _MidNoiseScale);
                return n * _MidNoise;
            }

            // ---------------------------------------------------------
            // Fine dust
            // ---------------------------------------------------------
            float fineDust(float2 uv)
            {
                float n = fbm(uv * _FineDustScale);
                n = pow(n, _FineDustSharpness);
                return n * _FineDust;
            }

            // ---------------------------------------------------------
            // Micro specks
            // ---------------------------------------------------------
            float microSpecks(float2 uv)
            {
                float n = fbm(uv * _MicroSpeckScale);
                float m = smoothstep(0.7, 0.9, n);
                return m * _MicroSpecks;
            }

            // ---------------------------------------------------------
            // Occlusion haze
            // ---------------------------------------------------------
            float occlusion(float2 uv)
            {
                float o = fbm(uv * _OcclusionScale);
                return pow(o, 2.0) * _OcclusionStrength;
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

                float B  = blotch(uv);
                float D  = directional(uv);
                float M  = midNoise(uv);
                float F  = fineDust(uv);
                float S  = microSpecks(uv);
                float O  = occlusion(uv);
                float BR = breakup(uv);

                float v = B + D + M + F + S + O;

                v *= BR;
                v = pow(saturate(v), _Contrast);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}