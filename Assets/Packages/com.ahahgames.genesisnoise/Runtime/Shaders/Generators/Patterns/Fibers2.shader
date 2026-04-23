Shader "Hidden/Genesis/GrungeFibersDual"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (6,6,0,0)

        // -------------------------
        // Fiber Set A
        // -------------------------
        _DirA("Direction A", Vector) = (1,0,0,0)
        _DensityA("Density A", Range(0,1)) = 0.7
        _ThicknessA("Thickness A", Range(0.001,0.2)) = 0.04
        _SoftnessA("Softness A", Range(1,20)) = 8.0

        _WavinessA("Waviness A", Range(0,1)) = 0.4
        _WaveScaleA("Wave Scale A", Range(1,30)) = 10.0

        _ClumpA("Clump Strength A", Range(0,1)) = 0.5
        _ClumpScaleA("Clump Scale A", Range(1,20)) = 6.0

        // -------------------------
        // Fiber Set B
        // -------------------------
        _DirB("Direction B", Vector) = (0,1,0,0)
        _DensityB("Density B", Range(0,1)) = 0.7
        _ThicknessB("Thickness B", Range(0.001,0.2)) = 0.04
        _SoftnessB("Softness B", Range(1,20)) = 8.0

        _WavinessB("Waviness B", Range(0,1)) = 0.4
        _WaveScaleB("Wave Scale B", Range(1,30)) = 10.0

        _ClumpB("Clump Strength B", Range(0,1)) = 0.5
        _ClumpScaleB("Clump Scale B", Range(1,20)) = 6.0

        // -------------------------
        // Shared
        // -------------------------
        _NoiseAmount("Noise Amount", Range(0,1)) = 0.4
        _NoiseScale("Noise Scale", Range(2,40)) = 12.0

        _Breakup("Breakup Strength", Range(0,1)) = 0.5
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

            // Fiber Set A
            float4 _DirA;
            float _DensityA, _ThicknessA, _SoftnessA;
            float _WavinessA, _WaveScaleA;
            float _ClumpA, _ClumpScaleA;

            // Fiber Set B
            float4 _DirB;
            float _DensityB, _ThicknessB, _SoftnessB;
            float _WavinessB, _WaveScaleB;
            float _ClumpB, _ClumpScaleB;

            // Shared
            float _NoiseAmount, _NoiseScale;
            float _Breakup, _Contrast;

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
            // Fiber profile
            // ---------------------------------------------------------
            float fiberProfile(float d, float thickness, float softness)
            {
                float x = abs(d) / thickness;
                return exp(-softness * x * x);
            }

            // ---------------------------------------------------------
            // Generic fiber generator (A or B)
            // ---------------------------------------------------------
            float fiberSet(
                float2 uv,
                float2 dir,
                float density,
                float thickness,
                float softness,
                float waviness,
                float waveScale,
                float clumpStrength,
                float clumpScale
            )
            {
                float2 nrm = float2(-dir.y, dir.x);
                float2 p = uv * _Scale;

                float u = dot(p, dir);
                float v = dot(p, nrm);

                if (waviness > 0.0)
                {
                    float w = fbm(float2(u * waveScale, 0.0));
                    v += (w - 0.5) * waviness * 0.5;
                }

                float clump = 1.0;
                if (clumpStrength > 0.0)
                {
                    float c = fbm(float2(v * clumpScale, 0.0));
                    clump = lerp(1.0, c, clumpStrength);
                }

                float laneWidth = thickness * 4.0;
                float laneIndex = floor(v / laneWidth);
                float laneFrac  = (v / laneWidth) - laneIndex;

                float laneSeed = laneIndex;
                float laneRand = hash11(laneSeed);

                if (laneRand > density * clump)
                    return 0.0;

                float center = laneRand;
                float d = laneFrac - center;

                return fiberProfile(d, thickness, softness);
            }

            // ---------------------------------------------------------
            // Noise overlay
            // ---------------------------------------------------------
            float fiberNoise(float2 uv)
            {
                float n = fbm(uv * _NoiseScale);
                return n * _NoiseAmount;
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

                float2 dirA = normalize(_DirA.xy + 1e-5);
                float2 dirB = normalize(_DirB.xy + 1e-5);

                float FA = fiberSet(uv, dirA, _DensityA, _ThicknessA, _SoftnessA, _WavinessA, _WaveScaleA, _ClumpA, _ClumpScaleA);
                float FB = fiberSet(uv, dirB, _DensityB, _ThicknessB, _SoftnessB, _WavinessB, _WaveScaleB, _ClumpB, _ClumpScaleB);

                float N  = fiberNoise(uv);
                float BR = breakup(uv);

                float v = FA + FB + N;

                v *= BR;
                v = pow(saturate(v), _Contrast);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}