Shader "Hidden/Genesis/NormalNormalize"
{
    Properties
    {
        // Normal map input (tangent space)
        [InlineTexture]_Normal_2D("Normal", 2D) = "bump" {}
        [InlineTexture]_Normal_3D("Normal", 3D) = "bump" {}
        [InlineTexture]_Normal_Cube("Normal", Cube) = "bump" {}

        // Optional controls
        _Strength("Normalize Strength", Range(0, 2)) = 1.0
        _PreserveZ("Preserve Z", Int) = 0   // 0 = full normalize, 1 = keep Z magnitude
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

            TEXTURE_SAMPLER_X(_Normal);

            float _Strength;
            int   _PreserveZ;

            float3 SampleNormal(float3 uv, float3 dir)
            {
                float3 n = SAMPLE_X(_Normal, uv, dir).rgb;
                return n * 2.0 - 1.0; // 0–1 → -1..1
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float3 n = SampleNormal(uv, i.direction);

                // Optional: preserve Z magnitude (Substance-like behavior)
                float z = n.z;

                // Normalize XY or full vector
                if (_PreserveZ == 1)
                {
                    float2 xy = normalize(n.xy) * _Strength;
                    n = float3(xy, z);
                }
                else
                {
                    n = normalize(n) * _Strength;
                }

                // Back to 0–1
                float3 outN = n * 0.5 + 0.5;
                 
                return float4(outN, 1);
            }

            ENDHLSL
        }
    }
}