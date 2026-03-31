Shader "Hidden/Genesis/ColorMatte"
{	
	Properties
	{
		[HDR]_Color("Color", Color) = (1.0,0.3,0.1,1.0)
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

			float4 _Color;

			float4 genesis(v2f_customrendertexture i)
			{
				return _Color;
			}
			ENDHLSL
		}
	}
}
