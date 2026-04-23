Shader "Hidden/Genesis/DotsShader"
{	
	Properties
	{
		[InlineTexture]_UV_2D("UV", 2D) = "white" {}
		[InlineTexture]_UV_3D("UV", 3D) = "white" {}
		[InlineTexture]_UV_Cube("UV", Cube) = "white" {}

		[Tooltip(Grayscale or color output)]
		[Enum(Grayscale, 0, Color, 1)] _OutputType("Grayscale or Color",int)=0
		[Tooltip(Scale, minimum 2x2)]
		[GenesisVector2I] _Scale("Scale",vector) = (5,5,0,0)
		[Tooltip(Density of the dots distribution)]_Density("Density", Range(0.0,1.0))=1.0
		[Tooltip(Size of the dots)] _Size("Size", Range(0.0,1.0))=0.5
		[Tooltip(The variation of the size of the dots)] _Variation("Variation", Range(0.0,1.0))=0.75
		[Tooltip(The roundness of the dots)] _Roundness("Roundness", Range(0.0,1.0))=1.0
		[Tooltip(Random seed)] _Seed("Seed", int)=52

	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			HLSLPROGRAM
			#define BUILTIN_TARGET_API					
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/ValueNoise.hlsl"
			
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV

			int _OutputType;
			float2 _Scale;
			float _Density;
			float _Size;
			float _Variation;
			float _Roundness;
			int _Seed;

			float4 genesis(v2f_customrendertexture i)
            {
                float2 resolution = _ScreenParams.xy;
                
				#ifdef USE_CUSTOM_UV
				float uv = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);
			    #else
				float2 uv = GetDefaultUVs(i);
				#endif

				float3 val=dotsNoise(uv.xy,_Scale,_Density,_Size,_Variation,_Roundness,_Seed);
				if(_OutputType==0)
				{
				
					return float4(val.x,val.x,val.x,1);
				}
				return float4(val.x,0,0,1);
			}
			ENDHLSL
		}
	}
}
