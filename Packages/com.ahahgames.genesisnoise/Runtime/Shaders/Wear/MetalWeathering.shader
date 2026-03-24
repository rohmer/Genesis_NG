Shader "Hidden/Genesis/MetalWeathering"
{
    Properties
    {
        [InlineTexture]_UV_2D("Metal Height", 2D) = "white" {}
        [InlineTexture]_UV_3D("Metal Height", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Metal Height", Cube) = "white" {}

        _EdgeWear("Edge Wear", Range(0,1)) = 0.5
        _CavityRust("Cavity Rust", Range(0,1)) = 0.6
        _Oxidation("Oxidation Layer", Range(0,1)) = 0.4

        _Scratch("Directional Scratches", Range(0,1)) = 0.5
        _ScratchDir("Scratch Direction", Range(0,1)) = 0.0

        _Pitting("Micro Pitting", Range(0,1)) = 0.35
        _PitFreq("Pitting Frequency", Range(3,25)) = 12.0

        _Dirt("Dirt Accumulation", Range(0,1)) = 0.3

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

            float _EdgeWear, _CavityRust, _Oxidation;
            float _Scratch, _ScratchDir;
            float _Pitting, _PitFreq;
            float _Dirt;
            float _Contrast, _Invert;

            float rand(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float pitNoise(float2 uv)
            {
                float n = rand(uv * _PitFreq);
                return smoothstep(0.75, 1.0, n) * _Pitting;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 texel = float3(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y, 1.0 / _ScreenParams.z);

                float h = SAMPLE_X(_UV, uv,i.direction).r;

                // Neighbor samples for curvature + cavity detection
                float hL = SAMPLE_X(_UV, uv + float3(-1,0,0) * texel,i.direction).r;
                float hR = SAMPLE_X(_UV, uv + float3( 1,0,0) * texel,i.direction).r;
                float hU = SAMPLE_X(_UV, uv + float3(0, 1,0) * texel,i.direction).r;
                float hD = SAMPLE_X(_UV, uv + float3(0,-1,0) * texel,i.direction).r;

                float grad = abs(h - hL) + abs(h - hR) + abs(h - hU) + abs(h - hD);

                // Edge wear (brightening)
                float edgeWear = saturate(grad * _EdgeWear);

                // Cavity rust (darkening)
                float cavityRust = saturate((1.0 - h) * _CavityRust);

                // Oxidation (mid‑tone flattening)
                float oxidation = saturate((0.5 - abs(h - 0.5)) * _Oxidation);

                // Directional scratches
                float3 dir = float3(cos(_ScratchDir * 6.2831), sin(_ScratchDir * 6.2831),0);
                float hF = SAMPLE_X(_UV, uv + dir * texel,i.direction).r;
                float scratch = saturate((h - hF) * _Scratch);

                // Micro‑pitting
                float pits = pitNoise(uv);

                // Dirt accumulation
                float dirt = saturate((1.0 - h) * _Dirt);

                // Combine all effects
                float result =
                    h +
                    edgeWear -
                    cavityRust +
                    oxidation +
                    scratch +
                    pits +
                    dirt;

                result = pow(saturate(result), _Contrast);

                if (_Invert > 0.5)
                    result = 1.0 - result;

                return float4(result, result, result, 1.0);
            }

            ENDHLSL
        }
    }
}