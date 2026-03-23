Shader "Hidden/Genesis/GrungeLeaks1"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (4,4,0,0)
        _LeakDensity("Leak Density", Range(0,1)) = 0.55
        _BlotchRadius("Blotch Radius", Range(0.1,3.0)) = 1.2
        _BlotchSoftness("Blotch Softness", Range(0.5,8.0)) = 2.5

        _StreakStrength("Streak Strength", Range(0,2)) = 1.0
        _StreakStretch("Streak Stretch", Range(1,12)) = 6.0

        _Turbulence("Turbulence", Range(0,2)) = 0.8
        _Flow("Flow Warp", Range(0,1)) = 0.35

        _EdgeDarkening("Edge Darkening", Range(0,1)) = 0.4
        _Contrast("Contrast", Range(0.5,4.0)) = 1.3
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
            float  _LeakDensity;
            float  _BlotchRadius;
            float  _BlotchSoftness;

            float  _StreakStrength;
            float  _StreakStretch;

            float  _Turbulence;
            float  _Flow;

            float  _EdgeDarkening;
            float  _Contrast;

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
            // Gaussian falloff
            // ---------------------------------------------------------
            float gaussian(float d, float r, float softness)
            {
                float x = d / r;
                return exp(-softness * x * x);
            }

            // ---------------------------------------------------------
            // Turbulence warp
            // ---------------------------------------------------------
            float2 turbWarp(float2 uv)
            {
                float2 n = hash21(uv * 5.0);
                return (n - 0.5) * _Turbulence * 0.25;
            }

            // ---------------------------------------------------------
            // Flow warp (vertical drift)
            // ---------------------------------------------------------
            float2 flowWarp(float2 uv)
            {
                float2 n = hash21(floor(uv * 3.0));
                return float2(0, (n.x - 0.5) * _Flow);
            }

            // ---------------------------------------------------------
            // Vertical streak noise
            // ---------------------------------------------------------
            float streakNoise(float2 uv)
            {
                uv.y *= _StreakStretch;

                float2 ip = floor(uv);
                float2 fp = frac(uv);

                float a = hash11(ip.x + ip.y * 17.0);
                float b = hash11(ip.x + (ip.y + 1.0) * 17.0);

                float v = lerp(a, b, fp.y);
                return pow(abs(v), 1.5) * _StreakStrength;
            }

            // ---------------------------------------------------------
            // Blotch generator (leak origins)
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

                        if (rnd.x > _LeakDensity)
                            continue;

                        float2 center = rnd;
                        float2 fp2 = fp + float2(x, y);

                        fp2 += turbWarp(uv);
                        fp2 += flowWarp(uv);

                        float d = distance(fp2, center);

                        float g = gaussian(d, _BlotchRadius, _BlotchSoftness);

                        result = max(result, g);
                    }
                }

                return result;
            }

            // ---------------------------------------------------------
            // Edge darkening mask
            // ---------------------------------------------------------
            float edgeMask(float2 uv)
            {
                float d = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
                return pow(saturate(d * 4.0), _EdgeDarkening);
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float b = blotch(uv);
                float s = streakNoise(uv);

                float v = b + s;

                v *= edgeMask(uv);

                v = pow(v, _Contrast);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}