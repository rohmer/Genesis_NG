Shader "Hidden/Genesis/DirectionalGaussianBlur"
{
    Properties
    {
        [InlineTexture]_Input_2D("Input", 2D) = "white" {}
        [InlineTexture]_Input_3D("Input", 3D) = "white" {}
        [InlineTexture]_Input_Cube("Input", Cube) = "white" {}

        [GenesisBoxBlurRadius]_Radius("Radius", int) = 3
        _Sigma("Sigma", Float) = 3.0
        _Direction("Direction (XY)", Vector) = (1,0,0,0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET_API
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            TEXTURE_SAMPLER_X(_Input);

            int _Radius;
            float _Sigma;
            float2 _Direction;

            float Gaussian1D(float x, float sigma)
            {
                float s2 = sigma * sigma;
                return exp(-(x * x) / (2.0 * s2));
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uvw = i.localTexcoord.xyz;

                // Normalize direction and convert to UV space
                float2 dir = normalize(_Direction);
                float2 stepUV = dir * 0.01;

                float4 sum = 0.0;
                float weightSum = 0.0;

                // 1D Gaussian blur along direction
                for (int t = -_Radius; t <= _Radius; ++t)
                {
                    float w = Gaussian1D(t, _Sigma);
                    weightSum += w;

                    float3 uvwOffset = uvw;
                    uvwOffset.xy += stepUV * t;

                    sum += SAMPLE_X(_Input, uvwOffset, i.direction) * w;
                }

                return sum / weightSum;
            }

            ENDHLSL
        }
    }
}