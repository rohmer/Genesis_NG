Shader "Hidden/Genesis/BWSpots3"
{
    Properties
    {
        _Density("Spot Density", Range(0.0, 1.0)) = 0.55
        _Scale("Cell Scale", Range(1.0, 64.0)) = 10.0
        _Softness("Softness", Range(1.0, 12.0)) = 6.0
        _RadiusMin("Min Radius", Range(0.05, 1.0)) = 0.25
        _RadiusMax("Max Radius", Range(0.1, 2.0)) = 0.75
        _Warp("Warp Amount", Range(0.0, 1.0)) = 0.35
        _Contrast("Contrast", Range(0.5, 4.0)) = 1.2
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

            float _Density;
            float _Scale;
            float _Softness;
            float _RadiusMin;
            float _RadiusMax;
            float _Warp;
            float _Contrast;

            // -------------------------------
            // Hash helpers
            // -------------------------------
            float hash11(float n)
            {
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7));
                return frac(sin(float2(n, n + 1.234)) * 43758.5453);
            }

            // -------------------------------
            // Soft falloff
            // -------------------------------
            float falloff(float d, float r, float s)
            {
                float x = saturate(1.0 - d / r);
                return pow(x, s);
            }

            // -------------------------------
            // BW Spots 3 core
            // -------------------------------
            float bwSpots3(float2 uv)
            {
                float2 p = uv * _Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);

                float result = 0.0;

                // 3×3 neighborhood
                [unroll]
                for (int y = -1; y <= 1; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 cell = ip + float2(x, y);

                        float2 rnd = hash21(cell);

                        // Density gating
                        if (rnd.x > _Density)
                            continue;

                        // Spot center
                        float2 center = rnd;

                        // Radius variation (bigger than BW Spots 1/2)
                        float radius = lerp(_RadiusMin, _RadiusMax,
                                            hash11(dot(cell, float2(91.7, 12.3))));

                        // Softness variation
                        float soft = lerp(_Softness * 0.8, _Softness * 1.4, rnd.y);

                        // Organic warp
                        float2 warp = (rnd - 0.5) * _Warp;
                        float2 fp2 = fp + float2(x, y) + warp;

                        float d = distance(fp2, center);
                        float s = falloff(d, radius, soft);

                        result = max(result, s);
                    }
                }

                // Painterly contrast shaping
                result = pow(result, _Contrast);

                return result;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float v = bwSpots3(uv);
                v=smoothstep(0.0, 1.0, v); // Optional: increase contrast
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}