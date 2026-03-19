Shader "Hidden/Genesis/GaussianSpots4"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (7,7,0,0)
        _Density("Spot Density", Range(0,1)) = 0.52
        _RadiusMin("Min Radius", Range(0.05,1.5)) = 0.28
        _RadiusMax("Max Radius", Range(0.1,3.0)) = 1.55
        _Softness("Softness", Range(0.5,10.0)) = 3.2
        _Halo("Halo Strength", Range(0,1)) = 0.65
        _MicroBloom("Micro Bloom", Range(0,1)) = 0.35
        _Flow("Flow Warp", Range(0,1)) = 0.45
        _Turbulence("Turbulence", Range(0,2)) = 0.85
        _Contrast("Contrast", Range(0.5,4.0)) = 1.08
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
            float  _Halo;
            float  _MicroBloom;
            float  _Flow;
            float  _Turbulence;
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
            // Turbulence warp (volumetric breakup)
            // ---------------------------------------------------------
            float2 turbWarp(float2 uv)
            {
                float2 n = hash21(uv * 5.0);
                return (n - 0.5) * _Turbulence * 0.25;
            }

            // ---------------------------------------------------------
            // Micro bloom (tiny Gaussian cores)
            // ---------------------------------------------------------
            float microBloom(float2 fp, float2 center, float2 cell)
            {
                float r = lerp(0.05, 0.18, hash11(dot(cell, float2(13.7, 77.3))));
                float d = distance(fp, center);
                return gaussian(d, r, 6.0) * _MicroBloom;
            }

            // ---------------------------------------------------------
            // Spots 4 Variant core
            // ---------------------------------------------------------
            float spots4Variant(float2 uv)
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
                        float soft = lerp(_Softness * 0.7, _Softness * 1.4, rnd.y);

                        // Combined warp
                        float2 fp2 = fp + float2(x, y);
                        fp2 += flowWarp(uv);
                        fp2 += turbWarp(uv);

                        float d = distance(fp2, center);

                        // Core Gaussian
                        float g = gaussian(d, radius, soft);

                        // Volumetric halo
                        float halo = gaussian(d, radius * 3.0, soft * 0.35) * _Halo;

                        // Micro bloom
                        float mb = microBloom(fp2, center, cell);

                        result = max(result, g + halo + mb);
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

                float v = spots4Variant(uv);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}