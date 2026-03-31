Shader "Hidden/Genesis/DirectionalBlur"
{
    Properties
    {
        [InlineTexture]_Input_2D("Input", 2D) = "white" {}
        [InlineTexture]_Input_3D("Input", 3D) = "white" {}
        [InlineTexture]_Input_Cube("Input", Cube) = "white" {}

        [GenesisBoxBlurRadius]_Radius("Radius", int) = 3
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
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            TEXTURE_SAMPLER_X(_Input);

            int _Radius;
            float2 _Direction;   // user‑supplied direction (x,y)
            
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uvw = i.localTexcoord.xyz;

                // Normalize direction and convert to UV space
                float2 dir = normalize(_Direction);
                float2 stepUV = dir * 0.01;

                float4 sum = 0.0;
                int taps = 0;

                // 1D directional blur
                for (int t = -_Radius; t <= _Radius; ++t)
                {
                    float3 uvwOffset = uvw;
                    uvwOffset.xy += stepUV * t;

                    sum += SAMPLE_X(_Input, uvwOffset, i.direction);
                    taps++;
                }

                return sum / taps;
            }

            ENDHLSL
        }
    }
}