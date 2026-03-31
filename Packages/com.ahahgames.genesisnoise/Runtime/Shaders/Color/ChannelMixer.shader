Shader "Hidden/Genesis/ChannelMixer"
{
    Properties
    {
        [InlineTexture]_UV_2D("Input", 2D) = "white" {}
        [InlineTexture]_UV_3D("Input", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Input", Cube) = "white" {}

        // Per‑channel mixing weights
        _R_from_R("R from R", Range(-2, 2)) = 1
        _R_from_G("R from G", Range(-2, 2)) = 0
        _R_from_B("R from B", Range(-2, 2)) = 0
        _R_from_A("R from A", Range(-2, 2)) = 0

        _G_from_R("G from R", Range(-2, 2)) = 0
        _G_from_G("G from G", Range(-2, 2)) = 1
        _G_from_B("G from B", Range(-2, 2)) = 0
        _G_from_A("G from A", Range(-2, 2)) = 0

        _B_from_R("B from R", Range(-2, 2)) = 0
        _B_from_G("B from G", Range(-2, 2)) = 0
        _B_from_B("B from B", Range(-2, 2)) = 1
        _B_from_A("B from A", Range(-2, 2)) = 0

        _A_from_R("A from R", Range(-2, 2)) = 0
        _A_from_G("A from G", Range(-2, 2)) = 0
        _A_from_B("A from B", Range(-2, 2)) = 0
        _A_from_A("A from A", Range(-2, 2)) = 1

        _Clamp("Clamp Output", Range(0,1)) = 1
        _Grayscale("Force Grayscale Output", Range(0,1)) = 0
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

            float _R_from_R, _R_from_G, _R_from_B, _R_from_A;
            float _G_from_R, _G_from_G, _G_from_B, _G_from_A;
            float _B_from_R, _B_from_G, _B_from_B, _B_from_A;
            float _A_from_R, _A_from_G, _A_from_B, _A_from_A;

            float _Clamp;
            float _Grayscale;

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float4 c = SAMPLE_X(_UV, uv, i.dir);

                // Compute each output channel
                float r = c.r * _R_from_R + c.g * _R_from_G + c.b * _R_from_B + c.a * _R_from_A;
                float g = c.r * _G_from_R + c.g * _G_from_G + c.b * _G_from_B + c.a * _G_from_A;
                float b = c.r * _B_from_R + c.g * _B_from_G + c.b * _B_from_B + c.a * _B_from_A;
                float a = c.r * _A_from_R + c.g * _A_from_G + c.b * _A_from_B + c.a * _A_from_A;

                if (_Clamp > 0.5)
                {
                    r = saturate(r);
                    g = saturate(g);
                    b = saturate(b);
                    a = saturate(a);
                }

                // Optional grayscale override
                if (_Grayscale > 0.5)
                {
                    float gray = dot(float3(r, g, b), float3(0.299, 0.587, 0.114));
                    return float4(gray, gray, gray, a);
                }

                return float4(r, g, b, a);
            }

            ENDHLSL
        }
    }
}