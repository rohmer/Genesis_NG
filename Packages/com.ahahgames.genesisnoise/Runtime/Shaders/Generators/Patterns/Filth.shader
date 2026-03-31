Shader "Hidden/Genesis/Dirt"
{	
	Properties
	{		
		[InlineTexture]_Dirt_2D("Dirt Mask", 2D) = "white" {}
		[InlineTexture]_Dirt_3D("Dirt Mask", 3D) = "white" {}
		[InlineTexture]Dirt_Cube("Dirt Mask", Cube) = "white" {}

		[Tooltip(Add dirt generation)]
		[Enum(Disabled, 0, Enabled, 1)] _UseDirt("Use Dirt", int) = 1
		[VisibleIf(_UseDirt,1)] _DirtIntesity("Dirt Intensity", Range(0, 2)) = 0.5
		[VisibleIf(_UseDirt,1)] _DirtScale("Dirt Scale", Range(0,10)) = 1.0

		[Tooltip(Add smudge generation)]
		[Enum(Disabled, 0, Enabled, 1)] _UseSmudges("Use Smudge", int) = 1
		[InlineTexture]_Smudge_2D("Smudge Mask", 2D) = "white" {}
		[InlineTexture]_Smudge_3D("Smudge Mask", 3D) = "white" {}
		[InlineTexture]_Smudge_Cube("Smudge Mask", Cube) = "white" {}
		[VisibleIf(_UseSmudges,1)] _SmudgeIntensity("Smudge Intensity", Range(0, 2)) = 0.5
		[VisibleIf(_UseSmudges,1)] _SmudgeScale("Smudge Scale", Range(0, 10)) = 1.0 
		[VisibleIf(_UseScratches,1)] [GenesisVector2]_SmudgeDirection("Smudge Direction", Vector) = (1,1,0,0)
		
		[Tooltip(Add scratch generation)]
		[Enum(Disabled, 0, Enabled, 1)] _UseScratches("Use Scratches", int) = 1
		[InlineTexture]_Scratches_2D("Scratches Mask", 2D) = "white" {}
		[InlineTexture]_Scratches_3D("Scratches Mask", 3D) = "white" {}
		[InlineTexture]_Scratches_Cube("Scratches Mask", Cube) = "white" {}
		[VisibleIf(_UseScratches,1)] _ScratchesIntensity("Scratch Intensity", Range(0, 2)) = 0.5
		[VisibleIf(_UseScratches,1)] _ScratchesFrequency("Scratch Frequency", Range(0, 10)) = 0.25

		[Tooltip(Add rain streaks)]
		[Enum(Disabled, 0, Enabled, 1)] _UseRainStreaks("Use Rain Streaks", int) = 1
		[InlineTexture]_RainStreaks_2D("Rain Streaks Mask", 2D) = "white" {}
		[InlineTexture]_RainStreaks_3D("Rain Streaks Mask", 3D) = "white" {}
		[InlineTexture]_RainStreaks_Cube("Rain Streaks Mask", Cube) = "white" {}	 				
		[VisibleIf(_UseRainStreaks,1)] _RainStreaksIntensity("Rain Intensity", Range(0, 2)) = 0.5
		[VisibleIf(_UseRainStreaks,1)] _RainStreaksSpeed("Rain Speed", Range(0, 10)) = 0.25
		[VisibleIf(_UseRainStreaks,1)] _RainStreaksLength("Rain Length", Range(0, 10)) = 1.0

		[Tooltip(Add a condensation effect)]
		[Enum(Disabled, 0, Enabled, 1)] _UseCondensation("Use Condensation", int) = 1
		[InlineTexture]_Condensation_2D("Condensation Mask", 2D) = "white" {}
		[InlineTexture]_Condensation_3D("Condensation Mask", 3D) = "white" {}
		[InlineTexture]_Condensation_Cube("Condensation Mask", Cube) = "white" {}
		[VisibleIf(_UseCondensation,1)] _CondensationIntensity("Condensation Intensity", Range(0, 2)) = 0.5
		[VisibleIf(_UseCondensation,1)] _CondensationSpread("Condensation Spread", Range(0, 10)) = 1.0
		[VisibleIf(_UseCondensation,1)] _CondensationEdge("Condesentation sharpness", Range(0,1)) = 0.25
		
		[Tooltip(Modifying the time moves the animation along)]
		_Time("Time", Range(0,100)) = 52.0

		
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
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/ValueNoise.hlsl"
			
			#pragma vertex CustomRenderTextureVertexShader
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment

			int _UseCondensation,_UseDirt, _UseSmudges, _UseScratches, _UseRainStreaks;
			float _DirtIntesity, _DirtScale, _SmudgeIntensity, _SmudgeScale, _ScratchesIntensity, _ScratchesFrequency, _RainStreaksIntensity, _RainStreaksSpeed, _RainStreaksLength, _CondensationIntensity, _CondensationSpread, _CondensationEdge;
			float2 _SmudgeDirection;
			float _Time;
			// Samplers			
			SAMPLER_X(_Dirt);
			SAMPLER_X(_Smudge);
			SAMPLER_X(_RainStreaks);
			SAMPLER_X(_Scratches);
			SAMPLER_X(_Condensation);

			float hash21(float2 p)
			{
				p = frac(p * float2(123.34, 456.21));
				p += dot(p, p + 45.32);
				return frac(p.x * p.y);
			}

			float noise(float2 p)
			{
				float2 i = floor(p);
				float2 f = frac(p);
				float a = hash21(i);
				float b = hash21(i + float2(1, 0));
				float c = hash21(i + float2(0, 1));
				float d = hash21(i + float2(1, 1));
				float2 u = f * f * (3.0 - 2.0 * f);
				return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
			}

			float dirtLayer(float3 uv, float3 dir)
			{
				float n = noise(uv * _DirtScale + _Time * 0.1);
				float texMask=SAMPLE_X(_Dirt,  uv, dir).r;
				return lerp(n, texMask, 0.5) * _DirtIntesity;
			}

			float smudgeLayer(float3 uv, float3 dir)
			{
				float2 offset = _SmudgeDirection * sin(dot(uv, float2(20.0, 20.0)) + _Time) * 0.01 * _SmudgeScale;
				float texMask=SAMPLE_X(_Smudge, float3(uv+offset,uv.z), dir).r;
				return texMask * _SmudgeIntensity;
			}

			float scratchLayer(float3 uv, float3 dir)
			{
				float stripe = smoothstep(0.0, 0.01, abs(sin(uv.y * _ScratchesFrequency + _Time * 5.0)));
				float texMask = SAMPLE_X(_Scratches,  uv, dir).r;
				return max(stripe, texMask) * _ScratchesIntensity;
			}

			float rainStreakLayer(float3 uv, float3 dir)
			{
				float3 scrollUV = uv;
				scrollUV.y += _Time * _RainStreaksSpeed;
				float streak = SAMPLE_X(_RainStreaks, scrollUV, dir).r;
				
				streak *= smoothstep(0.0, _RainStreaksLength, uv.y); // fade near bottom
				return streak * _RainStreaksIntensity;
			}

			float condensationLayer(float3 uv, float3 dir)
			{
				float fog = SAMPLE_X(_Condensation, uv, dir).r;
				float edge = smoothstep(0.0, _CondensationEdge, length(uv - 0.5));
				return fog * edge * _CondensationSpread * _CondensationIntensity;
			}





			float4 genesis(v2f_customrendertexture i)
			{				
				float4 baseColor= float4(GetDefaultUVs(i),1);
				float3 uv=i.localTexcoord;
				float dirt=1;
				if(_UseDirt==1)
				{
					dirt=dirtLayer(uv,i.direction);
				}
				float smudge=0;
				float scratches=0;
				float rain=0;
				float condensation=0;

				if(_UseSmudges==1)
				{
					float smudge=smudgeLayer(uv,i.direction);
				}
				if(_UseScratches==1)
				{
					float scratches=scratchLayer(uv,i.direction);
				}
				if(_UseRainStreaks==1)
				{
					float rain=rainStreakLayer(uv,i.direction);
				}
				if(_UseCondensation==1)
				{
					float condensation=condensationLayer(uv,i.direction);	
				}

				float grime = saturate(dirt + smudge + scratches + rain + condensation);
				float4 grimeColor = lerp(baseColor, float4(0, 0, 0, 1), grime);

				return grimeColor;
			}
			ENDHLSL
		}
	}
}