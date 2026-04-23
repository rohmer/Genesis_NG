Shader "Hidden/Genesis/HistogramEqualize"
{
    Properties
    {
        [InlineTexture]_UV_2D("Input", 2D) = "white" {}
        [InlineTexture]_UV_3D("Input", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Input", Cube) = "white" {}

        _Strength("Equalization Strength", Range(0.0, 1.0)) = 1.0
        _Contrast("Contrast Boost", Range(0.1, 4.0)) = 1.0
        _Bias("Bias", Range(-1.0, 1.0)) = 0.0
        _Gain("Gain", Range(0.1, 4.0)) = 1.0
        _Window("Local Window Size", Range(1.0, 8.0)) = 3.0
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

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            TEXTURE_SAMPLER_X(_UV);

            float _Strength;
            float _Contrast;
            float _Bias;
            float _Gain;
            float _Window;

            // Simple luminance
            float luminance(float3 c)
            {
                return dot(c, float3(0.299, 0.587, 0.114));
            }

            // Smooth CDF approximation using local neighborhood
            float localCDF(float3 uv, float3 dir)
            {
                float sum = 0.0;
                float count = 0.0;

                float3 texel = float3(0.01,0.01,0.01);

                int w = (int)_Window;

                float center = SAMPLE_X(_UV, uv, dir).r;

                for (int x = -w; x <= w; x++)
                {
                    for (int y = -w; y <= w; y++)
                    {
                        float3 o = uv + float3(x, y, uv.z) * texel;
                        float v = SAMPLE_X(_UV, o,i.dir).r;

                        // Count how many neighbors are <= center
                        sum += step(v, center);
                        count += 1.0;
                    }
                }

                return sum / count;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 dir=i.direction;
                float3 col = SAMPLE_X(_UV, uv, i.dir).rgb;
                float g = luminance(col);

                // Compute local CDF (approx histogram equalization)
                float eq = localCDF(uv,dir);

                // Blend between original and equalized
                float v = lerp(g, eq, _Strength);

                // Apply shaping
                v = pow(saturate(v + _Bias), _Contrast) * _Gain;
                v = saturate(v);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}