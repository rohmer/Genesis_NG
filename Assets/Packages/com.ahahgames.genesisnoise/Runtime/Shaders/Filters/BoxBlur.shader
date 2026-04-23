Shader "Hidden/Genesis/BoxBlur"
{	
	Properties
	{
		[InlineTexture]_Input_2D("Input", 2D) = "white" {}
		[InlineTexture]_Input_3D("Input", 3D) = "white" {}
		[InlineTexture]_Input_Cube("Input", Cube) = "white" {}

		[GenesisBoxBlurRadius]_Radius("Radius",int)=3
		
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
			#pragma shader_feature _ USE_CUSTOM_UV
			
			TEXTURE_SAMPLER_X(_Input);
			int _Radius;

			// Round up to next power of two
            int NextPow2(int v)
            {
                v--;
                v |= v >> 1;
                v |= v >> 2;
                v |= v >> 4;
                v |= v >> 8;
                v |= v >> 16;
                v++;
                return v;
            }

			float4 genesis(v2f_customrendertexture i) : SV_Target
            {
				float4 sum = 0.0;
				int taps = 0;
				float3 uvw = i.localTexcoord.xyz;

				for (int y = -_Radius; y <= _Radius; ++y)
				{
					for (int x = -_Radius; x <= _Radius; ++x)
					{
						float X=x*0.01;
						float Y=y*0.01;
						float2 offset = float2(X, Y);
						float3 uvwOffset = uvw;
                        uvwOffset.xy += offset;


						sum += SAMPLE_X(_Input, uvwOffset, i.direction);
						taps++;
					}
				}

				return sum / taps;
              
            }

			ENDHLSL
		}
	}
}
