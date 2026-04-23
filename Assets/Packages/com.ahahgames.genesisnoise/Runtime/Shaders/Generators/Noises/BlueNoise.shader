Shader "Hidden/Genesis/BlueNoise"
{
	Properties
	{
		[InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
		[InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
		[InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

		[KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 0
		[ShowInInspector][Enum(2D, 0, 3D, 1)] _UVMode("UV Mode", Float) = 0
		[ShowInInspector][GenesisVector2]_OutputRange("Output Range", Vector) = (0, 1, 0, 0)
		_Frequency("Frequency", Float) = 64
		_BlueAmount("Blue Amount", Range(0, 1)) = 1
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
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma target 3.0

			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV
			#pragma shader_feature _TILINGMODE_NONE _TILINGMODE_TILED

			TEXTURE_SAMPLER_X(_UV);

			float _Frequency;
			float _BlueAmount;
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

			float BlueHash(float3 cell, float period, int seed)
			{
				#ifdef _TILINGMODE_TILED
					cell = PositiveModulo(cell, period);
				#endif

				return WhiteNoise(cell + RandomOffset3(seed));
			}

			float BlueNoise01(float3 uvs, int seed)
			{
				float frequency = max(_Frequency, 1.0);

				#ifdef _TILINGMODE_TILED
					frequency = round(frequency);
				#endif

				float3 cell = floor(uvs * frequency);
				float center = BlueHash(cell, frequency, seed);

				float neighborAverage = 0.0;
				neighborAverage += BlueHash(cell + float3( 1,  0,  0), frequency, seed);
				neighborAverage += BlueHash(cell + float3(-1,  0,  0), frequency, seed);
				neighborAverage += BlueHash(cell + float3( 0,  1,  0), frequency, seed);
				neighborAverage += BlueHash(cell + float3( 0, -1,  0), frequency, seed);
				neighborAverage += BlueHash(cell + float3( 1,  1,  0), frequency, seed);
				neighborAverage += BlueHash(cell + float3(-1,  1,  0), frequency, seed);
				neighborAverage += BlueHash(cell + float3( 1, -1,  0), frequency, seed);
				neighborAverage += BlueHash(cell + float3(-1, -1,  0), frequency, seed);
				neighborAverage *= 0.125;

				float highPass = saturate((center - neighborAverage) * _Contrast + 0.5);
				return lerp(center, highPass, saturate(_BlueAmount));
			}

			float GenerateNoise(v2f_customrendertexture i, int seed)
			{
				float3 uvs = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), seed);

				#ifdef CRT_2D
					if (_UVMode == 0)
						uvs.z = 0.5;
				#endif

				float noise = BlueNoise01(uvs, seed);
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
