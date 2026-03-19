Shader "Hidden/Genesis/GrungeDirt4"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (1,1,0,0)

        _CrustDensity("Crust Density", Range(0,1)) = 0.7
        _CrustRadius("Crust Radius", Range(0.5,6.0)) = 3.2
        _CrustSoftness("Crust Softness", Range(0.5,10.0)) = 2.0

        _ChunkDensity("Chunk Density", Range(0,1)) = 0.6
        _ChunkRadius("Chunk Radius", Range(0.2,4.0)) = 1.8
        _ChunkSoftness("Chunk Softness", Range(0.5,10.0)) = 2.5

        _FineDust("Fine Dust", Range(0,1)) = 0.5
        _FineDustScale("Fine Dust Scale", Range(6,40)) = 14.0
        _FineDustSharpness("Fine Dust Sharpness", Range(1,8)) = 2.8

        _MicroSpecks("Micro Specks", Range(0,1)) = 0.4
        _MicroSpeckScale("Micro Speck Scale", Range(20,140)) = 70.0

        _CavityStrength("Cavity Strength", Range(0,1)) = 0.65
        _CavityScale("Cavity Scale", Range(0.5,8.0)) = 2.2

        _Breakup("Breakup Strength", Range(0,1)) = 0.75
        _Contrast("Contrast", Range(0.5,4.0)) = 1.45
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

            float _CrustDensity;
            float _CrustRadius;
            float _CrustSoftness;

            float _ChunkDensity;
            float _ChunkRadius;
            float _ChunkSoftness;

            float _FineDust;
            float _FineDustScale;
            float _FineDustSharpness;

            float _MicroSpecks;
            float _MicroSpeckScale;

            float _CavityStrength;
            float _CavityScale;

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
            // Large crust deposits (biggest, heaviest)
            // ---------------------------------------------------------
            float crust(float2 uv)
            {
                float2 p = uv * (_Scale * 0.4);
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

                        if (rnd.x > _CrustDensity)
                            continue;

                        float2 center = rnd;
                        float2 fp2 = fp + float2(x, y);

                        float d = distance(fp2, center);
                        float g = gaussian(d, _CrustRadius, _CrustSoftness);

                        result = max(result, g);
                    }
                }

                return result;
            }

            // ---------------------------------------------------------
            // Chunky mid-scale deposits
            // ---------------------------------------------------------
            float chunks(float2 uv)
            {
                float2 p = uv * (_Scale * 0.8);
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

                        if (rnd.x > _ChunkDensity)
                            continue;

                        float2 center = rnd;
                        float2 fp2 = fp + float2(x, y);

                        float d = distance(fp2, center);
                        float g = gaussian(d, _ChunkRadius, _ChunkSoftness);

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
            // Deep cavity occlusion
            // ---------------------------------------------------------
            float cavity(float2 uv)
            {
                float o = fbm(uv * _CavityScale);
                return pow(o, 3.0) * _CavityStrength;
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

                float C  = crust(uv);
                float K  = chunks(uv);
                float F  = fineDust(uv);
                float S  = microSpecks(uv);
                float O  = cavity(uv);
                float B  = breakup(uv);

                float v = C + K + F + S + O;

                v *= B;
                v = pow(saturate(v), _Contrast);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}