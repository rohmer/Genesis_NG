Shader "Hidden/Genesis/VectorFieldBlur"
{	
	Properties
	{
		[Tooltip(Input Texture)] _Input_2D("Input Texture", 2D) = "input" {}
		[Tooltip(Input Texture)] _Input_3D("Input Texture", 3D) = "input" {}
		[Tooltip(Input Texture)] _Input_Cube("Input Texture", Cube) = "input" {}			
		[Enum(Grayscale, 0, NoConvert, 1)] _Grayscale("Convert to Grayscale", int) = 0
		_Seed("Seed", Int) = 42
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Name "Noise Blur"
			HLSLPROGRAM			
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"		
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma target 3.0

			// The list of defines that will be active when processing the node with a certain dimension
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _TILINGMODE_NONE _TILINGMODE_TILED
			#pragma shader_feature _ USE_CUSTOM_SCALE
			
			// This macro will declare a version for each dimention (2D, 3D and Cube)
			TEXTURE_SAMPLER_X(_Input);
			float _UseScaling;			
			float _ScaleFactor;
			int _Seed;
			int _Grayscale;
			
			float hash(float n)
			{
				return frac(sin(n) * 43758.5453);
			}

			float noise(float2 x)
			{
				float2 p = floor(x);
				float2 f = frac(x);
				f = f * f * (3.0 - 2.0 * f); // Smoothstep

				float n = p.x + p.y * 57.0;

				float res = lerp(
					lerp(hash(n + 0.0),  hash(n + 1.0),  f.x),
					lerp(hash(n + 57.0), hash(n + 58.0), f.x),
					f.y
				);
    
				return res;
			}

			float2 map(float2 p, float offset)
			{
				p.x += 0.1 * sin(_Seed + 2.0 * p.y);
				p.y += 0.1 * sin(_Seed + 2.0 * p.x);

				float a = noise(p * 1.5 + sin(0.1 * _Seed)) * 6.2831;
				a -= offset;

				return float2(cos(a), sin(a));
			}

			float4 genesis(v2f_customrendertexture i)
			{
				float3 sampleCol = SAMPLE_X(_Input, i.localTexcoord.xyz, i.direction);
				float2 coords1 = i.localTexcoord.xy;
				float2 uv =	i.localTexcoord.xy; //i-1.0+2.0*coords1;

				float acc=0.0;
				float3 col=float3(0,0,0);
				
				[unroll]
				for(int j=0; j<32; j++)
				{
					float2 dir=map(uv,(float)_Seed);   // Might change to the i.direction

					float h=(float)i/32.0;
					float w = 4.0*h*(1.0-h);
					float3 uvz=float3(uv.x,uv.y,i.localTexcoord.z);
					float3 ttt = w * SAMPLE_X(_Input, uvz, i.direction);
					float d = dot(reflect(float3(dir, 0.0), float3(1.0, 0.0, 0.0)).xy, float2(0.707, 0.707));
					ttt *= lerp(float3(0.6, 0.7, 0.7), float3(1.0, 0.95, 0.9), 0.5 - 0.5 * d);
					col += w * ttt;
					acc += w;

					uv += 0.008 * dir;
				}

				col /= acc;
				float gg = dot(col, float3(0.333, 0.333, 0.333));
				float3 nor = normalize(float3(ddx(gg), 0.5, ddy(gg)));

				col += float3(0.4,0.4,0.4) * dot(nor, float3(0.7, 0.01, 0.7));

				float2 di = map(coords1, (float)_Seed);
				col *= 0.65 + 0.35 * dot(di, float2(0.707, 0.707));
				col *= 0.20 + 0.80 * pow(4.0 * coords1.x * (1.0 - coords1.x), 0.1);
				col *= 1.7;

			
				
				if(_Grayscale==1)
				{
					return float4(col,1.0);
				}
				float grayscale=dot(col,float3(0.299,0.587,0.114));
				return float4(grayscale,grayscale,grayscale,1.0);
			}
			ENDHLSL
		}
	}
}
