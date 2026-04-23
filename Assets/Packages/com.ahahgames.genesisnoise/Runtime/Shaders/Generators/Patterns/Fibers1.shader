Shader "Hidden/Genesis/GrungeFibers"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (6,6,0,0)

        _Direction("Direction XY", Vector) = (1,0,0,0)
        _FiberDensity("Fiber Density", Range(0,1)) = 0.7
        _FiberThickness("Fiber Thickness", Range(0.001,0.2)) = 0.04
        _FiberSoftness("Fiber Softness", Range(1,20)) = 8.0

        _Waviness("Waviness", Range(0,1)) = 0.4
        _WaveScale("Wave Scale", Range(1,30)) = 10.0

        _ClumpStrength("Clump Strength", Range(0,1)) = 0.5
        _ClumpScale("Clump Scale", Range(1,20)) = 6.0

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

            float4 _Direction;
            float _FiberDensity;
            float _FiberThickness;
            float _FiberSoftness;

            float _Waviness;
            float _WaveScale;

            float _ClumpStrength;
            float _ClumpScale;

            float _NoiseAmount;
            float _NoiseScale;

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
            // Fiber distance profile
            // ---------------------------------------------------------
            float fiberProfile(float d, float thickness, float softness)
            {
                float x = abs(d) / thickness;
                return exp(-softness * x * x);
            }

            // ---------------------------------------------------------
            // Fiber field (directional, clumped, wavy)
            // ---------------------------------------------------------
            float fibers(float2 uv)
            {
                // Normalize direction
                float2 dir = normalize(_Direction.xy + 1e-5);
                float2 nrm = float2(-dir.y, dir.x);

                float2 p = uv * _Scale;

                // Project into fiber space
                float u = dot(p, dir);   // along fibers
                float v = dot(p, nrm);   // across fibers

                // Waviness: offset v by a sinusoidal function along u
                if (_Waviness > 0.0)
                {
                    float w = fbm(float2(u * _WaveScale, 0.0));
                    v += (w - 0.5) * _Waviness * 0.5;
                }

                // Clumping: modulate density across v
                float clump = 1.0;
                if (_ClumpStrength > 0.0)
                {
                    float c = fbm(float2(v * _ClumpScale, 0.0));
                    clump = lerp(1.0, c, _ClumpStrength);
                }

                // Fiber lanes: use integer lanes along v
                float laneWidth = _FiberThickness * 4.0;
                float laneIndex = floor(v / laneWidth);
                float laneFrac  = (v / laneWidth) - laneIndex;

                // Random offset per lane
                float laneSeed = laneIndex;
                float laneRand = hash11(laneSeed);

                // Density gate
                if (laneRand > _FiberDensity * clump)
                    return 0.0;

                // Center of fiber in lane
                float center = laneRand; // [0,1]
                float d = laneFrac - center;

                float baseFiber = fiberProfile(d, _FiberThickness, _FiberSoftness);

                return baseFiber;
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

                float F  = fibers(uv);
                float N  = fiberNoise(uv);
                float BR = breakup(uv);

                float v = F + N;

                v *= BR;
                v = pow(saturate(v), _Contrast);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}