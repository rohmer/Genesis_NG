Shader "Hidden/Genesis/VioletNoise"
{
	Properties
	{
		[InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
		[InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
		[InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

		[KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 0
		[ShowInInspector][Enum(2D, 0, 3D, 1)] _UVMode("UV Mode", Float) = 0
		[ShowInInspector][GenesisVector2]_OutputRange("Output Range", Vector) = (0, 1, 0, 0)
		_Frequency("Frequency", Float) = 96
		_VioletAmount("Violet Amount", Range(0, 1)) = 1
		_Contrast("Contrast", Range(0.25, 4)) = 1
		_Seed("Seed", Int) = 42
		[Tooltip(Select how many noise values to generate and which channels to write. More channels cost more noise evaluations.)]
		[ShowInInspector][Enum(RRRR, 0, R, 1, RG, 2, RGB, 3, RGBA, 4)]_Channels("Channels", Int) = 0
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			HLSLPROGRAM
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma target 3.0

			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV
			#pragma shader_feature _TILINGMODE_NONE _TILINGMODE_TILED

			TEXTURE_SAMPLER_X(_UV);

			float _Frequency;
			float _VioletAmount;
			float _Contrast;
			float2 _OutputRange;
			int _Seed;
			int _Channels;
			int _UVMode;

			float3 PositiveModulo(float3 value, float period)
			{
				period = max(period, 1.0);
				return value - period * floor(value / period);
			}

			float VioletHash(float3 cell, float period, int seed)
			{
				#ifdef _TILINGMODE_TILED
					cell = PositiveModulo(cell, period);
				#endif

				return WhiteNoise(cell + RandomOffset3(seed));
			}

			float RingAverage2D(float3 cell, float stepSize, float period, int seed)
			{
				float average = 0.0;
				average += VioletHash(cell + float3( stepSize,  0.0,       0.0), period, seed);
				average += VioletHash(cell + float3(-stepSize,  0.0,       0.0), period, seed);
				average += VioletHash(cell + float3( 0.0,       stepSize,  0.0), period, seed);
				average += VioletHash(cell + float3( 0.0,      -stepSize,  0.0), period, seed);
				average += VioletHash(cell + float3( stepSize,  stepSize,  0.0), period, seed);
				average += VioletHash(cell + float3(-stepSize,  stepSize,  0.0), period, seed);
				average += VioletHash(cell + float3( stepSize, -stepSize,  0.0), period, seed);
				average += VioletHash(cell + float3(-stepSize, -stepSize,  0.0), period, seed);
				return average * 0.125;
			}

			float RingAverage3D(float3 cell, float stepSize, float period, int seed)
			{
				float average = 0.0;
				average += VioletHash(cell + float3( stepSize,  0.0,       0.0), period, seed);
				average += VioletHash(cell + float3(-stepSize,  0.0,       0.0), period, seed);
				average += VioletHash(cell + float3( 0.0,       stepSize,  0.0), period, seed);
				average += VioletHash(cell + float3( 0.0,      -stepSize,  0.0), period, seed);
				average += VioletHash(cell + float3( 0.0,       0.0,       stepSize), period, seed);
				average += VioletHash(cell + float3( 0.0,       0.0,      -stepSize), period, seed);
				return average / 6.0;
			}

			float VioletNoise01(float3 uvs, int seed)
			{
				float frequency = max(_Frequency, 1.0);

				#ifdef _TILINGMODE_TILED
					frequency = round(frequency);
				#endif

				float3 cell = floor(uvs * frequency);
				float center = VioletHash(cell, frequency, seed);
				float innerAverage;
				float outerAverage;

				#ifdef CRT_2D
					if (_UVMode == 0)
					{
						innerAverage = RingAverage2D(cell, 1.0, frequency, seed);
						outerAverage = RingAverage2D(cell, 2.0, frequency, seed);
					}
					else
				#endif
					{
						innerAverage = RingAverage3D(cell, 1.0, frequency, seed);
						outerAverage = RingAverage3D(cell, 2.0, frequency, seed);
					}

				float firstDifference = center - innerAverage;
				float secondDifference = center - 2.0 * innerAverage + outerAverage;
				float violet = saturate((firstDifference + secondDifference) * _Contrast + 0.5);
				return lerp(center, violet, saturate(_VioletAmount));
			}

			float GenerateNoise(v2f_customrendertexture i, int seed)
			{
				float3 uvs = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), seed);

				#ifdef CRT_2D
					if (_UVMode == 0)
						uvs.z = 0.5;
				#endif

				float noise = VioletNoise01(uvs, seed);
				return RemapClamp(noise, 0, 1, _OutputRange.x, _OutputRange.y);
			}

			float4 genesis(v2f_customrendertexture i)
			{
				return GenerateNoiseForChannels(i, _Channels, _Seed);
			}
			ENDHLSL
		}
	}
}
