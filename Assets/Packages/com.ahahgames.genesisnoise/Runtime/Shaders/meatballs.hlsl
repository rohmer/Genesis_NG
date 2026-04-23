#ifndef MEATBALLS
#define MEATBALLS

#include "Distance.hlsl"

float metaballs(float2 pos, float2 scale, float jitter, float seed)
{
    pos *= scale;

    float2 i = floor(pos);
    float2 f = pos - i;

    float3 offset = float3(-1.0, 0.0, 1.0);
    float4 cells = fmod(float4(i.xyxy + offset.xxzz), scale.xyxy) + seed;
    i = fmod(i, scale) + seed;

    float4 dx0, dy0, dx1, dy1;
    multiHash2D(float4(cells.xy, float2(i.x, cells.y)), float4(cells.zyx, i.y), dx0, dy0);
    multiHash2D(float4(cells.zwz, i.y), float4(cells.xw, float2(i.x, cells.w)), dx1, dy1);

    dx0 = offset.xyzx + dx0 * jitter - f.xxxx;
    dy0 = offset.xxxy + dy0 * jitter - f.yyyy;
    dx1 = offset.zzxy + dx1 * jitter - f.xxxx;
    dy1 = offset.zyzz + dy1 * jitter - f.yyyy;

    float4 d0 = dx0 * dx0 + dy0 * dy0;
    float4 d1 = dx1 * dx1 + dy1 * dy1;

    float2 centerPos = multiHash2D(i) * jitter - f;

    float d = min(1.0, dot(centerPos, centerPos));
    d = min(d, d * d0.x);
    d = min(d, d * d0.y);
    d = min(d, d * d0.z);
    d = min(d, d * d0.w);
    d = min(d, d * d1.x);
    d = min(d, d * d1.y);
    d = min(d, d * d1.z);
    d = min(d, d * d1.w);

    return sqrt(d);
}

float metaballs(float2 pos, float2 scale, float jitter, float width, float smoothness, float seed)
{
    float d = metaballs(pos, scale, jitter, seed); // assumes this function is defined elsewhere
    return smoothstep(width, width + smoothness, d);
}

float metaballs(float2 pos, float2 scale, float jitter, float phase, float seed)
{
    const float kPI2 = 6.2831853071;
    pos *= scale;

    float2 i = floor(pos);
    float2 f = pos - i;

    float3 offset = float3(-1.0, 0.0, 1.0);
    float4 cells = fmod(float4(i.xyxy + offset.xxzz), scale.xyxy) + seed;
    i = fmod(i, scale) + seed;

    float4 dx0, dy0, dx1, dy1;
    multiHash2D(float4(cells.xy, float2(i.x, cells.y)), float4(cells.zyx, i.y), dx0, dy0);
    multiHash2D(float4(cells.zwz, i.y), float4(cells.xw, float2(i.x, cells.w)), dx1, dy1);

    dx0 = 0.5 * sin(phase + kPI2 * dx0) + 0.5;
    dy0 = 0.5 * sin(phase + kPI2 * dy0) + 0.5;
    dx1 = 0.5 * sin(phase + kPI2 * dx1) + 0.5;
    dy1 = 0.5 * sin(phase + kPI2 * dy1) + 0.5;

    dx0 = offset.xyzx + dx0 * jitter - f.xxxx;
    dy0 = offset.xxxy + dy0 * jitter - f.yyyy;
    dx1 = offset.zzxy + dx1 * jitter - f.xxxx;
    dy1 = offset.zyzz + dy1 * jitter - f.yyyy;

    float4 d0 = dx0 * dx0 + dy0 * dy0;
    float4 d1 = dx1 * dx1 + dy1 * dy1;

    float2 centerPos = (0.5 * sin(phase + kPI2 * multiHash2D(i)) + 0.5) * jitter - f;

    float d = min(1.0, dot(centerPos, centerPos));
    d = min(d, d * d0.x);
    d = min(d, d * d0.y);
    d = min(d, d * d0.z);
    d = min(d, d * d0.w);
    d = min(d, d * d1.x);
    d = min(d, d * d1.y);
    d = min(d, d * d1.z);
    d = min(d, d * d1.w);

    return sqrt(d);
}

float metaballs(float2 pos, float2 scale, float jitter, float phase, float width, float smoothness, float seed)
{
    float d = metaballs(pos, scale, jitter, phase, seed); // assumes scalar field function is defined elsewhere
    return smoothstep(width, width + smoothness, d);
}

float metaballs(float2 pos, float2 scale, float jitter, float phase, uint metric, float seed)
{
    const float kPI2 = 6.2831853071;
    pos *= scale;

    float2 i = floor(pos);
    float2 f = pos - i;

    float3 offset = float3(-1.0, 0.0, 1.0);
    float4 cells = fmod(float4(i.xyxy + offset.xxzz), scale.xyxy) + seed;
    i = fmod(i, scale) + seed;

    float4 dx0, dy0, dx1, dy1;
    multiHash2D(float4(cells.xy, float2(i.x, cells.y)), float4(cells.zyx, i.y), dx0, dy0);
    multiHash2D(float4(cells.zwz, i.y), float4(cells.xw, float2(i.x, cells.w)), dx1, dy1);

    dx0 = 0.5 * sin(phase + kPI2 * dx0) + 0.5;
    dy0 = 0.5 * sin(phase + kPI2 * dy0) + 0.5;
    dx1 = 0.5 * sin(phase + kPI2 * dx1) + 0.5;
    dy1 = 0.5 * sin(phase + kPI2 * dy1) + 0.5;

    dx0 = offset.xyzx + dx0 * jitter - f.xxxx;
    dy0 = offset.xxxy + dy0 * jitter - f.yyyy;
    dx1 = offset.zzxy + dx1 * jitter - f.xxxx;
    dy1 = offset.zyzz + dy1 * jitter - f.yyyy;

    float4 d0 = distanceMetric(dx0, dy0, metric); // assumes distanceMetric(float4, float4, uint)
    float4 d1 = distanceMetric(dx1, dy1, metric);

    float2 centerPos = (0.5 * sin(phase + kPI2 * multiHash2D(i)) + 0.5) * jitter - f;
    float d = min(1.0, distanceMetric(centerPos, metric)); // assumes distanceMetric(float2, uint)

    d = min(d, d * d0.x);
    d = min(d, d * d0.y);
    d = min(d, d * d0.z);
    d = min(d, d * d0.w);
    d = min(d, d * d1.x);
    d = min(d, d * d1.y);
    d = min(d, d * d1.z);
    d = min(d, d * d1.w);

    return (metric == 0u) ? sqrt(d) : d;
}

float metaballs(float2 pos, float2 scale, float jitter, float phase, float width, float smoothness, uint metric, float seed)
{
    float d = metaballs(pos, scale, jitter, phase, metric, seed); // assumes scalar field function is defined elsewhere
    return smoothstep(width, width + smoothness, d);
}

#endif