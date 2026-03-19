Shader "Hidden/Genesis/BlueNoise"
{	
	Properties
	{
		_density("Density",Range(0,1.0))=0.75
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			HLSLPROGRAM
			float _density;

			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"			
            #pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma target 3.0
			
			// Expand 16-bit integer into 32-bit with interleaved bits (Morton encoding)
			uint part1by1(uint x)
			{
				x = (x & 0x0000ffffu);
				x = ((x ^ (x << 8u)) & 0x00ff00ffu);
				x = ((x ^ (x << 4u)) & 0x0f0f0f0fu);
				x = ((x ^ (x << 2u)) & 0x33333333u);
				x = ((x ^ (x << 1u)) & 0x55555555u);
				return x;
			}

			// Compact interleaved bits back into original 16-bit integer (Morton decoding)
			uint compact1by1(uint x)
			{
				x = (x & 0x55555555u);
				x = ((x ^ (x >> 1u)) & 0x33333333u);
				x = ((x ^ (x >> 2u)) & 0x0f0f0f0fu);
				x = ((x ^ (x >> 4u)) & 0x00ff00ffu);
				x = ((x ^ (x >> 8u)) & 0x0000ffffu);
				return x;
			}

			// Pack 2D coordinates into a 32-bit Morton code
			uint pack_morton2x16(uint2 v)
			{
				return part1by1(v.x) | (part1by1(v.y) << 1);
			}

			// Unpack 32-bit Morton code into 2D coordinates
			uint2 unpack_morton2x16(uint p)
			{
				return uint2(compact1by1(p), compact1by1(p >> 1));
			}

			// Invert a 32-bit Gray code to its binary representation
			uint inverse_gray32(uint n)
			{
				n = n ^ (n >> 1);
				n = n ^ (n >> 2);
				n = n ^ (n >> 4);
				n = n ^ (n >> 8);
				n = n ^ (n >> 16);
				return n;
			}

			uint hilbert(int2 p, int level)
			{
				uint d = 0;
				for (int k = 0; k < level; ++k)
				{
					int n = level - k - 1;
					int2 r = (p >> n) & 1;
					d += ((3 * r.x) ^ r.y) << (2 * n);
					if (r.y == 0)
					{
						if (r.x == 1)
							p = (1 << n) - 1 - p;
						p = int2(p.y, p.x);
					}
				}
				return d;
			}

			int2 ihilbert(int i, int level)
			{
				int2 p = int2(0, 0);
				for (int k = 0; k < level; ++k)
				{
					int2 r = int2(i >> 1, i ^ (i >> 1)) & 1;
					if (r.y == 0)
					{
						if (r.x == 1)
							p = (1 << k) - 1 - p;
						p = int2(p.y, p.x);
					}
					p += r << k;
					i >>= 2;
				}
				return p;
			}

			uint kmhf(uint x)
			{
				return 0x80000000u + 2654435789u * x;
			}

			uint kmhf_inv(uint x)
			{
				return (x - 0x80000000u) * 827988741u;
			}

			uint hilbert_r1_blue_noise(uint2 p)
			{
				// Option A: Hilbert curve index
				uint x = hilbert(int2(p), 17) % (1u << 17u);

				// Option B: Morton + Gray decoding (commented out)
				/*
				// p = p ^ (p >> 1); // optional Gray encode
				uint x = pack_morton2x16(p) % (1u << 17u);
				// x = x ^ (x >> 1); // optional Gray decode
				x = inverse_gray32(x);
				*/

				// Option A: Quasirandom float via golden ratio (commented out)
				/*
				const float phi = 2.0 / (sqrt(5.0) + 1.0);
				return frac(0.5 + phi * float(x));
				*/

				// Option B: Knuth hash for R1 sequence
				x = kmhf(x);
				return x;
			}

			float hilbert_r1_blue_noisef(uint2 p)
			{
				uint x = hilbert_r1_blue_noise(p);
				// Option 2: Normalize full 32-bit value to [0,1)
				return (float)x / 4294967296.0;
			}

			float4 mixture (v2f_customrendertexture i) : SV_Target
			{
				float c = hilbert_r1_blue_noisef(uint2(i.localTexcoord.xy*_ScreenParams.xy));

				c=step(c, _density);
				return float4(c,c,c,1.0);
			}
			ENDHLSL

		}
	}
}


