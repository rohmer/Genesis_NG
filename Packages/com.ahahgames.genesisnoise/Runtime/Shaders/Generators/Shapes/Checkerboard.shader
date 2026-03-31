Shader "Hidden/Genesis/Checkerboard"
{	
	Properties
	{
		[InlineTexture]_UV_2D("UV", 2D) = "white" {}
		[InlineTexture]_UV_3D("UV", 3D) = "white" {}
		[InlineTexture]_UV_Cube("UV", Cube) = "white" {}
		[Tooltip(Number of tiles per axis)] _Density("Tile Density",int) = 2	
		[Tooltip(Rotation of the tiles, Degrees)] _Rotation("Rotation", Range(0,359.9)) = 0
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
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/PerlinNoise.hlsl"
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV

			int _Density;
			float _Rotation;

			TEXTURE_SAMPLER_X(_UV);

			#pragma target 3.0
								
			float4 Checkerboard(float2 uv, float2 resolution, float density)
			{
				// Scale UVs to desired checker size
				float2 scaledUV = uv * density;

				// Compute checker pattern using floor and mod
				float checker = fmod(floor(scaledUV.x) + floor(scaledUV.y), 2.0);

				// Return black or white based on checker value
				return lerp(float4(1,1,1,1), float4(0,0,0,1), checker);
			}

			// Rotatable checkerboard function in HLSL
			// Parameters:
			// - uv: Normalized screen coordinates (0..1)
			// - resolution: Viewport resolution (optional if uv is already normalized)
			// - density: Controls the number of checkers (higher = more)
			// - angle: Rotation angle in radians (clockwise)

			float4 CheckerboardRotated(float2 uv, float2 resolution, float density, float angle)
			{
				// Shift to center
				float2 center = float2(0.5, 0.5);
				uv -= center;

				// Apply rotation matrix
				float s = sin(angle);
				float c = cos(angle);
				float2x2 rot = float2x2(c, -s, s, c);
				uv = mul(rot, uv);

				// Return to normalized space
				uv += center;

				// Scale UV to control checker density
				float2 scaledUV = uv * density;

				// Generate checker pattern
				float checker = fmod(floor(scaledUV.x) + floor(scaledUV.y), 2.0);

				// Output black or white based on checker
				return lerp(float4(1,1,1,1), float4(0,0,0,1), checker);
			}

			float4 genesis(v2f_customrendertexture i)
            {
                float2 resolution = _ScreenParams.xy;
                
				#ifdef USE_CUSTOM_UV
				float uv = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);
			    #else
				float2 uv = GetDefaultUVs(i);
				#endif

				return CheckerboardRotated(uv.xy, float2(1,1), _Density, _Rotation);
			}
           ENDHLSL
        }

	}
}