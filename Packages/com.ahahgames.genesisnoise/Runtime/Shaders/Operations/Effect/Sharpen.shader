Shader "Hidden/Genesis/Sharpen"
{	
	Properties
	{
		// By default a shader node is supposed to handle all the input texture dimension, we use a prefix to determine which one is used
		[Tooltip(Source Texture)][InlineTexture]_Source_2D("Source", 2D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_3D("Source", 3D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_Cube("Source", Cube) = "white" {}

		[Tooltip(Radius of the sharpening kernel, larger results in slower performans)][GenesisKernelSize]_kernelSize("Kernel size", int)=3
		[Tooltip(Sharpening intensity)]_sharpening("Sharpening Intensity", Range(0.001,3.0))=1.0
	}

	SubShader 
	{
		Pass
		{
			HLSLPROGRAM			
			#define BUILTIN_TARGET_API					
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"			
			#pragma vertex CustomRenderTextureVertexShader
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment

			TEXTURE_X(_Source);
			SAMPLER_X(sampler_Source); 
			float _sharpening;
			float _kernelSize;

			float3 Sharpen(float2 uv, float2 texelSize, int radius, float sharpness, float3 dir)
			{
				float centerWeight = 1.0 + sharpness * (float)(radius * radius * 4);
				float3 centerColor=SAMPLE_X_SAMPLER(_Source,sampler_Source,uv,dir);				

				float3 accum = float3(0.0, 0.0, 0.0);
				int count = 0;

				for (int y = -radius; y <= radius; ++y)
				{
					for (int x = -radius; x <= radius; ++x)
					{
						if (x == 0 && y == 0) continue;

						float2 offset = float2(x, y) * texelSize;						
						float3 sample=SAMPLE_X_SAMPLER(_Source,sampler_Source,uv+offset,dir);						
						accum += sample;
						count += 1;
					}
				}

				float3 blurred = accum / count;
				return saturate(centerColor * centerWeight - blurred * sharpness);
			}

			
			float4 mixture (v2f_customrendertexture i) : SV_Target
            {
				float2 texelSize=float2(1.0/_ScreenParams.x*_ScreenParams.x,1.0/_ScreenParams.y);				
				int radius=5;
				if(_kernelSize==0)
					radius=3;
					else if(_kernelSize==1)
						radius=5;
						else if(_kernelSize==2)
							radius=7;
							else if(_kernelSize==3)
								radius=9;
								else if(_kernelSize==4)
									radius=11;
				float3 color=Sharpen(i.localTexcoord,texelSize,radius,_sharpening,i.direction);
				return float4(color,1);
			}
			ENDHLSL
		}
	}
}