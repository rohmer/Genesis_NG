Shader "Hidden/CustomRenderTextureMissingMaterial"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			HLSLPROGRAM
			#include "../Shaders/GenesisFixed.hlsl"
			#pragma fragment GenesisFragment

            #pragma vertex CustomRenderTextureVertexShader
			#pragma target 3.0

			float4 genesis(v2f_customrendertexture i)
			{
				return float4(1, 0, 1, 1);
			}
			ENDHLSL
		}
	}
}
