Shader "Hidden/Genesis/GrungeScratchesDirty"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (4,4,0,0)

        _Direction("Scratch Direction", Range(0,1)) = 0.15
        _ScratchDensity("Scratch Density", Range(0.1,4.0)) = 1.5

        _MicroScratchIntensity("Micro Scratch Intensity", Range(0,1)) = 0.7
        _MicroScratchScale("Micro Scratch Scale", Range(2,32)) = 12.0

        _DirtAmount("Dirt Amount", Range(0,1)) = 0.6
        _DirtScale("Dirt Scale", Range(0.5,8.0)) = 1.8

        _Breakup("Breakup Strength", Range(0,1)) = 0.8
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
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            float2 _Scale;

            float  _Direction;
            float  _ScratchDensity;

            float  _MicroScratchIntensity;
            float  _MicroScratchScale;

            float  _DirtAmount;
            float  _DirtScale;

            float  _Breakup;
            float  _Contrast;

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

                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
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
            // Long directional scratches
            // ---------------------------------------------------------
            float directionalScratches(float2 uv)
            {
                float angle = _Direction * 6.2831853; // 0–1 → 0–2π
                float2 dir = float2(cos(angle), sin(angle));

                float proj = dot(uv, dir) * (40.0 * _ScratchDensity);
                float lline = frac(proj);

                float dist = abs(lline - 0.5);
                float thin = smoothstep(0.01, 0.03, dist);

                return 1.0 - thin;
            }

            // ---------------------------------------------------------
            // Chaotic micro scratches
            // ---------------------------------------------------------
            float microScratches(float2 uv)
            {
                float n = fbm(uv * _MicroScratchScale);
                float m = smoothstep(0.6, 0.8, n);
                return m * _MicroScratchIntensity;
            }

            // ---------------------------------------------------------
            // Dirt accumulation (broad, soft)
            // ---------------------------------------------------------
            float dirtMask(float2 uv)
            {
                float d = fbm(uv * _DirtScale);
                d = pow(d, 2.0);
                return d * _DirtAmount;
            }

            // ---------------------------------------------------------
            // Breakup noise
            // ---------------------------------------------------------
            float breakup(float2 uv)
            {
                float b = fbm(uv * 4.0);
                return lerp(1.0, b, _Breakup);
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;
                float2 suv = uv * _Scale;

                float dirS = directionalScratches(suv);
                float micro = microScratches(suv);
                float dirt  = dirtMask(suv);
                float brk   = breakup(suv);

                // Combine: scratches dark, dirt fills recesses, breakup modulates
                float scratches = min(dirS, 1.0 - micro);
                float combined  = lerp(scratches, dirt, _DirtAmount);

                float v = combined * brk;

                v = pow(saturate(v), _Contrast);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}