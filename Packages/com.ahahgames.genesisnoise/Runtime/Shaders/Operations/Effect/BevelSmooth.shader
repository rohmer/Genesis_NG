Shader "Hidden/Genesis/BevelSmooth"
{
    Properties
    {
        [InlineTexture]_Height_2D("Height", 2D) = "black" {}
        [InlineTexture]_Height_3D("Height", 3D) = "black" {}
        [InlineTexture]_Height_Cube("Height", Cube) = "black" {}

        _BevelWidth("Bevel Width", Range(0, 10)) = 2
        _Intensity("Intensity", Range(0, 4)) = 1
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        _Invert("Invert Height", Int) = 0
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

            TEXTURE_SAMPLER_X(_Height);

            float _BevelWidth;
            float _Intensity;
            float _Smoothness;
            int   _Invert;

            // ------------------------------------------------------------
            float SampleHeight(float3 uv, float3 dir)
            {
                float h = SAMPLE_X(_Height, uv, dir).r;
                return _Invert ? (1.0 - h) : h;
            }

            // Smooth gradient (Gaussian-like)
            float2 SmoothGradient(float3 uv, float3 texel, float3 dir)
            {
                float2 g = float2(0, 0);
                float wSum = 0;

                // 3x3 Gaussian kernel
                const float k[3][3] = {
                    { 1, 2, 1 },
                    { 2, 4, 2 },
                    { 1, 2, 1 }
                };

                for (int j = -1; j <= 1; j++)
                for (int i = -1; i <= 1; i++)
                {
                    float3 p = float3(i, j, 0);
                    float w = k[j+1][i+1];

                    float h = SampleHeight(uv + p * texel, dir);

                    g += p * h * w;
                    wSum += w;
                }

                g /= wSum;
                return g;
            }

            // Smooth profile curve (Substance-like)
            float SmoothProfile(float x)
            {
                // x in [0,1]
                float s = smoothstep(0, 1, x);
                float r = pow(x, 0.75); // softer than sharp bevel
                return lerp(s, r, _Smoothness);
            }

            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01) * _BevelWidth;

                // Smooth gradient
                float2 grad = SmoothGradient(uv, texel, i.direction);

                // Convert to normal
                float3 n = normalize(float3(-grad.x, -grad.y, 1.0 / _Intensity));

                // Smooth shading
                float shade = saturate(n.z);

                // Apply smooth profile
                shade = SmoothProfile(shade);

                return float4(shade.xxx, 1);
            }

            ENDHLSL
        }
    }
}