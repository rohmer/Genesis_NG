Shader "Hidden/Genesis/NoiseBlur"
{	
	Properties
	{
		// By default a shader node is supposed to handle all the input texture dimension, we use a prefix to determine which one is used
		[Tooltip(Source Texture)][InlineTexture]_Source_2D("Source", 2D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_3D("Source", 3D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_Cube("Source", Cube) = "white" {}

		[Tooltip(Source Texture)][InlineTexture]_Noise_2D("Noise Input", 2D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Noise_3D("Noise Input", 3D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Noise_Cube("Noise Input", Cube) = "white" {}

		[Tooltip(Base blur radius in percent)]_Radius("Radius", Range(0, 100)) = 16
		// Other parameters
	}
	 
HLSLINCLUDE
	#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

	#define SAMPLE_COUNT 32

	static float gaussianWeights[SAMPLE_COUNT] = {
		0.03740084,
		0.03723684,
		0.03674915,
		0.03595048,
		0.03486142,
		0.03350953,
		0.03192822,
		0.03015531,
		0.02823164,
		0.02619939,
		0.02410068,
		0.02197609,
		0.01986344,
		0.01779678,
		0.01580561,
		0.01391439,
		0.01214227,
		0.01050313,
		0.009005766,
		0.007654299,
		0.006448714,
		0.005385472,
		0.004458177,
		0.003658254,
		0.002975593,
		0.002399142,
		0.001917438,
		0.001519042,
		0.001192892,
		0.0009285718,
		0.0007164943,
		0.0005480157,
	};

	float4 GaussianBlur(v2f_customrendertexture i, int radius, float3 direction, bool sampleSelf)
	{
		float4 color;
		
		if (sampleSelf)
			color = SAMPLE_SELF(i.localTexcoord.xyz, i.direction);
		else
			color = SAMPLE_X_SAMPLER(_Source, sampler_Source, i.localTexcoord.xyz, i.direction);

		if (radius == 0)
			return color;

		float mod=SAMPLE_X_SAMPLER(_Noise, noise_Source, i.localTexcoord.xyz, i.direction);

		float3 rad = (radius * 0.01 / SAMPLE_COUNT)*mod;

		color *= gaussianWeights[0];

		for (int j = 1; j < SAMPLE_COUNT; j++)
		{
			float3 uvOffset = direction * j * rad;
			float cubemapDirectionOffset = j * rad.x * 360; // humm ?
			float3 positiveDirectionOffset = Rotate(direction, i.direction, cubemapDirectionOffset);
			float3 negativeDirectionOffset = Rotate(direction, i.direction, -cubemapDirectionOffset);

			if (sampleSelf)
			{
				color += SAMPLE_SELF(i.localTexcoord.xyz + uvOffset, positiveDirectionOffset) * gaussianWeights[j];
				color += SAMPLE_SELF(i.localTexcoord.xyz - uvOffset, negativeDirectionOffset) * gaussianWeights[j];
			}
			else
			{
				color += SAMPLE_X_SAMPLER(_Source, sampler_Source, i.localTexcoord.xyz + uvOffset, positiveDirectionOffset) * gaussianWeights[j];
				color += SAMPLE_X_SAMPLER(_Source, sampler_Source, i.localTexcoord.xyz - uvOffset, negativeDirectionOffset) * gaussianWeights[j];
			}
		}

		return color;
	}
	ENDHLSL	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Name "Vertical Blur"

			HLSLPROGRAM
			float4 genesis(v2f_customrendertexture i) : SV_Target
			{
				return GaussianBlur(i, float3(1, 0, 0), false);
			}
			ENDHLSL
		}

		Pass
		{
			Name "Horizontal Blur"

			HLSLPROGRAM
			float4 genesis(v2f_customrendertexture i) : SV_Target
			{
				return GaussianBlur(i, float3(0, 1, 0), true);
			}
			ENDHLSL
		}

		Pass
		{
			Name "Depth Blur"

			HLSLPROGRAM
			float4 genesis(v2f_customrendertexture i) : SV_Target
			{
				return GaussianBlur(i, float3(0, 0, 1), true);
			}
			ENDHLSL
		}
	}
}