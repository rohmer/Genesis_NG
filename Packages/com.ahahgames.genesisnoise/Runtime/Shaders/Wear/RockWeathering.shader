Shader "Hidden/Genesis/RockWeathering"
{
    Properties
    {
        [InlineTexture]_UV_2D("Rock Height", 2D) = "white" {}
        [InlineTexture]_UV_3D("Rock Height", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Rock Height", Cube) = "white" {}

        _Erode("Mechanical Erosion", Range(0,1)) = 0.45
        _Chip("Edge Chipping", Range(0,1)) = 0.35
        _Cavity("Cavity Darkening", Range(0,1)) = 0.5

        _Sediment("Sediment/Dust Accumulation", Range(0,1)) = 0.4
        _SedimentDir("Sediment Direction", Range(0,1)) = 0.0

        _Cracks("Micro-Cracks", Range(0,1)) = 0.35
        _CrackFreq("Crack Frequency", Range(3,25)) = 10.0

        _RoughBreak("Surface Breakup", Range(0,1)) = 0.3
        _RoughFreq("Breakup Frequency", Range(3,20)) = 8.0

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

            float _Erode, _Chip, _Cavity;
            float _Sediment, _SedimentDir;
            float _Cracks, _CrackFreq;
            float _RoughBreak, _RoughFreq;
            float _Contrast, _Invert;

            float rand(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float crackNoise(float3 uv)
            {
                float n = rand(uv * _CrackFreq);
                return smoothstep(0.8, 1.0, n) * _Cracks;
            }

            float breakupNoise(float3 uv)
            {
                float n = rand(uv * _RoughFreq);
                return smoothstep(0.5, 1.0, n) * _RoughBreak;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 texel = float3(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y, 1.0 / _ScreenParams.z);

                float h = SAMPLE_X(_UV, uv,i.direction).r;

                // Neighbor samples for curvature + erosion
                float hL = SAMPLE_X(_UV, uv + float3(-1,0,0) * texel,i.direction).r;
                float hR = SAMPLE_X(_UV, uv + float3( 1,0,0) * texel,i.direction).r;
                float hU = SAMPLE_X(_UV, uv + float3(0, 1,0) * texel,i.direction).r;
                float hD = SAMPLE_X(_UV, uv + float3(0,-1,0) * texel,i.direction).r;

                float grad = abs(h - hL) + abs(h - hR) + abs(h - hU) + abs(h - hD);

                // Mechanical erosion (softening)
                float erode = saturate(h - grad * _Erode);

                // Edge chipping (sharp breakup)
                float chip = saturate(grad * _Chip);

                // Cavity darkening
                float cavity = saturate((1.0 - h) * _Cavity);

                // Sediment accumulation (directional)
                float3 dir = float3(cos(_SedimentDir * 6.2831), sin(_SedimentDir * 6.2831),0);
                float hF = SAMPLE_X(_UV, uv + dir * texel,i.direction).r;
                float sediment = saturate((hF - h) * _Sediment);

                // Micro-cracks
                float cracks = crackNoise(uv);

                // Surface breakup
                float breakup = breakupNoise(uv);

                // Combine all effects
                float result =
                    erode +
                    chip -
                    cavity +
                    sediment +
                    cracks +
                    breakup;

                result = pow(saturate(result), _Contrast);

                if (_Invert > 0.5)
                    result = 1.0 - result;

                return float4(result, result, result, 1.0);
            }

            ENDHLSL
        }
    }
}