Shader "Hidden/Genesis/LuminanceHighPass"
{
    Properties
    {
        [InlineTexture]_UV_2D("Input", 2D) = "white" {}
        [InlineTexture]_UV_3D("Input", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Input", Cube) = "white" {}

        _Radius("Blur Radius", Range(0.0, 4.0)) = 1.0
        _Strength("High Pass Strength", Range(0.0, 4.0)) = 1.0

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

            float _Radius;
            float _Strength;
            float _Contrast;
            float _Bias;
            float _Gain;
            float _Invert;

            float luminance(float3 c)
            {
                return dot(c, float3(0.299, 0.587, 0.114));
            }

            // Cheap analytic blur approximation (Substance preview style)
            float blurApprox(float3 uv, float3 direction)
            {
                float3 texel = float3(1.0 / _ScreenParams.x,1.0 / _ScreenParams.y,1.0/_ScreenParams.z);

                float r = _Radius;

                float s = 0.0;
                float w = 0.0;

                // 5-tap cross blur (fast, stable, CRT-safe)
                float3 c0 = SAMPLE_X(_UV, uv, direction).rgb;
                float3 cx1 = SAMPLE_X(_UV, uv + float3( r, 0,0) * texel, direction).rgb;
                float3 cx2 = SAMPLE_X(_UV, uv + float3(-r, 0,0) * texel, direction).rgb;
                float3 cy1 = SAMPLE_X(_UV, uv + float3(0,  r,0) * texel, direction).rgb;
                float3 cy2 = SAMPLE_X(_UV, uv + float3(0, -r,0) * texel, direction).rgb;

                s += luminance(c0) * 4.0; w += 4.0;
                s += luminance(cx1);     w += 1.0;
                s += luminance(cx2);     w += 1.0;
                s += luminance(cy1);     w += 1.0;
                s += luminance(cy2);     w += 1.0;

                return s / w;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float3 col = SAMPLE_X(_UV, uv, i.direction).rgb;

                // Original luminance
                float lum = luminance(col);

                // Blurred luminance
                float blurLum = blurApprox(uv, i.direction);

                // High-pass = original - blurred
                float hp = lum - blurLum;

                // Strength
                hp *= _Strength;

                // Normalize to 0–1
                hp = hp * 0.5 + 0.5;
                hp = saturate(hp);

                // Shaping
                hp = pow(saturate(hp + _Bias), _Contrast) * _Gain;
                hp = saturate(hp);

                // Optional invert
                if (_Invert > 0.5)
                    hp = 1.0 - hp;

                return float4(hp, hp, hp, 1.0);
            }

            ENDHLSL
        }
    }
}