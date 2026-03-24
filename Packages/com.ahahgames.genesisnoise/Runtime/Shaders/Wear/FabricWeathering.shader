Shader "Hidden/Genesis/FabricWeathering"
{
    Properties
    {
        [InlineTexture]_UV_2D("Fabric Mask", 2D) = "white" {}
        [InlineTexture]_UV_3D("Fabric Mask", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Fabric Mask", Cube) = "white" {}

        _ThreadWear("Thread Wear", Range(0,1)) = 0.4
        _FiberFuzz("Fiber Fuzz", Range(0,1)) = 0.35
        _Fray("Edge Fray", Range(0,1)) = 0.3
        _Dirt("Dirt Accumulation", Range(0,1)) = 0.25

        _Pilling("Micro-Pilling", Range(0,1)) = 0.3
        _PillFreq("Pill Frequency", Range(2,20)) = 8.0

        _Abrasion("Directional Abrasion", Range(0,1)) = 0.4
        _AbrasionDir("Abrasion Direction", Range(0,1)) = 0.0

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

            float _ThreadWear, _FiberFuzz, _Fray, _Dirt;
            float _Pilling, _PillFreq;
            float _Abrasion, _AbrasionDir;
            float _Contrast, _Invert;

            float rand(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float pillNoise(float2 uv)
            {
                float n = rand(uv * _PillFreq);
                return smoothstep(0.8, 1.0, n) * _Pilling;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 texel = float3(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y, 1.0 / _ScreenParams.z);

                float m = SAMPLE_X(_UV, uv,i.direction).r;

                // Neighbor samples for edge + thread detection
                float mL = SAMPLE_X(_UV, uv + float3(-1,0,0) * texel,i.direction).r;
                float mR = SAMPLE_X(_UV, uv + float3( 1,0,0) * texel,i.direction).r;
                float mU = SAMPLE_X(_UV, uv + float3(0, 1,0) * texel,i.direction).r;
                float mD = SAMPLE_X(_UV, uv + float3(0,-1,0) * texel,i.direction).r;

                // Thread wear (thinning)
                float threadWear = saturate(m - _ThreadWear * 0.5);

                // Edge fray (strong where gradient is high)
                float grad = abs(m - mL) + abs(m - mR) + abs(m - mU) + abs(m - mD);
                float fray = saturate(grad * _Fray);

                // Fiber fuzz (soft halo around threads)
                float fuzz = saturate(grad * _FiberFuzz * 0.5);

                // Dirt accumulation (in cavities)
                float dirt = saturate((1.0 - m) * _Dirt);

                // Micro-pilling (tiny fiber balls)
                float pill = pillNoise(uv);

                // Directional abrasion
                float3 dir = float3(cos(_AbrasionDir * 6.2831), sin(_AbrasionDir * 6.2831),0);
                float mF = SAMPLE_X(_UV, uv + dir * texel,i.direction).r;
                float abrasion = saturate((m - mF) * _Abrasion);

                // Combine all effects
                float result =
                    threadWear +
                    fray +
                    fuzz +
                    dirt +
                    pill +
                    abrasion;

                result = pow(saturate(result), _Contrast);

                if (_Invert > 0.5)
                    result = 1.0 - result;

                return float4(result, result, result, 1.0);
            }

            ENDHLSL
        }
    }
}