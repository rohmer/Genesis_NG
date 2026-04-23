﻿Shader "Hidden/Genesis/Dither"
{	
	Properties
	{
		// By default a shader node is supposed to handle all the input texture dimension, we use a prefix to determine which one is used
		[Tooltip(Source Texture)][InlineTexture]_Source_2D("Source", 2D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_3D("Source", 3D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_Cube("Source", Cube) = "white" {}
		[Tooltip(Dithering algorithm)][Enum(Equidistant,0,Ordered,1,Stepped,2,Random,3)]_Algo("Dithering Algorithm",int)=1
		[Tooltip(Number of samples, higher is more expensive)]
		[GenesisFibonacci]_Samples("Samples", int)=3
		[Tooltip(Seed for randomness)]_Seed("Seed", Float)=52
	}

	HLSLINCLUDE
	#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

	#pragma target 3.0
	// The list of defines that will be active when processing the node with a certain dimension
	#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
	#pragma vertex CustomRenderTextureVertexShader
	#pragma fragment GenesisFragment
	
	TEXTURE_SAMPLER_X(_Source);
	int _Algo;
	int _Samples;
	float _Seed;

	float nrand(float seed) 
	{	
		float2 n=(seed,seed);
		return frac(sin(dot(n.xy, float2(12.9898, 78.233)))* 43758.5453);
	}

	int SampEnumToInt()
	{
		if(_Samples==0)
			return 1;
		if(_Samples==1)
			return 2;
		if(_Samples==2)
			return 3;
		if(_Samples==3)
			return 5;
		if(_Samples==4)
			return 8;
		if(_Samples==5)
			return 13;
		if(_Samples==6)
			return 21;
		if(_Samples==7)
			return 34;
		return 5;
	}

	float4 DitherBandy(float3 pos, float stepVec,float3 dir)
	{
		float3 p=pos;
		float4 sum_bandy=SAMPLE_X(_Source,pos,dir);
		const float num_samples_f=float(SampEnumToInt());
		
		for(int i=1; i<SampEnumToInt(); i++)
		{
			p+=stepVec;
			sum_bandy+=SAMPLE_X(_Source,p,dir);
		}

		return(sum_bandy/num_samples_f);
	}

	float4 DitherOrdered(float3 pos, float stepVec, float3 dir, float3 fragCoord)
	{
		const float4 D2=0.25*float4(3,1,0,2);
		const float4 tgt=float4(0,1,2,3);
		float2 ij = floor(fmod(fragCoord.xy, float2(2.0, 2.0)));
		float idx=ij.x+2.0*ij.y;
		float4 m=step(abs(float4(idx,idx,idx,idx)-tgt),float4(0.5,0.5,0.5,0.5))*D2;
		float d=m.x+m.y+m.z+m.w;
		float3 p=pos+d*stepVec;
		float4 sum_ordered=SAMPLE_X(_Source,p,dir);
		const float num_samples_f=float(SampEnumToInt());
		
		for(int i=1; i<SampEnumToInt(); i++)
		{
			p+=stepVec;
			sum_ordered+=SAMPLE_X(_Source,p,dir);
		}
		return(sum_ordered/num_samples_f);
	}

	float4 DitherNoise(float3 pos, float stepVec, float3 dir)
	{
		float nrnd=nrand(_Seed);
		float srnd=nrnd-0.5;
		float3 p=pos+srnd*stepVec;
		const float num_samples_f=float(SampEnumToInt());

		float4 sum_noisy=SAMPLE_X(_Source,p,dir);		
		for(int i; i<SampEnumToInt(); i++)
		{
			p+=stepVec;
			sum_noisy+=SAMPLE_X(_Source,p,dir);
		}
		return(sum_noisy/num_samples_f);
	}

	float4 DitherOffset(float3 pos, float stepVec, float3 dir)
	{
		float nrnd=nrand(_Seed);		
		float3 p=pos+0.5*step(nrnd,0.5)*stepVec;
		float4 sum_dither=SAMPLE_X(_Source,p,dir);
		for(int i=1; i<SampEnumToInt(); i++)
		{
			p+=stepVec;
			sum_dither+=SAMPLE_X(_Source,p,dir);
		}
		const float num_samples_f=float(SampEnumToInt());

		return(sum_dither/num_samples_f);
	}

	float4 DitherAlgo(float3 pos, float stepVec, float3 dir, float3 fragCoord)
	{
		if(_Algo==0)
			return DitherBandy(pos, stepVec, dir);
		if(_Algo==1)
			return DitherOrdered(pos,stepVec,dir,fragCoord);
		if(_Algo==2)
			return DitherNoise(pos, stepVec, dir);
		if(_Algo==3)
			return DitherOffset(pos,stepVec,dir);
		return DitherOffset(pos,stepVec,dir);
	}		

	float4 Dither(float3 pos, float3 dir)
	{
		float2 uv=float2(0,1)+float2(1,-1)*pos.xy/_ScreenParams.xy;
		float2 uv2 = uv;
		uv.x=fmod(uv.x,0.25);
		float2 seed=uv2+frac(42);		
		float2 dist=float2(30.0,0)/_ScreenParams.xy;
		float2 p0=uv-0.5*dist;
		float2 p1=uv+0.5*dist;
		float2 stepvec=(p1-p0)/(SampEnumToInt()-1.0);
		
		return DitherAlgo(pos,stepvec,dir,pos);
	}

	ENDHLSL

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100		
		Pass
		{
			Name "Dithering"			

			HLSLPROGRAM
			float4 genesis(v2f_customrendertexture i) : SV_Target
			{
				return Dither(i.localTexcoord.xyz, i.direction);
			}
			ENDHLSL


		}
	}
}