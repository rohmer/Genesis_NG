Shader "Hidden/Genesis/MultiDirectionalWarp"
{
    Properties
    {
        // Source texture to warp
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Noise map controlling warp amount
        [InlineTexture]_Noise_2D("Noise", 2D) = "gray" {}
        [InlineTexture]_Noise_3D("Noise", 3D) = "gray" {}
        [InlineTexture]_Noise_Cube("Noise", Cube) = "gray" {}

        _Strength("Warp Strength", Range(0, 50)) = 10
        _Directions("Direction Count", Range(1, 8)) = 4
        _AngleOffset("Angle Offset", Range(0, 1)) = 0
        _NoiseScale("Noise Scale", Range(0.1, 10)) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_Source);
            TEXTURE_SAMPLER_X(_Noise);

            float _Strength;
            float _Directions;
            float _AngleOffset;
            float _NoiseScale;

            // ------------------------------------------------------------
            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float SampleNoise(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Noise, uv, dir).r;
            }

            float2 DirFromAngle(float a)
            {
                return float2(cos(a), sin(a));
            }

            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float dirCount = max(1, _Directions);
                float angleBase = _AngleOffset * 6.2831853;

                float3 accum = 0;

                // Multi‑direction warp loop
                for (int d = 0; d < 8; d++)
                {
                    if (d >= dirCount) break;

                    float angle = angleBase + (6.2831853 * d / dirCount);
                    float2 dir = DirFromAngle(angle);

                    // Noise sample for this direction
                    float n = SampleNoise(uv * _NoiseScale, i.direction);

                    // Warp offset
                    float2 offset = dir * (n * _Strength) * texel;

                    // Sample source at warped UV
                    float3 c = SampleSource(uv + float3(offset.x,offset.y,0), i.direction);

                    accum += c;
                }

                // Average all directional samples
                float3 result = accum / dirCount;

                return float4(result, 1);
            }

            ENDHLSL
        }
    }
}