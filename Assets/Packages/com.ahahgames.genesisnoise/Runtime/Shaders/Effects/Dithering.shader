Shader "Hidden/Genesis/Dithering"
{	
	Properties
	{
		[InlineTexture]_Input_2D("Input", 2D) = "white" {}
		[InlineTexture]_Input_3D("Input", 3D) = "white" {}
		[InlineTexture]_Input_Cube("Input", Cube) = "white" {}

		[Tooltip(Dithering Algorithm)]
		[Enum(FloydSteingberg,0,BlueNoise,1)] _algo("Algorithm", int)=1
		[VisibleIf(_algo,0)] [Enum(Four,4,Six,6,Eight,8,Sixteen,16,ThirtyTwo,32,SixtyFour,64)] _BitDepth("Bit Depth",int)=4
		[Enum(Grayscale,0,Color,1)] _OutputType("Output", int) = 0

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
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisDithering.hlsl"		
			
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV

			TEXTURE_SAMPLER_X(_Input);
			float _Density;
			int _OutputType;
			int _algo;
			int _BitDepth;
			
			// Quantize to N levels
			float quantize(float value, float levels)
			{
				return round(value * (levels - 1)) / (levels - 1);
			}

			float4 genesis(v2f_customrendertexture i)
            {			    
				float4	input = SAMPLE_X(_Input,i.localTexcoord.xyz, i.direction);
				
				float4 color = input;
				
				if(_algo==0)
				{
					float2 fragCoord=i.localTexcoord.xy*_ScreenParams.xy;
					float3 color=SAMPLE_X(_Input, i.localTexcoord.xyz,i.direction);
					float value=grayscale(color);

					float noise=nrand(floor(fragCoord));
					value+=(noise-0.5)/8.0;

					float quantized = quantize(saturate(value), _BitDepth);
					if(_OutputType==1)
					{
						float3 val=color*quantized;
						return float4(val,1.0);
					}
					return float4(quantized.xxx, 1.0);

				}
				if(_algo==1)
				{
					float gray=BlueNoiseDither(i.localTexcoord.xy,input.xyz);
					if(_OutputType==1)
					{
						if(gray==1)
						{							
							return(color);
						} else
						{
							return(0,0,0,1);
						}
					} else
					{
						return float4(gray,gray,gray,1);
					}
				}

							
				
				return float4(0,0,0,1);
			}
			ENDHLSL
		}
	}
}
