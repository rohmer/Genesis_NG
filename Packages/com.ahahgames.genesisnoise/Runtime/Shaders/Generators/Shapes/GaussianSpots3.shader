Shader "Hidden/Genesis/GaussianSpots3"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (8,8,0,0)
        _Density("Spot Density", Range(0,1)) = 0.55
        _RadiusMin("Min Radius", Range(0.05,1.0)) = 0.22
        _RadiusMax("Max Radius", Range(0.1,2.0)) = 0.95
        _Softness("Softness", Range(0.5,8.0)) = 2.0
        _Flow("Flow Amount", Range(0,1)) = 0.35
        _Smear("Directional Smear", Range(0,1)) = 0.45
        _Contrast("Contrast", Range(0.5,4.0)) = 1.15
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
            float  _Flow;
            float  _Smear;
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
            // Flow warp (soft watercolor drift)
            // ---------------------------------------------------------
            float2 flowWarp(float2 uv)
            {
                float2 n = hash21(floor(uv * 3.0));
                return (n - 0.5) * _Flow;
            }

            // ---------------------------------------------------------
            // Directional smear (anisotropic stretch)
            // ---------------------------------------------------------
            float2 smearWarp(float2 uv)
            {
                float2 n = hash21(uv * 6.0);
                float2 dir = normalize(float2(1.0, 0.35)); // subtle diagonal flow
                return dir * (n.x - 0.5) * _Smear;
            }

            // ---------------------------------------------------------
            // Spots 3 core
            // ---------------------------------------------------------
            float spots3(float2 uv)
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

                        float2 center = rnd;

                        // Radius variation
                        float radius = lerp(_RadiusMin, _RadiusMax,
                                            hash11(dot(cell, float2(91.7, 12.3))));

                        // Softness variation
                        float soft = lerp(_Softness * 0.8, _Softness * 1.4, rnd.y);

                        // Combined warp
                        float2 fp2 = fp + float2(x, y);
                        fp2 += flowWarp(uv);
                        fp2 += smearWarp(uv);

                        float d = distance(fp2, center);

                        float g = gaussian(d, radius, soft);

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
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float v = spots3(uv);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}