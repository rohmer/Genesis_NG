Shader "Hidden/Genesis/FBMD"
{	
	Properties
	{
		[InlineTexture]_UV_2D("UV", 2D) = "white" {}
		[InlineTexture]_UV_3D("UV", 3D) = "white" {}
		[InlineTexture]_UV_Cube("UV", Cube) = "white" {}
		[Tooltip(The variant of input for FBMD)]	
		[Enum(Value,0,Perlin,1)] _FBMType("FBMD Type",int)=0
		[Tooltip(Number of tiles, x and y)]
		[GenesisVector2I] _Scale("Scale",vector) = (5,5,0,0)
		[IRange] _Octaves("Octaves", Range(1,32)) = 5
		[Tooltip(Axial or rotational shift for each octave)]
		[VisibleIf(_FBMType, 1)] _AxialShift("Axial Shift",Float)=0
		[Tooltip(Position shift for each octave)]
		[VisibleIf(_FBMType, 0,)] _Shift("Shift", Range(0,100)) = 0
		[Tooltip(Mode used in combining the noise for the ocatves)]
		[VisibleIf(_FBMType, 1)]
		[Enum(AbsMult,0,Abs,1,Equal,2,Multiplied,3,AvgMultiplied,4,Avg,5)] _Mode("Mode", int)=0
		[Tooltip(Time shift for each octave)]
		[VisibleIf(_FBMType,0)] _TimeShift("Time Shift", Float) = 0
		[Tooltip(Gain for each octave)]
		_Gain("Gain", Range(0.0,2.0)) = 0.5
		_Lacunarity("Lacunarity", Range(1,32)) = 1
		[Tooltip(The octave intensity factor, the lower the more pronounced the lower octaves will be)]
		_OctaveFactor("OctaveFactor", Range(-1.0,1.0)) = 0
		_Slopeness("Slopeness", Range(0,1)) = 0.25
		[Tooltip(Interpolate factor between the multiplication mode and normal mode)]
		[VisibleIf(_FBMType, 2)] _Interp("Interpolate", Float)=0
		[ToolTip(Jitter factor for the cells, if zero then it will result in a square grid)]
		[VisibleIf(_FBMType, 2)] _Jitter("Jitter", Range(0.0,1.0)) = 1.0
		[Tooltip(Offsets the value of the noise)]
		[VisibleIf(_FBMType, 1)] _Offset("Offset", Range(-1.0,1.0))=0		
		[GenesisChannelMask] _ChannelMask("Channel Output",int)=6
		[Tooltip(Interpolate factor between the multiplication mode and normal mode)]
		_Seed("Seed value", int) = 0		
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
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFBM.hlsl"
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisVoronoi.hlsl"

			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV

			int _Lacunarity;
			float2 _Scale;
			float _Shift;
			float _TimeShift;
			float _Gain;
			float _OctaveFactor;
			int _Seed;
			int _Octaves;
			int _FBMType;
			int _Mode;
			float _AxialShift;
			float _PowIntensity;
			float _Offset;
			float _Interp;
			float _Jitter;
			float _Translate;
			float _WarpStrength;
			float _Width;
			float _Slopeness;
			int _ChannelMask;

			float4 mixture (v2f_customrendertexture i) : SV_Target
            {
                float2 resolution = _ScreenParams.xy;
                
				#ifdef USE_CUSTOM_UV
				float uv = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);
			    #else
				float2 uv = GetDefaultUVs(i);
				#endif

				return (1,1,1,1);
			
				if(_FBMType==0)
				{
					float3 noise=fbmd(uv.xy,_Scale,_Octaves,_Shift,_TimeShift,_Gain,_Lacunarity,_Slopeness, _OctaveFactor,_Seed);
					float4 returnVal=float4(0,0,0,1);
					if((_ChannelMask & (1 << 0))!=0)
						returnVal.x=noise.x;
					if((_ChannelMask & (1 << 1))!=0)
						returnVal.y=noise.y;
					if((_ChannelMask & (1 << 2))!=0)
						returnVal.z=noise.z;

					return returnVal;
				}
				else
				{
					float3 noise=fbmdPerlin(uv.xy, _Scale, _Octaves, _Shift, _TimeShift, _Gain, _Lacunarity, _OctaveFactor, _Jitter, _Interp, _Seed);
					float4 returnVal=float4(0,0,0,1);
					if((_ChannelMask & (1 << 0))!=0)
						returnVal.x=noise.x;
					if((_ChannelMask & (1 << 1))!=0)
						returnVal.y=noise.y;
					if((_ChannelMask & (1 << 2))!=0)
						returnVal.z=noise.z;
						 
					return returnVal;
				}				
			}
			ENDHLSL
		}
	}
}