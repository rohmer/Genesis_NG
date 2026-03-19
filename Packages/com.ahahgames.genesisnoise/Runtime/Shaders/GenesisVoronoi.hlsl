#ifndef GENESISVORONOI
#define GENESISVORONOI

#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/ValueNoise.hlsl"
#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisPerlinNoise.hlsl"
#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisGradiantNoise.hlsl"
#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/multiHash.hlsl"

float3 voronoi(float2 pos, float2 scale, float jitter, float phase, float seed)
{
    const float kPI2 = 6.2831853071;
    pos *= scale;
    float2 i = floor(pos);
    float2 f = pos - i;

    // First pass
    float2 minPos = 0.0, tilePos = 0.0;
    float minDistance = 1e+5;

    for (int k = 0; k < 8; k += 2)
    {
        int2 k1 = int2(k, k + 1);
        int2 ky = k1 / 3;
        float4 n = float4(k1 - ky * 3, ky).xzyw - 1.0;

        float4 ni = fmod(i.xyxy + n, scale.xyxy) + seed;
        float4 cPos = multiHash2D(ni.xy, ni.zw) * jitter;
        cPos = 0.5 * sin(phase + kPI2 * cPos) + 0.5;
        float4 rPos = n + cPos - f.xyxy;

        float4 temp = rPos * rPos;
        temp.xy = temp.xz + temp.yw;
        float4 minResult = (temp.x < temp.y) ? float4(rPos.xy, cPos.xy) : float4(rPos.zw, cPos.zw);
        float d = min(temp.x, temp.y);

        if (d < minDistance)
        {
            minDistance = d;
            minPos = minResult.xy;
            tilePos = minResult.zw;
        }
    }

    // Last cell
    {
        float2 n = float2(1.0, 1.0);
        float2 ni = fmod(i + n, scale) + seed;
        float2 cPos = multiHash2D(ni) * jitter;
        cPos = 0.5 * sin(phase + kPI2 * cPos) + 0.5;
        float2 rPos = n + cPos - f;

        float d = dot(rPos, rPos);
        if (d < minDistance)
        {
            minDistance = d;
            minPos = rPos;
            tilePos = cPos;
        }
    }

    // Second pass: distance to edges
    minDistance = 1e+5;
    for (int y = -2; y <= 2; y++)
    {
        for (int x = -2; x <= 2; x += 2)
        {
            float4 n = float4(x, y, x + 1, y);
            float4 ni = fmod(i.xyxy + n, scale.xyxy) + seed;
            float4 cPos = multiHash2D(ni.xy, ni.zw) * jitter;
            cPos = 0.5 * sin(phase + kPI2 * cPos) + 0.5;
            float4 rPos = n + cPos - f.xyxy;

            float4 temp = minPos.xyxy - rPos;
            temp *= temp;
            float2 l = temp.xz + temp.yw;

            float4 a = 0.5 * (minPos.xyxy + rPos);
            float4 b = rPos - minPos.xyxy;
            temp = b * b;
            b /= sqrt(temp.xz + temp.yw).xxyy;

            temp = a * b;
            float2 d = temp.xz + temp.yw;

            if (l.x > 1e-5) minDistance = min(minDistance, d.x);
            if (l.y > 1e-5) minDistance = min(minDistance, d.y);
        }
    }

    return float3(minDistance, tilePos);
}

float3 voronoiPosition(float2 pos, float2 scale, float jitter, float phase, float seed)
{
    const float kPI2 = 6.2831853071;
    pos *= scale;
    float2 i = floor(pos);
    float2 f = pos - i;

    float2 tilePos = 0.0;
    float minDistance = 1e+5;

    for (int k = 0; k < 8; k += 2)
    {
        int2 k1 = int2(k, k + 1);
        int2 ky = k1 / 3;
        float4 n = float4(k1 - ky * 3, ky).xzyw - 1.0;

        float4 ni = fmod(i.xyxy + n, scale.xyxy) + seed;
        float4 cPos = multiHash2D(ni.xy, ni.zw) * jitter;
        cPos = 0.5 * sin(phase + kPI2 * cPos) + 0.5;
        float4 rPos = n + cPos - f.xyxy;

        float4 temp = rPos * rPos;
        temp.xy = temp.xz + temp.yw;

        float3 minResult = (temp.x < temp.y) ? float3(cPos.xy, temp.x) : float3(cPos.zw, temp.y);
        float d = minResult.z;

        if (d < minDistance)
        {
            minDistance = d;
            tilePos = minResult.xy;
        }
    }

    // Last cell
    {
        float2 n = float2(1.0, 1.0);
        float2 ni = fmod(i + n, scale) + seed;
        float2 cPos = multiHash2D(ni) * jitter;
        cPos = 0.5 * sin(phase + kPI2 * cPos) + 0.5;
        float2 rPos = n + cPos - f;

        float d = dot(rPos, rPos);
        if (d < minDistance)
        {
            minDistance = d;
            tilePos = cPos;
        }
    }

    return float3(tilePos, minDistance);
}

float3 voronoiPattern(float2 pos, float2 scale, float jitter, float variance, float factor, float seed)
{
    float2 tilePos = voronoiPosition(pos, scale, jitter, 0.0, 0.0).xy; 
    float rand = abs(hash1D(tilePos * factor + seed)); 
    return (rand < variance) ? hash3D(tilePos + seed) : float3(rand, rand, rand); 
}

float3 cracks(float2 pos, float2 scale, float jitter, float width, float smoothness, float warp, float warpScale, bool warpSmudge, float smudgePhase, float seed)
{
    float3 g = gradientNoised(pos, scale * warpScale, smudgePhase, seed); // assumes gradientNoised() returns float3
    pos += (warpSmudge ? g.yz : g.xx) * (0.1 * warp);

    float3 v = voronoi(pos, scale, jitter, 0.0, seed); // assumes voronoi() returns float3

    float edge = smoothstep(max(width - smoothness, 0.0), width + fwidth(v.x), v.x);
    return float3(edge, v.yz);
}

float cracks(float2 pos, float2 scale, float jitter, float width, float smoothness, float warp, float warpScale, bool warpSmudge, float seed)
{
    return cracks(pos, scale, jitter, width, smoothness, warp, warpScale, warpSmudge, 0.0, seed).x;
}

#endif