Shader "Hidden/Genesis/AutoCrop"
{
    Properties
    {
        // Source image
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        _Threshold("Crop Threshold", Range(0, 1)) = 0.05
        _Padding("Padding", Range(0, 0.25)) = 0.02
        _Samples("Scan Samples", Range(4, 64)) = 16
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

            TEXTURE_SAMPLER_X(_Source);

            float _Threshold;
            float _Padding;
            float _Samples;

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float Luma(float3 c)
            {
                return dot(c, float3(0.299, 0.587, 0.114));
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                int S = max(4, (int)_Samples);

                // Initialize bounding box
                float2 minUV = float2(1e6, 1e6);
                float2 maxUV = float2(-1e6, -1e6);

                // Multi-sample scan around the pixel
                for (int x = 0; x < S; x++)
                {
                    for (int y = 0; y < S; y++)
                    {
                        float3 suv = float3(x / (float)(S - 1), y / (float)(S - 1),0);
                        float3 col = SampleSource(suv, i.direction);

                        if (Luma(col) > _Threshold)
                        {
                            minUV = min(minUV, suv);
                            maxUV = max(maxUV, suv);
                        }
                    }
                }

                // If nothing found, return original
                if (minUV.x > maxUV.x || minUV.y > maxUV.y)
                {
                    float3 col = SampleSource(uv, i.direction);
                    return float4(col, 1);
                }

                // Apply padding
                minUV -= _Padding;
                maxUV += _Padding;

                minUV = saturate(minUV);
                maxUV = saturate(maxUV);

                // Remap UV into cropped region
                float3 croppedUV = float3(lerp(minUV, maxUV, uv),0);

                float3 outCol = SampleSource(croppedUV, i.direction);

                return float4(outCol, 1); 
            }

            ENDHLSL
        }
    }
}