Shader "Hidden/Genesis/CracksWeathering"
{
    Properties
    {
        [InlineTexture]_UV_2D("Crack Mask", 2D) = "white" {}
        [InlineTexture]_UV_3D("Crack Mask", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Crack Mask", Cube) = "white" {}

        _Expand("Crack Expand/Contract", Range(-1,1)) = 0.0
        _Erode("Edge Erosion", Range(0,1)) = 0.2
        _Highlight("Edge Highlight", Range(0,1)) = 0.3
        _Cavity("Cavity Darkening", Range(0,1)) = 0.4
        _Dust("Dust Accumulation", Range(0,1)) = 0.2

        _MicroDetail("Micro Detail Strength", Range(0,1)) = 0.25
        _MicroFreq("Micro Detail Frequency", Range(1,20)) = 6.0

        _Contrast("Contrast", Range(0.1,4.0)) = 1.0
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

            float _Expand, _Erode, _Highlight, _Cavity, _Dust;
            float _MicroDetail, _MicroFreq;
            float _Contrast, _Invert;

            float rand(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float microNoise(float2 uv)
            {
                float n = rand(uv * _MicroFreq);
                return n * _MicroDetail;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float m = SAMPLE_X(_UV, uv,i.direction).r;

                // Expand / contract cracks
                m = saturate(m + _Expand);

                // Compute analytic derivatives (edge detection)
                float3 texel = float3(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y, 1.0/_ScreenParams.z);

                float mL = SAMPLE_X(_UV, uv + float3(-1,0,0) * texel,i.direction).r;
                float mR = SAMPLE_X(_UV, uv + float3( 1,0,0) * texel,i.direction).r;
                float mU = SAMPLE_X(_UV, uv + float3(0, 1,0) * texel,i.direction).r;
                float mD = SAMPLE_X(_UV, uv + float3(0,-1,0) * texel,i.direction).r;

                float grad = abs(m - mL) + abs(m - mR) + abs(m - mU) + abs(m - mD);

                // Edge erosion
                float eroded = saturate(m - grad * _Erode);

                // Highlight edges
                float highlight = saturate(grad * _Highlight);

                // Cavity darkening (inside cracks)
                float cavity = saturate(m * _Cavity);

                // Dust accumulation (outside cracks)
                float dust = saturate((1.0 - m) * _Dust);

                // Micro detail noise
                float micro = microNoise(uv);

                // Combine
                float result =
                    eroded +
                    highlight -
                    cavity +
                    dust +
                    micro;

                result = pow(saturate(result), _Contrast);

                if (_Invert > 0.5)
                    result = 1.0 - result;

                return float4(result, result, result, 1.0);
            }

            ENDHLSL
        }
    }
}