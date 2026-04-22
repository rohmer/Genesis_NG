Shader "Hidden/Genesis/VelvetNoise"
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
		_Density("Impulse Density", Range(0, 1)) = 0.18
		_Radius("Impulse Radius", Range(0.01, 0.75)) = 0.18
		_Softness("Softness", Range(0, 1)) = 0.2
		_Seed("Seed", Int) = 42
		[Tooltip(Select how many noise values to generate and which channels to write. More channels cost more impulse evaluations.)]
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
			float _Density;
			float _Radius;
			float _Softness;
			float2 _OutputRange;
			int _Seed;
			int _Channels;
			int _UVMode;

			float3 PositiveModulo(float3 value, float period)
			{
				period = max(period, 1.0);
				return value - period * floor(value / period);
			}

			float VelvetHash(float3 cell, float period, int seed)
			{
				#ifdef _TILINGMODE_TILED
					cell = PositiveModulo(cell, period);
				#endif

				return WhiteNoise(cell + RandomOffset3(seed));
			}

			float3 VelvetPointOffset(float3 cell, float period, int seed)
			{
				return float3(
					VelvetHash(cell, period, seed + 137),
					VelvetHash(cell, period, seed + 271),
					VelvetHash(cell, period, seed + 389));
			}

			float VelvetImpulse(float3 coordinate, float3 impulseCell, float period, int seed, float is2D)
			{
				float activation = VelvetHash(impulseCell, period, seed + 521);
				float active = activation <= saturate(_Density) ? 1.0 : 0.0;
				float3 impulsePosition = impulseCell + VelvetPointOffset(impulseCell, period, seed);
				impulsePosition.z = lerp(impulsePosition.z, coordinate.z, is2D);

				float radius = max(_Radius, 0.001);
				float normalizedDistance = length(coordinate - impulsePosition) / radius;
				float softness = saturate(_Softness);
				float hardImpulse = normalizedDistance <= 1.0 ? 1.0 : 0.0;
				float softImpulse = 1.0 - smoothstep(max(0.0, 1.0 - softness), 1.0, normalizedDistance);
				return active * lerp(hardImpulse, softImpulse, step(0.001, softness));
			}

			float VelvetNoise2D(float3 coordinate, float period, int seed)
			{
				float3 baseCell = floor(coordinate);
				float value = 0.0;

				[unroll]
				for (int y = -1; y <= 1; y++)
				{
					[unroll]
					for (int x = -1; x <= 1; x++)
					{
						float3 impulseCell = baseCell + float3(x, y, 0);
						value = max(value, VelvetImpulse(coordinate, impulseCell, period, seed, 1.0));
					}
				}

				return value;
			}

			float VelvetNoise3D(float3 coordinate, float period, int seed)
			{
				float3 baseCell = floor(coordinate);
				float value = 0.0;

				[unroll]
				for (int z = -1; z <= 1; z++)
				{
					[unroll]
					for (int y = -1; y <= 1; y++)
					{
						[unroll]
						for (int x = -1; x <= 1; x++)
						{
							float3 impulseCell = baseCell + float3(x, y, z);
							value = max(value, VelvetImpulse(coordinate, impulseCell, period, seed, 0.0));
						}
					}
				}

				return value;
			}

			float VelvetNoise01(float3 uvs, int seed)
			{
				float frequency = max(_Frequency, 1.0);

				#ifdef _TILINGMODE_TILED
					frequency = round(frequency);
				#endif

				float3 coordinate = uvs * frequency;

				#ifdef CRT_2D
					if (_UVMode == 0)
						return VelvetNoise2D(coordinate, frequency, seed);
				#endif

				return VelvetNoise3D(coordinate, frequency, seed);
			}

			float GenerateNoise(v2f_customrendertexture i, int seed)
			{
				float3 uvs = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), seed);

				#ifdef CRT_2D
					if (_UVMode == 0)
						uvs.z = 0.5;
				#endif

				float noise = VelvetNoise01(uvs, seed);
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
