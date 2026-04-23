Shader "Hidden/Genesis/FacingNormal"
{
    Properties
    {
        // Normal map in tangent space (0–1 RGB)
        [InlineTexture]_Normal_2D("Normal", 2D) = "bump" {}
        [InlineTexture]_Normal_3D("Normal", 3D) = "bump" {}
        [InlineTexture]_Normal_Cube("Normal", Cube) = "bump" {}

        // View direction in turns (0–1)
        _Angle("View Angle", Range(0, 1)) = 0.0

        _Softness("Softness", Range(0, 1)) = 0.35
        _Contrast("Contrast", Range(0, 4)) = 1.0
        _Invert("Invert", Int) = 0
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
            float _Softness;
            float _Contrast;
            int   _Invert;

            float3 SampleNormal(float3 uv, float3 dir)
            {
                float3 n = SAMPLE_X(_Normal, uv, dir).rgb;
                return normalize(n * 2.0 - 1.0); // 0–1 → -1..1
            }

            float2 DirFromAngle(float a)
            {
                float ang = a * 6.2831853;
                return float2(cos(ang), sin(ang));
            }

            // Soft shaping (Substance-like)
            float Shape(float x)
            {
                float smooth = smoothstep(0, 1, x);
                float sharp  = pow(x, 0.35);
                return lerp(smooth, sharp, _Softness);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float3 N = SampleNormal(uv, i.direction);

                // View direction in tangent plane (XY)
                float2 v2 = DirFromAngle(_Angle);
                float3 V = normalize(float3(v2.x, v2.y, 1e-3)); // slight Z to avoid flatness

                // Facing amount
                float f = saturate(dot(N, V));

                // Softness shaping
                f = Shape(f);

                // Contrast
                f = pow(f, max(0.0001, 1.0 / _Contrast));

                // Invert
                if (_Invert == 1)
                    f = 1.0 - f;

                return float4(f.xxx, 1);
            }

            ENDHLSL
        }
    }
}