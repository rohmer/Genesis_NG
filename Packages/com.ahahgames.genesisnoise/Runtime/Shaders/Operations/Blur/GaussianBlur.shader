Shader "Hidden/Genesis/GaussianBlur"
{
    Properties
    {
        [InlineTexture]_Input_2D("Input", 2D) = "white" {}
        [InlineTexture]_Input_3D("Input", 3D) = "white" {}
        [InlineTexture]_Input_Cube("Input", Cube) = "white" {}

        [GenesisBoxBlurRadius]_Radius("Radius", int) = 3
        _Sigma("Sigma", Float) = 2.0
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

            TEXTURE_SAMPLER_X(_Input);

            int _Radius;
            float _Sigma;

            float Gaussian(float x, float y, float sigma)
            {
                float s2 = sigma * sigma;
                return exp(-(x*x + y*y) / (2.0 * s2));
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uvw = i.localTexcoord.xyz;

                float4 sum = 0.0;
                float weightSum = 0.0;

                for (int y = -_Radius; y <= _Radius; ++y)
                {
                    for (int x = -_Radius; x <= _Radius; ++x)
                    {
                        float2 offset = float2(x, y) * 0.01;

                        float w = Gaussian(x, y, _Sigma);
                        weightSum += w;

                        float3 uvwOffset = uvw;
                        uvwOffset.xy += offset;

                        sum += SAMPLE_X(_Input, uvwOffset, i.direction) * w;
                    }
                }

                return sum / weightSum;
            }

            ENDHLSL
        }
    }
}