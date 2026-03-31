Shader "Hidden/Genesis/HeightNormalBlender"
{
    Properties
    {
        // Base normal map
        [InlineTexture]_BaseNormal_2D("Base Normal", 2D) = "bump" {}
        [InlineTexture]_BaseNormal_3D("Base Normal", 3D) = "bump" {}
        [InlineTexture]_BaseNormal_Cube("Base Normal", Cube) = "bump" {}

        // Detail normal map
        [InlineTexture]_DetailNormal_2D("Detail Normal", 2D) = "bump" {}
        [InlineTexture]_DetailNormal_3D("Detail Normal", 3D) = "bump" {}
        [InlineTexture]_DetailNormal_Cube("Detail Normal", Cube) = "bump" {}

        // Height map controlling blend
        [InlineTexture]_Height_2D("Height", 2D) = "gray" {}
        [InlineTexture]_Height_3D("Height", 3D) = "gray" {}
        [InlineTexture]_Height_Cube("Height", Cube) = "gray" {}

        _DetailIntensity("Detail Intensity", Range(0, 2)) = 1.0
        _HeightContrast("Height Contrast", Range(0, 4)) = 1.0
        _InvertHeight("Invert Height", Int) = 0
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

            TEXTURE_SAMPLER_X(_BaseNormal);
            TEXTURE_SAMPLER_X(_DetailNormal);
            TEXTURE_SAMPLER_X(_Height);

            float _DetailIntensity;
            float _HeightContrast;
            int   _InvertHeight;

            float3 SampleNormalBase(float3 uv, float3 dir)
            {
                float3 n = SAMPLE_X(_BaseNormal, uv, dir).rgb;
                return normalize(n * 2.0 - 1.0);
            }

            float3 SampleNormalDetail(float3 uv, float3 dir)
            {
                float3 n = SAMPLE_X(_DetailNormal, uv, dir).rgb;
                return normalize(n * 2.0 - 1.0);
            }

            float SampleHeight(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Height, uv, dir).r;
            }

            // Height shaping (Substance-like)
            float ShapeHeight(float h)
            {
                h = pow(h, max(0.0001, 1.0 / _HeightContrast));
                if (_InvertHeight == 1)
                    h = 1.0 - h;
                return saturate(h); 
            }

            // Proper tangent-space normal blend
            float3 BlendNormals(float3 baseN, float3 detailN, float h)
            {
                // Scale detail by height mask
                detailN.xy *= h * _DetailIntensity;

                // Re-normalize detail normal
                detailN = normalize(float3(detailN.xy, detailN.z));

                // Combine
                float3 n;
                n.xy = baseN.xy + detailN.xy;
                n.z  = baseN.z  * detailN.z;

                return normalize(n);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float3 baseN   = SampleNormalBase(uv, i.direction);
                float3 detailN = SampleNormalDetail(uv, i.direction);
                float  h       = ShapeHeight(SampleHeight(uv, i.direction));

                float3 finalN = BlendNormals(baseN, detailN, h);

                return float4(finalN * 0.5 + 0.5, 1);
            }

            ENDHLSL
        }
    }
}