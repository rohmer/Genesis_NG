Shader "Hidden/Genesis/Diffusion"
{
    Properties
    {
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        [InlineTexture]_Height_2D("Height", 2D) = "black" {}
        [InlineTexture]_Height_3D("Height", 3D) = "black" {}
        [InlineTexture]_Height_Cube("Height", Cube) = "black" {}

        _Radius("Radius", Range(1, 8)) = 3
        _Iterations("Iterations", Range(1, 8)) = 4
        _HeightSensitivity("Height Sensitivity", Range(0, 4)) = 1
        _Falloff("Falloff", Range(0, 1)) = 0.5
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
            TEXTURE_SAMPLER_X(_Height);

            float _Radius;
            float _Iterations;
            float _HeightSensitivity;
            float _Falloff;

            // ------------------------------------------------------------
            float SampleHeight(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Height, uv, dir).r;
            }

            float3 SampleColor(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            // Height‑guided weight
            float Weight(float hCenter, float hSample)
            {
                float dh = abs(hSample - hCenter);
                float w = exp(-dh * _HeightSensitivity);
                return pow(w, _Falloff * 4.0);
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01); 

                float3 color = SampleColor(uv, i.direction);
                float  hC    = SampleHeight(uv, i.direction);

                // Iterative diffusion
                for (int iter = 0; iter < _Iterations; iter++)
                {
                    float3 accum = 0;
                    float  wSum  = 0;

                    for (int j = -_Radius; j <= _Radius; j++)
                    for (int k = -_Radius; k <= _Radius; k++)
                    {
                        float3 offset = float3(k, j,0);
                        float3 suv = uv + offset * texel;

                        float3 cS = SampleColor(suv, i.direction);
                        float  hS = SampleHeight(suv, i.direction);

                        float w = Weight(hC, hS);

                        accum += cS * w;
                        wSum  += w;
                    }

                    if (wSum > 0)
                        color = accum / wSum;

                    // Update center height for next iteration
                    hC = SampleHeight(uv, i.direction);
                }

                return float4(color, 1);
            }

            ENDHLSL
        }
    }
}