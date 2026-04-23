#ifndef GPERLINNOISE
#define GPERLINNOISE

#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/multiHash.hlsl"
#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/interpolate.hlsl"

float perlinNoise(float2 pos, float2 scale, float seed)
{
    pos *= scale;

    float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
    float4 f = (pos.xyxy - i.xyxy) - float2(0.0, 1.0).xxyy;

    i = fmod(i, scale.xyxy) + seed;

    // Grid gradients
    float4 gradientX, gradientY;
    multiHash2D(i, gradientX, gradientY); // Assumes multiHash2D(float4, out float4, out float4) is defined
    gradientX -= 0.49999;
    gradientY -= 0.49999;

    // Perlin surflet
    float4 gradients = rsqrt(gradientX * gradientX + gradientY * gradientY) *
        (gradientX * f.xzxz + gradientY * f.yyww);

    gradients *= 2.3703703703703704; // Normalize: 1.0 / 0.75^3

    float4 lengthSq = f * f;
    lengthSq = lengthSq.xzxz + lengthSq.yyww;

    float4 xSq = 1.0 - min(float4(1.0, 1.0, 1.0, 1.0), lengthSq);
    xSq = xSq * xSq * xSq;

    return dot(xSq, gradients);
}

float perlinNoise(float2 pos, float2 scale, float2x2 transform, float seed)
{
    pos *= scale;

    float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
    float4 f = (pos.xyxy - i.xyxy) - float2(0.0, 1.0).xxyy;

    i = fmod(i, scale.xyxy) + seed;

    // Grid gradients
    float4 gradientX, gradientY;
    multiHash2D(i, gradientX, gradientY); // Assumes multiHash2D(float4, out float4, out float4) is defined
    gradientX -= 0.49999;
    gradientY -= 0.49999;

    // Transform gradients
    float4 mt = float4(transform);
    float4 rg = float4(gradientX.x, gradientY.x, gradientX.y, gradientY.y);
    rg = rg.xxzz * mt.xyxy + rg.yyww * mt.zwzw;
    gradientX.xy = rg.xz;
    gradientY.xy = rg.yw;

    rg = float4(gradientX.z, gradientY.z, gradientX.w, gradientY.w);
    rg = rg.xxzz * mt.xyxy + rg.yyww * mt.zwzw;
    gradientX.zw = rg.xz;
    gradientY.zw = rg.yw;

    // Perlin surflet
    float4 gradients = rsqrt(gradientX * gradientX + gradientY * gradientY) *
        (gradientX * f.xzxz + gradientY * f.yyww);

    gradients *= 2.3703703703703704; // Normalize: 1.0 / 0.75^3

    f = f * f;
    f = f.xzxz + f.yyww;

    float4 xSq = 1.0 - min(float4(1.0, 1.0, 1.0, 1.0), f);
    return dot(xSq * xSq * xSq, gradients);
}

float perlinNoise(float2 pos, float2 scale, float rotation, float seed)
{
    float2 sinCos = float2(sin(rotation), cos(rotation));
    float2x2 transform = float2x2(sinCos.y, sinCos.x, sinCos.x, sinCos.y);
    return perlinNoise(pos, scale, transform, seed); 
}

float3 perlinNoised(float2 pos, float2 scale, float seed)
{
    pos *= scale;

    float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
    float4 f = (pos.xyxy - i.xyxy) - float2(0.0, 1.0).xxyy;

    i = fmod(i, scale.xyxy) + seed;

    // Grid gradients
    float4 gradientX, gradientY;
    multiHash2D(i, gradientX, gradientY); // Assumes this function is defined elsewhere
    gradientX -= 0.49999;
    gradientY -= 0.49999;

    // Perlin surflet
    float4 gradients = rsqrt(gradientX * gradientX + gradientY * gradientY) *
        (gradientX * f.xzxz + gradientY * f.yyww);

    float4 m = f * f;
    m = m.xzxz + m.yyww;
    m = max(1.0 - m, 0.0);

    float4 m2 = m * m;
    float4 m3 = m * m2;

    // Derivatives
    float4 m2Gradients = -6.0 * m2 * gradients;
    float2 grad = float2(dot(m2Gradients, f.xzxz), dot(m2Gradients, f.yyww)) +
        float2(dot(m3, gradientX), dot(m3, gradientY));

    // Normalize: 1.0 / 0.75^3
    return float3(dot(m3, gradients), grad) * 2.3703703703703704;
}

float3 perlinNoised(float2 pos, float2 scale, float2x2 transform, float seed)
{
    pos *= scale;

    float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
    float4 f = (pos.xyxy - i.xyxy) - float2(0.0, 1.0).xxyy;

    i = fmod(i, scale.xyxy) + seed;

    // Grid gradients
    float4 gradientX, gradientY;
    multiHash2D(i, gradientX, gradientY); // Assumes this function is defined elsewhere
    gradientX -= 0.49999;
    gradientY -= 0.49999;

    // Transform gradients
    float4 mt = float4(transform);
    float4 rg = float4(gradientX.x, gradientY.x, gradientX.y, gradientY.y);
    rg = rg.xxzz * mt.xyxy + rg.yyww * mt.zwzw;
    gradientX.xy = rg.xz;
    gradientY.xy = rg.yw;

    rg = float4(gradientX.z, gradientY.z, gradientX.w, gradientY.w);
    rg = rg.xxzz * mt.xyxy + rg.yyww * mt.zwzw;
    gradientX.zw = rg.xz;
    gradientY.zw = rg.yw;

    // Perlin surflet
    float4 gradients = rsqrt(gradientX * gradientX + gradientY * gradientY) *
        (gradientX * f.xzxz + gradientY * f.yyww);

    float4 m = f * f;
    m = m.xzxz + m.yyww;
    m = max(1.0 - m, 0.0);

    float4 m2 = m * m;
    float4 m3 = m * m2;

    // Derivatives
    float4 m2Gradients = -6.0 * m2 * gradients;
    float2 grad = float2(dot(m2Gradients, f.xzxz), dot(m2Gradients, f.yyww)) +
        float2(dot(m3, gradientX), dot(m3, gradientY));

    // Normalize: 1.0 / 0.75^3
    return float3(dot(m3, gradients), grad) * 2.3703703703703704;
}

float3 perlinNoised(float2 pos, float2 scale, float rotation, float seed)
{
    float2 sinCos = float2(sin(rotation), cos(rotation));
    float2x2 transform = float2x2(sinCos.y, sinCos.x, sinCos.x, sinCos.y);
    return perlinNoised(pos, scale, transform, seed); // assumes perlinNoised(float2, float2, float2x2, float) is defined
}

float organicNoise(float2 pos, float2 scale, float density, float2 phase, float contrast, float highlights, float shift, float seed)
{
    float2 s = lerp(float2(1.0, 1.0), scale - 1.0, density);
    float nx = perlinNoise(pos + phase, scale, seed); // assumes perlinNoise(float2, float2, float) is defined
    float ny = perlinNoise(pos, s, seed);

    float2 blend = lerp(float2(2.0, 0.0), float2(0.0, 2.0), shift);
    float n = length(float2(nx, ny) * blend);
    n = pow(n, 1.0 + 8.0 * contrast) + (0.15 * highlights) / n;
    return n * 0.5;
}
#endif