Shader "Hidden/Genesis/FloodFillToRandomVector"
{
    Properties
    {
        // Region ID map from Flood Fill
        [InlineTexture]_RegionID_2D("Region ID", 2D) = "black" {}
        [InlineTexture]_RegionID_3D("Region ID", 3D) = "black" {}
        [InlineTexture]_RegionID_Cube("Region ID", Cube) = "black" {}

        _Seed("Seed", Range(0, 1000)) = 0
        _Normalize("Normalize Vector", Int) = 1
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

            TEXTURE_SAMPLER_X(_RegionID);

            float _Seed;
            int   _Normalize;

            // ------------------------------------------------------------
            // Hash functions for stable region vectors
            float Hash11(float x)
            {
                x = frac(x * 0.1031 + _Seed * 0.0137);
                x *= x + 33.33;
                x *= x + x;
                return frac(x);
            }

            float2 HashVector(float id)
            {
                float a = Hash11(id) * 6.2831853;     // angle
                float r = Hash11(id + 19.17) * 2 - 1; // magnitude bias

                float2 v = float2(cos(a), sin(a)) * r;

                if (_Normalize == 1)
                    v = normalize(v);

                return v;
            }

            float SampleRegionID(float3 uv, float3 dir)
            {
                return SAMPLE_X(_RegionID, uv, dir).r;
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float id = SampleRegionID(uv, i.direction);

                // Background (no region)
                if (id <= 0.00001)
                    return float4(0, 0, 0, 1);

                // Convert region ID → stable random vector
                float2 v = HashVector(id);

                // Pack vector into RG, leave B unused
                return float4(v, 0, 1);
            }

            ENDHLSL
        }
    }
}