Shader "Hidden/Genesis/TextureMatte"
{	
	Properties
	{
		[InlineTexture]_Texture_2D("Texture", 2D) = "white" {}
		[InlineTexture]_Texture_3D("Texture", 3D) = "white" {}
		[InlineTexture]_Texture_Cube("Texture", Cube) = "white" {}
		[GenesisVector3]_Scale("UV Scale", Vector) = (1.0,1.0,1.0,0.0)
		[GenesisVector3]_Bias("UV Bias", Vector) = (0.0,0.0,0.0,0.0)
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

			TEXTURE_SAMPLER_X(_Texture);

			float4 _Scale;
			float4 _Bias;

			float4 genesis(v2f_customrendertexture i) : SV_Target
			{
				i.localTexcoord.xyz = (i.localTexcoord.xyz * _Scale.xyz) + _Bias.xyz;
				float4 col = SAMPLE_X(_Texture, i.localTexcoord.xyz, i.direction);
				return col;
			}
			ENDHLSL
		}
	}
}
