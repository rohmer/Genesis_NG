Shader "Hidden/Genesis/GaussianSpots2"
{
    Properties
    {
        [GenesisVector2]_Scale("Cell Scale", Vector) = (12,12,0,0)
        _Density("Spot Density", Range(0,1)) = 0.6
        _RadiusMin("Min Radius", Range(0.01,1.0)) = 0.12
        _RadiusMax("Max Radius", Range(0.05,2.0)) = 0.45
        _Softness("Gaussian Softness", Range(0.5,8.0)) = 3.0
        _Contrast("Contrast", Range(0.5,4.0)) = 1.2
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
            float  _Density;
            float  _RadiusMin;
            float  _RadiusMax;
            float  _Softness;
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
            // Gaussian Spots core
            // ---------------------------------------------------------
            float gaussianSpots(float2 uv)
            {
                float2 p = uv * _Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);

                float result = 0.0;

                // 3×3 neighborhood for overlap
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

                        // Spot center inside cell
                        float2 center = rnd;

                        // Random Gaussian radius
                        float radius = lerp(_RadiusMin, _RadiusMax,
                                            hash11(dot(cell, float2(91.7, 12.3))));

                        // Distance to spot center
                        float2 fp2 = fp + float2(x, y);
                        float d = distance(fp2, center);

                        // Gaussian falloff
                        float g = gaussian(d, radius, _Softness);

                        // Additive blending (Substance‑style)
                        result = max(result, g);
                    }
                }

                // Final shaping
                result = pow(result, _Contrast);

                return result;
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float v = gaussianSpots(uv);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}