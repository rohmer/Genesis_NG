Shader "Hidden/Genesis/HistogramSelect"
{
    Properties
    {
        [InlineTexture]_UV_2D("Input", 2D) = "white" {}
        [InlineTexture]_UV_3D("Input", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Input", Cube) = "white" {}

        _Position("Position", Range(0,1)) = 0.5
        _Range("Range Width", Range(0.0, 1.0)) = 0.25
        _Softness("Softness", Range(0.0, 1.0)) = 0.1

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

            float _Position;
            float _Range;
            float _Softness;
            float _Contrast;
            float _Bias;
            float _Gain;
            float _Invert;

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float v = SAMPLE_X(_UV, uv, i.direction).r;

                // Compute window bounds
                float halfRange = _Range * 0.5;
                float mn = _Position - halfRange;
                float mx = _Position + halfRange;

                // Soft edges
                float edge = _Softness * 0.5;

                float low  = smoothstep(mn - edge, mn + edge, v);
                float high = smoothstep(mx + edge, mx - edge, v);

                float mask = low * high;

                // Apply shaping
                mask = pow(saturate(mask + _Bias), _Contrast) * _Gain;
                mask = saturate(mask);

                // Optional invert
                if (_Invert > 0.5)
                    mask = 1.0 - mask;

                return float4(mask, mask, mask, 1.0);
            }

            ENDHLSL
        }
    }
}