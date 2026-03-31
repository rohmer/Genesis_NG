Shader "Hidden/Genesis/GrungeScratchesFine"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (8,8,0,0)

        _Direction("Scratch Direction", Range(0,1)) = 0.25
        _ScratchDensity("Scratch Density", Range(10,200)) = 60.0
        _ScratchThickness("Scratch Thickness", Range(0.001,0.05)) = 0.01

        _MicroScratchIntensity("Micro Scratch Intensity", Range(0,1)) = 0.6
        _MicroScratchScale("Micro Scratch Scale", Range(4,40)) = 18.0

        _DirtAmount("Dirt Amount", Range(0,1)) = 0.35
        _DirtScale("Dirt Scale", Range(0.5,8.0)) = 2.0

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

            float _Direction;
            float _ScratchDensity;
            float _ScratchThickness;

            float _MicroScratchIntensity;
            float _MicroScratchScale;

            float _DirtAmount;
            float _DirtScale;

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
            // Fine directional scratches
            // ---------------------------------------------------------
            float fineScratches(float2 uv)
            {
                float angle = _Direction * 6.2831853;
                float2 dir = float2(cos(angle), sin(angle));

                float proj = dot(uv, dir) * _ScratchDensity;
                float lline = frac(proj);

                float dist = abs(lline - 0.5);
                float s = smoothstep(_ScratchThickness, _ScratchThickness * 0.25, dist);

                return 1.0 - s;
            }

            // ---------------------------------------------------------
            // Micro scratches (chaotic, tiny)
            // ---------------------------------------------------------
            float microScratches(float2 uv)
            {
                float n = fbm(uv * _MicroScratchScale);
                float m = smoothstep(0.55, 0.75, n);
                return m * _MicroScratchIntensity;
            }

            // ---------------------------------------------------------
            // Dirt accumulation (soft occlusion)
            // ---------------------------------------------------------
            float dirtMask(float2 uv)
            {
                float d = fbm(uv * _DirtScale);
                return pow(d, 2.0) * _DirtAmount;
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
                float2 suv = uv * _Scale;

                float f = fineScratches(suv);
                float m = microScratches(suv);
                float d = dirtMask(suv);
                float b = breakup(suv);

                float scratches = min(f, 1.0 - m);
                float combined  = lerp(scratches, d, _DirtAmount);

                float v = combined * b;

                v = pow(saturate(v), _Contrast);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}