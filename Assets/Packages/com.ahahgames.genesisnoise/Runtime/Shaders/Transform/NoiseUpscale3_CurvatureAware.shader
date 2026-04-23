Shader "Hidden/Genesis/NoiseUpscale3_CurvatureAware"
{
    Properties
    {
        [InlineTexture]_Source_2D("Source", 2D) = "gray" {}
        [InlineTexture]_Source_3D("Source", 3D) = "gray" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "gray" {}

        _Sharpness("Sharpness", Range(0, 4)) = 2.0
        _Detail("Detail Amount", Range(0, 1)) = 0.35
        _CurvBoost("Curvature Boost", Range(0, 3)) = 1.25
        _Contrast("Contrast", Range(0.5, 2.5)) = 1.2
        _Seed("Seed", Range(0, 9999)) = 1234
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 250

        Pass
        {
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_Source);

            float _Sharpness;
            float _Detail;
            float _CurvBoost;
            float _Contrast;
            float _Seed;

            // ------------------------------------------------------------
            float Hash21(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return frac(p.x * p.y);
            }

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            // Sharp bicubic kernel
            float Kernel(float x)
            {
                x = abs(x);
                float B = 0.0;
                float C = 0.5 * _Sharpness;

                if (x < 1.0)
                {
                    return ((12 - 9*B - 6*C) * x*x*x +
                            (-18 + 12*B + 6*C) * x*x +
                            (6 - 2*B)) / 6.0;
                }
                else if (x < 2.0)
                {
                    return ((-B - 6*C) * x*x*x +
                            (6*B + 30*C) * x*x +
                            (-12*B - 48*C) * x +
                            (8*B + 24*C)) / 6.0;
                }
                return 0.0;
            }

            float3 Bicubic(float2 uv, float2 texel, float3 dir)
            {
                float2 p = uv / texel;
                float2 f = frac(p);
                float2 i0 = floor(p) - 1.0;

                float3 col = 0;
                for (int iy = 0; iy < 4; iy++)
                {
                    for (int ix = 0; ix < 4; ix++)
                    {
                        float2 coord = (i0 + float2(ix, iy)) * texel;
                        float w = Kernel(ix - 1 - f.x) * Kernel(iy - 1 - f.y);
                        float3 c=float3(coord,0);
                        col += SampleSource(c, dir) * w;
                    }
                }
                return col;
            }

            // Curvature via Laplacian
            float Curvature(float3 uv, float3 texel, float3 dir)
            {
                float c  = SampleSource(uv, dir).r;
                float l  = SampleSource(uv + texel * float3(-1,  0, 0), dir).r;
                float r  = SampleSource(uv + texel * float3( 1,  0, 0), dir).r;
                float t  = SampleSource(uv + texel * float3( 0, -1, 0), dir).r;
                float b  = SampleSource(uv + texel * float3( 0,  1, 0), dir).r;

                float lap = (l + r + t + b - 4*c);
                return lap; // signed curvature
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                // Base upscale
                float3 base = Bicubic(uv, texel, i.direction);

                // Curvature detection
                float curv = Curvature(uv, texel, i.direction);

                // Curvature mask: convex = +, concave = -
                float convexMask = saturate(curv * _CurvBoost * 4.0);
                float concaveMask = saturate(-curv * _CurvBoost * 4.0);

                // Micro detail (suppressed in concave areas)
                float3 jitter = float3(
                    Hash21(uv * 37.1 + _Seed),
                    Hash21(uv * 91.7 + _Seed * 2.0),
                    0
                );

                float3 detail = (jitter - 0.5) * _Detail * (1.0 - concaveMask);

                // Curvature‑aware sharpening
                float3 sharpened = lerp(base, base * (1.0 + convexMask), convexMask);

                float3 final = sharpened + detail;

                // Contrast shaping
                final = pow(saturate(final), _Contrast);

                return float4(final, 1);
            }

            ENDHLSL
        }
    }
}