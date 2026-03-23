Shader "Hidden/Genesis/GrungeDirt3"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (1,1,0,0)

        _LargeBlotchDensity("Large Blotch Density", Range(0,1)) = 0.65
        _LargeBlotchRadius("Large Blotch Radius", Range(0.5,5.0)) = 2.4
        _LargeBlotchSoftness("Large Blotch Softness", Range(0.5,10.0)) = 2.2

        _MidBlotchDensity("Mid Blotch Density", Range(0,1)) = 0.55
        _MidBlotchRadius("Mid Blotch Radius", Range(0.2,3.0)) = 1.2
        _MidBlotchSoftness("Mid Blotch Softness", Range(0.5,10.0)) = 2.8

        _FineDust("Fine Dust", Range(0,1)) = 0.45
        _FineDustScale("Fine Dust Scale", Range(6,40)) = 14.0
        _FineDustSharpness("Fine Dust Sharpness", Range(1,8)) = 2.5

        _MicroSpecks("Micro Specks", Range(0,1)) = 0.35
        _MicroSpeckScale("Micro Speck Scale", Range(20,120)) = 60.0

        _OcclusionStrength("Occlusion Strength", Range(0,1)) = 0.55
        _OcclusionScale("Occlusion Scale", Range(0.5,8.0)) = 2.0

        _Breakup("Breakup Strength", Range(0,1)) = 0.7
        _Contrast("Contrast", Range(0.5,4.0)) = 1.4
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

            float _LargeBlotchDensity;
            float _LargeBlotchRadius;
            float _LargeBlotchSoftness;

            float _MidBlotchDensity;
            float _MidBlotchRadius;
            float _MidBlotchSoftness;

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
            // Gaussian falloff
            // ---------------------------------------------------------
            float gaussian(float d, float r, float softness)
            {
                float x = d / r;
                return exp(-softness * x * x);
            }

            // ---------------------------------------------------------
            // Large blotches (heavy dirt masses)
            // ---------------------------------------------------------
            float largeBlotch(float2 uv)
            {
                float2 p = uv * (_Scale * 0.5);
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

                        if (rnd.x > _LargeBlotchDensity)
                            continue;

                        float2 center = rnd;
                        float2 fp2 = fp + float2(x, y);

                        float d = distance(fp2, center);
                        float g = gaussian(d, _LargeBlotchRadius, _LargeBlotchSoftness);

                        result = max(result, g);
                    }
                }

                return result;
            }

            // ---------------------------------------------------------
            // Mid-scale blotches (bridge between large + fine)
            // ---------------------------------------------------------
            float midBlotch(float2 uv)
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

                        if (rnd.x > _MidBlotchDensity)
                            continue;

                        float2 center = rnd;
                        float2 fp2 = fp + float2(x, y);

                        float d = distance(fp2, center);
                        float g = gaussian(d, _MidBlotchRadius, _MidBlotchSoftness);

                        result = max(result, g);
                    }
                }

                return result;
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
                float m = smoothstep(0.75, 0.9, n);
                return m * _MicroSpecks;
            }

            // ---------------------------------------------------------
            // Occlusion haze
            // ---------------------------------------------------------
            float softOcclusion(float2 uv)
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
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float L = largeBlotch(uv);
                float M = midBlotch(uv);
                float F = fineDust(uv);
                float S = microSpecks(uv);
                float O = softOcclusion(uv);
                float B = breakup(uv);

                float v = L + M + F + S + O;

                v *= B;
                v = pow(saturate(v), _Contrast);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}