Shader "Hidden/Genesis/VoronoiNoise"
{	
	Properties
	{
		[Tooltip(Custom Noise UV)][InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
		[Tooltip(Custom Noise UV)][InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
		[Tooltip(Custom Noise UV)][InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}			
		[Enum(No, 0, Yes, 1)] _UseScaling("Use Scaling", Float)=1
		[VisibleIf(_UseScaling,1)] _ScaleFactor("Scaling Factor", Float) = 5
		[VisibleIf(_UseScaling,1,_ScaleFactor,0), Tooltip(Custom Time Scale)][InlineTexture(HideInNodeInspector)] _SCALE_2D("Scale", 2D) = "scale" {}
		[VisibleIf(_UseScaling,1,_ScaleFactor,0), Tooltip(Custom Time Scale)][InlineTexture(HideInNodeInspector)] _SCALE_3D("Scale", 3D) = "scale" {}
		[VisibleIf(_UseScaling,1,_ScaleFactor,0), Tooltip(Custom Time Scale)][InlineTexture(HideInNodeInspector)] _SCALE_Cube("Scale", Cube) = "scale" {}		
		[VisibleIf(_UseSmoothness,1), Tooltip(Custom Time Scale)][InlineTexture(HideInNodeInspector)] _SMOOTH_2D("Smoothness", 2D) = "smooth" {}
		[VisibleIf(_UseSmoothness,1), Tooltip(Custom Time Scale)][InlineTexture(HideInNodeInspector)] _SMOOTH_3D("Smoothness", 3D) = "smooth" {}
		[VisibleIf(_UseSmoothness,1), Tooltip(Custom Time Scale)][InlineTexture(HideInNodeInspector)] _SMOOTH_Cube("Smoothness", Cube) = "smooth" {}
		[Enum(None, 0, Tiled, 1)] _TilingMode("Tiling Mode", Float) = 1	
		[Enum(EuclideanSquared, 0, Euclidian, 1, Manhattan, 2, Chebyshev, 3, Minkowski, 4)] _DistanceFunction("Distance Function", Float) = 0
		[VisibleIf(_DistanceFunction, 4)] _MinkowskiPower("Minkowski Power", Float) = 1
		[Enum(Cells, 0, Crystal, 1, Glass, 2, Caustic, 3, Distance, 4)] _MethodType("Generation Method", Float) = 0
		[Enum(Nine, 9, TwentySeven, 27, FortyFive, 45, SixtyThree, 63)] _SearchQuality("Search Quality", Float) = 27
		[IntRange]_Octaves("Octaves", Range(1, 12)) = 5
		[Enum(NoiseValue, 0, UVValue, 1, IDValue, 2)] _ImageType("Image Type", Float) = 0
		_Seed("Seed", Int) = 42
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Name "Voronoi Shader"
			HLSLPROGRAM			
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"		
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma target 3.0

			// The list of defines that will be active when processing the node with a certain dimension
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV
			#pragma shader_feature _TILINGMODE_NONE _TILINGMODE_TILED
			#pragma shader_feature _ USE_CUSTOM_SCALE
			#pragma shader_feature _ USE_CUSTOM_SMOOTH

			// This macro will declare a version for each dimention (2D, 3D and Cube)
			TEXTURE_SAMPLER_X(_UV);
			TEXTURE_SAMPLER_X(_TIMEFRAME);
			TEXTURE_SAMPLER_X(_SMOOTH);
			TEXTURE_SAMPLER_X(_SCALE);
			float _Octaves;
			float _TilingMode;
			float _UseScaling;			
			float _DistanceFunction;
			float _MethodType;
			float _MinkowskiPower;
			float _SearchQuality;
			float _ImageType;
			float _UseSmoothness;
			float _ScaleFactor;
			int _Seed;

			float2 VoronoiHash( float2 p, float scale )
			{
				p = lerp( p,  p - scale * floor (p / scale), _UseScaling);
				p = float2(dot (p, float2(127.1, 311.7)), dot (p, float2(269.5, 183.3)));
				return frac (sin (p) *43758.5453);
			}
			
			float Voronoi( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, float scale )
			{
				float2 n = floor(v);
				float2 f = frac(v);
				float F1 = 8.0;
				float F2 = 8.0; 
				float2 mg = 0;
				for (int j = -_SearchQuality; j <= _SearchQuality; j++)
				{
					for (int i = -_SearchQuality; i <= _SearchQuality; i++)
					{
						float2 g = float2(i, j);
						float2 o = VoronoiHash (n + g, scale);
						o = (sin (time + o * 6.2831) * 0.5 + 0.5); float2 r = f - g - o;
						float d = 0;
						//Euclidean^2
						if (_DistanceFunction== 0)
						{
							d = 0.5 * dot (r, r);
						}
						//Euclidean
						else if (_DistanceFunction== 1)
						{
							d = 0.707 * sqrt (dot (r, r));
						}
						//Manhattan
						else if (_DistanceFunction== 2)
						{
							d = 0.5 * (abs (r.x) + abs (r.y));
						}
						//Chebyshev
						else if (_DistanceFunction== 3)
						{
							d = max (abs (r.x), abs (r.y));
						}
						//Minkowski
						else if (_DistanceFunction== 4)
						{
							d = (1 / pow(2, 1 / _MinkowskiPower))  * pow( ( pow( abs( r.x ), _MinkowskiPower) + pow( abs( r.y ), _MinkowskiPower) ),  (1 / _MinkowskiPower));
						}

						if (_MethodType == 0 && _UseSmoothness == 1)
						{
							float h = smoothstep (0.0, 1.0, 0.5 + 0.5 * (F1 - d) / smoothness);
							F1 = lerp (F1, d, h) - smoothness * h * (1.0 - h);
							mg = g; mr = r; id = o;
						}
						else
						{
							if (d < F1)
							{
								F2 = F1;
								F1 = d; mg = g; mr = r; id = o;
							}
							else if (d < F2)
							{
								F2 = d;
							}
						
						}

					}
				}

				//Cells
				if(_MethodType == 0)
				{
					return F1;
				}
				//Crystal
				else if (_MethodType == 1)
				{
					return F2;
				}
				//Glass 
				else if (_MethodType == 2)
				{
					return F2 - F1;
				}
				//Caustic
				else if (_MethodType == 3)
				{
					return (F2 + F1) * 0.5;
				}
				//Distance
				else if (_MethodType == 4)
				{
					F1 = 8.0;
					for (int j = -2; j <= 2; j++)
					{
						for (int i = -2; i <= 2; i++)
						{
							float2 g = mg + float2(i, j);
							float2 o = VoronoiHash (n + g, scale);
							o = ( sin (time + o * 6.2831) * 0.5 + 0.5); 
							float2 r = f - g - o;
							float d = dot (0.5 * (mr + r), normalize (r - mr));
							F1 = min (F1, d);
						}
					}
					return F1;
				}
				else
					return F1;
			}

			float GetSmoothValue(v2f_customrendertexture i)
			{
				if(_UseSmoothness==0)
				{
					return 0;
				}
				float3 smooths = GetNoiseUVs(i, SAMPLE_X(_SMOOTH, i.localTexcoord.xyz, i.direction), _Seed);
				float1 result = dot(smooths, float3(1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0));
				return result;
			}

			float GetScaleValue(v2f_customrendertexture i)
			{
				if(_UseScaling==0)
				{
					return 1;
				}
				if(_ScaleFactor!=0)
				{
					return _ScaleFactor;
				}
				float3 scale=GetNoiseUVs(i, SAMPLE_X(_SCALE,i.localTexcoord.xyz, i.direction), _Seed);
				float1 result=dot(scale,float3(1.0/3.0,1.0/3.0,1.0/3.0));
				return result;
			}

			float4 genesis(v2f_customrendertexture i)
			{
				float smoothness=GetSmoothValue(i);
				float scaling=GetScaleValue(i);
				float3 uvs = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);
				float2 coords1 = i.localTexcoord.xy;
				float2 id=0;
				float2 uv=0;
				coords1*=scaling;
				float noise = Voronoi(coords1, _Seed, id, uvs.xy, smoothness, scaling);
				if (_Octaves == 1)
				{
					if( _ImageType == 2)
						return float4( uv, 0, 1 );
					else if( _ImageType == 1)
						return float4( id, 0, 1 );
					else
						return float4(noise.xxx, 1);
				}
				else
				{
					float fade = 0.5;
					float voroi = 0;
					float rest = 0;
					for (int it = 0; it < _Octaves; it++)
					{
						voroi += fade * Voronoi( coords1, _Seed, id, uvs.xy, smoothness, scaling);
						rest += fade;
						uvs *= 2;
						fade *= 0.5;
					}
					voroi /= rest;
					if( _ImageType == 2)
						return float4( uvs, 1 );
					else if( _ImageType == 1)
						return float4( id, 0, 1 );
					else
						return float4(voroi.xxx, 1);
				}                                
				

			}
			ENDHLSL
		}
	}
}
