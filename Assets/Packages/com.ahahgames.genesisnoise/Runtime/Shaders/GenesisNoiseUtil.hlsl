#ifndef GENESIS_NOISE_UTIL
#define GENESIS_NOISE_UTIL
#include "NoiseUtils.hlsl"

float3 NoiseUV(v2f_customrendertexture i, float4 customUvs, inout int seed)
{
#if defined (USE_CUSTOM_UV)
    seed += customUvs.a * 100;
    float3 offset = RandomOffset3(seed);
    return customUvs.xyz+offset;
#endif
    float3 offset = RandomOffset3(seed);
    return GetDefaultUVs(i)+offset;
}
#endif