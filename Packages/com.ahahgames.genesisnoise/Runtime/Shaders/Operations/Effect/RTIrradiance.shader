Shader "Hidden/Genesis/RTIrradiance"
{
    Properties
    {
        // Height or albedo input
        [InlineTexture]_Source_2D("Source", 2D) = "gray" {}
        [InlineTexture]_Source_3D("Source", 3D) = "gray" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "gray" {}

        _Radius("Radius", Range(1, 32)) = 8
        _Strength("Strength", Range(0, 4)) = 1
        _Bias("Height Bias", Range(0, 1)) = 0.1
        _Samples("Sample Count", Range(4, 32)) = 12
        _Hemisphere("Hemisphere Weight", Range(0, 1)) = 0.75
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

            float _Radius;
            float _Strength;
            float _Bias;
            float _Samples;
            float _Hemisphere;

            // ------------------------------------------------------------
            float SampleHeight(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).r;
            }

            // Hemisphere weighting (Substance-like)
            float HemisphereWeight(float2 dir)
            {
                float w = saturate(dot(normalize(dir), float2(0, -1)));
                return lerp(1.0, w, _Hemisphere);
            }

            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float h0 = SampleHeight(uv, i.direction);

                float accum = 0.0;
                float total = 0.0;

                int N = (int)_Samples;

                // Multi-direction hemisphere sampling
                for (int s = 0; s < 32; s++)
                {
                    if (s >= N) break;

                    float angle = (6.2831853 * s) / N;
                    float2 dir = float2(cos(angle), sin(angle));

                    float w = HemisphereWeight(dir);

                    float2 offset = dir * _Radius * texel;

                    float h = SampleHeight(uv + float3(offset,0), i.direction);

                    float occlusion = saturate((h - h0 + _Bias));

                    accum += occlusion * w;
                    total += w;
                }

                float irradiance = accum / max(total, 1e-5);

                irradiance *= _Strength;

                return float4(irradiance.xxx, 1);
            }

            ENDHLSL
        }
    }
}