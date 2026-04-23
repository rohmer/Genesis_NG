Shader "Hidden/Genesis/FinalCopy"
{	
	Properties
	{
		_Source_2D("Source", 2D) = "white" {}
		_Source_3D("Source", 3D) = "white" {}
		_Source_Cube("Source", Cube) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			HLSLPROGRAM

			#include "../Shaders/GenesisFixed.hlsl"
			#include "../Shaders/GenesisSRGB.hlsl"
			
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

			#pragma fragment GenesisFragment
            #pragma vertex CustomRenderTextureVertexShader
			#pragma target 3.0

			TEXTURE_X(_Source);

			float4 genesis(v2f_customrendertexture i)
			{
				float4 color = SAMPLE_LOD_X_NEAREST_CLAMP(_Source, i.localTexcoord.xyz, i.direction, _CustomRenderTextureMipLevel);

				color.rgb = ConvertToLinearIfNeeded(color.rgb);

				return color;
			}
			ENDHLSL
		}
	}
}
