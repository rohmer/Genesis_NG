Shader "Hidden/Genesis/QuantizeColor"
{
    Properties
    {
        [InlineTexture]_UV_2D("Input", 2D) = "white" {}
        [InlineTexture]_UV_3D("Input", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Input", Cube) = "white" {}

        // HSV quantization steps
        _HueSteps("Hue Steps", Range(1, 64)) = 8
        _SatSteps("Saturation Steps", Range(1, 64)) = 4
        _ValSteps("Value Steps", Range(1, 64)) = 4

        // Modes
        _UseHSV("Use HSV Quantization", Range(0,1)) = 1
        _PerChannel("Per-Channel RGB Quantization", Range(0,1)) = 0

        // Dithering
        _Dither("Dither Strength", Range(0.0, 1.0)) = 0.0
        _Seed("Seed", Float) = 1

        // Shaping
        _Contrast("Contrast", Range(0.1, 4.0)) = 1.0
        _Bias("Bias", Range(-1.0, 1.0)) = 0.0
        _Gain("Gain", Range(0.1, 4.0)) = 1.0

        _Invert("Invert Output", Range(0,1)) = 0
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

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            TEXTURE_SAMPLER_X(_UV);

            float _HueSteps, _SatSteps, _ValSteps;
            float _UseHSV, _PerChannel;
            float _Dither, _Seed;
            float _Contrast, _Bias, _Gain;
            float _Invert;

            float rand(float2 uv)
            {
                return frac(sin(dot(uv + _Seed, float2(12.9898, 78.233))) * 43758.5453);
            }

            // RGB <-> HSV
            float3 rgb2hsv(float3 c)
            {
                float4 K = float4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
                float4 p = (c.g < c.b) ? float4(c.bg, K.wz) : float4(c.gb, K.xy);
                float4 q = (c.r < p.x) ? float4(p.xyw, c.r) : float4(c.r, p.yzx);

                float d = q.x - min(q.w, q.y);
                float e = 1e-10;

                return float3(
                    abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                    d / (q.x + e),
                    q.x
                );
            }

            float3 hsv2rgb(float3 c)
            {
                float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }

            float quantize(float v, float steps)
            {
                return round(v * steps) / steps;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 col = SAMPLE_X(_UV, uv, i.direction).rgb;

                float d = (rand(uv) - 0.5) * _Dither;

                float3 result;

                // RGB per-channel quantization
                if (_PerChannel > 0.5)
                {
                    result.r = quantize(saturate(col.r + d), _HueSteps);
                    result.g = quantize(saturate(col.g + d), _SatSteps);
                    result.b = quantize(saturate(col.b + d), _ValSteps);
                }
                else if (_UseHSV > 0.5)
                {
                    // HSV quantization (Substance behavior)
                    float3 hsv = rgb2hsv(col);

                    hsv.x = quantize(hsv.x + d, _HueSteps);
                    hsv.y = quantize(hsv.y + d, _SatSteps);
                    hsv.z = quantize(hsv.z + d, _ValSteps);

                    result = hsv2rgb(hsv);
                }
                else
                {
                    // Luminance-based fallback
                    float lum = dot(col, float3(0.299, 0.587, 0.114));
                    float q = quantize(lum + d, _ValSteps);
                    result = float3(q, q, q);
                }

                // Shaping
                result = pow(saturate(result + _Bias), _Contrast) * _Gain;
                result = saturate(result);

                if (_Invert > 0.5)
                    result = 1.0 - result;

                return float4(result, 1.0);
            }

            ENDHLSL
        }
    }
}