Shader "Hidden/Genesis/Crystal1"
{
    Properties
    {
        _Scale("Scale", Float) = 8.0
        _Jitter("Jitter", Range(0,1)) = 0.75
        _Sharpness("Facet Sharpness", Range(0,4)) = 1.5
        _EdgeBoost("Edge Boost", Range(0,2)) = 0.0

        [Enum(None,0, CellID,1, Distance,2, Edges,3)]
        _Debug("Debug Mode", Float) = 0
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

            float _Scale;
            float _Jitter;
            float _Sharpness;
            float _EdgeBoost;
            float _Debug;

            // ------------------------------------------------------------
            // Hash functions (deterministic, Substance-like)
            // ------------------------------------------------------------
            float hash11(float n)
            {
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float n)
            {
                return float2(
                    hash11(n),
                    hash11(n + 19.19)
                );
            }

            float3 hash31(float n)
            {
                return float3(
                    hash11(n),
                    hash11(n + 19.19),
                    hash11(n + 47.77)
                );
            }

            // ------------------------------------------------------------
            // Voronoi Crystal 1 core
            // ------------------------------------------------------------
            float crystalNoise(float3 p, out float edgeMask, out float cellID)
            {
                p *= _Scale;

                float3 ip = floor(p);
                float3 fp = frac(p);

                float minDist = 9999.0;
                float secondDist = 9999.0;

                float bestID = 0.0;

                // Search 3x3x3 neighborhood
                [unroll]
                for (int xo = -1; xo <= 1; xo++)
                [unroll]
                for (int yo = -1; yo <= 1; yo++)
                [unroll]
                for (int zo = -1; zo <= 1; zo++)
                {
                    float3 cell = ip + float3(xo, yo, zo);
                    float id = cell.x + cell.y * 157 + cell.z * 113;

                    float3 rnd = hash31(id);
                    float3 jitter = (rnd - 0.5) * _Jitter;

                    float3 pos = cell + jitter;
                    float3 d = p - pos;

                    float dist = dot(d, d);

                    if (dist < minDist)
                    {
                        secondDist = minDist;
                        minDist = dist;
                        bestID = id;
                    }
                    else if (dist < secondDist)
                    {
                        secondDist = dist;
                    }
                }

                // Crystal 1 characteristic facet sharpening
                float f = pow(minDist, _Sharpness);

                // Edge mask (difference between nearest and second nearest)
                float edge = saturate((secondDist - minDist) * 4.0);
                edgeMask = pow(edge, _EdgeBoost);

                cellID = frac(bestID * 0.001);

                return f;
            }

            // ------------------------------------------------------------
            // CRT entry point
            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float edgeMask;
                float cellID;

                float n = crystalNoise(uv, edgeMask, cellID);

                // Debug modes
                if (_Debug == 1) return float4(cellID, 0, 0, 1);
                if (_Debug == 2) return float4(n, n, n, 1);
                if (_Debug == 3) return float4(edgeMask, edgeMask, edgeMask, 1);

                // Final Crystal 1 output
                float3 col = n.xxx + edgeMask.xxx;

                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}