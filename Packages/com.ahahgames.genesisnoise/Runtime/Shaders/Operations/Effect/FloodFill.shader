Shader "Hidden/Genesis/FloodFill"
{
    Properties
    {
        // Input mask (white = region, black = background)
        [InlineTexture]_Source_2D("Source", 2D) = "black" {}
        [InlineTexture]_Source_3D("Source", 3D) = "black" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "black" {}

        _Steps("Steps", Range(1, 8)) = 4
        _Threshold("Threshold", Range(0, 1)) = 0.5
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

            float _Steps;
            float _Threshold;

            // ------------------------------------------------------------
            float SampleMask(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).r;
            }

            // Hash to generate stable region IDs
            float Hash21(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return frac(p.x * p.y);
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float mask = SampleMask(uv, i.direction);

                // Background → no region
                if (mask <= _Threshold)
                    return float4(0, 0, 0, 1);

                // Seed ID = hash of pixel position
                float id = Hash21(uv * 4096.0);

                // Jump Flood iterations
                int steps = (int)_Steps;

                for (int s = 0; s < steps; s++)
                {
                    float jump = pow(2.0, (float)(steps - 1 - s));

                    float bestID = id;

                    // Check 8 neighbors at jump distance
                    for (int oy = -1; oy <= 1; oy++)
                    for (int ox = -1; ox <= 1; ox++)
                    {
                        if (ox == 0 && oy == 0) continue;

                        float3 suv = uv + float3(ox, oy,0) * texel * jump;

                        float m = SampleMask(suv, i.direction);
                        if (m <= _Threshold)
                            continue;

                        float nid = Hash21(suv * 4096.0);

                        // Pick the smallest hash = stable region ID
                        if (nid < bestID)
                            bestID = nid;
                    }

                    id = bestID;
                }
                  
                return float4(id.xxx, 1);
            }

            ENDHLSL
        }
    }
}