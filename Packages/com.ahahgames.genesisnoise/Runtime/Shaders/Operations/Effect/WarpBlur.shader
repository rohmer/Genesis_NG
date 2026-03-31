Shader "Hidden/Genesis/WarpBlur"
{	
	Properties
	{
		[Tooltip(First Texture)][InlineTexture]_Source1_2D("Source1", 2D) = "white" {}
		[Tooltip(First Texture)][InlineTexture]_Source1_3D("Source1", 3D) = "white" {}
		[Tooltip(First Texture)][InlineTexture]_Source1_Cube("Source1", Cube) = "white" {}
		[Tooltip(Second Texture)][InlineTexture]_Source2_2D("Source2", 2D) = "white" {}
		[Tooltip(Second Texture)][InlineTexture]_Source2_3D("Source2", 3D) = "white" {}
		[Tooltip(Second Texture)][InlineTexture]_Source2_Cube("Source2", Cube) = "white" {}
		[Tooltip(Strength)]_Strength("Warp Strength", Range(0.0,3.0)) = 0.3
		[Tooltip(Position of warp.  0 is fully source 1.  1 is fully source 2)]_Position("Warp Position", Range(0.0,1.0)) = 0.5
		[Tooltip(Seed of randomness)]_Seed("Seed",int)=52

		HLSLINCLUDE
		#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

		#pragma target 3.0
		// The list of defines that will be active when processing the node with a certain dimension
		#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
		#pragma vertex CustomRenderTextureVertexShader
		#pragma fragment GenesisFragment

		TEXTURE_SAMPLER_X(_Source1);
		TEXTURE_SAMPLER_X(_Source2);
		float _Strength;
		float _Position;
		int _Seed;

		#define PI = 3.141592653589793;

		float LinearEase(float begin, float change, float duration, float time)
		{
			return change * time / duration + begin;
		}

		float ExponentialEaseInOut(float begin, float change, float duration, float time)
		{
			if (time == 0.0)
				return begin;
			else if (time == duration)
				return begin + change;

			time = time / (duration * 0.5);

			if (time < 1.0)
				return change * 0.5 * pow(2.0, 10.0 * (time - 1.0)) + begin;

			return change * 0.5 * (-pow(2.0, -10.0 * (time - 1.0)) + 2.0) + begin;
		}

		float SinusoidalEaseInOut(float begin, float change, float duration, float time)
		{
			return -change * 0.5 * (cos(3.14159265 * time / duration) - 1.0) + begin;
		}

		float random(float3 scale, float3 pos, int seed)
		{
			float3 fragCoord = float3(pos.xy, 0.0); // Simulate gl_FragCoord.xyz
			return frac(sin(dot(fragCoord + seed, scale)) * 43758.5453 + seed);
		}

		float3 crossFade(float3 uv, float dissolve, float3 dir)
		{
			float4 col0 = SAMPLE_X(_Source1, uv, dir);
			float4 col1 = SAMPLE_X(_Source2, uv, dir);
			return lerp(col0, col1, dissolve);
		}
			
		ENDHLSL
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100		
		Pass
		{
			Name "Warp Blur"			

			HLSLPROGRAM
			float4 genesis(v2f_customrendertexture i) : SV_Target
			{
				float3 texCoord=i.localTexcoord/_ScreenParams;
				float progress=sin(_Position)*0.5+0.5;
				float3 center=float3(LinearEase(0.5,0.0,1.0,progress),0.5,0.5);
				float dissolve=ExponentialEaseInOut(0.0,_Strength,0.5,progress);
				float3 color=float3(0.0,0.0,0.0);

				float total=0.0;
				float3 toCenter=center-texCoord;
				 /* randomize the lookup values to hide the fixed number of samples */
				float offset = random(float3(12.9898, 78.233, 151.7182), 0.0, _Seed)*0.5;

				[unroll]
				for (float t = 0.0; t <= 20.0; t++) {
					float percent = (t + offset) / 20.0;
					float weight = 1.0 * (percent - percent * percent);
					float3 first=texCoord+toCenter*percent*_Strength;

					color += crossFade(first, dissolve, i.direction) * weight;
					total += weight;
				}

				return float4(color,1);
			}
			ENDHLSL
		}
	}
}
