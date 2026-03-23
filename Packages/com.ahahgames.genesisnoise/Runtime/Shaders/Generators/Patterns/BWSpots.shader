Shader "Hidden/Genesis/BWSpots"
{
    Properties
    {
        _Density("Spot Density", Range(0.0, 1.0)) = 0.6
        _Scale("Spot Scale (Cells)", Range(1.0, 64.0)) = 12.0
        _Softness("Spot Softness", Range(0.5, 8.0)) = 3.0
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

            float _Density;
            float _Scale;
            float _Softness;

            // --- Hash helpers ---
            float hash11(float n)
            {
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7));
                return frac(sin(float2(n, n + 1.234)) * 43758.5453);
            }

            // --- Spot falloff ---
            float spotFalloff(float d, float radius, float softness)
            {
                float x = saturate(1.0 - d / radius);
                return pow(x, softness);
            }

            // --- BW Spots core ---
            float bwSpots(float2 uv, float density, float scale, float softness)
            {
                float2 p = uv * scale;
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
                        float2 center = rnd;

                        float radius = lerp(0.05, 0.45,
                                            hash11(dot(cell, float2(12.34, 56.78))));

                        if (rnd.x > density)
                            continue;

                        float d = distance(fp + float2(x, y), center);
                        float s = spotFalloff(d, radius, softness);

                        result = max(result, s);
                    }
                }

                return result;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy; // 0–1 CRT UV

                float v = bwSpots(uv, _Density, _Scale, _Softness);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}