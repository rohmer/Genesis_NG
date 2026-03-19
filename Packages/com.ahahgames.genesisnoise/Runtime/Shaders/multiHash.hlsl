#ifndef MULTIHASH
#define MULTIHASH
float3 permutePrepareMod289(float3 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 permutePrepareMod289(float4 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 permuteResolve(float4 x)
{
    return frac(x * (7.0 / 288.0));
}

float4 permuteHashInternal(float4 x)
{
    return frac(x * ((34.0 / 289.0) * x + (1.0 / 289.0))) * 289.0;
}

// Generates a random number for each of the 4 cell corners
float4 permuteHash2D(float4 cell)
{
    cell = permutePrepareMod289(cell * 32.0);
    return permuteResolve(permuteHashInternal(permuteHashInternal(cell.xzxz) + cell.yyww));
}

// Generates 2 random numbers for each of the 4 cell corners
void permuteHash2D(float4 cell, out float4 hashX, out float4 hashY)
{
    cell = permutePrepareMod289(cell);
    hashX = permuteHashInternal(permuteHashInternal(cell.xzxz) + cell.yyww);
    hashY = permuteResolve(permuteHashInternal(hashX));
    hashX = permuteResolve(hashX);
}

uint ihash1D(uint x)
{
    x ^= x >> 17;
    x *= 0xed5ad4bbu;
    x ^= x >> 11;
    x *= 0xac4c1b51u;
    x ^= x >> 15;
    x *= 0x31848babu;
    x ^= x >> 14;
    return x;
}

uint2 ihash1D(uint2 q)
{
    q = q * 747796405u + 2891336453u;
    q = (q << 13u) ^ q;
    return q * (q * q * 15731u + 789221u) + 1376312589u;
}

uint4 ihash1D(uint4 q)
{
    q = q * 747796405u + 2891336453u;
    q = (q << 13u) ^ q;
    return q * (q * q * 15731u + 789221u) + 1376312589u;
}

float hash1D(float x)
{
    uint state = (uint)(x * 8192.0) * 747796405u + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (float)((word >> 22u) ^ word) * (1.0 / 4294967295.0);
}

float hash1D(float2 x)
{
    uint2 q = (uint2)(x * 8192.0);
    q = 1103515245u * ((q >> 1u) ^ q.yx);
    uint n = 1103515245u * (q.x ^ (q.y >> 3u));
    return (float)(n) * (1.0 / 4294967295.0);
}

float hash1D(float3 x)
{
    uint3 v = (uint3)(x * 8192.0) * 1664525u + 1013904223u;
    v += v.yzx * v.zxy;
    v ^= v >> 16u;
    return (float)(v.x + v.y * v.z) * (1.0 / 4294967295.0);
}

float2 hash2D(float2 x)
{
    uint2 val= (x * 8192.0).xyyx + uint2(0u, 3115245u).xxyy;
    uint4 q = (val.x, val.y,val.x,val.y);
    q = 1103515245u * ((q >> 1u) ^ q.yxwz);
    uint2 n = 1103515245u * (q.xz ^ (q.yw >> 3u));
    return float2(n) * (1.0 / 4294967295.0);
}

float3 hash3D(float2 x)
{
    uint3 v = (uint3)(x.xyx * 8192.0) * 1664525u + 1013904223u;
    v += v.yzx * v.zxy;
    v ^= v >> 16u;

    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;

    return float3(v) * (1.0 / 4294967295.0);
}

float3 hash3D(float3 x)
{
    uint3 v = (uint3)(x * 8192.0) * 1664525u + 1013904223u;

    v += v.yzx * v.zxy;
    v ^= v >> 16u;

    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;

    return float3(v) * (1.0 / 4294967295.0);
}

float4 hash4D(float2 x)
{
    uint4 v = (uint4)(x.xyyx * 8192.0) * 1664525u + 1013904223u;

    v += v.yzxy * v.wxyz;
    v.x += v.y * v.w;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v.w += v.y * v.z;

    v.x += v.y * v.w;
    v.w += v.y * v.z;

    v ^= v >> 16u;

    return float4(v ^ (v >> 16u)) * (1.0 / 4294967295.0);
}

float4 hash4D(float4 x)
{
    uint4 v = (uint4)(x * 8192.0) * 1664525u + 1013904223u;

    v += v.yzxy * v.wxyz;
    v.x += v.y * v.w;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v.w += v.y * v.z;

    v.x += v.y * v.w;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v.w += v.y * v.z;

    v ^= v >> 16u;

    return float4(v ^ (v >> 16u)) * (1.0 / 4294967295.0);
}

float2 betterHash2D(float2 x)
{
    uint2 q = uint2(x);
    uint h0 = ihash1D(ihash1D(q.x) + q.y);
    uint h1 = h0 * 1933247u + ~h0 ^ 230123u;
    return float2(h0, h1) * (1.0 / 4294967295.0); // Normalize
}

float4 betterHash2D(float4 cell)
{
    uint4 i = uint4(cell);
    uint4 hash = ihash1D(ihash1D(i.xzxz) + i.yyww);
    return float4(hash) * (1.0 / 4294967295.0);
}

void betterHash2D(float4 cell, out float4 hashX, out float4 hashY)
{
    uint4 i = uint4(cell);
    uint4 hash0 = ihash1D(ihash1D(i.xzxz) + i.yyww);
    uint4 hash1 = ihash1D(hash0 ^ 1933247u);
    hashX = float4(hash0) * (1.0 / 4294967295.0);
    hashY = float4(hash1) * (1.0 / 4294967295.0);
}

float4 betterHash2D(float2 coords0, float2 coords1)
{
    uint4 i = uint4(coords0, coords1);    
    uint2 ih = ihash1D(ihash1D(i.xz) + i.yw);
    uint4 hash = (ih.x, ih.x, ih.y, ih.y);
    hash.yw = hash.yw * 1933247u + ~hash.yw ^ 230123u;
    return float4(hash) * (1.0 / 4294967295.0);
}

void betterHash2D(float4 coords0, float4 coords1, out float4 hashX, out float4 hashY)
{
    uint4 i0 = uint4(coords0.xz, coords1.xz);
    uint4 i1 = uint4(coords0.yw, coords1.yw);
    uint4 hash0 = ihash1D(ihash1D(i0) + i1);
    uint4 hash1 = hash0 * 1933247u + ~hash0 ^ 230123u;
    hashX = float4(hash0) * (1.0 / 4294967295.0);
    hashY = float4(hash1) * (1.0 / 4294967295.0);
}

void permuteHash3D(float3 cell, float3 cellPlusOne, out float4 lowHash, out float4 highHash)
{
    cell = permutePrepareMod289(cell);
    cellPlusOne = step(cell, float3(287.5f, 287.5f, 287.5f)) * cellPlusOne;

    float4 xz = float4(cell.x, cellPlusOne.x, cell.x, cellPlusOne.x); // xyxy
    float4 yz = float4(cell.y, cell.y, cellPlusOne.y, cellPlusOne.y); // xxyy

    highHash = permuteHashInternal(permuteHashInternal(xz) + yz);
    lowHash = permuteResolve(permuteHashInternal(highHash + cell.zzzz));
    highHash = permuteResolve(permuteHashInternal(highHash + cellPlusOne.zzzz));
}

void fastHash3D(float3 cell, float3 cellPlusOne, out float4 lowHash, out float4 highHash)
{
    const float2 kOffset = float2(50.0, 161.0);
    const float kDomainScale = 289.0;
    const float kLargeValue = 635.298681;
    const float kk = 48.500388;

    cell -= floor(cell * (1.0 / kDomainScale)) * kDomainScale;
    cellPlusOne = step(cell, float3(kDomainScale - 1.5, kDomainScale - 1.5, kDomainScale - 1.5)) * cellPlusOne;

    float4 r = float4(cell.xy, cellPlusOne.xy) + kOffset.xyxy;
    r *= r;
    r = float4(r.x * r.z, r.x * r.w, r.y * r.z, r.y * r.w); // xzxz * yyww

    float2 invZ = 1.0 / (kLargeValue + float2(cell.z, cellPlusOne.z) * kk);
    lowHash = frac(r * invZ.xxxx);
    highHash = frac(r * invZ.yyyy);
}

void betterHash3D(float3 cell, float3 cellPlusOne, out float4 lowHash, out float4 highHash)
{
    uint4 cells = uint4(cell.xy, cellPlusOne.xy);
    uint4 hash = ihash1D(ihash1D(cells.xzxz) + cells.yyww);
    int lh = ihash1D(hash + (uint)cell.z);
    int hh = ihash1D(hash + (uint)cellPlusOne.z);

    lowHash = float4(lh,lh,lh,lh) * (1.0 / 4294967295.0);
    highHash = float4(hh,hh,hh,hh) * (1.0 / 4294967295.0);
}

#define multiHash2D betterHash2D
#define multiHash3D betterHash3D

void smultiHash2D(float4 cell, out float4 hashX, out float4 hashY)
{
    multiHash2D(cell, hashX, hashY);
    hashX = hashX * 2.0 - 1.0;
    hashY = hashY * 2.0 - 1.0;
}


#endif