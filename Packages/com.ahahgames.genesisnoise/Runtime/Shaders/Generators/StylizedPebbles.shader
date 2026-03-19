Shader "Hidden/Genesis/StylizedPebbles"
{
    Properties
    {
         _PebbleScale ("Pebble Cell Scale", Range(1, 50)) = 10
        _PebbleRound ("Pebble Roundness", Range(0.1, 1)) = 0.8
        _Color1 ("Base Color A", Color) = (0.55, 0.5, 0.45, 1)
        _Color2 ("Base Color B", Color) = (0.4, 0.35, 0.3, 1)
        _EdgeDarken ("Edge Darken", Range(0, 1)) = 0.3
        _LightDir ("Light Direction", Vector) = (0.3, 0.6, 0.7, 0)
        _BumpStrength ("Bump Strength", Range(0, 1)) = 0.3
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            // Feature keywords            
            #pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV

            float _PebbleScale;
            float _PebbleRound;
            float4 _Color1, _Color2;
            float _EdgeDarken;
            float4 _LightDir;
            float _BumpStrength;

            // Hash & noise helpers
            float2 hash2(float2 p)
            {
                p = float2(dot(p, float2(127.1, 311.7)),
                           dot(p, float2(269.5, 183.3)));
                return frac(sin(p) * 43758.5453);
            }
              
            // Worley/Voronoi cell lookup
            void voronoi(float2 uv, out float minDist, out float2 cellId, out float2 cellCenter)
            {
                float2 gv = floor(uv);
                float2 lv = frac(uv);
                minDist = 8.0;
                cellId = 0;
                cellCenter = 0;

                [loop]
                for (int j = -1; j <= 1; j++)
                {
                    for (int i = -1; i <= 1; i++)
                    {
                        float2 neighbor = float2(i, j);
                        float2 pt = hash2(gv + neighbor);
                        pt = _PebbleRound * 0.5 + (1.0 - _PebbleRound) * pt; // make more round

                        float2 diff = neighbor + pt - lv;
                        float dist = length(diff);
                        if (dist < minDist)
                        {
                            minDist = dist;
                            cellId = gv + neighbor;
                            cellCenter = pt;
                        }
                    }
                }
            }

            float3 pebbleNormal(float2 uv, float dist)
            {
                // Fake bump by distance gradient
                float h = smoothstep(0.5, 0.0, dist);
                float grad = 0.01;
                float dX = smoothstep(0.5, 0.0, dist + grad) - h;
                float dY = smoothstep(0.5, 0.0, dist + grad) - h;
                float3 n = normalize(float3(dX, _BumpStrength, dY));
                return n;
            }

            float4 mixture (v2f_customrendertexture i)
            {      
                float2 uv = i.localTexcoord.xy * _PebbleScale;
                float minDist;
                float2 cellId, cellCenter;
                voronoi(uv, minDist, cellId, cellCenter);

                // Pebble mask
                float pebble = smoothstep(0.5, 0.48, minDist);

                // Color variation per cell
                float rand = frac(sin(dot(cellId, float2(17.1, 91.7))) * 43758.5453);
                float3 baseCol = lerp(_Color1.rgb, _Color2.rgb, rand);

                // Darken towards edges for depth
                float edgeShade = lerp(1.0, 1.0 - _EdgeDarken, smoothstep(0.4, 0.5, minDist));

                // Lighting
                float3 n = normalize(float3(0, 1, 0)); // flat base
                if (_BumpStrength > 0.0)
                {
                    // approximate normal from pebble shape
                    float h = smoothstep(0.5, 0.0, minDist);
                    float3 pert = normalize(float3(cellCenter.x - 0.5, _BumpStrength, cellCenter.y - 0.5));
                    n = normalize(lerp(n, pert, pebble));
                }
                float3 L = normalize(_LightDir.xyz);
                float diff = saturate(dot(n, L));

                float3 col = baseCol * edgeShade;
                col *= lerp(1.0, diff, _BumpStrength);

                return float4(col, 1);

            }
            ENDHLSL
        }
    }
}
