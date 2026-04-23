Shader "Hidden/Genesis/NormalVectorRotation"
{
    Properties
    {
        // Tangent-space normal map
        [InlineTexture]_Normal_2D("Normal", 2D) = "bump" {}
        [InlineTexture]_Normal_3D("Normal", 3D) = "bump" {}
        [InlineTexture]_Normal_Cube("Normal", Cube) = "bump" {}

        // Rotation angle in turns (0–1)
        _Angle("Rotation Angle", Range(0, 1)) = 0.25

        // Optional controls
        _Strength("Rotation Strength", Range(0, 2)) = 1.0
        _PreserveZ("Preserve Z", Int) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_Normal);

            float _Angle;
            float _Strength;
            int   _PreserveZ;

            float3 SampleNormal(float3 uv, float3 dir)
            {
                float3 n = SAMPLE_X(_Normal, uv, dir).rgb;
                return n * 2.0 - 1.0; // 0–1 → -1..1
            }

            float2 Rotate(float2 v, float ang)
            {
                float s = sin(ang);
                float c = cos(ang);
                return float2(
                    v.x * c - v.y * s,
                    v.x * s + v.y * c
                );
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float3 n = SampleNormal(uv, i.direction);

                float angle = _Angle * 6.2831853; // turns → radians

                float z = n.z;

                // Rotate XY
                float2 xy = Rotate(n.xy, angle);

                // Apply strength
                xy *= _Strength;

                if (_PreserveZ == 1)
                {
                    n = normalize(float3(xy, z));
                }
                else
                {
                    n = normalize(float3(xy, n.z));
                }

                float3 outN = n * 0.5 + 0.5;

                return float4(outN, 1);
            }

            ENDHLSL
        }
    }
}