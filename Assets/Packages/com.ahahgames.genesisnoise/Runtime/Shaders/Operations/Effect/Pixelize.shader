Shader "Hidden/Genesis/Pixelize"
{	
	Properties
	{
		// By default a shader node is supposed to handle all the input texture dimension, we use a prefix to determine which one is used
		[Tooltip(Source Texture)][InlineTexture]_Source_2D("Source", 2D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_3D("Source", 3D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_Cube("Source", Cube) = "white" {}
		[Tooltip(Simulated resolution width)]_ResX("Resolution X", Range(4,1024)) = 320
		[Tooltip(Simulated resolution height)]_ResY("Resolution Y", Range(4,1024)) = 240
		[Tooltip(Scan line intensity)]_ScanIntensity("Scan Intensity", Range(0.0,1.0))=0.25
		[Tooltip(Vignette intensity)]_VIntense("Vignette Intensity", Range(0.0,1.0))=0.25
		[Tooltip(Use barrel warping)][Enum(No,0,Yes,1)]_UseBarrelWarp("Barrel Warp",int)=1
		[Tooltip(Use chromatic intesity)][Enum(No,0,Yes,1)]_UseChroma("Chromatic Intensity",int)=1
		[Tooltip(Barrel warping intensity)]
		[VisibleIf(_UseBarrelWarp,1)]
		[GenesisVector2]_BarrelWarp("Barrel Warp", Vector)=(0.2,0.1,0.0)
		[Tooltip(Use subpixel bleeding effect)][Enum(No,0,Yes,1)]_UseBleed("Sub-pixel Bleed",int)=1

		[Tooltip(Chroma intesity)]
		[VisibleIf(_UseChroma,1)]
		_ChromaIntense("Chroma Intensity",Range(0.0,8.0))=2.		
		
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
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/PerlinNoise.hlsl"
			#pragma vertex CustomRenderTextureVertexShader
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment

			TEXTURE_X(_Source);
			SAMPLER_X(sampler_Source); 

			float _ResX;
			float _ResY;
			float _ScanIntensity;
			float _VIntense;
			float2 _BarrelWarp;
			float _ChromaIntense;
			int _UseBarrelWarp, _UseChroma, _UseBleed;

			#pragma target 3.0
			float2 WarpUV(float2 uv)
			{
				float2 centered = uv * 2.0 - 1.0;
				centered *= float2(1.0 + _BarrelWarp.y * centered.y * centered.y,
								   1.0 + _BarrelWarp.x * centered.x * centered.x);
				return centered * 0.5 + 0.5;
			}


			
			float4 genesis(v2f_customrendertexture i)
            {
				float2 uv=i.localTexcoord.xy;
				// Apply barrel warping
				if(_UseBarrelWarp==1)
				{
					uv=WarpUV(i.localTexcoord.xy);
				}
				float rX=1.0/_ResX;
				float rY=1.0/_ResY;
				float2 pixelSize=float2(rX,rY);
				float2 pixelUV = floor(uv / pixelSize) * pixelSize;
				float4 color;
				
				
				// Chromatic offsets				
				if(_UseChroma==1)
				{
					float2 chromaOffset = _ChromaIntense / _ScreenParams.xy;
					float colorR=SAMPLE_X_SAMPLER(_Source, sampler_Source, pixelUV -chromaOffset,i.direction).r;				 
					float colorG = SAMPLE_X_SAMPLER(_Source, sampler_Source, pixelUV ,i.direction).g;
					float colorB = SAMPLE_X_SAMPLER(_Source, sampler_Source, pixelUV +chromaOffset,i.direction).b;
					color = float4(colorR, colorG, colorB,1);
				} else
				{
					color=SAMPLE_X_SAMPLER(_Source, sampler_Source, pixelUV, i.direction);
				}

				if(_UseBleed==1)
				{
					float2 bleedOffset = pixelSize * 0.3;
					float4 c1=SAMPLE_X_SAMPLER(_Source, sampler_Source, pixelUV + bleedOffset, i.direction) * 0.2;
					float4 c2=SAMPLE_X_SAMPLER(_Source, sampler_Source, pixelUV - bleedOffset, i.direction) * 0.2;
					color+=c1;
					color+=c2;

					color /= 1.4;
				}

				// Scanline modulation
				float scanline = 0.5 + 0.5 * cos(uv.y * i.localTexcoord.y * 3.1415);
				color *= lerp(1.0, scanline, _ScanIntensity);
				
				// Vignette
				float2 dist = uv - 0.5;
				float vignette = 1.0 - _VIntense * dot(dist, dist) * 4.0;
				color *= saturate(vignette);

				return float4(color);				
			}
           ENDHLSL
        }

	}
}
/*
﻿Shader "Hidden/Genesis/Pixelize"
{	
	Properties
	{
		// By default a shader node is supposed to handle all the input texture dimension, we use a prefix to determine which one is used
		[Tooltip(Source Texture)][InlineTexture]_Source_2D("Source", 2D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_3D("Source", 3D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_Cube("Source", Cube) = "white" {}
		[Tooltip(Simulated resolution width)]_ResX("Res X", Range(128,1024)) = 320
		[Tooltip(Simulated resolution width)]_ResY("Res Y", Range(128,1024)) = 240
		[Tooltip(Scan line intensity)]_ScanIntensity("Scan Intensity", Range(0.0,1.0))=0.25
		[Tooltip(Vignette intensity)]_VIntense("Vignette Intensity", Range(0.0,1.0))=0.25
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Name "Vertical Blur"

			HLSLPROGRAM
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
			TEXTURE_X_SAMPLER(_Source);
			float _ResX;
			float _ResY;
			float _ScanIntensity;
			float _VIntense; 
	
			float4 genesis(v2f_customrendertexture i) : SV_Target
			{	
				float rX=1.0/_ResX;
				float rY=1.0/_ResY;
				float2 pixelSize=float2(rX,rY);
				float2 blockUV=floor(i.localTexcoord.xy/pixelSize)*pixelSize;
				return SAMPLE_X(_Source,i.localTexcoord,i.direction);
				color=SAMPLE_X_SAMPLER(_Source,blockUV, i.localTexcoord,i.direction);
				return float4(col,1);
			}
			ENDHLSL
		} 

	}
}

*/