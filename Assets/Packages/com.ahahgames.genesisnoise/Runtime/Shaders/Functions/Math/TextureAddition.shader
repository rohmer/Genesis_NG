Shader "Hidden/Genesis/TextureAddition"
{	
	Properties
	{
		[InlineTexture]_SourceA_2D("SourceA", 2D) = "black" {}
		[InlineTexture]_SourceA_3D("SourceA", 3D) = "black" {}
		[InlineTexture]_SourceA_Cube("SourceA", Cube) = "black" {}

		[InlineTexture]_SourceB_2D("SourceB", 2D) = "black" {}
		[InlineTexture]_SourceB_3D("SourceB", 3D) = "black" {}
		[InlineTexture]_SourceB_Cube("SourceB", Cube) = "black" {}

		_FloatVal("FloatVal",Float)=0
		_MathMode ("MathMode",Float) = 0		// 0 add textures, 1 add texture A to a float value

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

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
		
			TEXTURE_SAMPLER_X(_SourceA);
			TEXTURE_SAMPLER_X(_SourceB);
			float _FloatVal, _MathMode;

			float4 genesis(v2f_customrendertexture i)
			{
				float4 value;

				if (_MathMode == 0)
				{
					float4 sourceA = SAMPLE_X(_SourceA, i.localTexcoord.xyz, i.direction);
					float4 sourceB = SAMPLE_X(_SourceB, i.localTexcoord.xyz, i.direction);
					value = sourceA + sourceB;
				}
				else
				{
					float4 sourceA = SAMPLE_X(_SourceA, i.localTexcoord.xyz, i.direction);
					value = sourceA + _FloatVal;
				}
				return value;
			}
			ENDHLSL
		}
	}
}