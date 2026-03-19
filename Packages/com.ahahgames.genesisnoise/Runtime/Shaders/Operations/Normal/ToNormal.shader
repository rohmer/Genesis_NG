Shader "Hidden/Genesis/ToNormal"
{	
	Properties
	{
		// By default a shader node is supposed to handle all the input texture dimension, we use a prefix to determine which one is used
		[Tooltip(Source Texture)][InlineTexture]_Source_2D("Source", 2D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_3D("Source", 3D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_Cube("Source", Cube) = "white" {}

		[Tooltip(Normal strength add or subtracts to the generated normal)]_normalStrength("Normal Strength", Range(0.001,25))=1.0	

	}

	SubShader 
	{
		Pass
		{
			HLSLPROGRAM			
			#define BUILTIN_TARGET_API					
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"						
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment

			TEXTURE_SAMPLER_X(_Source);
			float _normalStrength;
			float _heightScale;

			float3 HeightToNormal(float3 uv, float3 direction, float texelSize) {
				// Sample neighboring height values
				float hL=SAMPLE_X(_Source,uv+float3(-texelSize,0,0),direction).r;
				float hR=SAMPLE_X(_Source,uv+float3(texelSize,0,0),direction).r;
				float hD=SAMPLE_X(_Source,uv+float3(0,-texelSize,0),direction).r;
				float hU=SAMPLE_X(_Source,uv+float3(0,texelSize,0),direction).r;

				// Compute gradient
				float dx = (hR - hL) * _normalStrength;
				float dy = (hU - hD) * _normalStrength;

				// Construct normal
				float3 normal = normalize(float3(-dx, -dy, 1.0));
				return normal * 0.5 + 0.5; // Remap to [0,1] for texture output
			}

			float4 mixture (v2f_customrendertexture i) : SV_Target
            {
				float texelSize=1.0/_ScreenParams.x;
				float3 iNorm=HeightToNormal(i.localTexcoord, i.direction,texelSize);
				return float4(iNorm,1);
			}
			ENDHLSL
		}
	}
}