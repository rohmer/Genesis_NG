#ifndef GENESISFBM
#define GENESISFBM

#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/ValueNoise.hlsl"
#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisPerlinNoise.hlsl"
#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisVoronoi.hlsl"
#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/meatballs.hlsl"

float fbm(float2 pos, float2 scale, int octaves, float shift, float timeShift, float gain, float lacunarity, float octaveFactor, float seed)
{
	float amplitude = gain;
	float time = timeShift;
	float2 frequency = scale;
	float2 offset = float2(shift, 0.0);
	float2 p = pos * frequency;
	octaveFactor = 1.0 + octaveFactor * 0.12;

	float2 sinCos = float2(sin(shift), cos(shift));
	float2x2 rotate = float2x2(sinCos.y, sinCos.x, sinCos.x, sinCos.y);

	float value = 0.0;
	for (int i = 0; i < octaves; i++)
	{
		float n = noise(p / frequency, frequency, time, seed); // assumes noise() is defined elsewhere
		value += amplitude * n;

		p = p * lacunarity + offset * float(1 + i);
		frequency *= lacunarity;
		amplitude = pow(amplitude * gain, octaveFactor);
		time += timeShift;
		offset = mul(rotate, offset);
	}

	return value * 0.5 + 0.5;
}

float fbmPerlin(float2 pos, float2 scale, int octaves, float shift, float axialShift, float gain, float lacunarity, uint mode, float factor, float offset, float octaveFactor, float seed)
{
	float amplitude = gain;
	float2 frequency = floor(scale);
	float angle = axialShift;
	float n = 1.0;
	float2 p = frac(pos) * frequency;

	float value = 0.0;
	for (int i = 0; i < octaves; i++)
	{
		float pn = perlinNoise(p / frequency, frequency, angle, seed) + offset;

		if (mode == 0u)
		{
			n *= abs(pn);
		}
		else if (mode == 1u)
		{
			n = abs(pn);
		}
		else if (mode == 2u)
		{
			n = pn;
		}
		else if (mode == 3u)
		{
			n *= pn;
		}
		else if (mode == 4u)
		{
			n = pn * 0.5 + 0.5;
		}
		else
		{
			n *= pn * 0.5 + 0.5;
		}

		n = pow(max(n, 0.0), factor);
		value += amplitude * n;

		p = p * lacunarity + shift;
		frequency *= lacunarity;
		amplitude = pow(amplitude * gain, octaveFactor);
		angle += axialShift;
	}

	return value;
}

float4 fbmVoronoi(float2 pos, float2 scale, int octaves, float shift, float timeShift, float gain, float lacunarity, float octaveFactor, float jitter, float interpolate, float seed)
{
	float amplitude = gain;
	float time = timeShift;
	float2 frequency = scale;
	float2 offset = float2(shift, 0.0);
	float2 p = pos * frequency;
	octaveFactor = 1.0 + octaveFactor * 0.12;

	float2 sinCos = float2(sin(shift), cos(shift));
	float2x2 rotate = float2x2(sinCos.y, sinCos.x, sinCos.x, sinCos.y);

	float n = 1.0;
	float4 value = float4(0.0, 0.0, 0.0, 0.0);

	for (int i = 0; i < octaves; i++)
	{
		float3 v = voronoi(p / frequency, frequency, jitter, timeShift, seed); // assumes voronoi() is defined
		v.x = v.x * 2.0 - 1.0;
		n *= v.x;

		float3 h = hash3D(v.yz); // assumes hash3D(float2) returns float3
		value += amplitude * float4(lerp(v.x, n, interpolate), h);

		p = p * lacunarity + offset * float(1 + i);
		frequency *= lacunarity;
		amplitude = pow(amplitude * gain, octaveFactor);
		time += timeShift;
		offset = mul(rotate, offset);
	}

	value.x = value.x * 0.5 + 0.5;
	return value;
}

float fbmGrid(float2 pos, float2 scale, int octaves, float shift, float timeShift, float gain, float lacunarity, float3 translate, float warpStrength, float octaveFactor, float seed)
{
	float amplitude = gain;
	float time = timeShift;
	float2 frequency = scale;
	float2 offset = float2(shift, 0.0);
	float2 p = pos * frequency;
	octaveFactor = 1.0 + octaveFactor * 0.12;

	float2 sinCos = float2(sin(shift), cos(shift));
	float2x2 rotate = float2x2(sinCos.y, sinCos.x, sinCos.x, sinCos.y);

	float value = 0.0;
	for (int i = 0; i < octaves; i++)
	{
		float2 pi = p / frequency + value * warpStrength;

		float4 offset0 = float4(pi.xyxy + float2(0.0, translate.x).xxyy);
		float4 offset1 = float4(pi.xyxy + float4(translate.y, translate.y, translate.z, translate.z));

		float2 n0 = multiNoise(offset0, frequency.xyxy, time, seed); // assumes multiNoise returns float2
		float2 n1 = multiNoise(offset1, frequency.xyxy, time, seed);

		float2 n = n0 * n1;
		float noiseVal = pow(abs(n.x * n.y), 0.25) * 2.0 - 1.0;
		value += amplitude * noiseVal;

		p = p * lacunarity + offset * (1.0 + i);
		frequency *= lacunarity;
		amplitude = pow(amplitude * gain, octaveFactor);
		time += timeShift;
		offset = mul(offset, rotate);
	}

	value = value * 0.5 + 0.5;
	return value * value;
}

float fbmMetaballs(float2 pos,float2 scale,int octaves,float shift,float timeShift,float gain,float lacunarity,float octaveFactor,float jitter,float interpolate,float2 width,float seed)
{
	float amplitude = gain;
	float time = timeShift;
	float2 frequency = scale;
	float2 offset = float2(shift, 0.0);
	float2 p = pos * frequency;
	octaveFactor = 1.0 + octaveFactor * 0.12;

	float2 sinCos = float2(sin(shift), cos(shift));
	float2x2 rotate = float2x2(sinCos.y, sinCos.x, sinCos.x, sinCos.y);

	float n = 1.0;
	float value = 0.0;

	for (int i = 0; i < octaves; i++)
	{
		float cn = metaballs(p / frequency, frequency, jitter, timeShift, width.x, width.y, seed) * 2.0 - 1.0;
		n *= cn;
		value += amplitude * lerp(n, abs(n), interpolate);

		p = p * lacunarity + offset * (1.0 + i);
		frequency *= lacunarity;
		amplitude = pow(amplitude * gain, octaveFactor);
		time += timeShift;
		offset = mul(offset, rotate);
	}

	return value * 0.5 + 0.5;
}

float3 fbmd(float2 pos, float2 scale, int octaves, float2 shift, float timeShift, float gain, float2 lacunarity, float slopeness, float octaveFactor, float seed)
{
	float amplitude = gain;
	float time = timeShift;
	float2 frequency = scale;
	float2 p = pos * frequency;
	octaveFactor = 1.0 + octaveFactor * 0.12;

	float2 sinCos = float2(sin(shift.x), cos(shift.y));
	float2x2 rotate = float2x2(sinCos.y, sinCos.x, sinCos.x, sinCos.y);

	float3 value = float3(0.0, 0.0, 0.0);
	float2 derivative = float2(0.0, 0.0);

	for (int i = 0; i < octaves; i++)
	{
		float3 n = noised(p / frequency, frequency, time, seed).xyz;
		derivative += n.yz;

		n *= amplitude;
		n.x /= (1.0 + lerp(0.0, dot(derivative, derivative), slopeness));
		value += n;

		p = (p + shift) * lacunarity;
		frequency *= lacunarity;
		amplitude = pow(amplitude * gain, octaveFactor);
		shift = mul(shift, rotate);
		time += timeShift;
	}

	value.x = value.x * 0.5 + 0.5;
	return value;
}

float3 fbmd(float2 pos, float2 scale, int octaves, float shift, float timeShift, float gain, float lacunarity, float slopeness, float octaveFactor, float seed)
{
	return fbmd(pos, scale, octaves, float2(shift, shift), timeShift, gain, float2(lacunarity, lacunarity), slopeness, octaveFactor, seed);
}

float3 fbmd(float2 pos, float2 scale, int octaves, float2 shift, float timeShift, float gain, float lacunarity, float slopeness, float octaveFactor, float seed)
{
	return fbmd(pos, scale, octaves, shift, timeShift, gain, float2(lacunarity, lacunarity), slopeness, octaveFactor, seed);
}

float3 fbmdPerlin(float2 pos, float2 scale, int octaves, float2 shift, float2x2 transform, float gain, float2 lacunarity, float slopeness, float octaveFactor, bool negative, float seed)
{
	float amplitude = gain;
	float2 frequency = floor(scale);
	float2 p = pos * frequency;
	octaveFactor = 1.0 + octaveFactor * 0.3;

	float3 value = float3(0.0, 0.0, 0.0);
	float2 derivative = float2(0.0, 0.0);

	for (int i = 0; i < octaves; i++)
	{
		float3 n = perlinNoised(p / frequency, frequency, transform, seed);
		derivative += n.yz;
		n.x = negative ? n.x : n.x * 0.5 + 0.5;
		n *= amplitude;
		value.x += n.x / (1.0 + lerp(0.0, dot(derivative, derivative), slopeness));
		value.yz += n.yz;

		p = (p + shift) * lacunarity;
		frequency *= lacunarity;
		amplitude = pow(amplitude * gain, octaveFactor);
		transform = mul(transform, transform);
	}

	return value;
}

float3 fbmdPerlin(float2 pos, float2 scale, int octaves, float2 shift, float axialShift, float gain, float2 lacunarity, float slopeness, float octaveFactor, bool negative, float seed)
{
	float2 cosSin = float2(cos(axialShift), sin(axialShift));
	float2x2 rot = float2x2(
		cosSin.x, cosSin.y,
		-cosSin.y, cosSin.x
	);
	float2x2 skew = float2x2(0.8, -0.6, 0.6, 0.8);
	float2x2 transform = mul(rot, skew);

	return fbmdPerlin(pos, scale, octaves, shift, transform, gain, lacunarity, slopeness, octaveFactor, negative, seed);
}


#endif