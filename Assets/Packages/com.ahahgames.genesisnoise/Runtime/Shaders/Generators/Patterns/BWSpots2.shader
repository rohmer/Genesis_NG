Shader "Hidden/Genesis/BWSpots2"
{
    Properties
    {
        _Density("Spot Density", Range(0.0, 1.0)) = 0.7
        _Scale("Cell Scale", Range(2.0, 64.0)) = 18.0
        _ClusterScale("Cluster Scale", Range(1.0, 32.0)) = 6.0
        _Softness("Softness", Range(1.0, 8.0)) = 3.0
        _Contrast("Contrast", Range(0.5, 4.0)) = 1.6
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET_API
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            float _Density;
            float _Scale;
            float _ClusterScale;
            float _Softness;
            float _Contrast;

            // -------------------------------
            // Hash helpers
            // -------------------------------
            float hash11(float n)
            {
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7));
                return frac(sin(float2(n, n + 1.234)) * 43758.5453);
            }

            // -------------------------------
            // Spot falloff
            // -------------------------------
            float falloff(float d, float r, float s)
            {
                float x = saturate(1.0 - d / r);
                return pow(x, s);
            }

            // -------------------------------
            // BW Spots 2 core
            // -------------------------------
            float bwSpots2(float2 uv)
            {
                float2 p = uv * _Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);

                // Cluster noise
                float2 clusterP = uv * _ClusterScale;
                float2 clusterCell = floor(clusterP);
                float clusterMask = hash11(dot(clusterCell, float2(12.34, 56.78)));

                float result = 0.0;

                // 3×3 neighborhood
                [unroll]
                for (int y = -1; y <= 1; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 cell = ip + float2(x, y);

                        float2 rnd = hash21(cell);

                        // Cluster gating
                        if (rnd.x > _Density * (0.5 + clusterMask))
                            continue;

                        // Spot center
                        float2 center = rnd;

                        // Elliptical distortion
                        float2 dir = float2(rnd.y - 0.5, rnd.x - 0.5);
                        float2 fp2 = fp + float2(x, y) + dir * 0.25;

                        // Radius jitter
                        float radius = lerp(0.05, 0.55, hash11(dot(cell, float2(91.7, 12.3))));

                        // Softness jitter
                        float soft = lerp(_Softness * 0.7, _Softness * 1.3, rnd.y);

                        float d = distance(fp2, center);
                        float s = falloff(d, radius, soft);

                        result = max(result, s);
                    }
                }

                // Contrast shaping
                result = pow(result, _Contrast);

                return result;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float v = bwSpots2(uv);
                v=smoothstep(0.0,1.0,v);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}