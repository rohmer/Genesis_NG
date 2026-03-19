Shader "Hidden/Genesis/Invert"
{	
	Properties
	{
		[InlineTexture]_Source_2D("Input", 2D) = "white" {}
		[InlineTexture]_Source_3D("Input", 3D) = "white" {}
		[InlineTexture]_Source_Cube("Input", Cube) = "white" {}

		[Tooltip(Invertion type, either RGB or HSV)][Enum(RGB,0,HSV,1)]_iType("Inversion type", int)=0
		[VisibleIf(_iType,0)][Tooltip(Invert red channel)][Enum(No,0,Yes,1)]_redChannel("Invert Red",int)=1
		[VisibleIf(_iType,0)][Tooltip(Invert green channel)][Enum(No,0,Yes,1)]_greenChannel("Invert Green",int)=1
		[VisibleIf(_iType,0)][Tooltip(Invert blue channel)][Enum(No,0,Yes,1)]_blueChannel("Invert Blue",int)=1
		[VisibleIf(_iType,1)][Tooltip(Invert hue channel)][Enum(No,0,Yes,1)]_hueChannel("Invert Hue",int)=1
		[VisibleIf(_iType,1)][Tooltip(Invert saturation channel)][Enum(No,0,Yes,1)]_saturationChannel("Invert Saturation",int)=1
		[VisibleIf(_iType,1)][Tooltip(Invert value channel)][Enum(No,0,Yes,1)]_valueChannel("Invert Value",int)=1
		[Tooltip(Invert alpha channel)][Enum(No,0,Yes,1)]_alphaChannel("Invert Alpha",int)=0
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


			TEXTURE_SAMPLER_X(_Source);
			int _redChannel, _greenChannel, _blueChannel,_hueChannel,_saturationChannel,_valueChannel,_alphaChannel;
			int _iType;

			float4 invertRGB(float4 src)
			{
				if(_redChannel==1)
					src.x=1.0-src.x;
				if(_greenChannel==1)
					src.y=1.0-src.y;
				if(_blueChannel==1)
					src.z=1.0-src.z;
				if(_alphaChannel==1)
					src.w=1-src.w;
				return src;
			}						

			float3 InvertHSV(float3 rgb) {
				float3 hsv = RGBtoHSV(rgb);
				hsv.x = frac(hsv.x + 0.5); // Invert hue
				return HSVtoRGB(hsv);
			}

			float4 mixture(v2f_customrendertexture i) : SV_Target
			{
				float4 source = SAMPLE_X(_Source, i.localTexcoord.xyz, i.direction);
				if(_iType==0)	
				{
					return invertRGB(source);
				}

				if(_alphaChannel==1)
				{
					source.w=1.0-source.w;
				}
				return float4(InvertHSV(source.xyz), source.w);				
			}
			ENDHLSL
		}
	}
}
