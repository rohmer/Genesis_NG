Shader "Hidden/Genesis/RustWeathering"
{
    Properties
    {
        [InlineTexture]_UV_2D("Metal Height", 2D) = "white" {}
        [InlineTexture]_UV_3D("Metal Height", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Metal Height", Cube) = "white" {}

        _Oxidation("Oxidation Layer", Range(0,1)) = 0.5
        _CavityRust("Cavity Rust", Range(0,1)) = 0.6
        _Flakes("Rust Flaking", Range(0,1)) = 0.4

        _Pitting("Micro Pitting", Range(0,1)) = 0.35
        _PitFreq("Pitting Frequency", Range(3,25)) = 12.0

        _Streaks("Rust Streaks", Range(0,1)) = 0.4
        _StreakDir("Streak Direction", Range(0,1)) = 0.0

        _Spread("Rust Spread", Range(0,1)) = 0.5
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

            float _Oxidation, _CavityRust, _Flakes;
            float _Pitting, _PitFreq;
            float _Streaks, _StreakDir;
            float _Spread, _Contrast, _Invert;

            float rand(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float pitNoise(float3 uv)
            {
                float n = rand(uv * _PitFreq);
                return smoothstep(0.75, 1.0, n) * _Pitting;
            }

            float flakeNoise(float3 uv)
            {
                float n = rand(uv * (_PitFreq * 0.5));
                return smoothstep(0.6, 1.0, n) * _Flakes;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
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

                // Oxidation layer (mid‑tone flattening)
                float oxidation = saturate((0.5 - abs(h - 0.5)) * _Oxidation);

                // Cavity rust (deep rust)
                float cavityRust = saturate((1.0 - h) * _CavityRust);

                // Rust flakes (surface breakup)
                float flakes = flakeNoise(uv);

                // Micro‑pitting (corrosion)
                float pits = pitNoise(uv);

                // Directional streaks (rain‑driven rust)
                float3 dir = float3(cos(_StreakDir * 6.2831), sin(_StreakDir * 6.2831),0);
                float hF = SAMPLE_X(_UV, uv + dir * texel,i.direction).r;
                float streaks = saturate((hF - h) * _Streaks);

                // Combine all rust influences
                float rust =
                    oxidation +
                    cavityRust +
                    flakes +
                    pits +
                    streaks;

                rust *= _Spread;
                rust = pow(saturate(rust), _Contrast);

                if (_Invert > 0.5)
                    rust = 1.0 - rust;

                return float4(rust, rust, rust, 1.0);
            }

            ENDHLSL
        }
    }
}