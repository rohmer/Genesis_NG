Shader "Hidden/Genesis/FloodFillToRandomGrayscale"
{
    Properties
    {
        // Region ID map from Flood Fill
        [InlineTexture]_RegionID_2D("Region ID", 2D) = "black" {}
        [InlineTexture]_RegionID_3D("Region ID", 3D) = "black" {}
        [InlineTexture]_RegionID_Cube("Region ID", Cube) = "black" {}

        _Seed("Seed", Range(0, 1000)) = 0
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

            TEXTURE_SAMPLER_X(_RegionID);

            float _Seed;

            // ------------------------------------------------------------
            // Hash function to convert region ID → stable random grayscale
            float Hash11(float x)
            {
                x = frac(x * 0.1031 + _Seed * 0.0137);
                x *= x + 33.33;
                x *= x + x;
                return frac(x);
            }

            float SampleRegionID(float3 uv, float3 dir)
            {
                return SAMPLE_X(_RegionID, uv, dir).r;
            }

            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                // Region ID from Flood Fill
                float id = SampleRegionID(uv, i.direction);

                // Background (no region)
                if (id <= 0.00001)
                    return float4(0, 0, 0, 1);

                // Convert region ID → stable random grayscale
                float g = Hash11(id);

                return float4(g.xxx, 1);
            }

            ENDHLSL
        }
    }
}