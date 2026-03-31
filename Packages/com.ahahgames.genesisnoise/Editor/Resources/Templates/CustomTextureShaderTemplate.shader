Shader "CustomTexture/#NAME#"
{	
	Properties
	{
		_Input("Input", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			HLSLPROGRAM
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
			#pragma fragment GenesisFragment

            #pragma vertex CustomRenderTextureVertexShader
			#pragma target 3.0

            sampler2D _Input;

			float4 genesis(v2f_customrendertexture i)
			{
				return tex2D(_Input, i.localTexcoord.xy);
			}
			ENDHLSL
		}
	}
}
