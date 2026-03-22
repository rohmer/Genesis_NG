Shader "Hidden/Genesis/NormalSobel"
{
    Properties
    {
        // Height map input
        [InlineTexture]_Height_2D("Height", 2D) = "gray" {}
        [InlineTexture]_Height_3D("Height", 3D) = "gray" {}
        [InlineTexture]_Height_Cube("Height", Cube) = "gray" {}

        _Intensity("Normal Intensity", Range(0, 8)) = 1.0
        _InvertX("Invert X", Int) = 0
        _InvertY("Invert Y", Int) = 0
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

            TEXTURE_SAMPLER_X(_Height);

            float _Intensity;
            int _InvertX;
            int _InvertY;

            float SampleHeight(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Height, uv, dir).r;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                // Sobel kernel sampling
                float h00 = SampleHeight(uv + texel * float3(-1, -1, 0), i.direction);
                float h10 = SampleHeight(uv + texel * float3( 0, -1, 0), i.direction);
                float h20 = SampleHeight(uv + texel * float3( 1, -1, 0), i.direction);

                float h01 = SampleHeight(uv + texel * float3(-1,  0, 0), i.direction);
                float h21 = SampleHeight(uv + texel * float3( 1,  0, 0), i.direction);

                float h02 = SampleHeight(uv + texel * float3(-1,  1, 0), i.direction);
                float h12 = SampleHeight(uv + texel * float3( 0,  1, 0), i.direction);
                float h22 = SampleHeight(uv + texel * float3( 1,  1, 0), i.direction);

                // Sobel X and Y
                float gx = (h20 + 2*h21 + h22) - (h00 + 2*h01 + h02);
                float gy = (h02 + 2*h12 + h22) - (h00 + 2*h10 + h20);

                // Apply intensity
                gx *= _Intensity;
                gy *= _Intensity;

                // Optional inversion
                if (_InvertX == 1) gx = -gx;
                if (_InvertY == 1) gy = -gy;

                // Construct tangent-space normal
                float3 n = float3(-gx, -gy, 1.0);

                n = normalize(n);

                // Back to 0–1
                float3 outN = n * 0.5 + 0.5;

                return float4(outN, 1);
            }

            ENDHLSL 
        }
    }
}