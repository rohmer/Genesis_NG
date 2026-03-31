Shader "Hidden/Genesis/ArcPavement"
{
	Properties
	{
		_Mask_2D("Mask", 2D) = "white" {}
		_Mask_3D("Mask", 3D) = "white" {}
		_Mask_Cube("Mask", Cube) = "white" {}

		[Tooltip(Enable mask texture)]
		[Enum(Disabled, 0, Enabled, 1)] _UseMask("Use Mask", int) = 0

		[Tooltip(Global tiling)] _Scale("Scale", Range(0.1, 10.0)) = 1.0

		[Tooltip(Number of concentric arcs)] _ArcsAmount("Arcs Amount", Range(1, 64)) = 12
		[Tooltip(Base bricks per arc)] _PatternAmount("Pattern Amount", Range(1, 128)) = 24
		[Tooltip(Randomization of bricks per arc)] _PatternAmountRandom("Pattern Amount Random", Range(0, 1)) = 0.5
		[Tooltip(Minimum bricks per arc)] _PatternMinAmount("Pattern Min Amount", Range(1, 128)) = 8

		[Tooltip(Angular brick size)] _PatternWidth("Pattern Width", Range(0, 1)) = 0.8
		[Tooltip(Radial brick size)] _PatternHeight("Pattern Height", Range(0, 1)) = 0.8
		[Tooltip(Per brick width random)] _PatternWidthRandom("Pattern Width Random", Range(0, 1)) = 0.3
		[Tooltip(Per brick height random)] _PatternHeightRandom("Pattern Height Random", Range(0, 1)) = 0.3
		[Tooltip(Global width random per arc)] _GlobalPatternWidthRandom("Global Width Random", Range(0, 1)) = 0.2

		[Tooltip(Height decrease at arc ends)] _PatternHeightDecrease("Pattern Height Decrease", Range(0, 1)) = 0.5
		[Tooltip(Per brick color variation)] _ColorRandom("Color Random", Range(0, 1)) = 0.4

		[Tooltip(Non square compensation (x,y))] [GenesisVector2]_NonSquare("Non-Square Ratio", Vector) = (1, 1, 0, 0)

		[Tooltip(Height intensity of pattern)] _Intensity("Intensity", Range(0, 1)) = 1.0
		[Tooltip(Base color of arcs)] [GenesisColor]_ArcColor("Arc Color", Color) = (0.7, 0.7, 0.7, 1)

		[Tooltip(Randomization seed)] _Seed("Seed", int) = 52
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

			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma vertex   CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment

			// ---------------------------------------------------------------------
			// Properties (Unity will bind these)
			float  _Scale;
			float  _ArcsAmount;
			float  _PatternAmount;
			float  _PatternAmountRandom;
			float  _PatternMinAmount;

			float  _PatternWidth;
			float  _PatternHeight;
			float  _PatternWidthRandom;
			float  _PatternHeightRandom;
			float  _GlobalPatternWidthRandom;

			float  _PatternHeightDecrease;
			float  _ColorRandom;

			float2 _NonSquare;

			float  _Intensity;
			float4 _ArcColor;

			float  _Seed;
			int    _UseMask;

			SAMPLER_X(_Mask);

			// ---------------------------------------------------------------------
			// Hash helpers (deterministic, seed-aware)
			float Hash11(float x)
			{
				x += _Seed * 17.0;
				x = frac(x * 0.1031);
				x *= x + 33.33;
				x *= x + x;
				return frac(x);
			}

			float2 Hash21(float x)
			{
				float2 p = float2(x, x + 17.0 + _Seed);
				p = frac(p * 0.1031);
				p += dot(p, p.yx + 33.33);
				return frac(float2(p.x * p.y, p.x + p.y));
			}

			struct ArcPavementResult
			{
				float  height;
				float3 color;
			};

			ArcPavementResult ArcPavement(float2 uv)
			{
				ArcPavementResult o;
				o.height = 0.0;
				o.color  = 0.0.xxx;

				// Centered UV, global scale, non-square
				float2 p = (uv - 0.5) * _Scale;
				p *= _NonSquare;

				float r = length(p);
				float a = atan2(p.y, p.x);          // [-PI, PI]
				const float twoPi = 6.28318530718;
				a = (a + twoPi) * (1.0 / twoPi);    // [0,1]

				// Arc index
				float arcsF = max(_ArcsAmount, 1.0);
				float arcIdxF = r * arcsF;
				int   arcIdx  = (int)floor(arcIdxF);

				if (arcIdx < 0 || arcIdx >= (int)arcsF)
					return o;

				// Per-arc random
				float arcSeed = arcIdx * 13.37;
				float arcRand = Hash11(arcSeed);

				// Bricks per arc
				float bricksF = _PatternAmount +
					(arcRand * 2.0 - 1.0) * _PatternAmountRandom * _PatternAmount;
				bricksF = max(bricksF, _PatternMinAmount);
				int bricks = max(1, (int)round(bricksF));

				// Angle → brick index
				float brickIdxF = a * bricks;
				int   brickIdx  = (int)floor(brickIdxF);

				// Per-brick randoms
				float brickSeed = arcSeed + brickIdx * 57.0;
				float2 brickRand2 = Hash21(brickSeed);
				float brickRandW  = brickRand2.x;
				float brickRandH  = brickRand2.y;

				// Base sizes
				float baseAngularSize = 1.0 / bricks;
				float baseRadialSize  = 1.0 / arcsF;

				float localWidth  = _PatternWidth  * baseAngularSize;
				float localHeight = _PatternHeight * baseRadialSize;

				// Width random
				float wVar  = 1.0 + (brickRandW * 2.0 - 1.0) * _PatternWidthRandom;
				float gwVar = 1.0 + (arcRand    * 2.0 - 1.0) * _GlobalPatternWidthRandom;
				localWidth *= wVar * gwVar;

				// Height random
				float hVar = 1.0 + (brickRandH * 2.0 - 1.0) * _PatternHeightRandom;
				localHeight *= hVar;

				// Local coords in arc/brick cell
				float arcLocal   = frac(arcIdxF);
				float brickLocal = frac(brickIdxF);

				float2 cell   = float2(brickLocal, arcLocal);
				float2 center = 0.5.xx;
				float2 d      = abs(cell - center);

				// Apply width/height scaling
				d.x /= max(localWidth  * 0.5, 1e-4);
				d.y /= max(localHeight * 0.5, 1e-4);

				// Box-like brick
				float shape = max(d.x, d.y);

				// Height falloff near arc ends
				float edgeFalloff = 1.0 - _PatternHeightDecrease *
					smoothstep(0.4, 0.5, abs(brickLocal - 0.5) * 2.0);

				float brickMask = saturate(1.0 - shape);
				brickMask *= edgeFalloff;

				o.height = brickMask;

				// Per-brick color variation
				float3 baseColor = _ArcColor.rgb;
				float3 randColor = float3(
					Hash11(brickSeed + 1.0),
					Hash11(brickSeed + 2.0),
					Hash11(brickSeed + 3.0)
				);
				o.color = baseColor + (randColor - 0.5.xxx) * _ColorRandom;

				return o;
			}

			// ---------------------------------------------------------------------
			float4 genesis(v2f_customrendertexture i) : SV_Target
			{
				float3 uv  = i.localTexcoord;
				float3 dir = i.direction;

				ArcPavementResult res = ArcPavement(uv.xy);

				float mask = res.height;

				if (_UseMask != 0)
				{
					mask *= SAMPLE_X(_Mask, uv, dir).r;
				}

				float3 col = res.color * (mask * _Intensity);

				// Height-style output (good for feeding HeightToNormal etc.)
				// If you want pure height, you can also just use mask in R.
				return float4(col, 1.0);
			}

			ENDHLSL 
		}
	}
}