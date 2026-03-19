﻿Shader "Hidden/Genesis/Scratches"
{	
	Properties
	{		
		_Mask_2D("Mask", 2D) = "white" {}
		_Mask_3D("Mask", 3D) = "white" {}
		_Mask_Cube("Mask", Cube) = "white" {}

		[Tooltip(Enable scratch mask texture)]
		[Enum(Disabled, 0, Enabled, 1)] _UseMask("Use Mask", int) = 1

		[Tooltip(Density of scraches, over 0..2 is recommended)]_Density("Density", Range(0.0, 100.0)) = 15
		[Tooltip(The angle in radians of the scratches)] _Angle("Angle", Range(0, 6.283)) = 0.0

		//TODO: Figure out the defaults
		[Tooltip(Minimum thickness. Hairline to gouge (In UV units after scaling))] _MinThickness("Min Thickness", Range(0, 1)) = 0.01
		[Tooltip(Maximum thickness. Hairline to gouge (In UV units after scaling))] _MaxThickness("Max Thickness", Range(0, 1)) = 0.1
		[Tooltip(Minimum length of a scratch)] _MinLength("Min Length", Range(0, 1)) = 0.1
		[Tooltip(Maximum length of a scratch)] _MaxLength("Max Length", Range(0, 1)) = 0.5
		
		[Tooltip(Curvature mode of the scratches.  None makes straight scratches)]
		[Enum(Straight,0,Parabolic,1,Radial,2)] _CurvatureMode("Curvature Mode", int) = 0
		[VisibleIf(_CurvatureMode,1)] [Tooltip(Parabolic curvature factor)] _ParabolicFactor("Parabolic Factor", Range(0, 1)) = 0.100
		[VisibleIf(_CurvatureMode,2)] [Tooltip(Radial curvature scale, defines how many arcs)] _RadialScale("Radial Scale", Range(0, 5)) = 0.100
		[VisibleIf(_CurvatureMode,2)] [Tooltip(UV Center of the arcs)] [GenesisVector2]_RadialCenter("Radial Center", Vector)= (0.5, 0.5, 0, 0)

		// Dashing
		[Tooltip(Units along line direction, UV units)] _DashLength("Dash Length", Range(0, 1)) = 0.100
		[Tooltip(Gap size, UV units)] _DashGap("Gap Size", Range(0, 1)) = 0.050
		[Tooltip(Sets the softness of the edge)] _DashSoftness("Dash Softness", Range(0, 0.5)) = 0.05
		[Tooltip(Per stripe random phase jitter)] _DashJitter("Dash jitter", Range(0, 1)) = 0.075

		// Look
		[Tooltip(Defines the mixture intensity)] _Intensity("Intensity", Range(0, 1)) = 0.5
		[Tooltip(The color of the scratches)] [GenesisColor]_scratchColor("Color", Color) = (0.7, 0.7, 0.7, 1)

		[Tooltip(Randomization seed)] _Seed("Seed", int)=52
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
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/ValueNoise.hlsl"
			
			#pragma vertex CustomRenderTextureVertexShader
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment


			// Variables
			float _Density,_Direction,_DirectionDeviation,_MinThickness,_MaxThickness,_MinLength,_MaxLength;
			float _CurvatureMode,_ParabolicFactor,_RadialScale;
			float2 _RadialCenter;
			float _DashLength,_DashGap,_DashSoftness,_DashJitter;
			float _Intensity, _seed;
			float4 _Color;
			float _Seed;
			float _Angle;			
			SAMPLER_X(_Mask);
			int _UseMask;
			float4 _scratchColor;
			
			//------------------------------------------------------------------------------
			// Utils
			float2 rotate2D(float2 p, float a)
			{
				float s = sin(a), c = cos(a);
				return float2(c*p.x - s*p.y, s*p.x + c*p.y);
			}

			float hash11(float n)
			{
				return frac(sin(n*12.9898 + 78.233 + _Seed) * 43758.5453);
			}

			float softPulse(float x, float lo, float hi, float s)
			{
				float a = smoothstep(lo - s, lo + s, x);
				float b = 1.0 - smoothstep(hi - s, hi + s, x);
				return saturate(a * b);
			}

			// Periodic lines across coordinate s
			float lineField(float s, float density, float width)
			{
				float u = frac(s * density);
				float d = abs(u - 0.5);
				float aa = fwidth(s * density);
				return saturate((width - d) / max(aa, 1e-4));
			}

			// Dashing along t with soft edges
			float dashField(float t, float dashLength, float dashGap, float softness, float anim)
			{
				float period = max(dashLength + dashGap, 1e-4);
				float duty   = saturate(dashLength / period);
				float x      = frac(t / period + anim);

				float aa = fwidth(t / period);
				float s  = max(aa, softness * 0.5);

				return softPulse(x, 0.0, duty, s);
			}

			// Curved coordinates for stripes: returns s (across) and t (along)
			void curvedCoords(float3 uv, out float s, out float t)
			{
				float2 p = uv - 0.5;
				p = rotate2D(p, _Angle);

				if (_CurvatureMode == 1)
				{
					// Parabolic bend: x += k*y^2
					float bend = _ParabolicFactor * (p.y * p.y);
					s = p.x + bend;
					t = p.y;
				}
				else if (_CurvatureMode == 2)
				{
					// Radial arcs: stripes at constant angle
					float2 q = uv - _RadialCenter;
					float r  = length(q) + 1e-6;
					float th = atan2(q.y, q.x);
					s = th * _RadialScale;   // across
					t = r;                  // along (outward)
				}
				else
				{
					s = p.x;
					t = p.y;
				}
			}

			float randBetween(float2 seed, float minVal, float maxVal)
			{
				float h = dot(seed, float2(12.9898, 78.233));
				float n = frac(sin(h) * 43758.5453); // Generates a pseudo-random value in [0,1)
				return lerp(minVal, maxVal, n);
			}

			float4 mixture (v2f_customrendertexture i) : SV_Target
			{	
				float3 uv=i.localTexcoord;
				float3 dir=i.direction;
				float4 baseColor=float4(0,0,0,1);
				
				// Curved coordinates
				float s, t;
				curvedCoords(uv, s, t);

				// Per-stripe jitter
				float stripeId = floor(s * _Density);
				float jitter   = (hash11(stripeId + 13.37) - 0.5) * 2.0 * _DashJitter;

				// Build geometry
				float lineWidth=randBetween(float2(i.localTexcoord.xy), _MinThickness, _MaxThickness);
				float stripes = lineField(s, _Density, lineWidth);
				float anim    = jitter;
				float dashes  = dashField(t, _DashLength, _DashGap, _DashSoftness, anim);
				
				float geomMask = stripes * dashes;

				float scratchMask;
				if(_UseMask)
				{										
					scratchMask=saturate(geomMask*SAMPLE_X(_Mask, uv, dir).r);
				} else
				{
					scratchMask=saturate(geomMask); // No mask, use full strength
				}
				// Blend: add colored scratch contribution scaled by intensity
				float3 result = baseColor.rgb + scratchMask * _scratchColor * _Intensity;



				return float4(result,baseColor.a);
			}
			ENDHLSL
		}
	}
}