#ifndef VALUENOISE
#define VALUENOISE

#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/multiHash.hlsl"
#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/interpolate.hlsl"

float noise(float pos, float scale, float seed)
{
    pos *= scale;

    float2 i = floor(pos).xx + float2(0.0, 1.0);
    float f = pos - i.x;

    i = fmod(i, float2(scale, scale)) + seed;

    float u = noiseInterpolate(f); // assumes noiseInterpolate(float) returns float
    return lerp(hash1D(i.x), hash1D(i.y), u) * 2.0 - 1.0;
}

float noise(float2 pos, float2 scale, float seed)
{
    pos *= scale;

    float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
    float2 f = pos - i.xy;

    i = fmod(i, scale.xyxy) + seed;

    float4 hash = multiHash2D(i); // assumes multiHash2D(float4) returns float4
    float a = hash.x;
    float b = hash.y;
    float c = hash.z;
    float d = hash.w;

    float2 u = noiseInterpolate(f); // assumes noiseInterpolate(float2) returns float2
    float value = lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;

    return value * 2.0 - 1.0;
}

float noise(float2 pos, float2 scale, float phase, float seed)
{
    const float kPI2 = 6.2831853071;
    pos *= scale;

    float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
    float2 f = pos - i.xy;

    i = fmod(i, scale.xyxy) + seed;

    float4 hash = multiHash2D(i); // assumes multiHash2D(float4) returns float4
    hash = 0.5 * sin(phase + kPI2 * hash) + 0.5;

    float a = hash.x;
    float b = hash.y;
    float c = hash.z;
    float d = hash.w;

    float2 u = noiseInterpolate(f); // assumes noiseInterpolate(float2) returns float2
    float value = lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;

    return value * 2.0 - 1.0;
}

float3 noised(float2 pos, float2 scale, float seed)
{
    pos *= scale;

    float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
    float2 f = pos - i.xy;

    i = fmod(i, scale.xyxy) + seed;

    float4 hash = multiHash2D(i); // assumes multiHash2D(float4) returns float4
    float a = hash.x;
    float b = hash.y;
    float c = hash.z;
    float d = hash.w;

    float4 udu = noiseInterpolateDu(f); // assumes noiseInterpolateDu(float2) returns float4(u, du)
    float abcd = a - b - c + d;
    float value = a + (b - a) * udu.x + (c - a) * udu.y + abcd * udu.x * udu.y;

    float2 derivative = udu.zw * (udu.yx * abcd + float2(b, c) - a);

    return float3(value * 2.0 - 1.0, derivative);
}

float3 noised(float2 pos, float2 scale, float phase, float seed)
{
    const float kPI2 = 6.2831853071;
    pos *= scale;

    float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
    float2 f = pos - i.xy;

    i = fmod(i, scale.xyxy) + seed;

    float4 hash = multiHash2D(i); // assumes multiHash2D(float4) returns float4
    hash = 0.5 * sin(phase + kPI2 * hash) + 0.5;

    float a = hash.x;
    float b = hash.y;
    float c = hash.z;
    float d = hash.w;

    float4 udu = noiseInterpolateDu(f); // assumes noiseInterpolateDu(float2) returns float4(u, du)
    float abcd = a - b - c + d;
    float value = a + (b - a) * udu.x + (c - a) * udu.y + abcd * udu.x * udu.y;

    float2 derivative = udu.zw * (udu.yx * abcd + float2(b, c) - a);

    return float3(value * 2.0 - 1.0, derivative);
}

float noise3d(float2 pos, float2 scale, float height, float seed)
{
    pos *= scale;

    float3 i = floor(float3(pos, height));
    float3 ip1 = i + 1.0;
    float3 f = float3(pos, height) - i;

    float4 mi = fmod(float4(i.xy, ip1.xy), scale.xyxy);
    i.xy = mi.xy;
    ip1.xy = mi.zw;

    float4 hashLow, hashHigh;
    multiHash3D(i + seed, ip1 + seed, hashLow, hashHigh); // assumes multiHash3D(float3, float3, out float4, out float4)

    float3 u = noiseInterpolate(f); // assumes noiseInterpolate(float3) returns float3
    float4 r = lerp(hashLow, hashHigh, u.z);
    r = lerp(r.xyxz, r.zwyw, float4(u.yy, u.xx));

    return (r.x + (r.y - r.x) * u.x) * 2.0 - 1.0;
}

float4 noised3d(float2 pos, float2 scale, float time, float seed)
{
    pos *= scale;

    float3 i = floor(float3(pos, time));
    float3 ip1 = i + 1.0;
    float3 f = float3(pos, time) - i;

    float4 mi = fmod(float4(i.xy, ip1.xy), scale.xyxy);
    i.xy = mi.xy;
    ip1.xy = mi.zw;

    float4 hashLow, hashHigh;
    multiHash3D(i + seed, ip1 + seed, hashLow, hashHigh); // assumes multiHash3D(float3, float3, out float4, out float4)

    float3 u, du;
    noiseInterpolateDu(f, u, du); // assumes noiseInterpolateDu(float3, out float3 u, out float3 du)

    float4 res0 = lerp(hashLow, hashHigh, u.z);
    float4 res1 = lerp(res0.xyxz, res0.zwyw, float4(u.yy, u.xx));
    float4 res2 = lerp(float4(hashLow.xy, hashHigh.xy), float4(hashLow.zw, hashHigh.zw), u.y);
    float2 res3 = lerp(res2.xz, res2.yw, u.x);

    float4 results = float4(res1.x, 0.0, 0.0, 0.0) +
        (float4(res1.yyw, res3.y) - float4(res1.xxz, res3.x)) * float4(u.x, du);

    return float4(results.x * 2.0 - 1.0, results.yzw);
}

float2 multiNoise(float4 pos, float4 scale, float phase, float2 seed)
{
    const float kPI2 = 6.2831853071;
    pos *= scale;

    float4 i = floor(pos);
    float4 f = pos - i;

    float4 i0 = fmod(i.xyxy + float2(0.0, 1.0).xxyy, scale.xyxy) + seed.x;
    float4 i1 = fmod(i.zwzw + float2(0.0, 1.0).xxyy, scale.xyxy) + seed.y;

    float4 hash0 = multiHash2D(i0); // assumes multiHash2D(float4) returns float4
    hash0 = 0.5 * sin(phase + kPI2 * hash0) + 0.5;

    float4 hash1 = multiHash2D(i1);
    hash1 = 0.5 * sin(phase + kPI2 * hash1) + 0.5;

    float2 a = float2(hash0.x, hash1.x);
    float2 b = float2(hash0.y, hash1.y);
    float2 c = float2(hash0.z, hash1.z);
    float2 d = float2(hash0.w, hash1.w);

    float4 u = noiseInterpolate(f); // assumes noiseInterpolate(float4) returns float4
    float2 value = lerp(a, b, u.xz) + (c - a) * u.yw * (1.0 - u.xz) + (d - b) * u.xz * u.yw;

    return value * 2.0 - 1.0;
}

float gridNoise(float2 pos, float2 scale, float3 translate, float intensity, float time, float seed)
{
    float4 n;

    float4 offset0 = float4(pos.xyxy + float2(0.0, translate.x).xxyy);
    float4 offset1 = float4(pos.xyxy + float4(translate.y, translate.y, translate.z, translate.z));

    n.xy = multiNoise(offset0, scale.xyxy, time, seed); // assumes multiNoise returns float2
    n.zw = multiNoise(offset1, scale.xyxy, time, seed);

    n.xy *= n.zw;

    float t = abs(n.x * n.y);
    return pow(t, lerp(0.5, 0.1, intensity));
}

float3 Hash3D(float2 x)
{
    uint3 v = (uint3)(x.xyx * 8192.0) * 1664525u + 1013904223u;
    v += v.yzx * v.zxy;
    v ^= v >> 16u;

    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;

    return float3(v) * (1.0 / 4294967295.0);
}

float gridNoise(float2 pos, float2 scale, float intensity, float time, float seed)
{    
    float3 hash = hash3D(float2(seed,seed)) * 2.0 - 1.0; // assumes hash3D(float2) returns float3
    float4 translate = float4(0.0, hash.x * scale.x, hash.y * scale.y, hash.z * scale.x);

    float4 offset0 = float4(pos.xyxy + translate.xxyy);
    float4 offset1 = float4(pos.xyxy + translate.zzww);

    float2 n0 = multiNoise(offset0, scale.xyxy, time, seed); // assumes multiNoise returns float2
    float2 n1 = multiNoise(offset1, scale.xyxy, time, seed);

    float2 n = n0 * n1;

    float t = abs(n.x * n.y);
    return pow(t, lerp(0.5, 0.1, intensity));
}

float3 dotsNoise(float2 pos, float2 scale, float density, float size, float sizeVariation, float roundness, float seed)
{
    pos *= scale;

    float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
    float2 f = pos - i.xy;

    i = fmod(i, scale.xyxy);

    float4 hash = hash4D(i.xy + seed); // assumes hash4D(float2) returns float4 in [0,1]
    if (hash.w > density)
        return float3(0.0, 0.0, 0.0);

    float radius = clamp(size + (hash.z * 2.0 - 1.0) * sizeVariation * 0.5, 0.0, 1.0);
    float value = radius / size;
    radius = 2.0 / radius;

    f = f * radius - (radius - 1.0);
    f += hash.xy * (radius - 2.0);

    float exponent = lerp(20.0, 1.0, sqrt(roundness));
    f = pow(abs(f), float2(exponent, exponent));

    float u = 1.0 - min(dot(f, f), 1.0);
    return float3(clamp(u * u * u * value, 0.0, 1.0), hash.w, hash.z);
}

float2 randomLines(float2 pos, float2 scale, float count, float width, float jitter, float2 smoothness, float phase, float seed)
{
    float strength = jitter * 1.25;

    // Finite difference gradient approximation
    float2 grad;
    float3 offsets = float3(1.0, 0.0, -1.0) / 1024.0;

    float4 p = float4(pos.xyxy + offsets.xyzy);
    //float4 tmp=float4(scale.x,scale.y,scale.x,scale.y);
    float2 nv = count * (strength * multiNoise(p, scale.xyxy, phase, float2(seed,seed)) + p.yw);
    grad.x = nv.x - nv.y;

    p = float4(pos.xyxy + offsets.yxyz);
    nv = count * (strength * multiNoise(p, scale.xyxy, phase, float2(seed,seed)) + p.yw);
    grad.y = nv.x - nv.y;

    float v = count * (strength * noise(pos, scale, phase, seed) + pos.y);
    float w = frac(v) / length(grad / (2.0 * offsets.x));

    width *= 0.1;
    smoothness *= width;
    smoothness += max(abs(grad.x), abs(grad.y)) * 0.02;

    float d = smoothstep(0.0, smoothness.x, w) - smoothstep(max(width - smoothness.y, 0.0), width, w);
    return float2(d, fmod(floor(v), count));
}

float4 randomLines(float2 pos, float2 scale, float count, float width, float jitter, float2 smoothness, float phase, float colorVariation, float seed)
{
    float2 l = randomLines(pos, scale, count, width, jitter, smoothness, phase, seed); // assumes float2 version is defined
    float3 r = hash3D(float2(l.y, l.y) + seed); // assumes hash3D(float2) returns float3

    float3 color = (r.x <= colorVariation) ? r : float3(r.x, r.x, r.x);
    return float4(l.x * color, l.x);
}
#endif