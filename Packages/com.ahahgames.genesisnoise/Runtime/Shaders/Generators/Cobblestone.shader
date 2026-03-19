Shader "Hidden/Genesis/Cobblestone"
{
    Properties
    {
       
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
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/FastNoiseLite.hlsl"

            // Feature keywords   
            #pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV

            // Properties
            
            // Functions
            float hash21(float2 p) {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 34.45);
                return frac(p.x * p.y);
            }
		    
            float voronoi(float2 uv, out float2 cellUV, out float cellID) {
                float d = 1.0;
                cellID = 0.0;
                float2 gv = floor(uv);
                float2 lv = frac(uv);
                for (int y = -1; y <= 1; y++) {
                    for (int x = -1; x <= 1; x++) {
                        float2 cell = float2(x, y);
                        float2 cellPos = gv + cell;
                        float2 rand = float2(hash21(cellPos), hash21(cellPos + 1.0));
                        float2 diff = cell + rand - lv;
                        float dist = length(diff);
                        if (dist < d) {
                            d = dist;
                            cellUV = cellPos;
                            cellID = hash21(cellPos);
                        }
                    }
                }
                return d;
            }


            
            float4 mixture (v2f_customrendertexture i)
            { 
                float2 cellUV;
                float cellID;
                float2 worldUV = i.localTexcoord * 10.0; // Tiling factor
                float d = voronoi(worldUV, cellUV, cellID);

                // Height profile: rounded cobblestones
                float height = smoothstep(0.0, 0.5, 0.5 - d);

                // Edge wear: darken near borders
                float edge = smoothstep(0.0, 0.1, d);

                // Color palette
                float3 baseColor = lerp(float3(0.3, 0.25, 0.2), float3(0.5, 0.45, 0.4), frac(cellID));
                float3 finalColor = baseColor * height * (1.0 - edge * 0.5);

                return float4(finalColor, 1.0);


            }
            ENDHLSL
        }
    }
}