﻿Shader "Hidden/Genesis/Torus"
{	
	Properties
	{	
		[Tooltip(Number of toruses to create)] _numTorus("# of Toruses",Range(1,200))=5
		[Tooltip(Randomize rotation)][Enum(Disabled, 0, Enabled, 1)]  _rotation("Enable Rotation",int)=1
		[Tooltip(Randomize color)][Enum(Disabled, 0, Enabled, 1)]  _randColor("Enable Random Color",int)=1		
		[VisibleIf(_randColor,1)] [GenesisColor][Tooltip(Starting random color)] _startColor("Start Color", Color)=(0.2,0.0,0.0,1)
		[VisibleIf(_randColor,1)] [GenesisColor][Tooltip(End random color)] _endColor("End Color", Color)=(0.9,0.0,0.9,1)

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
            #pragma vertex CustomRenderTextureVertexShader
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			
			float _numTorus;
			int _rotation, _randColor;
			float3 _startColor, _endColor;

			// === Utility ===
            float3 rotateVector(float3 p, float3 axis, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                float oc = 1.0 - c;

                float3x3 rot = float3x3(
                    oc * axis.x * axis.x + c,         oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s,
                    oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c,         oc * axis.y * axis.z - axis.x * s,
                    oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c
                );

                return mul(rot, p);
            }
            float hash(float n) {
                return frac(sin(n) * 43758.5453);
            }

            float3 hash3(float n) {
                return float3(hash(n), hash(n + 1.0), hash(n + 2.0));
            }

            float sdTorus(float3 p, float2 t)
            {
                float2 q = float2(length(p.xz) - t.x, p.y);
                return length(q) - t.y;
            }

            struct HitInfo {
                float dist;
                float3 color;
            };
            float rand(float2 seed)
            {
                // Dot with large prime numbers to scramble the seed
                float dotVal = dot(seed, float2(12.9898, 78.233));
    
                // Apply sine and fract to get a pseudo-random value
                return frac(sin(dotVal) * 43758.5453);
            }

            HitInfo map(float3 p)
            {
                HitInfo hit;
                hit.dist = 1e5;
                hit.color = float3(0,0,0);  
                
                for (int i = 0; i < _numTorus; i++)
                {
                    //float seed = i * 13.37;
                    float3 _color;
                    
                    float seed=i*13.37;
                    float3 rnd = hash3(seed);
                    float3 pos = rnd * 20.0 - 10.0;
                    if(_randColor==1)
                    {
                        float r=rand(pos.xy);
                        _color=lerp(_startColor,_endColor,r);                        
                    }
                    float2 radii = float2(0.5 + rnd.x, 0.2 + rnd.y * 0.3);

                    float angle = rnd.z * 6.28; // random rotation angle
                    float3 axis = normalize(hash3(seed + 1.0)); // random rotation axis

                    float3 localP = p - pos;
                    localP = rotateVector(localP, axis, angle); // rotate into torus space

                    float d = sdTorus(localP, radii);
                    if (d < hit.dist)
                    {
                        hit.dist = d;
                        if(_randColor==0)
                        {
                            hit.color = rnd * 0.8 + 0.2;
                        } else
                        {
                            hit.color=rnd*_color;
                        }
                    }
                }
                return hit;
            }

            float3 getNormal(float3 p)
            {
                float eps = 0.001;
                float3 e = float3(eps, 0, 0);
                return normalize(float3(
                    map(p + e.xyy).dist - map(p - e.xyy).dist,
                    map(p + e.yxy).dist - map(p - e.yxy).dist,
                    map(p + e.yyx).dist - map(p - e.yyx).dist
                ));
            }


            float4 genesis(v2f_customrendertexture i)
            {
               float2 uv = i.localTexcoord;
               float3 ro = float3(0, 0, -10);
               float3 rd = normalize(float3(uv, 1));

               float t = 0.0;
               float3 col = float3(0,0,0);

               for (int j = 0; j < 128; j++)
               {
                    float3 p = ro + rd * t;
                    HitInfo hit = map(p);
                    if (hit.dist < 0.001)
                    {
                        float3 normal = getNormal(p);
                        float3 lightDir = normalize(float3(0.5, 0.8, -0.6));
                        float diff = max(dot(normal, lightDir), 0.0);
                        col = hit.color * diff;
                        break;
                    }
                    t += hit.dist;
                    if (t > 100.0) break;
               }



                return float4(col, 1.0);
            }

			ENDHLSL
		}
	}
}