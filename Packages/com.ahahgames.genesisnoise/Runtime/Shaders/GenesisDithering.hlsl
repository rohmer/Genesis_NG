#ifndef GENESISDITHERING
#define GENESISDITHERING

float BayerDither4x4(float2 coord, float value, float density)
{
    const float4x4 bayer = {
        0.0 / 16.0,  8.0 / 16.0,  2.0 / 16.0, 10.0 / 16.0,
        12.0 / 16.0, 4.0 / 16.0, 14.0 / 16.0, 6.0 / 16.0,
        3.0 / 16.0, 11.0 / 16.0, 1.0 / 16.0, 9.0 / 16.0,
        15.0 / 16.0, 7.0 / 16.0, 13.0 / 16.0, 5.0 / 16.0
    };

    int2 pos = int2(coord) % 4;
    float threshold = bayer[pos.y][pos.x];
    float adjThresh = lerp(0.0, 1.0, density) * threshold;
    return step(threshold, value);
}

float BayerDither4x4(float2 coord, float3 color, float density)
{
    float gray = dot(color, float3(0.3, 0.59, 0.11));
    return BayerDither4x4(coord, gray, density);
}

float BayerDither8x8(float2 coord, float value, float density)
{
    // 8×8 Bayer matrix normalized to[0, 1]
    const float bayer[8][8] = {
        { 0.0 / 64.0, 32.0 / 64.0,  8.0 / 64.0, 40.0 / 64.0,  2.0 / 64.0, 34.0 / 64.0, 10.0 / 64.0, 42.0 / 64.0 },
        {48.0 / 64.0, 16.0 / 64.0, 56.0 / 64.0, 24.0 / 64.0, 50.0 / 64.0, 18.0 / 64.0, 58.0 / 64.0, 26.0 / 64.0 },
        {12.0 / 64.0, 44.0 / 64.0,  4.0 / 64.0, 36.0 / 64.0, 14.0 / 64.0, 46.0 / 64.0,  6.0 / 64.0, 38.0 / 64.0 },
        {60.0 / 64.0, 28.0 / 64.0, 52.0 / 64.0, 20.0 / 64.0, 62.0 / 64.0, 30.0 / 64.0, 54.0 / 64.0, 22.0 / 64.0 },
        { 3.0 / 64.0, 35.0 / 64.0, 11.0 / 64.0, 43.0 / 64.0,  1.0 / 64.0, 33.0 / 64.0,  9.0 / 64.0, 41.0 / 64.0 },
        {51.0 / 64.0, 19.0 / 64.0, 59.0 / 64.0, 27.0 / 64.0, 49.0 / 64.0, 17.0 / 64.0, 57.0 / 64.0, 25.0 / 64.0 },
        {15.0 / 64.0, 47.0 / 64.0,  7.0 / 64.0, 39.0 / 64.0, 13.0 / 64.0, 45.0 / 64.0,  5.0 / 64.0, 37.0 / 64.0 },
        {63.0 / 64.0, 31.0 / 64.0, 55.0 / 64.0, 23.0 / 64.0, 61.0 / 64.0, 29.0 / 64.0, 53.0 / 64.0, 21.0 / 64.0 }
    };

    int2 pos = int2(coord) % 8;
    float threshold = bayer[pos.y][pos.x];
    float adjThresh = lerp(0.0, 1.0, density) * threshold;
    return step(threshold, value);
}

float BayerDither9x9(float2 coord, float3 color, float density)
{
    float gray = dot(color, float3(0.3, 0.59, 0.11));
    return BayerDither8x8(coord, gray, density);
}

float hash21(float2 p)
{
    // Simple hash function for 2D coordinates
    p = frac(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return frac(p.x * p.y);
}

float BlueNoiseDither(float2 coord, float value)
{
    float noise = hash21(coord);
    return step(noise, value);
}

float BlueNoiseDither(float2 coord, float3 color)
{
    float gray = dot(color, float3(0.3, 0.59, 0.11));
    return BlueNoiseDither(coord, gray);
}

// Converts color to grayscale using luminance
float grayscale(float3 color)
{
    return dot(color, float3(0.3, 0.59, 0.11));
}

// Hash-based pseudo-random number generator
float nrand(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}


#endif
