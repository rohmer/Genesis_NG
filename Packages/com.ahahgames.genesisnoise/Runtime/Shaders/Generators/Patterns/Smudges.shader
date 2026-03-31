﻿Shader "Hidden/Genesis/Smudges"
{	
	Properties
	{				
		[InlineTexture(HideInNodeInspector)]_Mask_2D("Mask", 2D) = "white" {}
		[InlineTexture(HideInNodeInspector)]_Mask_3D("Mask", 3D) = "white" {}
		[InlineTexture(HideInNodeInspector)]_Mask_Cube("Mask", Cube) = "white" {}

		[Tooltip(Enable scratch mask texture)]
		[Enum(Disabled, 0, Enabled, 1)] _UseMask("Use Mask", int) = 1

		[Tooltip(Noise generator for smudges)]
		[Enum(Value, 0, ValueCubic, 1, Cellular, 2)] _NoiseGenerator("Noise Generator", int) = 0

		[Tooltip(Fractal type for noise, PingPong tends to make islands which are a good starting point for smudging)]
		[Enum(PingPong,0,FBM,1,Ridged,2)] _FractalType("Fractal Type", int) = 0

		[Tooltip(Octaves of noise)] _Octaves("Octaves", Range(1, 8)) = 4
		[Tooltip(Lacunarity of noise)] _Lacunarity("Lacunarity", Range(1.0, 4.0)) = 1.25
		[Tooltip(Frequency of noise, use lower values for realistic smudging except with Value generator, larger values are required)] _Frequency("Frequency", Range(0.0001, 5)) = .20
		[Tooltip(Gain of the noise, recommneded to use values higher than 1 to create larger smudges)]
		_Gain("Gain", Range(0.1, 10.0)) = 5.0
		[Tooltip(Weighted strength pushes the noise towards islands, very good for a smudging effect.  A side effect is that the smudges lose value variety at higher levels as they end up maxed at 1.0)]
		_WeightedStrength("Weighted Strength", Range(0.0, 8.0)) =  6.0
		[VisibleIf(_FractalType,0)]
		[Tooltip(Ping Pong strength increases the values across the noise.  Lower levels will create more islands, higher levels will fill in the noise completely)]
		_PingPongStrength("Ping Pong Strength", Range(0.0, 1.0)) = 0.280

		[VisibleIf(_NoiseGenerator, 2)]
		[Tooltip(Various distance functions for defining cellular noise)]
		[Enum(Euclidean, 0, EuclideanSq, 1, Manhattan, 2, Hybrid, 3)] _DistanceFunction("Distance Function", int) = 0

		[VisibleIf(_NoiseGenerator, 2)]
		[Tooltip(Return value of the noise function.  This has a fairly dramatic effect on the value, experiment or see the documentation for examples)]
		[GenesisNoiseValueReturn] _NoiseReturn("Noise Return", int) = 4

		[VisibleIf(_NoiseGenerator, 2)]
		[Tooltip(Jitter introduces more randomness to the noise, lower values result in fewer artifacts and more order)]
		_Jitter("Jitter", Range(0.8, 5.0)) = 1.6
			
		[Tooltip(Density of smudges, 0.1 to 0.2 is recommended)] _Density("Density", Range(0.0, 0.5)) = 0.2

		[Tooltip(Post generation blur.  This will smooth out the edges)] [Enum(Disabled, 0, Enabled, 1)] _Blur("Blur", int) = 1
		[VisibleIf(_Blur, 1)][Tooltip(Amount of blur, higher values are more expensive)] _BlurAmount("Blur Amount", Range(1, 8)) = 4

		[Tooltip(Push smudges in a direction)][Enum(Disabled, 0, Enabled, 1)] _DirectionalSmudge("Directional Smudge", int) = 1
		
		[VisibleIf(_DirectionalSmudge,1)][Tooltip(Direction of smudges in radians)] _Direction("Direction", Range(0, 6.283)) = 0.0	
		[VisibleIf(_DirectionalSmudge,1)][Tooltip(Smearing intensity 0..1, pushes and blurs the smudge to the direction defined above)]_SmearingIntensity("Smearing Intensity", Range(0, 1)) = 0.2
		[VisibleIf(_DirectionalSmudge,1)][Tooltip(Cross jitter adds an amount of randomness perpendicular to the direction)]
		_CrossJitter("Cross Jitter", Range(0, 4)) = 1.0

		[Tooltip(Seed for the noise generator)] _Seed("Seed", Int) = 52
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
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/FastNoiseLite.hlsl"
			#pragma vertex CustomRenderTextureVertexShader
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment

			// Variables
			TEXTURE_SAMPLER_X(_Mask);
			int _seed,_UseMask,_NoiseGenerator,_FractalType,_DistanceFunction,_NoiseReturn,_Blur,
				_DirectionalSmudge;
			float _Octaves,_Lacunarity,_Frequency,_Gain,_WeightedStrength,_PingPongStrength,_Jitter,
				_Density,_Direction,_SmearingIntensity, _CrossJitter;
			int _BlurAmount;

			fnl_state BuildState()
			{
				fnl_state state;
				state.seed = _seed;
				state.frequency = _Frequency;
				state.lacunarity = _Lacunarity;
				state.octaves = _Octaves;
				state.gain = _Gain;
				state.weighted_strength = _WeightedStrength;
				state.ping_pong_strength = _PingPongStrength;
				state.cellular_jitter_mod = _Jitter;
				state.cellular_distance_func = _DistanceFunction;
				state.cellular_return_type = _NoiseReturn;
				state.fractal_type = _FractalType;
				state.noise_type = _NoiseGenerator;
				return state;
			}

			float blur2(float2 iuv)
			{
				float total=0;
				int count=0;
				int halfBlur=int(_BlurAmount*0.5);
				float2 dir = float2(cos(_Direction), sin(_Direction));
				for(int x=-halfBlur;x<=halfBlur;x++)
				{
					for(int y=-halfBlur;y<=halfBlur;y++)
					{
						float2 offset = float2(x,y);
						//offset=offset-(dot(offset,dir)*dir*_SmearingIntensity);
						float2 uv=iuv+offset*(_Density*0.5);
						fnl_state state = BuildState();
						#ifdef CRT_2D
							total+=fnlGetNoise2D(state,uv.x, uv.y);
						#else				
							total+=fnlGetNoise3D(state,uv.y, uv.y, uv.z);
						#endif
						count++;
					}
				}
				return total/count;
			}
			
			float blur(v2f_customrendertexture i)
			{
				float total=0;
				int count=0;
				int halfBlur=int(_BlurAmount*0.5);
				float2 dir = float2(cos(_Direction), sin(_Direction));
				for(int x=-halfBlur;x<=halfBlur;x++)
				{
					for(int y=-halfBlur;y<=halfBlur;y++)
					{
						float2 offset = float2(x,y);
						//offset=offset-(dot(offset,dir)*dir*_SmearingIntensity);
						float2 uv=i.localTexcoord.xy+offset*(_Density*0.5);
						fnl_state state = BuildState();
						#ifdef CRT_2D
							total+=fnlGetNoise2D(state,uv.x, uv.y);
						#else				
							total+=fnlGetNoise3D(state,uv.y, uv.y, uv.z);
						#endif
						count++;
					}
				}
				return total/count;
			}

			float GetNoise(float3 uv)
			{
				fnl_state state = BuildState();
				float noise;
				#ifdef CRT_2D
					noise = fnlGetNoise2D(state,uv.x, uv.y);
				#else				
					noise = fnlGetNoise3D(state,uv.y, uv.y, uv.z);
				#endif
				return noise;	
			}

			float GetBlurredNoise(v2f_customrendertexture i)
			{
				if(_Blur==0)
				{
					return GetNoise(i.localTexcoord.xyz);
				}
				return blur(i);
			}
						
			float GetBlurredNoise2(float2 uv)
			{
				if(_Blur==0)
				{
					return GetNoise(float3(uv,0));
				}
				return blur2(uv);
			}

			float2 _TexelSize(float2 resolution) { return 1.0 / max(resolution, 1.0.xx); }
			float2 _DirNorm(float2 d)            { return normalize(d + 1e-8.xx); }
			float2 _Perp(float2 d)               { return float2(-d.y, d.x); }

			// 1) Constant directional warp (amount in pixels)
			float2 WarpDirUV(float2 uv, float2 dir, float amountPx, float2 resolution)
			{
				float2 nd   = _DirNorm(dir);
				float2 step = _TexelSize(resolution) * amountPx;
				return uv + nd * step;
			}

			// 2) Masked directional warp (per-pixel scalar mask 0..1)
			float2 WarpDirUV_Mask(float2 uv, float2 dir, float amountPx, float mask, float2 resolution)
			{
				float2 nd   = _DirNorm(dir);
				float2 step = _TexelSize(resolution) * (amountPx * mask);
				return uv + nd * step;
			}

			// 3) Noise-modulated directional warp with advection along dir
			//    - noiseTex: single-channel noise/blue-noise
			//    - noiseTiling: repeats per UV 0..1
			//    - speed: scroll units per second in noise UV space
			float2 WarpDirUV_Noise(
				Texture2D noiseTex, SamplerState samp,
				float2 uv,
				float2 dir,
				float  amountPx,
				float2 resolution,
				float2 noiseTiling,
				float  time,
				float  speed)
			{
				float2 nd   = _DirNorm(dir);
				float2 adv  = nd * (time * speed);
				float  n    = noiseTex.Sample(samp, uv * noiseTiling + adv).r; // 0..1
				float  m    = (n * 2.0 - 1.0);                                 // -1..1
				float2 step = _TexelSize(resolution) * (amountPx * m);
				return uv + nd * step;
			}

			// 4) Slightly “wider” streak by adding a small perpendicular jitter
			float2 WarpDirUV_NoiseWide(
				float2 uv,
				float2 dir,
				float  amountPx,
				float2 resolution,
				float2 noiseTiling,
				float  time,
				float  speed,
				float  crossJitter // pixels along perpendicular (e.g., 0..4)
			){
				float2 nd    = _DirNorm(dir);
				float2 pd    = _Perp(nd);
				float2 adv   = nd * (time * speed);
				float2 nUV   = uv * noiseTiling + adv;

				float  nL    = GetBlurredNoise2(nUV).r * 2.0 - 1.0; // main along-Dir
				float  nP    = GetBlurredNoise2(nUV + float2(0.37, 0.61)).r * 2.0 - 1.0; // decorrelated

				float2 texel = _TexelSize(resolution);
				float2 along = nd * (amountPx * nL);
				float2 cross = pd * (crossJitter * nP);

				return uv + (along + cross) * texel;
			}			


			float4 genesis(v2f_customrendertexture i)
			{				
				
				float n;

				if(_DirectionalSmudge==1)
				{
					n=WarpDirUV_NoiseWide(i.localTexcoord.xy,
						float2(cos(_Direction), sin(_Direction)),
						_Density,
						_ScreenParams.xy,
						float2(1,1),
						1,
						_SmearingIntensity,
						_CrossJitter
					).x;
				}
				if(_UseMask==1)
				{
					float mask = SAMPLE_X(_Mask, i.localTexcoord.xyz, i.direction).r;
					n=n*mask;
				}

				return float4(n,n,n,1);
			}
			ENDHLSL
		}
	}
}