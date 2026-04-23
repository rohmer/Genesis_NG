Shader "Hidden/Genesis/CurlNoise"
{	
	Properties
	{
		[InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
		[InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
		[InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
		[ShowInInspector][Enum(2D, 0, 3D, 1)]_UVMode("UV Mode", Float) = 0
		[ShowInInspector]_Lacunarity("Lacunarity", Float) = 2
		_Frequency("Frequency", Float) = 5
		_Persistance("Persistance", Float) = 0.5
		[IntRange]_Octaves("Octaves", Range(1, 12)) = 5
		_Seed("Seed", Int) = 42
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			HLSLPROGRAM
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/PerlinNoise.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma target 3.0

			// The list of defines that will be active when processing the node with a certain dimension
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV
			#pragma shader_feature _TILINGMODE_NONE _TILINGMODE_TILED

			TEXTURE_SAMPLER_X(_UV);
			float _Frequency;
			float _Octaves;
			float _Lacunarity;
			float _Persistance;
			int _Seed;
			int _UVMode;

			float4 genesis(v2f_customrendertexture i)
			{
				float3 uvs = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);
				SetupNoiseTiling(_Lacunarity, _Frequency);

				float3 noise = 0;
#ifdef CRT_2D
				if (_UVMode == 0)
					noise = float3(GeneratePerlin2DCurlNoise(uvs.xy, _Frequency, _Octaves, _Persistance, _Lacunarity, _Seed), 0);
				else
#endif
					noise = GeneratePerlin3DCurlNoise(uvs, _Frequency, _Octaves, _Persistance, _Lacunarity, _Seed);

				return float4(noise.xyz, 1);
			}
			ENDHLSL
		}
	}
}
