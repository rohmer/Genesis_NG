Shader "Hidden/Genesis/GrungeDirtFine"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (8,8,0,0)

        _DustDensity("Dust Density", Range(0,1)) = 0.55
        _DustScale("Dust Scale", Range(4,40)) = 22.0
        _DustSharpness("Dust Sharpness", Range(1,8)) = 3.0

        _MicroSpecks("Micro Specks", Range(0,1)) = 0.45
        _MicroSpeckScale("Micro Speck Scale", Range(20,120)) = 60.0

        _SoftOcclusion("Soft Occlusion", Range(0,1)) = 0.35
        _OcclusionScale("Occlusion Scale", Range(0.5,8.0)) = 2.5

        _Breakup("Breakup Strength", Range(0,1)) = 0.65
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

            float _DustDensity;
            float _DustScale;
            float _DustSharpness;

            float _MicroSpecks;
            float _MicroSpeckScale;

            float _SoftOcclusion;
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
            // Fine dust clusters (no big blotches)
            // ---------------------------------------------------------
            float fineDust(float2 uv)
            {
                float n = fbm(uv * _DustScale);
                n = pow(n, _DustSharpness);
                return n * _DustDensity;
            }

            // ---------------------------------------------------------
            // Micro specks (tiny particulate)
            // ---------------------------------------------------------
            float microSpecks(float2 uv)
            {
                float n = fbm(uv * _MicroSpeckScale);
                float m = smoothstep(0.75, 0.9, n);
                return m * _MicroSpecks;
            }

            // ---------------------------------------------------------
            // Soft occlusion haze
            // ---------------------------------------------------------
            float softOcclusion(float2 uv)
            {
                float o = fbm(uv * _OcclusionScale);
                return pow(o, 2.0) * _SoftOcclusion;
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
                float2 suv = uv * _Scale;

                float d  = fineDust(suv);
                float m  = microSpecks(suv);
                float o  = softOcclusion(suv);
                float br = breakup(suv);

                float v = d + m + o;

                v *= br;
                v = pow(saturate(v), _Contrast);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}