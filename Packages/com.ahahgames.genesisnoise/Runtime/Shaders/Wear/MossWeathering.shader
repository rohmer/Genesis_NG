Shader "Hidden/Genesis/MossWeathering"
{
    Properties
    {
        [InlineTexture]_UV_2D("Height Input", 2D) = "white" {}
        [InlineTexture]_UV_3D("Height Input", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Height Input", Cube) = "white" {}

        _Moisture("Moisture Influence", Range(0,1)) = 0.5
        _Cavity("Cavity Growth", Range(0,1)) = 0.6
        _Shadow("Shadow Growth", Range(0,1)) = 0.5
        _Slope("Slope Growth", Range(0,1)) = 0.4
        _SlopeDir("Preferred Growth Direction", Range(0,1)) = 0.0

        _Cluster("Cluster Strength", Range(0,1)) = 0.5
        _ClusterFreq("Cluster Frequency", Range(1,20)) = 6.0

        _Fuzz("Micro Moss Fuzz", Range(0,1)) = 0.25
        _FuzzFreq("Fuzz Frequency", Range(5,30)) = 12.0

        _Spread("Overall Spread", Range(0,1)) = 0.5
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

            float _Moisture, _Cavity, _Shadow, _Slope, _SlopeDir;
            float _Cluster, _ClusterFreq;
            float _Fuzz, _FuzzFreq;
            float _Spread, _Contrast, _Invert;

            float rand(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float clusterNoise(float2 uv)
            {
                float n = rand(uv * _ClusterFreq);
                return smoothstep(0.4, 1.0, n) * _Cluster;
            }

            float fuzzNoise(float2 uv)
            {
                float n = rand(uv * _FuzzFreq);
                return smoothstep(0.7, 1.0, n) * _Fuzz;
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

                // Moisture-like cavity growth
                float cavity = saturate((1.0 - h) * _Cavity);

                // Shadow-like occlusion (low gradient areas)
                float shadow = saturate((1.0 - grad) * _Shadow);

                // Slope-aware growth
                float3 dir = float3(cos(_SlopeDir * 6.2831), sin(_SlopeDir * 6.2831),0);
                float hF = SAMPLE_X(_UV, uv + dir * texel,i.direction).r;
                float slope = saturate((hF - h) * _Slope);

                // Organic clustering
                float cluster = clusterNoise(uv);

                // Micro moss fuzz
                float fuzz = fuzzNoise(uv);

                // Combine all moss influences
                float moss =
                    cavity * _Moisture +
                    shadow +
                    slope +
                    cluster +
                    fuzz;

                moss *= _Spread;
                moss = pow(saturate(moss), _Contrast);

                if (_Invert > 0.5)
                    moss = 1.0 - moss;

                return float4(moss, moss, moss, 1.0);
            }

            ENDHLSL
        }
    }
}