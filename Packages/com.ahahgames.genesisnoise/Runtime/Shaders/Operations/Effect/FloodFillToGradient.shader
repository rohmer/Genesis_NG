Shader "Hidden/Genesis/FloodFillToGradient"
{
    Properties
    {
        // Region ID map from Flood Fill
        [InlineTexture]_RegionID_2D("Region ID", 2D) = "black" {}
        [InlineTexture]_RegionID_3D("Region ID", 3D) = "black" {}
        [InlineTexture]_RegionID_Cube("Region ID", Cube) = "black" {}

        // Bounding box map from Flood Fill to Bounding Box
        [InlineTexture]_BBox_2D("Bounding Box", 2D) = "black" {}
        [InlineTexture]_BBox_3D("Bounding Box", 3D) = "black" {}
        [InlineTexture]_BBox_Cube("Bounding Box", Cube) = "black" {}

        _Angle("Gradient Angle", Range(0, 1)) = 0
        _Invert("Invert", Int) = 0
        _Randomize("Randomize Per Region", Int) = 0
        _Seed("Seed", Range(0, 1000)) = 0
        _Profile("Profile", Range(0, 1)) = 0.5
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
            TEXTURE_SAMPLER_X(_BBox);

            float _Angle;
            int   _Invert;
            int   _Randomize;
            float _Seed;
            float _Profile;

            // ------------------------------------------------------------
            float SampleRegionID(float3 uv, float3 dir)
            {
                return SAMPLE_X(_RegionID, uv, dir).r;
            }

            float3 SampleBBox(float3 uv, float3 dir)
            {
                return SAMPLE_X(_BBox, uv, dir).rgb;
            }

            // Hash for stable per‑region randomization
            float Hash11(float x)
            {
                x = frac(x * 0.1031 + _Seed * 0.0137);
                x *= x + 33.33;
                x *= x + x;
                return frac(x);
            }

            // Profile shaping (Substance‑style)
            float ProfileCurve(float x)
            {
                float smooth = smoothstep(0, 1, x);
                float sharp  = pow(x, 0.35);
                return lerp(smooth, sharp, _Profile);
            }

            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float id = SampleRegionID(uv, i.direction);

                // Background
                if (id <= 0.00001)
                    return float4(0, 0, 0, 1);

                // Bounding box data
                float3 bb = SampleBBox(uv, i.direction);

                float2 norm = bb.xy;   // normalized position inside region
                float  size = bb.z;    // region size (optional)

                // Base gradient direction
                float angle = _Angle * 6.2831853;

                // Optional per‑region random rotation
                if (_Randomize == 1)
                {
                    float r = Hash11(id);
                    angle += r * 6.2831853;
                }

                float2 dir = float2(cos(angle), sin(angle));

                // Project normalized coordinate onto gradient direction
                float g = dot(norm * 2 - 1, dir) * 0.5 + 0.5;

                // Invert if needed
                if (_Invert == 1)
                    g = 1.0 - g;

                // Apply profile shaping
                g = ProfileCurve(saturate(g));

                return float4(g.xxx, 1);
            }

            ENDHLSL
        }
    }
}