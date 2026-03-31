Shader "Hidden/Genesis/NonUniformDirectionalWarp"
{
    Properties
    {
        // Source to warp
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Noise controlling warp amount
        [InlineTexture]_Noise_2D("Noise", 2D) = "gray" {}
        [InlineTexture]_Noise_3D("Noise", 3D) = "gray" {}
        [InlineTexture]_Noise_Cube("Noise", Cube) = "gray" {}

        _Strength("Strength", Range(0, 50)) = 10
        _Angle("Direction Angle", Range(0, 1)) = 0
        _NoiseScale("Noise Scale", Range(0.1, 10)) = 1
        _Softness("Softness", Range(0, 1)) = 0.25
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
            float _Angle;
            float _NoiseScale;
            float _Softness;

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
                float ang = a * 6.2831853;
                return float2(cos(ang), sin(ang));
            }

            // Soft shaping of noise (Substance-like)
            float Shape(float n)
            {
                float smooth = smoothstep(0, 1, n);
                float sharp  = pow(n, 0.35);
                return lerp(smooth, sharp, _Softness);
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                // Direction vector
                float2 dir = DirFromAngle(_Angle);

                // Noise controls warp amount
                float n = SampleNoise(uv * _NoiseScale, i.direction);
                n = Shape(n);

                // Warp offset
                float2 offset = dir * (n * _Strength) * texel;

                // Sample source at warped UV
                float3 result = SampleSource(uv + float3(offset.x,offset.y,0), i.direction);

                return float4(result, 1);
            }

            ENDHLSL
        }
    }
}