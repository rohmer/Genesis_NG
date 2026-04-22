Shader "Hidden/Genesis/PinkNoise"
{
	Properties
	{
		[InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
		[InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
		[InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

		[KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 0
		[ShowInInspector][Enum(2D, 0, 3D, 1)] _UVMode("UV Mode", Float) = 0
		[ShowInInspector][GenesisVector2]_OutputRange("Output Range", Vector) = (0, 1, 0, 0)
		_Frequency("Base Frequency", Float) = 4
		[IntRange]_Octaves("Octaves", Range(1, 12)) = 6
		_Lacunarity("Lacunarity", Float) = 2
		_Falloff("Amplitude Falloff", Range(0.1, 0.95)) = 0.5
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
			float _Octaves;
			float _Lacunarity;
			float _Falloff;
			float2 _OutputRange;
			int _Seed;
			int _Channels;
			int _UVMode;

			float3 SmoothValue(float3 value)
			{
				return value * value * value * (value * (value * 6.0 - 15.0) + 10.0);
			}

			float3 PositiveModulo(float3 value, float period)
			{
				period = max(period, 1.0);
				return value - period * floor(value / period);
			}

			float PinkHash(float3 cell, float period, int seed)
			{
				#ifdef _TILINGMODE_TILED
					cell = PositiveModulo(cell, period);
				#endif

				return WhiteNoise(cell + RandomOffset3(seed));
			}

			float ValueNoise(float3 coordinate, float period, int seed)
			{
				float3 cell = floor(coordinate);
				float3 fraction = frac(coordinate);
				float3 blend = SmoothValue(fraction);

				float c000 = PinkHash(cell + float3(0, 0, 0), period, seed);
				float c100 = PinkHash(cell + float3(1, 0, 0), period, seed);
				float c010 = PinkHash(cell + float3(0, 1, 0), period, seed);
				float c110 = PinkHash(cell + float3(1, 1, 0), period, seed);
				float c001 = PinkHash(cell + float3(0, 0, 1), period, seed);
				float c101 = PinkHash(cell + float3(1, 0, 1), period, seed);
				float c011 = PinkHash(cell + float3(0, 1, 1), period, seed);
				float c111 = PinkHash(cell + float3(1, 1, 1), period, seed);

				float x00 = lerp(c000, c100, blend.x);
				float x10 = lerp(c010, c110, blend.x);
				float x01 = lerp(c001, c101, blend.x);
				float x11 = lerp(c011, c111, blend.x);
				float y0 = lerp(x00, x10, blend.y);
				float y1 = lerp(x01, x11, blend.y);

				return lerp(y0, y1, blend.z);
			}

			float PinkNoise01(float3 uvs, int seed)
			{
				float frequency = max(_Frequency, 1.0);
				float lacunarity = max(_Lacunarity, 1.0);

				#ifdef _TILINGMODE_TILED
					frequency = round(frequency);
					lacunarity = round(lacunarity);
				#endif

				int octaveCount = (int)clamp(round(_Octaves), 1.0, 12.0);
				float falloff = clamp(_Falloff, 0.01, 0.99);
				float amplitude = 1.0;
				float amplitudeSum = 0.0;
				float total = 0.0;

				for (int octave = 0; octave < 12; octave++)
				{
					if (octave >= octaveCount)
						break;

					float octaveFrequency = max(frequency, 1.0);
					float noise = ValueNoise(uvs * octaveFrequency, octaveFrequency, seed + octave * 1013);
					total += (noise * 2.0 - 1.0) * amplitude;
					amplitudeSum += amplitude;
					amplitude *= falloff;
					frequency *= lacunarity;

					#ifdef _TILINGMODE_TILED
						frequency = round(frequency);
					#endif
				}

				return amplitudeSum > 0.0 ? total / amplitudeSum * 0.5 + 0.5 : 0.0;
			}

			float GenerateNoise(v2f_customrendertexture i, int seed)
			{
				float3 uvs = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), seed);

				#ifdef CRT_2D
					if (_UVMode == 0)
						uvs.z = 0.5;
				#endif

				float noise = PinkNoise01(uvs, seed);
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
