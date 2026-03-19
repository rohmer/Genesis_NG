#ifndef GENESIS_FIXED
#define GENESIS_FIXED

#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisUtils.hlsl"
#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/CustomTexture.hlsl"
#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/Blending.hlsl"

float3 GetDefaultUVs(v2f_customrendertexture i)
{
#ifdef CRT_CUBE
    return i.direction;
#elif CRT_2D
    return float3(i.localTexcoord.xy, 0.5);
#else
    return i.localTexcoord.xyz;
#endif
}

#endif
