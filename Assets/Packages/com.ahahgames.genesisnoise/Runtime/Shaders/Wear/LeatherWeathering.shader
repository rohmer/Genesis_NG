Shader "Hidden/Genesis/LeatherWeathering"
{
    Properties
    {
        [InlineTexture]_UV_2D("Leather Height", 2D) = "white" {}
        [InlineTexture]_UV_3D("Leather Height", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Leather Height", Cube) = "white" {}

        _Crease("Crease Brightening", Range(0,1)) = 0.4
        _Cavity("Cavity Darkening", Range(0,1)) = 0.35
        _Burnish("Edge Burnish", Range(0,1)) = 0.3
        _Scuff("Directional Scuffing", Range(0,1)) = 0.4
        _ScuffDir("Scuff Direction", Range(0,1)) = 0.0

        _Crackle("Micro-Crackle", Range(0,1)) = 0.3
        _CrackleFreq("Crackle Frequency", Range(2,20)) = 10.0

        _Pores("Pore Darkening", Range(0,1)) = 0.25
        _PoreFreq("Pore Frequency", Range(5,30)) = 12.0

        _Dryness("Dryness", Range(0,1)) = 0.3

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
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            TEXTURE_SAMPLER_X(_UV);

            float _Crease, _Cavity, _Burnish, _Scuff, _ScuffDir;
            float _Crackle, _CrackleFreq;
            float _Pores, _PoreFreq;
            float _Dryness;
            float _Contrast, _Invert;

            float rand(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float crackleNoise(float2 uv)
            {
                float n = rand(uv * _CrackleFreq);
                return smoothstep(0.7, 1.0, n) * _Crackle;
            }

            float poreNoise(float2 uv)
            {
                float n = rand(uv * _PoreFreq);
                return smoothstep(0.5, 0.8, n) * _Pores;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 texel = float3(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y, 1.0 / _ScreenParams.z);

                float h = SAMPLE_X(_UV, uv,i.direction).r;

                // Neighbor samples for curvature + edges
                float hL = SAMPLE_X(_UV, uv + float3(-1,0,0) * texel,i.direction).r;
                float hR = SAMPLE_X(_UV, uv + float3( 1,0,0) * texel,i.direction).r;
                float hU = SAMPLE_X(_UV, uv + float3(0, 1,0) * texel,i.direction).r;
                float hD = SAMPLE_X(_UV, uv + float3(0,-1,0) * texel,i.direction).r;

                float grad = abs(h - hL) + abs(h - hR) + abs(h - hU) + abs(h - hD);

                // Crease brightening (high curvature)
                float crease = saturate(grad * _Crease);

                // Cavity darkening (low height)
                float cavity = saturate((1.0 - h) * _Cavity);

                // Edge burnish (high curvature but inverted)
                float burnish = saturate((1.0 - grad) * _Burnish);

                // Directional scuffing
                float3 dir = float3(cos(_ScuffDir * 6.2831), sin(_ScuffDir * 6.2831),0);
                float hF = SAMPLE_X(_UV, uv + dir * texel,i.direction).r;
                float scuff = saturate((h - hF) * _Scuff);

                // Micro-crackle
                float crackle = crackleNoise(uv);

                // Pore darkening
                float pores = poreNoise(uv);

                // Dryness (flattening + brightening)
                float dryness = saturate((h * 0.5 + 0.5) * _Dryness);

                // Combine all effects
                float result =
                    h +
                    crease -
                    cavity +
                    burnish +
                    scuff +
                    crackle -
                    pores +
                    dryness;

                result = pow(saturate(result), _Contrast);

                if (_Invert > 0.5)
                    result = 1.0 - result;

                return float4(result, result, result, 1.0);
            }

            ENDHLSL
        }
    }
}