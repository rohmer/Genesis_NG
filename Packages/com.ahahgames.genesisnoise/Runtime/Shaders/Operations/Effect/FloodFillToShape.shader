Shader "Hidden/Genesis/FloodFillToShape"
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

        _ShapeType("Shape Type", Int) = 0   // 0=Circle, 1=Diamond, 2=Square
        _Softness("Softness", Range(0, 1)) = 0.25
        _Randomize("Randomize Per Region", Int) = 0
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
            TEXTURE_SAMPLER_X(_BBox);

            int   _ShapeType;
            float _Softness;
            int   _Randomize;
            float _Seed;

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

            // Shape functions ------------------------------------------------
            float ShapeCircle(float2 p)
            {
                return 1.0 - length(p);
            }

            float ShapeDiamond(float2 p)
            {
                return 1.0 - (abs(p.x) + abs(p.y));
            }

            float ShapeSquare(float2 p)
            {
                float d = max(abs(p.x), abs(p.y));
                return 1.0 - d;
            }

            // Soft edge
            float Soft(float v)
            {
                return smoothstep(0.0, _Softness, v);
            }

            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float id = SampleRegionID(uv, i.direction);

                // Background
                if (id <= 0.00001)
                    return float4(0, 0, 0, 1);

                // Bounding box normalized coords
                float3 bb = SampleBBox(uv, i.direction);
                float2 norm = bb.xy; // 0–1 inside region

                // Convert to centered -1..1 space
                float2 p = norm * 2.0 - 1.0;

                // Optional per‑region random rotation
                if (_Randomize == 1)
                {
                    float a = Hash11(id) * 6.2831853;
                    float2x2 R = float2x2(cos(a), -sin(a), sin(a), cos(a));
                    p = mul(R, p);
                }

                // Evaluate shape
                float v = 0.0;

                if (_ShapeType == 0)
                    v = ShapeCircle(p);
                else if (_ShapeType == 1)
                    v = ShapeDiamond(p);
                else
                    v = ShapeSquare(p);

                // Soft edge
                v = Soft(v);

                return float4(v.xxx, 1);
            }

            ENDHLSL
        }
    }
}