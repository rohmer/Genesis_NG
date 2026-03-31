Shader "Hidden/Genesis/NoiseUpscale1"
{
    Properties
    {
        // Low-resolution noise input
        [InlineTexture]_Source_2D("Source", 2D) = "gray" {}
        [InlineTexture]_Source_3D("Source", 3D) = "gray" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "gray" {}

        _Sharpness("Sharpness", Range(0, 2)) = 1.0
        _Detail("Micro Detail", Range(0, 1)) = 0.25
        _Seed("Seed", Range(0, 9999)) = 1234
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_Source);

            float _Sharpness;
            float _Detail;
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

            // Bicubic-like sharpened kernel
            float Kernel(float x)
            {
                x = abs(x);
                float a = -0.5 * _Sharpness;
                if (x < 1.0)
                    return (a + 2.0) * x * x * x - (a + 3.0) * x * x + 1.0;
                else if (x < 2.0)
                    return a * x * x * x - 5.0 * a * x * x + 8.0 * a * x - 4.0 * a;
                return 0.0;
            }

            float3 Bicubic(float3 uv, float3 texel, float3 dir)
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
                        float3 c=float3(coord,0);
                        float w = Kernel(ix - 1 - f.x) * Kernel(iy - 1 - f.y);
                        col += SampleSource(c, dir) * w;
                    }
                }
                return col;
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01); 

                // Bicubic upscale
                float3 base = Bicubic(uv, texel, i.direction);

                // Micro-detail injection
                float3 jitter = float3(
                    Hash21(uv * 37.1 + _Seed),
                    Hash21(uv * 91.7 + _Seed * 2.0),
                    0
                );

                float3 detail = (jitter - 0.5) * _Detail;

                float3 final = base + detail;

                return float4(final, 1);
            }

            ENDHLSL
        }
    }
}