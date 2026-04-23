Shader "Hidden/Genesis/NormalInvert"
{
    Properties
    {
        // Normal map input (tangent space)
        [InlineTexture]_Normal_2D("Normal", 2D) = "bump" {}
        [InlineTexture]_Normal_3D("Normal", 3D) = "bump" {}
        [InlineTexture]_Normal_Cube("Normal", Cube) = "bump" {}

        // Optional toggles
        _InvertX("Invert X", Int) = 1
        _InvertY("Invert Y", Int) = 1
        _Normalize("Renormalize", Int) = 1
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

            int _InvertX;
            int _InvertY;
            int _Normalize;

            float3 SampleNormal(float3 uv, float3 dir)
            {
                float3 n = SAMPLE_X(_Normal, uv, dir).rgb;
                return n * 2.0 - 1.0; // 0–1 → -1..1
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz; 

                float3 n = SampleNormal(uv, i.direction);

                // Invert channels
                if (_InvertX == 1) n.x = -n.x;
                if (_InvertY == 1) n.y = -n.y;

                // Optional renormalization
                if (_Normalize == 1)
                    n = normalize(n);

                // Back to 0–1
                float3 outN = n * 0.5 + 0.5;

                return float4(outN, 1);
            }

            ENDHLSL
        }
    }
}