#ifndef INTERP
#define INTERP
float noiseInterpolate(float x)
{
    float x2 = x * x;
    return x2 * x * (x * (x * 6.0 - 15.0) + 10.0);
}

float2 noiseInterpolate(float2 x)
{
    float2 x2 = x * x;
    return x2 * x * (x * (x * 6.0 - 15.0) + 10.0);
}

float3 noiseInterpolate(float3 x)
{
    float3 x2 = x * x;
    return x2 * x * (x * (x * 6.0 - 15.0) + 10.0);
}

float4 noiseInterpolate(float4 x)
{
    float4 x2 = x * x;
    return x2 * x * (x * (x * 6.0 - 15.0) + 10.0);
}

float2 noiseInterpolateDu(float x)
{
    float x2 = x * x;
    float u = x2 * x * (x * (x * 6.0 - 15.0) + 10.0);
    float du = 30.0 * x2 * (x * (x - 2.0) + 1.0);
    return float2(u, du);
}

float4 noiseInterpolateDu(float2 x)
{
    float2 x2 = x * x;
    float2 u = x2 * x * (x * (x * 6.0 - 15.0) + 10.0);
    float2 du = 30.0 * x2 * (x * (x - 2.0) + 1.0);
    return float4(u, du);
}

void noiseInterpolateDu(float3 x, out float3 u, out float3 du)
{
    float3 x2 = x * x;
    u = x2 * x * (x * (x * 6.0 - 15.0) + 10.0);
    du = 30.0 * x2 * (x * (x - 2.0) + 1.0);
}

#endif