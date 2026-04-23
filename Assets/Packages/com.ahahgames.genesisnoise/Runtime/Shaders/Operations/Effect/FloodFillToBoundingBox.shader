Shader "Hidden/Genesis/FloodFillToBoundingBox"
{
    Properties
    {
        // Region ID map from Flood Fill
        [InlineTexture]_RegionID_2D("Region ID", 2D) = "black" {}
        [InlineTexture]_RegionID_3D("Region ID", 3D) = "black" {}
        [InlineTexture]_RegionID_Cube("Region ID", Cube) = "black" {}

        _Steps("Steps", Range(1, 8)) = 4
        _Threshold("Threshold", Range(0, 1)) = 0.0001
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

            float _Steps;
            float _Threshold;

            // ------------------------------------------------------------
            float SampleRegionID(float3 uv, float3 dir)
            {
                return SAMPLE_X(_RegionID, uv, dir).r;
            }

            // Hash helpers
            float Hash11(float x)
            {
                x = frac(x * 0.1031);
                x *= x + 33.33;
                x *= x + x;
                return frac(x);
            }

            float2 Hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7));
                return frac(sin(float2(n, n + 1.0)) * 43758.5453);
            }

            // ------------------------------------------------------------
            // Estimate bounding box using jump-flood style propagation
            // Each region accumulates min/max UVs via hashed seeds
            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01); 

                float id = SampleRegionID(uv, i.direction);

                // Background → no region
                if (id <= _Threshold)
                    return float4(0, 0, 0, 1);

                // Initial bounding box seed from hashed UV
                float2 seedMin = Hash21(uv * 4096.0);
                float2 seedMax = seedMin;

                int steps = (int)_Steps;

                // Jump Flood iterations
                for (int s = 0; s < steps; s++)
                {
                    float jump = pow(2.0, (float)(steps - 1 - s));

                    float2 bbMin = seedMin;
                    float2 bbMax = seedMax;

                    for (int oy = -1; oy <= 1; oy++)
                    for (int ox = -1; ox <= 1; ox++)
                    {
                        float3 suv = uv + float3(ox, oy,0) * texel * jump;

                        float nid = SampleRegionID(suv, i.direction);
                        if (abs(nid - id) > _Threshold)
                            continue;

                        float2 h = Hash21(suv * 4096.0);

                        bbMin = min(bbMin, h);
                        bbMax = max(bbMax, h);
                    }

                    seedMin = bbMin;
                    seedMax = bbMax;
                }

                // Normalize current pixel inside bounding box
                float2 hSelf = Hash21(uv * 4096.0);

                float2 boxSize = max(seedMax - seedMin, float2(1e-5, 1e-5));
                float2 norm = saturate((hSelf - seedMin) / boxSize);

                // Optional: encode region size in B
                float sizeVal = max(boxSize.x, boxSize.y);

                return float4(norm, sizeVal, 1);
            }

            ENDHLSL
        }
    }
}