Shader "Hidden/Genesis/RadialBlur"
{	
	Properties
	{
		// By default a shader node is supposed to handle all the input texture dimension, we use a prefix to determine which one is used
		[Tooltip(Source Texture)][InlineTexture]_Source_2D("Source", 2D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_3D("Source", 3D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_Cube("Source", Cube) = "white" {}
		[Tooltip(Blur intensity)]_Intensity("Intensity", Range(0,1))=0.02
		[Tooltip(Number of blur samples, higher is slower)]
		[GenesisPower]_Samples("Samples", Float)=5
	}

	HLSLINCLUDE
	#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

	#pragma target 3.0
	// The list of defines that will be active when processing the node with a certain dimension
	#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
	#pragma vertex CustomRenderTextureVertexShader
	#pragma fragment GenesisFragment

	TEXTURE_SAMPLER_X(_Source);
	float _Intensity;
	float _Samples;

	int SampToNumber()
	{
		if(_Samples==0)
			return 9;
		if(_Samples==1)
			return 16;
		if(_Samples==2)
			return 25;
		if(_Samples==3)
			return 36;
		if(_Samples==4)
			return 49;
		if(_Samples==5)
			return 64;
		if(_Samples==6)
			return 81;
		if(_Samples==7)
			return 100;
		if(_Samples==8)
			return 121;
		if(_Samples==9)
			return 144;

		return 36;
	}

	float4 RadialBlurPS(v2f_customrendertexture i)
	{
		float2 center = float2(0.5, 0.5); // Center of the blur (normalized coordinates)
		float blurAmount = _Intensity;          // Intensity of the blur
		int samples = SampToNumber();                 // Number of samples for the blur

		float4 color = float4(0, 0, 0, 0); // Accumulated color
		float2 direction = i.localTexcoord.xy - center;    // Direction vector from the center
		float dist = length(direction);    // Distance from the center

		// Normalize the direction
		direction /= dist;

		float2 uv=i.localTexcoord.xy;
		// Accumulate samples
		for (int j = 0; j < samples; j++)
		{
			float t = j / (float)samples; // Interpolation factor
			float offset=direction*t*_Intensity;
			float3 uv=i.localTexcoord-offset;			

			color += SAMPLE_X(_Source, uv, i.direction);
		}

		// Average the accumulated color
		color /= samples;

		return color;
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
				return RadialBlurPS(i);
			}
			ENDHLSL


		}
	}
}