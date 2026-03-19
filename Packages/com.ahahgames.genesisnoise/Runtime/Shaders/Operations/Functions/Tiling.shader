Shader "Hidden/Genesis/Tiling"
{	
	Properties
	{
		// By default a shader node is supposed to handle all the input texture dimension, we use a prefix to determine which one is used
		[Tooltip(Source Texture)][InlineTexture]_Source_2D("Source", 2D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_3D("Source", 3D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_Cube("Source", Cube) = "white" {}

		[Tooltip(Tiling method, tiling is a straight copy and stochastic adds a level of randomness)]
		[Enum(Tiling,0,Stochastic,1)]_method("Tiling Method", int)=1

				
		[Tooltip(Number of tiles to create in the X axis)]
		_tileScaleX("Tile Scale X",Range(1,64))=3
				
		[Tooltip(Number of tiles to create in the Y axis)]
		_tileScaleY("Tile Scale Y",Range(1,64))=32
		
		[VisibleIf(_method,0)]
		[Tooltip(Blend softness range)]
		_blendWidth("Blend Width", Range(0.00,0.3))=0.1
		


	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			HLSLPROGRAM
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"			
			#pragma vertex CustomRenderTextureVertexShader
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment

			TEXTURE_X(_Source);
			SAMPLER_X(sampler_Source); 
			float _blendWidth;
			int _tileScaleX,_tileScaleY;
			int _method;

			float hash(float2 p) 
			{
				return frac(sin(dot(p, float2(41.32, 97.17))) * 105.97);
			}

			float2 rotateUV(float2 uv, float angle) 
			{
				float s = sin(angle), c = cos(angle);
				uv -= 0.5;
				uv = float2(c * uv.x - s * uv.y, s * uv.x + c * uv.y);
				return uv + 0.5;
			}

			float4 StochasticTile(float2 uv, float2 tileScale, float3 dir)
			{
				float2 scaledUV1 = uv * tileScale;
				float2 tileID = floor(scaledUV1);
				float2 tileUV1 = frac(scaledUV1);

				// Noise-based offset
				float2 noiseOffset = frac(sin(tileID * 43.53) * float2(57.29, 19.77));

				// Rotation angle
				float rotation = hash(tileID) * 6.2831853;

				// Flip logic
				bool flipX = hash(tileID + 13.7) > 0.5;
				bool flipY = hash(tileID + 3.9) > 0.5;

				if (flipX) tileUV1.x = 1.0 - tileUV1.x;
				if (flipY) tileUV1.y = 1.0 - tileUV1.y;

				tileUV1 = rotateUV(tileUV1, rotation);
				float2 finalUV = frac(tileUV1 + noiseOffset);


				return SAMPLE_X_SAMPLER(_Source,sampler_Source,finalUV,dir);
			}
			
			float4 TileBlend(float2 uv, float3 dir)
			{
				float2 tileScale=float2(_tileScaleX,_tileScaleY);
				float2 scaledUV=uv*tileScale;
				float2 tileUV=frac(scaledUV);

				// Edge fade based on distance from tile edge
				float2 edgeBlend = smoothstep(0.0, _blendWidth, tileUV) * 
                       smoothstep(0.0, _blendWidth, 1.0 - tileUV);

				// Sample texture
				float4 texColor = SAMPLE_X_SAMPLER(_Source,sampler_Source,tileUV,dir);

				// Multiply by edge alpha
				return texColor * edgeBlend.x * edgeBlend.y;
			}
			

			float4 mixture(v2f_customrendertexture i) : SV_Target
			{
				if(_method==0)
				{
					float uv=i.localTexcoord.xy;
					float dir=i.direction;

					float2 tileScale=float2(_tileScaleX,_tileScaleY);
					float2 scaledUV=uv*tileScale;
					float2 tileUV=frac(scaledUV);

					// Edge fade based on distance from tile edge
					float2 edgeBlend = smoothstep(0.0, _blendWidth, tileUV) * 
						   smoothstep(0.0, _blendWidth, 1.0 - tileUV);

					// Sample texture
					float4 texColor = SAMPLE_X_SAMPLER(_Source,sampler_Source,tileUV,dir);

					// Multiply by edge alpha
					return texColor * edgeBlend.x * edgeBlend.y;
				} else
				if(_method==1)
				{
					return StochasticTile(i.localTexcoord.xy,float2(_tileScaleX,_tileScaleY), i.direction);
				}
				
				return float4(1,1,1,1);
			}
			ENDHLSL
		}
	}
}