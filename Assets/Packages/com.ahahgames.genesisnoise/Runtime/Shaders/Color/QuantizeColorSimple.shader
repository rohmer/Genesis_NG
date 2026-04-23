Shader "Hidden/Genesis/QuantizeColorSimple"
{
    Properties
    {
        [InlineTexture]_UV_2D("Input", 2D) = "white" {}
        [InlineTexture]_UV_3D("Input", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Input", Cube) = "white" {}

        _Steps("Steps", Range(2, 64)) = 8
        _PerChannel("Per-Channel Quantization", Range(0,1)) = 1
        _LuminanceMode("Luminance Quantization", Range(0,1)) = 0

        _Dither("Dither Strength", Range(0.0, 1.0)) = 0.0

        _Contrast("Contrast", Range(0.1, 4.0)) = 1.0
        _Bias("Bias", Range(-1.0, 1.0)) = 0.0
        _Gain("Gain", Range(0.1, 4.0)) = 1.0

        _Invert("Invert Output", Range(0,1)) = 0
        _Seed("Seed", Float) = 1
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

            float _Steps;
            float _PerChannel;
            float _LuminanceMode;
            float _Dither;
            float _Contrast;
            float _Bias;
            float _Gain;
            float _Invert;
            float _Seed;

            float rand(float2 uv)
            {
                return frac(sin(dot(uv + _Seed, float2(12.9898, 78.233))) * 43758.5453);
            }

            float luminance(float3 c)
            {
                return dot(c, float3(0.299, 0.587, 0.114));
            }

            float quantize(float v, float steps)
            {
                return round(v * steps) / steps;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 col = SAMPLE_X(_UV, uv,i.direction).rgb;

                float steps = max(1.0, _Steps);

                // Optional dithering
                float d = (rand(uv) - 0.5) * (_Dither / steps);

                float3 result;

                if (_LuminanceMode > 0.5)
                {
                    // Quantize luminance only
                    float lum = luminance(col) + d;
                    lum = quantize(saturate(lum), steps);
                    result = float3(lum, lum, lum);
                }
                else if (_PerChannel > 0.5)
                {
                    // Quantize each channel independently
                    result.r = quantize(saturate(col.r + d), steps);
                    result.g = quantize(saturate(col.g + d), steps);
                    result.b = quantize(saturate(col.b + d), steps);
                }
                else
                {
                    // Quantize based on luminance but apply to RGB
                    float lum = luminance(col) + d;
                    float q = quantize(saturate(lum), steps);
                    result = float3(q, q, q);
                }

                // Shaping
                result = pow(saturate(result + _Bias), _Contrast) * _Gain;
                result = saturate(result);

                // Optional invert
                if (_Invert > 0.5)
                    result = 1.0 - result;

                return float4(result, 1.0);
            }

            ENDHLSL
        }
    }
}