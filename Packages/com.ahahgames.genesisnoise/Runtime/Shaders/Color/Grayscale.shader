Shader "Hidden/Genesis/Grayscale"
{	
	Properties
	{
		[InlineTexture]_Input_2D("Input", 2D) = "white" {}
		[InlineTexture]_Input_3D("Input", 3D) = "white" {}
		[InlineTexture]_Input_Cube("Input", Cube) = "white" {}

		[Tooltip(Algorithm for converting to grayscale)]
		[GenesisGrayscale] _Algorithm("Algorithm", int) = 0
		[VisibleIf(_Algorithm,4)][Enum(R,0,G,1,B,2,A,3)] _Channel("Channel", int) = 0
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
			#pragma fragment GenesisFragment
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV

			TEXTURE_SAMPLER_X(_Input);
			int _Algorithm;
			int _Channel;

			float grayscaleLuminance(float3 color)
			{
				return dot(color, float3(0.3, 0.59, 0.11));
			}

			float grayscaleAverage(float3 color)
			{
				return (color.r + color.g + color.b) / 3.0;
			}

			float grayscaleLightness(float3 color)
			{
				float maxC = max(max(color.r, color.g), color.b);
				float minC = min(min(color.r, color.g), color.b);
				return (maxC + minC) / 2.0;
			}

			float grayscaleDesaturate(float3 color)
			{
				return (min(color.r, min(color.g, color.b)) + max(color.r, max(color.g, color.b))) * 0.5;
			}

			float linearize(float c)
			{
				return (c <= 0.04045) ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4);
			}

			float grayscaleGammaCorrected(float3 color)
			{
				float3 lin = float3(linearize(color.r), linearize(color.g), linearize(color.b));
				return dot(lin, float3(0.3, 0.59, 0.11)); // or use linear weights
			}

			float4 mixture (v2f_customrendertexture i) : SV_Target
            {			    
				float4	input = SAMPLE_X(_Input,i.localTexcoord.xyz, i.direction);
				
				float color;
				switch(_Algorithm)
				{
					case 0:
						color=grayscaleLuminance(input.xyz);
						break;
					case 1:
						color=grayscaleAverage(input.xyz);
						break;
					case 2:
						color=grayscaleLightness(input.xyz);
						break;
					case 3:
						color=grayscaleDesaturate(input.xyz);
						break;
					case 4:
						if(_Channel==0)
							color=input.x;
						if(_Channel==1)
							color=input.y;
						if(_Channel==2)
							color=input.z;
						if(_Channel==3)
							color=input.w;
						break;
					case 5:
						color=grayscaleGammaCorrected(input.xyz);
						break;
				}

				return float4(color.xxx,1);
			}
			ENDHLSL
		}
	}
}