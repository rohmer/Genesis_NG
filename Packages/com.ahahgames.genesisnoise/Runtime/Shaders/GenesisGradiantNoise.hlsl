#ifndef GENESISGRADIANT
#define GENESISGRADIANT

#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/ValueNoise.hlsl"
#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/interpolate.hlsl"

float gradientNoise(float2 pos, float2 scale, float seed)
{
    pos *= scale;

    float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
    float4 f = (pos.xyxy - i.xyxy) - float2(0.0, 1.0).xxyy;

    i = fmod(i, scale.xyxy) + seed;

    float4 hashX, hashY;
    smultiHash2D(i, hashX, hashY); 

    float4 gradients = hashX * f.xzxz + hashY * f.yyww;

    float2 u = noiseInterpolate(f.xy); 
    float2 g = lerp(gradients.xz, gradients.yw, u.x);

    return 1.4142135623730950 * lerp(g.x, g.y, u.y);
}

float gradientNoise(float2 pos, float2 scale, float2x2 transform, float seed)
{
    pos *= scale;

    float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
    float4 f = (pos.xyxy - i.xyxy) - float2(0.0, 1.0).xxyy;

    i = fmod(i, scale.xyxy) + seed;

    float4 hashX, hashY;
    smultiHash2D(i, hashX, hashY); // assumes smultiHash2D(float4, out float4, out float4) is defined

    // Transform gradients
    float4 m = float4(transform);
    float4 rh = float4(hashX.x, hashY.x, hashX.y, hashY.y);
    rh = rh.xxzz * m.xyxy + rh.yyww * m.zwzw;
    hashX.xy = rh.xz;
    hashY.xy = rh.yw;

    rh = float4(hashX.z, hashY.z, hashX.w, hashY.w);
    rh = rh.xxzz * m.xyxy + rh.yyww * m.zwzw;
    hashX.zw = rh.xz;
    hashY.zw = rh.yw;

    float4 gradients = hashX * f.xzxz + hashY * f.yyww;

    float2 u = noiseInterpolate(f.xy); // assumes noiseInterpolate(float2) returns float2
    float2 g = lerp(gradients.xz, gradients.yw, u.x);

    return 1.4142135623730950 * lerp(g.x, g.y, u.y);
}

float gradientNoise(float2 pos, float2 scale, float rotation, float seed)
{
    float2 sinCos = float2(sin(rotation), cos(rotation));
    float2x2 transform = float2x2(sinCos.y, sinCos.x, sinCos.x, sinCos.y);
    return gradientNoise(pos, scale, transform, seed); // assumes gradientNoise(float2, float2, float2x2, float) is defined
}

float3 gradientNoised(float2 pos, float2 scale, float seed)
{
    pos *= scale;

    float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
    float4 f = (pos.xyxy - i.xyxy) - float2(0.0, 1.0).xxyy;

    i = fmod(i, scale.xyxy) + seed;

    float4 hashX, hashY;
    smultiHash2D(i, hashX, hashY); // assumes smultiHash2D(float4, out float4, out float4) is defined

    float2 a = float2(hashX.x, hashY.x);
    float2 b = float2(hashX.y, hashY.y);
    float2 c = float2(hashX.z, hashY.z);
    float2 d = float2(hashX.w, hashY.w);

    float4 gradients = hashX * f.xzxz + hashY * f.yyww;

    float4 udu = noiseInterpolateDu(f.xy); // assumes noiseInterpolateDu(float2) returns float4(u, du)
    float2 u = udu.xy;
    float2 g = lerp(gradients.xz, gradients.yw, u.x);

    float2 dxdy = a + u.x * (b - a) + u.y * (c - a) + u.x * u.y * (a - b - c + d);
    dxdy += udu.zw * (u.yx * (gradients.x - gradients.y - gradients.z + gradients.w) + gradients.yz - gradients.x);

    return float3(lerp(g.x, g.y, u.y) * 1.4142135623730950, dxdy);
}

float3 gradientNoised(float2 pos, float2 scale, float2x2 transform, float seed)
{
    pos *= scale;

    float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
    float4 f = (pos.xyxy - i.xyxy) - float2(0.0, 1.0).xxyy;

    i = fmod(i, scale.xyxy) + seed;

    float4 hashX, hashY;
    smultiHash2D(i, hashX, hashY); // assumes smultiHash2D(float4, out float4, out float4) is defined

    // Transform gradients
    float4 m = float4(transform);
    float4 rh = float4(hashX.x, hashY.x, hashX.y, hashY.y);
    rh = rh.xxzz * m.xyxy + rh.yyww * m.zwzw;
    hashX.xy = rh.xz;
    hashY.xy = rh.yw;

    rh = float4(hashX.z, hashY.z, hashX.w, hashY.w);
    rh = rh.xxzz * m.xyxy + rh.yyww * m.zwzw;
    hashX.zw = rh.xz;
    hashY.zw = rh.yw;

    float2 a = float2(hashX.x, hashY.x);
    float2 b = float2(hashX.y, hashY.y);
    float2 c = float2(hashX.z, hashY.z);
    float2 d = float2(hashX.w, hashY.w);

    float4 gradients = hashX * f.xzxz + hashY * f.yyww;

    float4 udu = noiseInterpolateDu(f.xy); // assumes noiseInterpolateDu(float2) returns float4(u, du)
    float2 u = udu.xy;
    float2 g = lerp(gradients.xz, gradients.yw, u.x);

    float2 dxdy = a + u.x * (b - a) + u.y * (c - a) + u.x * u.y * (a - b - c + d);
    dxdy += udu.zw * (u.yx * (gradients.x - gradients.y - gradients.z + gradients.w) + gradients.yz - gradients.x);

    return float3(lerp(g.x, g.y, u.y) * 1.4142135623730950, dxdy);
}

float3 gradientNoised(float2 pos, float2 scale, float rotation, float seed)
{
    float2 sinCos = float2(sin(rotation), cos(rotation));
    float2x2 transform = float2x2(sinCos.y, sinCos.x, sinCos.x, sinCos.y);
    return gradientNoised(pos, scale, transform, seed); // assumes gradientNoised(float2, float2, float2x2, float) is defined
}

float gradientNoiseDisorder(float2 pos, float2 scale, float disorder, float seed)
{
    pos *= scale;

    float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
    float4 f = (pos.xyxy - i.xyxy) - float2(0.0, 1.0).xxyy;

    i = fmod(i, scale.xyxy) + seed;

    float4 hashX, hashY;
    multiHash2D(i, hashX, hashY); // assumes multiHash2D(float4, out float4, out float4) is defined

    hashX = (hashX * disorder) * 2.0 - 1.0;
    hashY = (hashY * disorder) * 2.0 - 1.0;

    float4 gradients = hashX * f.xzxz + hashY * f.yyww;

    float2 u = noiseInterpolate(f.xy); // assumes noiseInterpolate(float2) returns float2
    float2 g = lerp(gradients.xz, gradients.yw, u.x);

    return 1.4142135623730950 * lerp(g.x, g.y, u.y);
}

#endif
