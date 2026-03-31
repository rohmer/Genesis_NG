﻿Shader "Hidden/Genesis/Marble"
{	
	Properties
	{	
		[Tooltip(Scale of the marble)]
		_Scale("Scale", Range(0.25,100))=3
		[Tooltip(Length vs width ratio)]
		_Ratio("Ratio", float)=1.0
		[Tooltip(Defines the level of cracking added to the output)]
		_Crack_Depth("Cracking", Range(0.5, 10))=3.5
		[Tooltip(Adjustments change the shape of the cracks)]
		_Crack_Zebra_Scale("Crack Scale",Range(0.1,10.0))=2.25
		[Tooltip(Larger numbers equate to more whorlly cracks, smaller numbers more poliginal)]
		_Crack_Zebra_Amp("Crack shape", Range(0.1,5.0))=0.66
		[Tooltip(Determines the width of the individual cracks, simulating aging.  0.9 is tight cracking, 1.1 is wider more worn cracking)]
		_Crack_Profile("Crack Profile", Range(0.8,1.8))=1.0
		[Tooltip(Slope of crack.  Additional modifications to the thickness of the cracking feature)]
		_Crack_Slope("Crack Slope",Range(30,100))=55
		[Tooltip(Amplify jittering of Voronoi)]
		[Enum(Disable,0,Enable,1)]_AmpJitter("Amplify Jitter", int)=1
		[Tooltip(Level of effect of Perlin noise)]
		[Enum(Low,0,Medium,1,High,2)]_Mod("Perlin Effect", int)=1
		[Tooltip(Will output in color for further processing)]
		[Enum(Disable,0,Enable,1)]_MM("Colorize", int)=0
		_Seed("Seed", int)=52
	}
	 
	SubShader
    {
    	Tags { "RenderType"="Opaque" }
		LOD 100
		Cull Off
        ZWrite Off
        ZTest Always
        Blend One Zero
 
		Pass
		{
			HLSLPROGRAM
			#define BUILTIN_TARGET_API					
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			float _Ratio, _Crack_Depth, _Crack_Profile,_Crack_Slope,_Crack_Zebra_Amp, _Crack_Zebra_Scale, _Scale;
			int _AmpJitter,_Mod, _Seed, _MM;

			// Output: float3 in [0,1]
			inline float3 hash3(float3 p)
			{
				// Constants chosen for good spectral properties
				float3 dotVec = float3(127.1, 311.7, 74.7);
				float3 sinVec = float3(269.5, 183.3, 419.2);

				// Apply dot product and sine, then fract
				float3 h = sin(dot(p, dotVec) + sinVec) * 43758.5453;
				return frac(h);
			}


			inline float2 hash22(float2 p)
			{
				float2x2 m = float2x2(127.1, 311.7,
									  269.5, 183.3);

				// Multiply, take sine, scale, and fract
				float2 s = sin(mul(p, m)) * 18.5453;
				return frac(s);
			}

			inline float2 disp(float2 p)
			{
				float ofs=0;
				if(_AmpJitter==1)
				{
					ofs=0.5;
				}
				return -ofs + (1.0 + 2.0 * ofs) * hash22(p);
			}

			// HLSL voronoi function
			// Returns: x = distance to nearest cell center, y/z = ID vector (cell position + offset)
			inline float3 voronoi(float2 u)
			{
				float2 iu = floor(u);
				float2 v = 0.0;
				float m = 1e9;
				float d;

				if(_AmpJitter==1)
				{
					// 5x5 neighborhood				
					[unroll]
					for (int k = 0; k < 25; k++)
					{
						float2 p = iu + float2((k % 5) - 2, (k / 5) - 2);
						float2 o = disp(p); // your disp() function from earlier
						float2 r = p - u + o;
						d = dot(r, r);
						if (d < m)
						{
							m = d;
							v = r;
						}
					}
				} else
				{
					[unroll]
					for (int k = 0; k < 9; k++)
					{
						float2 p = iu + float2((k % 3) - 1, (k / 3) - 1);
						float2 o = disp(p); // your disp() function from earlier
						float2 r = p - u + o;
						d = dot(r, r);
						if (d < m)
						{
							m = d;
							v = r;
						}
					}
				}
								
				return float3(sqrt(m), v + u);
			}

			// Returns: x = distance to nearest edge, y/z = ID vector (cell position + offset)
			inline float3 voronoiB(float2 u)
			{
				float2 iu = floor(u);
				float2 C = 0.0;
				float2 P = 0.0;
				float m = 1e9;
				float d;

				// First pass: find closest cell center
				if (_AmpJitter==1)
				{
					// 5x5 neighborhood
					[unroll]
					for (int k = 0; k < 25; k++)
					{
						float2 p = iu + float2((k % 5) - 2, (k / 5) - 2);
						float2 o = disp(p);
						float2 r = p - u + o;
						d = dot(r, r);
						if (d < m)
						{
							m = d;
							C = p - iu;
							P = r;
						}
					}
				} else
				{
					[unroll]
					for (int k = 0; k < 9; k++)
					{
						float2 p = iu + float2((k % 3) - 1, (k / 3) - 1);
						float2 o = disp(p);
						float2 r = p - u + o;
						d = dot(r, r);
						if (d < m)
						{
							m = d;
							C = p - iu;
							P = r;
						}
					}
				}
				// Second pass: find distance to nearest edge
				m = 1e9;
				[unroll]
				for (int k = 0; k < 25; k++)
				{
					float2 p = iu + C + float2((k % 5) - 2, (k / 5) - 2);
					float2 o = disp(p);
					float2 r = p - u + o;

					if (dot(P - r, P - r) > 1e-5)
					{
						m = min(m, 0.5 * dot((P + r), normalize(r - P)));
					}
				}

				return float3(m, P + u);
			}

			// HLSL equivalent of GLSL's hash21
			inline float hash21(float2 p)
			{
				// dot(p, float2(127.1, 311.7))
				float h = dot(p, float2(127.1, 311.7));
				return frac(sin(h) * 43758.5453123);
			}

			// HLSL 2D value noise with smoothstep interpolation
			inline float noise2(float2 p)
			{
				float2 i = floor(p);
				float2 f = frac(p);

				// Smoothstep: f = f*f*(3 - 2*f)
				f = f * f * (3.0 - 2.0 * f);

				float v = lerp(
							  lerp(hash21(i + float2(0, 0)), hash21(i + float2(1, 0)), f.x),
							  lerp(hash21(i + float2(0, 1)), hash21(i + float2(1, 1)), f.x),
							  f.y
						  );

				#if _Mod == 0
					return v;
				#elif _Mod == 1
					return 2.0 * v - 1.0;
				#elif _Mod == 2
					return abs(2.0 * v - 1.0);
				#else
					return 1.0 - abs(2.0 * v - 1.0);
				#endif
			}

			// Rotation matrix helper
			inline float2x2 rot(float angle)
			{
				float s = sin(angle);
				float c = cos(angle);
				return float2x2(c, -s,
								s,  c);
			}

			// Fractal Brownian Motion (fbm2) using noise2()
			inline float fbm2(float2 p)
			{
				float v = 0.0;
				float a = 0.5;
				float2x2 R = rot(0.37);

				[unroll]
				for (int i = 0; i < 9; i++)
				{
					p = mul(R, p);       // rotate
					v += a * noise2(p);  // accumulate noise
					p *= 2.0;            // scale up frequency
					a *= 0.5;            // scale down amplitude
				}

				return v;
			}

			inline float2 noise22(float2 p)
			{
				return float2(
					noise2(p),
					noise2(p + float2(17.7, 17.7))
				);
			}

			// fbm22: 2D fractal Brownian motion returning float2
			inline float2 fbm22(float2 p)
			{
				float2 v = float2(0.0, 0.0);
				float a = 0.5;
				float2x2 R = rot(0.37);

				[unroll]
				for (int i = 0; i < 6; i++)
				{
					p = mul(R, p);       // rotate
					v += a * noise22(p); // accumulate noise
					p *= 2.0;            // increase frequency
					a *= 0.5;            // decrease amplitude
				}

				return v;
			}

			// mfbm22: multifractal fbm returning float2
			inline float2 mfbm22(float2 p)
			{
				float2 v = float2(1.0, 1.0);
				float a = 0.5;
				float2x2 R = rot(0.37);

				[unroll]
				for (int i = 0; i < 6; i++)
				{
					p = mul(R, p);                // rotate
					// v *= 1.0 + noise22(p);     // alternative multiplicative form
					v += v * a * noise22(p);      // current form
					p *= 2.0;                     // increase frequency
					a *= 0.5;                     // decrease amplitude
				}

				return v - 1.0;
			}

			float4 genesis(v2f_customrendertexture i)
			{	
				float2 UV=i.localTexcoord.xy*_Scale;
				//UV=4./_ScreenParams.y;
				UV+=_Seed;
				float4 O=float4(1.0-voronoiB(UV).x, voronoi(UV).x,0,0);
				float2 I = floor(UV / 2.0);
				bool vert = fmod(I.x + I.y, 2.0) == 0.0;

				float3 H0;
				O-=O;
				for(float i=0;i<_Crack_Depth; i++)
				{
					float2 V=UV/float2(_Ratio,1.0);
					float2 D=_Crack_Zebra_Amp*fbm22(UV/_Crack_Zebra_Scale)*_Crack_Zebra_Scale;
					float3 H=voronoiB(V+D);
					if(i==0)
					{
						H0=H;
					}
					float d=H.x;
					d = min( 1., _Crack_Slope * pow(max(0.,d),_Crack_Profile));
					O += float4(1.0 - d, 1.0 - d, 1.0 - d, 1.0 - d) / exp2(i);
					UV = mul((1.5 + rot(0.37)), UV);


				}
				if(_MM==1)
				{
					H0.z=0;
					O.g=hash3(H0).x;
				}
				return O;
			}
			ENDHLSL
		}
	}
}
