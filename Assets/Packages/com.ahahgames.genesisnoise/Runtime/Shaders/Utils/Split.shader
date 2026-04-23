Shader "Hidden/Genesis/Split"
{	
	Properties
	{
		// By default a shader node is supposed to handle all the input texture dimension, we use a prefix to determine which one is used
		[Tooltip(Source Texture)][InlineTexture]_Source_2D("Source", 2D) = "black" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_3D("Source", 3D) = "black" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_Cube("Source", Cube) = "black" {}

		[Tooltip(Select which channel to output)][GenesisSwizzle]_OutputChannel("Output Channel", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			HLSLPROGRAM
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma target 3.0

			// The list of defines that will be active when processing the node with a certain dimension
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

			// This macro will declare a version for each dimention (2D, 3D and Cube)
			TEXTURE_SAMPLER_X(_Source);
			float _OutputChannel;

			float4 genesis(v2f_customrendertexture i)
			{
				float4 c=SAMPLE_X(_Source,i.localTexcoord.xyz,i.direction);

				if(_OutputChannel==0)
				{
					return float4(c.r,0,0,1);
				}
				if(_OutputChannel==1)
				{
					return float4(0,c.g,0,1);
				}
				if(_OutputChannel==2)
				{
					return float4(0,0,c.b,1);
				}
				if(_OutputChannel==3)
					return float4(0,0,0,c.a);
				if(_OutputChannel==4)
					return float4(0,0,0,1);
				if(_OutputChannel==5)
					return float4(0.5,0.5,0.5,1);
				if(_OutputChannel==6)
					return float4(1,1,1,1);
				return float4(0.5,0,0,1);

			}
			ENDHLSL
		}
	}
}
