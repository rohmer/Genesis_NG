Shader "Hidden/Genesis/GenerativeDeco"
{	
	Properties
	{
		[Tooltip(Grayscale or color output)]
		[Enum(Grayscale, 0, Color, 1)] _OutputType("Grayscale or Color",int)=0
		[Tooltip(Shape size defines the amount and number of shapes rendered)]_ShapeSize("Shape Size",Range(0.001,1.0))=0.650
		[Tooltip(Chromatic Abberation will redefine the colors adjusting for the neighboring chroma)]_Chroma("Chromatic Abberation",Range(0.001,1.0))=0.150
		[Tooltip(Iterations, higer number will generate a generally more complex output)]_Iterations("Iterations",Range(0.1,25.0))=15.0
		[Tooltip(Initial luma defines the brightness of the final outcome)]_Luma("Initial Luma",Range(0.01,1.0))=0.25

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
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV

			#define PI 3.14159265359
			#define TWO_PI 6.28318530718
			
			int _OutputType, _Seed;
			float _ShapeSize, _Chroma, _Iterations, _Luma;

			TEXTURE_X(_Source);
			SAMPLER_X(sampler_Source); 

			float2x2 rotate2d(float angle)
			{
				float c = cos(angle);
				float s = sin(angle);
				return float2x2(c, -s,
								s,  c);
			}
			
			float sdPolygon(float angle, float distance)
			{
				float segment = TWO_PI / 4.0;
				float a = floor(0.5 + angle / segment) * segment - angle;
				return cos(a) * distance;
			}

			float getColorComponent(float2 st, float modScale, float blur)
			{
				float2 modSt = fmod(st, 1.0 / modScale) * modScale * 2.0 - 1.0;
				float dist = length(modSt);
				float angle = atan2(modSt.x, modSt.y) + sin(_Seed * 0.08) * 9.0;
				
				float shapeMap = smoothstep(_ShapeSize + blur, _ShapeSize - blur, sin(dist * 3.0) * 0.5 + 0.5);
				return shapeMap;
			}

			float4 mixture (v2f_customrendertexture i) : SV_Target
            {
				float blur = 0.4 + sin(_Seed * 0.52) * 0.2;

				float2 st = (2.0 * i.localTexcoord - _ScreenParams) / min(_ScreenParams.x, _ScreenParams.y);
				float2 origSt = st;

				st = mul(st, rotate2d(sin(_Seed * 0.14) * 0.3));
				st *= (sin(_Seed * 0.15) + 2.0) * 0.3;
				st *= log(length(st * 0.428)) * 1.1;

				float modScale = 1.0;
				float3 color = float3(0.0, 0.0, 0.0);
				float luma = _Luma;

				for (int i = 0; i < _Iterations; ++i)
				{
					float2 center = st + float2(sin(_Seed * 0.12), cos(_Seed * 0.13));
					//float fft = iChannel0.Sample(iChannel0Sampler, float2(length(center), 0.25)).r;

					float3 shapeColor = float3(
						getColorComponent(center - st * _Chroma, modScale, blur),
						getColorComponent(center, modScale, blur),
						getColorComponent(center + st * _Chroma, modScale, blur)
					) * luma;

					st *= 1.1 + getColorComponent(center, modScale, 0.04) * 1.2;
					st = mul(st, rotate2d(sin(_Seed * 0.05) * 1.33));
					color += shapeColor;
					color = saturate(color);

					luma *= 0.6;
					blur *= 0.63;
				}

				const float GRADING_INTENSITY = 0.4;
				float3 topGrading = float3(
					1.0 + sin(_Seed * 1.13 * 0.3) * GRADING_INTENSITY,
					1.0 + sin(_Seed * 1.23 * 0.3) * GRADING_INTENSITY,
					1.0 - sin(_Seed * 1.33 * 0.3) * GRADING_INTENSITY
				);

				float3 bottomGrading = float3(
					1.0 - sin(_Seed * 1.43 * 0.3) * GRADING_INTENSITY,
					1.0 - sin(_Seed * 1.53 * 0.3) * GRADING_INTENSITY,
					1.0 + sin(_Seed * 1.63 * 0.3) * GRADING_INTENSITY
				);

				float origDist = length(origSt);
				float3 colorGrading = lerp(topGrading, bottomGrading, origDist - 0.5);
				float3 gradedColor = pow(color, colorGrading);
				float vignette = smoothstep(2.1, 0.7, origDist);

				
				return float4(gradedColor, 1.0);

			}
			
			ENDHLSL
		}
	}
}