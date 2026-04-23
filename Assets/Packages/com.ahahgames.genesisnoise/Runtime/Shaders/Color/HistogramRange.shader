Shader "Hidden/Genesis/HistogramRange"
{
    Properties
    {
        [InlineTexture]_UV_2D("Input", 2D) = "white" {}
        [InlineTexture]_UV_3D("Input", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Input", Cube) = "white" {}

        _Min("Min Range", Range(0,1)) = 0.25
        _Max("Max Range", Range(0,1)) = 0.75
        _Softness("Softness", Range(0,1)) = 0.1

        _Remap("Remap Extracted Range to 0–1", Range(0,1)) = 1
        _Invert("Invert Output", Range(0,1)) = 0

        _Contrast("Contrast", Range(0.1, 4.0)) = 1.0
        _Bias("Bias", Range(-1.0, 1.0)) = 0.0
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

            float _Min, _Max, _Softness;
            float _Remap, _Invert;
            float _Contrast, _Bias;

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float v = SAMPLE_X(_UV, uv,i.direction).r;

                // Ensure min <= max
                float mn = min(_Min, _Max);
                float mx = max(_Min, _Max);

                // Soft edges using smoothstep
                float edge = _Softness * 0.5;

                float low  = smoothstep(mn - edge, mn + edge, v);
                float high = smoothstep(mx + edge, mx - edge, v);

                float mask = low * high;

                // Optional remap to 0–1
                if (_Remap > 0.5)
                {
                    mask = saturate((v - mn) / max(1e-5, (mx - mn)));
                }

                // Apply shaping
                mask = pow(saturate(mask + _Bias), _Contrast);

                // Optional invert
                if (_Invert > 0.5)
                    mask = 1.0 - mask;

                return float4(mask, mask, mask, 1.0);
            }

            ENDHLSL
        }
    }
}