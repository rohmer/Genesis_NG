Shader "Hidden/Genesis/HistogramShift"
{
    Properties
    {
        [InlineTexture]_UV_2D("Input", 2D) = "white" {}
        [InlineTexture]_UV_3D("Input", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Input", Cube) = "white" {}

        _Shift("Shift Amount", Range(-1.0, 1.0)) = 0.0
        _Wrap("Wrap Mode", Range(0,1)) = 0
        _Clamp("Clamp Output", Range(0,1)) = 1

        _Contrast("Contrast", Range(0.1, 4.0)) = 1.0
        _Bias("Bias", Range(-1.0, 1.0)) = 0.0
        _Gain("Gain", Range(0.1, 4.0)) = 1.0

        _Invert("Invert", Range(0,1)) = 0
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

            float _Shift;
            float _Wrap;
            float _Clamp;
            float _Contrast;
            float _Bias;
            float _Gain;
            float _Invert;

            float wrap01(float v)
            {
                return frac(v + 1.0);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float v = SAMPLE_X(_UV, uv, i.direction).r;

                // Core Substance behavior: shift histogram
                float shifted = v + _Shift;

                // Wrap or clamp
                if (_Wrap > 0.5)
                {
                    shifted = wrap01(shifted);
                }
                else if (_Clamp > 0.5)
                {
                    shifted = saturate(shifted);
                }

                // Apply shaping
                shifted = pow(saturate(shifted + _Bias), _Contrast) * _Gain;
                shifted = saturate(shifted);

                // Optional invert
                if (_Invert > 0.5)
                    shifted = 1.0 - shifted;

                return float4(shifted, shifted, shifted, 1.0);
            }

            ENDHLSL
        }
    }
}