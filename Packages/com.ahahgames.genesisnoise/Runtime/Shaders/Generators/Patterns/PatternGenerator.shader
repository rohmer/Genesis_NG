Shader "Hidden/Genesis/PatternGenerator"
{	
	Properties
	{
		[InlineTexture]_UV_2D("UV", 2D) = "white" {}
		[InlineTexture]_UV_3D("UV", 3D) = "white" {}
		[InlineTexture]_UV_Cube("UV", Cube) = "white" {}

		[Enum(Wave, 0,Cross,1,Stairs,2,Weave,3,Capsule,4)] _PatternType("Pattern Type", int) = 0
		[Tooltip(X Scale)] _XScale("XScale", Range(0.1,100)) = 5
		[Tooltip(Y Scale)] _YScale("YScale", Range(0.1,100)) = 5
		[VisibleIf(_PatternType, 0, 3, 4)] _Width("Width", Range(0.01,1)) = 1
		[Tooltip(Smoothness)] _Smoothness("Smoothness", Range(0.0,1.0)) = 0.5
		[VisibleIf(_PatternType, 3, 4)] _Count("Count", Range(0.1,100)) = 5
		[VisibleIf(_PatternType, 0)]_Amplitude("Amplitude", Range(0.1,100)) = 1
		[VisibleIf(_PatternType, 0)]_Interp("Interpolate", Range(0.1,100)) = 1
		[VisibleIf(_PatternType, 2)]_Distance("Distance", Range(0.0,1.0)) = 0.5
		
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
			
            #pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV		
			TEXTURE_SAMPLER_X(_UV);
			float _XScale;
			float _YScale;
			float _Width;
			float _Smoothness;
			float _Amplitude;
			float _Interp;
			int _PatternType;
			float _Distance;
			float _Count;

			#define PI 3.141592

			float triangleWave(float x)
			{
				float t = x / (PI * 2.0f) + (PI / 4.0f);
				return abs(frac(t) * 2.0f - 1.0f) * 2.0f - 1.0f;
			}

			float wavePattern(float2 pos, float2 scale, float width, float smoothness, float amplitude, float interpolate)
			{
				scale = floor(scale);			

				float2 p;
				p.x = pos.x * PI * scale.x;
				p.y = pos.y * scale.y;

				float sy = p.y + amplitude * lerp(triangleWave(p.x), sin(p.x), interpolate);
				float t  = triangleWave(sy * scale.y * PI * 0.25f);

				float edge0 = max(width - smoothness, 0.0f);
				float edge1 = width;

				return 1.0f - smoothstep(edge0, edge1, t * 0.5f + 0.5f);
			}

			float crossPattern(float2 pos, float2 scale, float2 smoothness)
			{
				scale = floor(scale);
				float2 p = pos * scale;

				const float N = 3.0;
				float2 w = max(smoothness, float2(0.001, 0.001));
				float2 halfW = 0.5 * w;

				float2 a = p + halfW;
				float2 b = p - halfW;

				float2 x = floor(a) + min(frac(a) * N, 1.0) - floor(b) - min(frac(b) * N, 1.0);
				float2 i = x / (N * w);

				return 1.0 - i.x - i.y + 2.0 * i.x * i.y;
			}

			float stairsPattern(float2 pos, float2 scale, float width, float smoothness, float distance)
			{
				float2 p = pos * scale;
				float2 f = frac(p);

				float2 m = floor(fmod(p, float2(2.0, 2.0)));
				float d = lerp(f.x, f.y, abs(m.x - m.y));
				d = lerp(d, abs(d * 2.0 - 1.0), distance);

				return 1.0 - smoothstep(max(width - smoothness, 0.0), width, d);
			}

			float sdfLens(float2 p, float width, float height)
			{
				float d = height / width - width / 4.0;
				float r = width / 2.0 + d;

				p = abs(p);

				float b = sqrt(r * r - d * d);
				float4 par = float4(p.xy, p.x - (-d), p.y - b); // equivalent to p.xyxy - float4(0.0, b, -d, 0.0)

				return (par.y * d > p.x * b) ? length(par.xy) : length(par.zw) - r;
			}

			float3 tileWeave(float2 pos, float2 scale, float count, float width, float smoothness)
			{
				float2 i = floor(pos * scale);
				float c = fmod(i.x + i.y, 2.0);

				float2 p = frac(pos * scale);
				p = lerp(p, p.yx, c); // conditional axis swap
				p = frac(p * float2(count, 1.0));

				width *= 2.0;
				p = p * 2.0 - 1.0;

				float d = sdfLens(p, width, 1.0); // assumes sdfLens is defined elsewhere
				float2 grad = float2(ddx(d), ddy(d));

				float s = 1.0 - smoothstep(0.0, dot(abs(grad), float2(1.0, 1.0)) + smoothness, -d);
				return float3(s, normalize(grad) * smoothstep(1.0, 0.99, s) * smoothstep(0.0, 0.01, s));
			}

			float sdfCapsule(float2 p, float radiusA, float radiusB, float height)
			{
				// Capsule SDF based on Inigo Quilez
				p.x = abs(p.x);
				p.y += height * 0.5;

				float b = (radiusA - radiusB) / height;
				float2 c = float2(sqrt(1.0 - b * b), b);

				float3 mnk = float3(c.x, p.x, c.x) * float3(p.x, p.x, p.y) +
							 float3(c.y, p.y, -c.y) * float3(p.y, p.y, p.x);

				if (mnk.z < 0.0)
					return sqrt(mnk.y) - radiusA;
				else if (mnk.z > c.x * height)
					return sqrt(mnk.y + height * height - 2.0 * height * p.y) - radiusB;

				return mnk.x - radiusA;
			}

			float3 tileCapsule(float2 pos, float2 scale, float count, float2 width, float smoothness)
			{
				float2 i = floor(pos * scale);
				float c = fmod(i.x + i.y, 2.0);

				float2 p = frac(pos * scale);
				p = lerp(p, p.yx, c); // conditional axis swap
				p = frac(p * float2(count, 1.0));

				p = p * 2.0 - 1.0;

				float d = sdfCapsule(p, width.x, width.y, 1.0 - max(width.x, width.y) * 0.75); // assumes sdfCapsule is defined
				float2 grad = float2(ddx(d), ddy(d));

				float s = 1.0 - smoothstep(0.0, dot(abs(grad), float2(1.0, 1.0)) + smoothness, -d);
				return float3(s, normalize(grad) * smoothstep(1.0, 0.99, s) * smoothstep(0.0, 0.01, s));
			}

			float4 genesis(v2f_customrendertexture i)
            {
				float2 resolution = _ScreenParams.xy;
                
				#ifdef USE_CUSTOM_UV
				float uv = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);
				#else
				float2 uv = GetDefaultUVs(i);
				#endif
				float2 scale;
				scale.x=_XScale; 
				scale.y=_YScale;
				if(_PatternType==0)
				{
					float noise=wavePattern(uv.xy,scale,_Width,_Smoothness,_Amplitude,_Interp);
					return float4(noise,noise,noise,1);
				}
				if(_PatternType==1)
				{
					float noise=crossPattern(uv.xy,scale,_Smoothness);
					return float4(noise,noise,noise,1);
				}
				if(_PatternType==2)
				{
					float noise=stairsPattern(uv.xy,scale,_Width,_Smoothness,_Distance);
					return float4(noise,noise,noise,1);
				}
				if(_PatternType==3)
				{
					float noise=tileWeave(uv.xy,scale,_Count,_Width,_Smoothness);
					return float4(noise,noise,noise,1);
				}
				if(_PatternType==4)
				{
					float noise=tileCapsule(uv.xy,scale,_Count,_Width,_Smoothness);
					return float4(noise,noise,noise,1);
				}
				return float4(1,1,1,1);
			}
			ENDHLSL
		}
	}
}
