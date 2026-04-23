Shader "Hidden/Genesis/Colorize"
{	
	Properties
	{
		[InlineTexture]_Input_2D("Input", 2D) = "white" {}
		[InlineTexture]_Input_3D("Input", 3D) = "white" {}
		[InlineTexture]_Input_Cube("Input", Cube) = "white" {}		
		_Gradient("Color Gradient", 2D) = "white" {}
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
			#pragma fragment GenesisFragment
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			
			TEXTURE_SAMPLER_X(_Input);
			sampler2D _Gradient;

			float4 grayToColor(float4 inputColor, float3 direction)
			{
				float cAvg=(inputColor.r+inputColor.g+inputColor.b)/3;								
				return tex2D(_Gradient,float2(cAvg,0.0));
				//return _Gradient.Sample(sampler_GradientTex,float2(cAvg,0.5));
			}

			float4 genesis(v2f_customrendertexture i)
			{
				float3 uv = GetDefaultUVs(i);
				float4 input=SAMPLE_X(_Input, i.localTexcoord.xyz, i.direction);

				return grayToColor(input, i.direction);
			}
			ENDHLSL
		}
	}
}