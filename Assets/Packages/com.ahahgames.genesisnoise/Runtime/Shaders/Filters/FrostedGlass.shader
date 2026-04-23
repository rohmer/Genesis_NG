Shader "Hidden/Genesis/FrostedGlass"
{	
	Properties
	{
		// By default a shader node is supposed to handle all the input texture dimension, we use a prefix to determine which one is used
		[Tooltip(Source Texture)][InlineTexture]_Source_2D("Source", 2D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_3D("Source", 3D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_Cube("Source", Cube) = "white" {}	
		[Tooltip(Strength of the blur]_BlurStrength ("Blur Strength", Float) = 1.0
        [Tooltip(Influence of distortion)]_DistortionStrength ("Distortion Strength", Float) = 0.05
		[Tooltip(Blur matrix size)]
		[GenesisBlurMatrix]_MatrixSize("Matrix Size",int)=3
        [Tooltip(Added Tint Color, set alpha to 0.0 to disable)]_TintColor ("Tint", Color) = (1,1,1,0.0)


	}

	HLSLINCLUDE
	#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

	#pragma target 3.0
	// The list of defines that will be active when processing the node with a certain dimension
	#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
	#pragma vertex CustomRenderTextureVertexShader
	#pragma fragment GenesisFragment
	
	TEXTURE_SAMPLER_X(_Source);
	float _BlurStrength;
	float _DistortionStrength;
	int _MatrixSize;
	float4 _TintColor;

	float hash(float2 p)
    {
        return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
    }

	// Do this so we can unroll loops, lots of typing :(

	float4 blur3x3(float3 uv, float2 offset, float3 direction)
	{
		float4 color=float4(0,0,0,0);
		float totalWeight=0.0;
		// 3x3 blur with noisy offsets
        [unroll]
        for (int x = -1; x <= 1; x++)
        {
            [unroll]
            for (int y = -1; y <= 1; y++)
            {
                float2 p = uv + float2(x, y) * offset;
                float noise = hash(p * 50.0);
                p += (noise - 0.5) * _DistortionStrength;
				float4 sample=SAMPLE_X(_Source, uv, direction);                
                color += sample;
                totalWeight += 1.0;
            }
        }

        color /= totalWeight;
		return color;
	}
	
	float4 blur5x5(float3 uv, float2 offset, float3 direction)
	{
		float4 color=float4(0,0,0,0);
		float totalWeight=0.0;
		// 5x5 blur with noisy offsets
        [unroll]
        for (int x = -2; x <= 2; x++)
        {
            [unroll]
            for (int y = -2; y <= 2; y++)
            {
                float2 p = uv + float2(x, y) * offset;
                float noise = hash(p * 50.0);
                p += (noise - 0.5) * _DistortionStrength;
				float4 sample=SAMPLE_X(_Source, uv, direction);                
                color += sample;
                totalWeight += 1.0;
            }
        }

        color /= totalWeight;
		return color;
	}
	
	float4 blur7x7(float3 uv, float2 offset, float3 direction)
	{
		float4 color=float4(0,0,0,0);
		float totalWeight=0.0;
		// 7x7 blur with noisy offsets
        [unroll]
        for (int x = -3; x <= 3; x++)
        {
            [unroll]
            for (int y = -3; y <= 3; y++)
            {
                float2 p = uv + float2(x, y) * offset;
                float noise = hash(p * 50.0);
                p += (noise - 0.5) * _DistortionStrength;
				float4 sample=SAMPLE_X(_Source, uv, direction);                
                color += sample;
                totalWeight += 1.0;
            }
        }

        color /= totalWeight;
		return color;
	}
	
	float4 blur9x9(float3 uv, float2 offset, float3 direction)
	{
		float4 color=float4(0,0,0,0);
		float totalWeight=0.0;
		// 3x3 blur with noisy offsets
        [unroll]
        for (int x = -4; x <= 4; x++)
        {
            [unroll]
            for (int y = -4; y <= 4; y++)
            {
                float2 p = uv + float2(x, y) * offset;
                float noise = hash(p * 50.0);
                p += (noise - 0.5) * _DistortionStrength;
				float4 sample=SAMPLE_X(_Source, uv, direction);                
                color += sample;
                totalWeight += 1.0;
            }
        }

        color /= totalWeight;
		return color;
	}
	
	float4 blur11x11(float3 uv, float2 offset, float3 direction)
	{
		float4 color=float4(0,0,0,0);
		float totalWeight=0.0;
		// 11x11 blur with noisy offsets
        [unroll]
        for (int x = -5; x <= 5; x++)
        {
            [unroll]
            for (int y = -5; y <= 5; y++)
            {
                float2 p = uv + float2(x, y) * offset;
                float noise = hash(p * 50.0);
                p += (noise - 0.5) * _DistortionStrength;
				float4 sample=SAMPLE_X(_Source, uv, direction);                
                color += sample;
                totalWeight += 1.0;
            }
        }

        color /= totalWeight;
		return color;
	}
	
	float4 blur13x13(float3 uv, float2 offset, float3 direction)
	{
		float4 color=float4(0,0,0,0);
		float totalWeight=0.0;
		// 13x13 blur with noisy offsets
        [unroll]
        for (int x = -6; x <= 6; x++)
        {
            [unroll]
            for (int y = -6; y <= 6; y++)
            {
                float2 p = uv + float2(x, y) * offset;
                float noise = hash(p * 50.0);
                p += (noise - 0.5) * _DistortionStrength;
				float4 sample=SAMPLE_X(_Source, uv, direction);                
                color += sample;
                totalWeight += 1.0;
            }
        }

        color /= totalWeight;
		return color;
	}
	
	float4 blur15x15(float3 uv, float2 offset, float3 direction)
	{
		float4 color=float4(0,0,0,0);
		float totalWeight=0.0;
		// 3x3 blur with noisy offsets
        [unroll]
        for (int x = -7; x <= 7; x++)
        {
            [unroll]
            for (int y = -7; y <= 7; y++)
            {
                float2 p = uv + float2(x, y) * offset;
                float noise = hash(p * 50.0);
                p += (noise - 0.5) * _DistortionStrength;
				float4 sample=SAMPLE_X(_Source, uv, direction);                
                color += sample;
                totalWeight += 1.0;
            }
        }

        color /= totalWeight;
		return color;
	}
	
	float4 RunBlur(float3 uv, float2 offset, float3 direction)
	{
		if(_MatrixSize==0)
			return blur3x3(uv,offset,direction);
		if(_MatrixSize==1)
			return blur5x5(uv,offset,direction);
		if(_MatrixSize==2)
			return blur7x7(uv,offset,direction);
		if(_MatrixSize==3)
			return blur9x9(uv,offset,direction);
		if(_MatrixSize==4)
			return blur11x11(uv,offset,direction);
		if(_MatrixSize==5)
			return blur13x13(uv,offset,direction);
		if(_MatrixSize==6)
			return blur15x15(uv,offset,direction);

		// This should never happpen
		return blur5x5(uv,offset,direction);
	}
	ENDHLSL
	

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100		
		Pass
		{
			Name "Radial Blur"			

			HLSLPROGRAM
			float4 genesis(v2f_customrendertexture i) : SV_Target
			{
				float3 uv=i.localTexcoord.xyz;
				float2 offset=_ScreenParams.xy*_BlurStrength;
				float4 color=float4(0,0,0,0);
				float totalWeight=0.0;

				color=RunBlur(uv,offset,i.direction);
				// Apply tint
                color.rgb = lerp(color.rgb, _TintColor.rgb, _TintColor.a);

				return color;
			}
			ENDHLSL


		}
	}
}