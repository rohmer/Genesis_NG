﻿Shader "Hidden/Genesis/RandomNGon"
{	
	Properties
	{	
		_PolygonCount ("Polygon Count", Int) = 10
        _MinSides ("Min Sides", Int) = 3
        _MaxSides ("Max Sides", Int) = 8
        _MinSize ("Min Size", Float) = 0.05
        _MaxSize ("Max Size", Float) = 0.2
        _EdgeSoftness ("Edge Softness", Float) = 0.01
		[GenesisColor]_BaseColor ("Base Color", Color) = (1, 0.5, 0.2, 1)
		[GenesisColor]_ColorRange ("Color Variation", Color) = (0.5, 0.5, 0.5, 0)
		_Seed("Seed", int)=52
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
			
			int _PolygonCount, _MinSides, _MaxSides;
			float _MinSize, _MaxSize, _EdgeSoftness;
			float4 _BaseColor;
			float4 _ColorRange;
			int _Seed;

			float hash(float2 p)
            {
                p = frac(p * 0.3183099 + _Seed);
                p *= 17.0;
                return frac(p.x * p.y * (p.x + p.y));
            }

			float2 hash21(float seed)
			{
				float2 p = float2(seed, seed * 1.3);
				return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
			}

			float3 getPolygonColor(float seed)
			{
				float2 r1 = hash21(seed + 5.0);
				float2 r2 = hash21(seed + 10.0);
				float3 randRGB = float3(r1.x, r1.y, r2.x);
				return saturate(_BaseColor + randRGB * _ColorRange);
			}

			float polygonSDF(float2 uv, float2 center, float size, float angle, int sides)
			{
				float2 local = uv - center;
				float s = sin(angle);
				float c = cos(angle);
				local = float2(c * local.x - s * local.y, s * local.x + c * local.y);

				float a = atan2(local.y, local.x);
				float r = length(local);

				float sector = 2.0 * 3.141592 / sides;
				float d = cos(floor(0.5 + a / sector) * sector - a) * r;

				return d - size;
			}

			float2 rand2(float2 seed)
			{
				seed = frac(seed * float2(0.3183099, 0.3678794)); // π⁻¹ and e⁻¹
				seed += dot(seed, seed.yx + 19.19);
				return frac(float2(
					sin(seed.x * 12.9898 + seed.y * 78.233) * 43758.5453,
					sin(seed.x * 93.9898 + seed.y * 67.345) * 24634.6345
				));
			}

			float4 mixture (v2f_customrendertexture i) : SV_Target
			{	
				float2 uv = i.localTexcoord;
				float4 result = float4(0, 0, 0, 1);

				for (int idx = 0; idx < _PolygonCount; idx++)
				{
					float seed = idx;
					float2 s=float2(idx,_Seed);
					float2 rand = rand2(s);
					float2 center = rand * 0.8 + 0.1;

					float size = lerp(_MinSize, _MaxSize, frac(sin(seed * 1.7) * 1000.0));
					float angle = frac(sin(seed * 2.3) * 1000.0) * 6.2831;
					int sides = (int)lerp(_MinSides, _MaxSides + 0.999, frac(sin(seed * 3.1) * 1000.0));

					float dist = polygonSDF(uv, center, size, angle, sides);
					float alpha = smoothstep(_EdgeSoftness, 0.0, dist);

					float4 polyColor = float4(getPolygonColor(seed), alpha);
					result.rgb = lerp(result.rgb, polyColor.rgb, alpha);
				}

				return float4(result.rgb, 1.0);
			}
			ENDHLSL
		}
	}
}