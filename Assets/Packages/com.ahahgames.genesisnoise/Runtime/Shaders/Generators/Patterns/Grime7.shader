Shader "Hidden/Genesis/Grunge007"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (1,1,0,0)

        _CellDensity("Cell Density", Range(0,1)) = 0.55
        _CellRadius("Cell Radius", Range(0.1,3.0)) = 1.2
        _CellSoftness("Cell Softness", Range(0.5,10.0)) = 2.5

        _Turbulence("Turbulence", Range(0,3)) = 1.4
        _Swirl("Swirl Amount", Range(0,1)) = 0.45

        _MidNoise("Mid Noise Amount", Range(0,1)) = 0.75
        _MidNoiseScale("Mid Noise Scale", Range(4,30)) = 12.0

        _FineDust("Fine Dust", Range(0,1)) = 0.55
        _FineDustScale("Fine Dust Scale", Range(10,60)) = 26.0
        _FineDustSharpness("Fine Dust Sharpness", Range(1,8)) = 3.0

        _MicroSpecks("Micro Specks", Range(0,1)) = 0.45
        _MicroSpeckScale("Micro Speck Scale", Range(40,200)) = 100.0

        _Breakup("Breakup Strength", Range(0,1)) = 0.6
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

            float _CellDensity;
            float _CellRadius;
            float _CellSoftness;

            float _Turbulence;
            float _Swirl;

            float _MidNoise;
            float _MidNoiseScale;

            float _FineDust;
            float _FineDustScale;
            float _FineDustSharpness;

            float _MicroSpecks;
            float _MicroSpeckScale;

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
            // Turbulence warp
            // ---------------------------------------------------------
            float2 turbWarp(float2 uv)
            {
                float2 n = hash21(uv * 6.0);
                return (n - 0.5) * _Turbulence * 0.35;
            }

            // ---------------------------------------------------------
            // Swirl warp (rotational breakup)
            // ---------------------------------------------------------
            float2 swirlWarp(float2 uv)
            {
                float2 c = uv - 0.5;
                float angle = (c.x + c.y) * 6.2831853 * _Swirl;
                float s = sin(angle);
                float co = cos(angle);
                float2 r = float2(c.x * co - c.y * s, c.x * s + c.y * co);
                return (r - c) * 0.5;
            }

            // ---------------------------------------------------------
            // Cellular clusters (organic pockets)
            // ---------------------------------------------------------
            float cells(float2 uv)
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

                        if (rnd.x > _CellDensity)
                            continue;

                        float2 center = rnd;
                        float2 fp2 = fp + float2(x, y);

                        float d = distance(fp2, center);
                        float g = exp(-_CellSoftness * (d / _CellRadius) * (d / _CellRadius));

                        result = max(result, g);
                    }
                }

                return result;
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
                float2 suv = uv;

                // Apply warps
                suv += turbWarp(suv);
                suv += swirlWarp(suv);

                float C  = cells(suv);
                float M  = midNoise(suv);
                float F  = fineDust(suv);
                float S  = microSpecks(suv);
                float BR = breakup(suv);

                float v = C + M + F + S;

                v *= BR;
                v = pow(saturate(v), _Contrast);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}