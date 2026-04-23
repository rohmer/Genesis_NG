Shader "CustomTexture/ShaderTextTextureCubeTemplate"
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
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
			#pragma fragment GenesisFragment
            #pragma vertex CustomRenderTextureVertexShader

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
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
