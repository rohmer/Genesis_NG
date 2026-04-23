#include "multiHash.hlsl"
#include "interpolate.hlsl"

float sdfHexagon(float2 pos, float radius, bool isVertical)
{
    // 60 degrees, tan(30°), and inverse angle factor
    const float3 kAngles = float3(1.047198, 0.954929249292, 0.523599);

    // Rotate coordinate system if horizontal
    pos = isVertical ? pos : -pos.yx;

    float2 temp = float2(radius, atan2(pos.y, pos.x)) * kAngles.zy + float2(0.0, 0.5);
    float angle = kAngles.x * floor(temp.y);
    float2 rotation = float2(sin(angle), cos(angle));

    // Apply rotation
    pos = pos.x * rotation.yx * float2(1.0, -1.0) + pos.y * rotation;

    float he = temp.x;
    float2 offset = float2(radius, clamp(pos.y, -he, he));
    return length(pos - offset) * sign(pos.x - radius);
}

float4 tileHexagonsRadii(float2 scale, bool isVertical)
{
    float2 tileSize = 0.3333333 / scale;
    float4 radii = isVertical ? float4(tileSize.y, tileSize.y, tileSize.y, tileSize.x)
        : float4(tileSize.x, tileSize.x, tileSize.x, tileSize.y);
    return radii * float4(1.0, 0.0, 0.5, 1.5);
}

float4 tileHexagons(float2 pos, float2 scale, bool isVertical)
{
    const float kSqrtThree = 1.73205080757;
    const float kHalfSqrtThree = 0.866025403785;
    const float kInvSqrtThree = 0.57735026919;

    float4 hexScale = float4(1.0, kSqrtThree, 1.0, kInvSqrtThree);
    hexScale = isVertical ? hexScale : hexScale.yxwz;

    float4 r = float4(1.0, kHalfSqrtThree, 0.5, kInvSqrtThree);
    r = isVertical ? r : r.yxwz;

    pos *= scale * hexScale.xy;

    float4 center = floor(pos.xyxy * hexScale.zwzw + float4(0.0, 0.0, -r.z, -r.w)) + 0.5;
    float4 uv = pos.xyxy - center * hexScale.xyxy + float4(0.0, 0.0, -0.5 * hexScale.x, -0.5 * hexScale.y);

    float4 temp = uv * uv;
    temp.xy = temp.xz + temp.yw;

    float4 uvCenter = (temp.x < temp.y)
        ? float4(uv.xy, center.xy)
        : float4(uv.zw, center.zw + 0.5);

    return uvCenter * float4(r.x, r.y, 1.0 / scale.x, 1.0 / scale.y) + float4(0.5, 0.5, 0.0, 0.0);
}

float4 tileHexagons(float2 pos, float2 scale, bool isVertical, out float edgeDistance)
{
    const float kSqrtThree = 1.73205080757;
    const float kHalfSqrtThree = 0.866025403785;
    const float kInvSqrtThree = 0.57735026919;

    float4 hexScale = float4(1.0, kSqrtThree, 1.0, kInvSqrtThree);
    hexScale = isVertical ? hexScale : hexScale.yxwz;

    float4 r = float4(1.0, kHalfSqrtThree, 0.5, kInvSqrtThree);
    r = isVertical ? r : r.yxwz;

    float2 invScale = 1.0 / scale;
    float2 p = pos * scale * hexScale.xy;

    float4 center = floor(p.xyxy * hexScale.zwzw + float4(0.0, 0.0, -r.z, -r.w)) + 0.5;
    float4 uv = p.xyxy - center * hexScale.xyxy + float4(0.0, 0.0, -0.5 * hexScale.x, -0.5 * hexScale.y);

    float4 temp = uv * uv;
    temp.xy = temp.xz + temp.yw;

    float4 uvCenter = (temp.x < temp.y)
        ? float4(uv.xy, center.xy)
        : float4(uv.zw, center.zw + 0.5);

    uvCenter = uvCenter * float4(r.xy, invScale) + float4(0.5, 0.5, 0.0, 0.0);

    // Edge distance calculation
    {
        const float3 kAngles = float3(1.047198, 0.954929249292, 0.523599); // 60°, tan(30°), π/6

        float size = isVertical ? invScale.x : invScale.y;
        p = (pos - uvCenter.zw) * scale * hexScale.xy * size;

        p = isVertical ? p : float2(-p.y, p.x); // 90° rotation if horizontal

        float radius = size * 0.5;
        temp.xy = float2(radius, atan2(p.y, p.x)) * kAngles.zy + float2(0.0, 0.5);
        float angle = kAngles.x * floor(temp.y);
        float2 rotation = float2(sin(angle), cos(angle));

        float2 rotated = p.x * float2(rotation.y, -rotation.x) + p.y * rotation;
        float2 offset = float2(radius, clamp(rotated.y, -temp.x, temp.x));

        edgeDistance = length(rotated - offset) / radius;
    }

    return uvCenter;
}

// 2D Gradient noise using an hexagonal grid.
// @param scale Number of tiles, must be an integer for tileable results, range: [1, inf]
// @param size The size of the gradient, range: [0, 2], default: 1.0
// @param jitter Jitter factor of the X and Y axis for the offsets, range: [0, 1], default: 1.0
// @param isVertical Changes the orientation of the hexagons.
// @return Value of the noise, range: [0, 1]
float noiseHexagons(float2 pos, float2 scale, float size, float2 jitter, bool isVertical, bool useCenter)
{
    const float kSqrtThree = 1.73205080757;
    const float kHalfSqrtThree = 0.866025403785;
    const float kInvSqrtThree = 0.57735026919;

    float2 invScale = 1.0 / scale;
    float2 center;

    {
        float4 hexScale = float4(1.0, kSqrtThree, 1.0, kInvSqrtThree);
        hexScale = isVertical ? hexScale : hexScale.yxwz;

        float4 r = float4(1.0, kHalfSqrtThree, 0.5, kInvSqrtThree);
        r = isVertical ? r : r.yxwz;

        float2 p = pos * scale * hexScale.xy;
        float4 c = floor(p.xyxy * hexScale.zwzw + float4(0.0, 0.0, -r.z, -r.w)) + 0.5;
        float4 uv = p.xyxy - c * hexScale.xyxy + float4(0.0, 0.0, -0.5 * hexScale.x, -0.5 * hexScale.y);

        float4 temp = uv * uv;
        temp.xy = temp.xz + temp.yw;
        center = (temp.x < temp.y) ? c.xy : c.zw + 0.5;
        center *= invScale;
    }

    float4 radii = isVertical
        ? invScale.yyxy * float4(0.0, 0.33333333, 0.5, 0.1666666666)
        : invScale.xxxy * float4(0.33333333, 0.0, 0.1666666666, 0.5);

    float radius = isVertical ? min(radii.y, radii.z) : min(radii.x, radii.w);
    jitter *= 0.5 * radius;

    float4 p0 = center.xyxy - radii;
    float4 p1 = center.xyxy + radii;

    float4 hash0, hash1;
    betterHash2D(frac(p0) * 8192.0, frac(p1) * 8192.0, hash0, hash1);

    float4 temp = hash0;
    hash0 = float4(temp.xy, hash1.xy).xzyw * 2.0 - 1.0;
    hash1 = float4(temp.zw, hash1.zw).xzyw * 2.0 - 1.0;

    float4 dc;
    temp = pos.xyxy - p0 + hash0 * jitter.xyxy;
    temp *= temp;
    dc.xy = temp.xz + temp.yw;

    temp = pos.xyxy - p1 + hash1 * jitter.xyxy;
    temp *= temp;
    dc.zw = temp.xz + temp.yw;
    dc.xy = min(dc.xy, dc.zw);

    p0 = center.xyxy + radii.zwzw * float4(-1.0, 1.0, 1.0, -1.0);
    betterHash2D(frac(p0) * 8192.0, frac(center.xyxy) * 8192.0, hash0, hash1);

    temp = hash0;
    hash0 = float4(temp.xy, hash1.xy).xzyw * 2.0 - 1.0;
    hash1.xy = float2(temp.z, hash1.z) * 2.0 - 1.0;

    temp = pos.xyxy - p0 + hash0 * jitter.xyxy;
    temp *= temp;
    dc.zw = temp.xz + temp.yw;
    dc.xy = min(dc.xy, dc.zw);

    float d = min(dc.x, dc.y);
    if (useCenter)
    {
        temp.xy = pos - center + hash1.xy * jitter.xy * 0.5;
        d = min(d, dot(temp.xy, temp.xy));
    }

    radius *= size;
    d = sqrt(d) - radius;

    return max(noiseInterpolate(-d / radius), 0.0);
}

float3 noiseHexagonsd(float2 pos, float2 scale, float size, float2 disorder, bool isVertical, bool useCenter)
{
    const float kSqrtThree = 1.73205080757;
    const float kHalfSqrtThree = 0.866025403785;
    const float kInvSqrtThree = 0.57735026919;

    float2 invScale = 1.0 / scale;
    float2 center;

    {
        float4 hexScale = float4(1.0, kSqrtThree, 1.0, kInvSqrtThree);
        hexScale = isVertical ? hexScale : hexScale.yxwz;

        float4 r = float4(1.0, kHalfSqrtThree, 0.5, kInvSqrtThree);
        r = isVertical ? r : r.yxwz;

        float2 p = pos * scale * hexScale.xy;
        float4 c = floor(p.xyxy * hexScale.zwzw + float4(0.0, 0.0, -r.z, -r.w)) + 0.5;
        float4 uv = p.xyxy - c * hexScale.xyxy + float4(0.0, 0.0, -0.5 * hexScale.x, -0.5 * hexScale.y);

        float4 temp = uv * uv;
        temp.xy = temp.xz + temp.yw;
        center = (temp.x < temp.y) ? c.xy : c.zw + 0.5;
        center *= invScale;
    }

    float4 radii = isVertical
        ? invScale.yyxy * float4(0.0, 0.33333333, 0.5, 0.1666666666)
        : invScale.xxxy * float4(0.33333333, 0.0, 0.1666666666, 0.5);

    float radius = isVertical ? min(radii.y, radii.z) : min(radii.x, radii.w);
    disorder *= 0.5 * radius;

    float4 p0 = center.xyxy - radii;
    float4 p1 = center.xyxy + radii;

    float4 hash0, hash1;
    betterHash2D(frac(p0) * 8192.0, frac(p1) * 8192.0, hash0, hash1);

    float4 temp = hash0;
    hash0 = float4(temp.xy, hash1.xy).xzyw * 2.0 - 1.0;
    hash1 = float4(temp.zw, hash1.zw).xzyw * 2.0 - 1.0;

    float4 dc;
    float4 pc;

    p0 = pos.xyxy - p0 + hash0 * disorder.xyxy;
    temp = p0 * p0;
    dc.xy = temp.xz + temp.yw;

    p1 = pos.xyxy - p1 + hash1 * disorder.xyxy;
    temp = p1 * p1;
    dc.zw = temp.xz + temp.yw;

    pc = lerp(p0, p1, step(dc.zw, dc.xy).xxyy);
    dc.xy = min(dc.xy, dc.zw);

    p0 = center.xyxy + radii.zwzw * float4(-1.0, 1.0, 1.0, -1.0);
    betterHash2D(frac(p0) * 8192.0, frac(center.xyxy) * 8192.0, hash0, hash1);

    temp = hash0;
    hash0 = float4(temp.xy, hash1.xy).xzyw * 2.0 - 1.0;
    hash1.xy = float2(temp.z, hash1.z) * 2.0 - 1.0;

    p0 = pos.xyxy - p0 + hash0 * disorder.xyxy;
    temp = p0 * p0;
    dc.zw = temp.xz + temp.yw;

    pc = lerp(pc, p0, step(dc.zw, dc.xy).xxyy);
    dc.xy = min(dc.xy, dc.zw);

    float d = min(dc.x, dc.y);
    pc.xy = (dc.x < dc.y) ? pc.xy : pc.zw;

    if (useCenter)
    {
        p0.xy = pos - center + hash1.xy * disorder.xy * 0.5;
        dc.x = dot(p0.xy, p0.xy);
        pc.xy = (d < dc.x) ? pc.xy : p0.xy;
        d = min(d, dc.x);
    }

    radius *= size;
    d = sqrt(d);
    float2 dxdy = pc.xy / d;

    float2 uDu = noiseInterpolateDu((radius - d) / radius);
    return float3(uDu.x, dxdy * (uDu.y * radius)) * step(0.0, uDu.x);
}

