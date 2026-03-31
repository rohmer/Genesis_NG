Shader "Hidden/Genesis/UVDistort"
{	
	Properties
	{
		[InlineTexture] _Texture_2D("Distort Map", 2D) = "black" {}
		[InlineTexture]_UV_2D("UV", 2D) = "uv" {}

		[InlineTexture]_Texture_3D("Distort Map", 3D) = "black" {}
		[InlineTexture]_UV_3D("UV", 3D) = "uv" {}

		[InlineTexture]_Texture_Cube("Distort Map", Cube) = "black" {}
		[InlineTexture]_UV_Cube("Direction", Cube) = "uv" {}

		[GenesisVector3]_Scale("Distort Scale", Vector) = (1.0,1.0,0.0,0.0)
		[GenesisVector3]_Bias("Distort Bias", Vector) = (0.0,0.0,0.0,0.0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			HLSLPROGRAM
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma target 3.0

			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV

			TEXTURE_SAMPLER_X(_Texture);
			TEXTURE_X(_UV);
			float4 _Scale;
			float4 _Bias;

			float4 genesis(v2f_customrendertexture i)
			{
#ifdef USE_CUSTOM_UV
				float4 uv = SAMPLE_X_NEAREST_CLAMP(_UV, i.localTexcoord.xyz, i.direction);
#else
				float4 uv = float4(GetDefaultUVs(i), 1);
#endif

				// Scale and Bias does not works on cubemap
				float3 distortionVector = SAMPLE_X(_Texture, i.localTexcoord.xyz, i.direction).rgb;
#ifdef CRT_CUBE
				uv.rgb += distortionVector * _Scale.xyz;
				uv.rgb = Rotate(float3(1, 0, 0), uv.rgb, _Bias.x);
				uv.rgb = Rotate(float3(0, 1, 0), uv.rgb, _Bias.y);
				uv.rgb = Rotate(float3(0, 0, 1), uv.rgb, _Bias.z);
#else
				uv.rgb += ScaleBias(distortionVector, _Scale.xyz, _Bias.xyz);
#endif

				return uv; 

			}
			ENDHLSL
		}
	}
}
