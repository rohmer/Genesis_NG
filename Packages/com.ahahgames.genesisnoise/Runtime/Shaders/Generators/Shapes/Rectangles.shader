﻿Shader "Hidden/Genesis/Rectangles"
{	
	Properties
	{		
		[GenesisColor]_BackgroundColor ("Background Color", Color) = (0, 0, 0, 1)
        [GenesisColor]_BaseColor ("Base Color", Color) = (1, 0.5, 0.2, 1)
        _RectCount ("Rectangle Count", Int) = 20
        _MinSize ("Min Size", Float) = 0.05
        _MaxSize ("Max Size", Float) = 0.2
        _EdgeSoftness ("Edge Softness", Float) = 0.005
        _Seed ("Random Seed", Float) = 52.0
        [Enum(Disabled, 0, Enabled, 1)]_Rotation("Random Rotation",int)=1
     
    }

    SubShader
    {
    	Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			HLSLPROGRAM
			#define BUILTIN_TARGET_API					
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment

            float4 _BackgroundColor;
            float4 _BaseColor;
            int _RectCount;
            float _MinSize;
            float _MaxSize;
            float _EdgeSoftness;
            float _Seed;
            float _Rotation;
     
            float roundedRectSDF(float2 uv, float2 center, float2 size, float angle, float radius)
            {
                float2 local = uv - center;
                float s = sin(angle);
                float c = cos(angle);
                local = float2(c * local.x - s * local.y, s * local.x + c * local.y);

                float2 halfSize = size * 0.5;
                float2 d = abs(local) - halfSize;
                return length(max(d, 0.0)) - radius;
            }

            // Hash-based pseudo-random generator
            float hash(float2 p)
            {
                p = frac(p * 0.3183099 + _Seed);
                p *= 17.0;
                return frac(p.x * p.y * (p.x + p.y));
            }

            float2 rand2(float2 p)
            {
                return float2(hash(p), hash(p + 1.23));
            }
            
            float2 rotateUV(float2 uv, float2 center, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                uv -= center;
                float2 rotated = float2(
                    uv.x * c - uv.y * s,
                    uv.x * s + uv.y * c
                );
                return rotated + center;
            }

			float4 genesis(v2f_customrendertexture i)
			{	
                float2 uv = i.localTexcoord.xy;
                float4 result = _BackgroundColor;

                for (int idx = 0; idx < _RectCount; idx++)
                {
                    float fi = float(idx);
                    float2 seed = float2(fi, _Seed);
                    
                    float2 pos = rand2(seed); // random position
                    float2 size = lerp(_MinSize, _MaxSize, rand2(seed + 10.0)); // random size
                    float4 color = lerp(_BaseColor, float4(1,1,1,1), rand2(seed + 20.0).x); // color variation

                    float2 localUV=uv;
                    if(_Rotation==1)
                    {
                        float2 center=pos+size*0.5;
                        float angle = rand2(seed + 30.0).x * 6.2831853; // random angle [0, 2π]
                        localUV=rotateUV(uv,center,-angle);
                    }
                    float2 min = pos;
                    float2 max = pos + size;
                   
                    float2 edge = smoothstep(min, min + _EdgeSoftness, localUV) *
                        (1.0 - smoothstep(max - _EdgeSoftness, max, localUV));
                    float alpha = edge.x * edge.y;
                    result = lerp(result, color, alpha);
                }

                return result;


            }
            ENDHLSL
        }
    }
}
