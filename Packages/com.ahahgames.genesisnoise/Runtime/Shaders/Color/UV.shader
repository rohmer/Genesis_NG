Shader "Hidden/Genesis/UV"
{	
	Properties
	{
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
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma target 3.0

			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE

			float4 _Scale;
			float4 _Bias;

			float4 genesis(v2f_customrendertexture i)
			{
#ifdef CRT_CUBE
				return float4(i.direction, 1) ;
#else
				return float4(i.globalTexcoord.xyz * _Scale.xyz + _Bias.xyz, 1);
#endif
			}
			ENDHLSL
		}
	}
}
