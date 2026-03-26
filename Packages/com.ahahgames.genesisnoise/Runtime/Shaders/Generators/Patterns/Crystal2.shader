Shader "Hidden/Genesis/Crystal2"
{
    Properties
    {
        _Scale("Scale", Float) = 8.0
        _Jitter("Jitter", Range(0,1)) = 0.75
        _Sharpness("Facet Sharpness", Range(0,4)) = 1.5
        _EdgeBoost("Edge Boost", Range(0,2)) = 0.0

        [Enum(None,0, F1,1, F2,2, F3,3, Facet,4, Edges,5)]
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
            // Deterministic hash functions
            // ------------------------------------------------------------
            float hash11(float n)
            {
                return frac(sin(n * 127.1) * 43758.5453);
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
            // Crystal 2 core: F1, F2, F3 Worley distances
            // ------------------------------------------------------------
            void crystal2(float3 p, out float f1, out float f2, out float f3)
            {
                p *= _Scale;

                float3 ip = floor(p);
                float3 fp = frac(p);

                f1 = 9999.0;
                f2 = 9999.0;
                f3 = 9999.0;

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

                    // Track F1, F2, F3
                    if (dist < f1)
                    {
                        f3 = f2;
                        f2 = f1;
                        f1 = dist;
                    }
                    else if (dist < f2)
                    {
                        f3 = f2;
                        f2 = dist;
                    }
                    else if (dist < f3)
                    {
                        f3 = dist;
                    }
                }
            }

            // ------------------------------------------------------------
            // CRT entry point
            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float f1, f2, f3;
                crystal2(uv, f1, f2, f3);

                // Normalize distances
                f1 = pow(f1, _Sharpness);
                f2 = pow(f2, _Sharpness);
                f3 = pow(f3, _Sharpness);

                // Crystal 2 characteristic facet intensity
                float facet = saturate((f3 - f1) * 2.0);

                // Edge mask
                float edge = saturate((f2 - f1) * 4.0);
                edge = pow(edge, _EdgeBoost);

                // Debug modes
                if (_Debug == 1) return float4(f1, f1, f1, 1);
                if (_Debug == 2) return float4(f2, f2, f2, 1);
                if (_Debug == 3) return float4(f3, f3, f3, 1);
                if (_Debug == 4) return float4(facet, facet, facet, 1);
                if (_Debug == 5) return float4(edge, edge, edge, 1);

                // Final Crystal 2 output
                float3 col = facet.xxx + edge.xxx;

                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}