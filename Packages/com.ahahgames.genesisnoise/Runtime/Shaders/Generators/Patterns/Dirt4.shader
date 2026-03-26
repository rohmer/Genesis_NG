Shader "Hidden/Genesis/GrungeDirt4"
{
    Properties
    {
        // Global
        _Scale("Base Scale", Float) = 6.0
        _Detail("Detail Strength", Range(0,2)) = 1.0
        _Contrast("Contrast", Range(0.2,3.0)) = 1.4
        _Intensity("Intensity", Range(0,3)) = 1.0

        // Speckle layer
        _SpeckScale("Speckle Scale", Float) = 220.0
        _SpeckDensity("Speckle Density", Range(0,1)) = 0.72
        _SpeckSize("Speck Size", Range(0.001,0.06)) = 0.012
        _SpeckVar("Speck Size Variation", Range(0,1)) = 0.55
        _SpeckSoft("Speck Softness", Range(0.0,0.5)) = 0.02

        // Splatter / blotches
        _Splatter("Splatter Amount", Range(0,1)) = 0.45
        _SplatterScale("Splatter Scale", Float) = 28.0

        // Anti-tiling
        _DomainWarp("Domain Warp Amount", Range(0,0.5)) = 0.05
        _TileBlend("Tile Blend", Range(0,1)) = 1
        _LargeNoiseScale("Large Noise Scale", Float) = 1.8

        // Curvature / AO input
        [InlineTexture]_Curvature_2D("Curvature AO", 2D) = "white" {}
        [Enum(Disabled,0,Enabled,1)] _UseCurvature("Use Curvature Input", Float) = 0
        _CurvStrength("Curvature Strength", Range(0,2)) = 1.0

        // Optional permutation texture for artist control
        [InlineTexture]_PermutationTex_2D("Permutation Texture", 2D) = "white" {}
        [Enum(Disabled,0,Enabled,1)] _UsePermutationTex("Use Permutation Texture", Float) = 0

        // Seed and temporal jitter
        _Seed("Seed", Float) = 0.0
        _FrameJitter("Frame Jitter", Float) = 0.0

        // Debug
        [Enum(None,0, BaseFBM,1, Splatter,2, Speckle,3, Curvature,4, Final,5)] _Debug("Debug Mode", Float) = 5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            TEXTURE_SAMPLER_X(_Curvature);
            TEXTURE_SAMPLER_X(_PermutationTex);

            float _Scale;
            float _Detail;
            float _Contrast;
            float _Intensity;

            float _SpeckScale;
            float _SpeckDensity;
            float _SpeckSize;
            float _SpeckVar;
            float _SpeckSoft;

            float _Splatter;
            float _SplatterScale;

            float _DomainWarp;
            float _TileBlend;
            float _LargeNoiseScale;

            float _UseCurvature;
            float _CurvStrength;

            float _UsePermutationTex;

            float _Seed;
            float _FrameJitter;

            float _Debug;

            // deterministic hash (TAA friendly)
            float hash11(float n) { return frac(sin(n * 127.1 + _Seed + _FrameJitter) * 43758.5453); }
            float2 hash21(float n) { return float2(hash11(n), hash11(n + 19.19)); }

            // value noise and FBM
            float valueNoise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                float a = hash11(i.x + i.y * 57.0);
                float b = hash11(i.x + 1.0 + i.y * 57.0);
                float c = hash11(i.x + (i.y + 1.0) * 57.0);
                float d = hash11(i.x + 1.0 + (i.y + 1.0) * 57.0);
                float2 u = f * f * (3.0 - 2.0 * f);
                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            float fbm(float2 p, int octaves)
            {
                float v = 0.0;
                float amp = 0.5;
                float2 shift = float2(12.9898, 78.233);
                for (int i = 0; i < octaves; ++i)
                {
                    v += amp * valueNoise(p);
                    p = p * 2.0 + shift;
                    amp *= 0.5;
                }
                return v;
            }

            float lowFbm(float2 p)
            {
                float v = 0.0;
                float amp = 0.5;
                float2 shift = float2(12.34, 98.76);
                for (int i = 0; i < 3; ++i)
                {
                    v += amp * valueNoise(p);
                    p = p * 2.0 + shift;
                    amp *= 0.5;
                }
                return v;
            }

            // domain warp
            float2 domainWarp(float2 uv, float amt)
            {
                if (amt <= 1e-6) return uv;
                float2 q = float2(lowFbm(uv * _LargeNoiseScale + 12.34), lowFbm(uv * _LargeNoiseScale + 98.76));
                return uv + (q - 0.5) * amt;
            }

            // tile window for blending neighbors
            float tileWindow(float2 tuv, float blend)
            {
                float b = saturate(blend);
                float2 w = smoothstep(b, 0.0, abs(tuv - 0.5) * 2.0);
                return min(w.x, w.y);
            }

            // optional permutation texture lookup
            int permutationLookup(int tileID, int tilesX, int tilesY)
            {
                if (_UsePermutationTex < 0.5) return tileID;
                int total = tilesX * tilesY;
                float idx = frac((float)tileID / max(1.0, (float)total));
                float2 uv = float2(idx, 0.5);
                float val = SAMPLE_X(_PermutationTex, float3(uv, 0.0), 0.0).r;
                int perm = (int)floor(val * (float)total);
                return perm;
            }

            // cellular-like splatter
            float splatterNoise(float2 uv)
            {
                float2 p = uv * _SplatterScale;
                float2 cell = floor(p);
                float2 f = frac(p);
                float best = 1e6;
                for (int y = -1; y <= 1; ++y)
                {
                    for (int x = -1; x <= 1; ++x)
                    {
                        float2 c = cell + float2(x, y);
                        float id = c.x + c.y * 4096.0;
                        float2 r = hash21(id);
                        float2 center = r - 0.5;
                        float2 d = (f - float2(x, y) - center);
                        float dist = dot(d, d);
                        best = min(best, dist);
                    }
                }
                float v = 1.0 - sqrt(best);
                return saturate(v);
            }

            // speckle per-cell
            float gaussian(float r, float sigma) { float s = max(1e-6, sigma); return exp(- (r * r) / (2.0 * s * s)); }

            float speckAtCell(float2 cellCoord, float2 local, float cellId)
            {
                float2 r = hash21(cellId);
                if (r.x > _SpeckDensity) return 0.0;
                float2 center = float2(0.5, 0.5) + (r - 0.5) * 0.9;
                float sizeNoise = lerp(1.0 - _SpeckVar, 1.0 + _SpeckVar, r.y);
                float size = max(1e-4, _SpeckSize * sizeNoise);
                float2 d = (local - center) / size;
                float dist = length(d);
                float sigma = max(0.001, _SpeckSoft / max(1e-6, size));
                float g = gaussian(dist, sigma);
                float bright = lerp(0.6, 1.4, hash11(cellId + 7.7)) * _Intensity;
                return g * bright;
            }

            float sampleSpeckleBase(float2 uv)
            {
                float2 p = uv * _SpeckScale;
                float2 cell = floor(p);
                float2 local = frac(p);
                float sum = 0.0;
                for (int y = -1; y <= 1; ++y)
                {
                    for (int x = -1; x <= 1; ++x)
                    {
                        float2 c = cell + float2(x, y);
                        float cellId = c.x + c.y * 4096.0;
                        float2 localPos = local - float2(x, y);
                        sum += speckAtCell(c, localPos, cellId);
                    }
                }
                return sum;
            }

            // base dirt generator
            float generateBase(float2 tuv)
            {
                float base = fbm(tuv * _Scale, 5) * 0.6 + 0.4 * fbm(tuv * _Scale * 2.0, 3);
                float spl = splatterNoise(tuv) * _Splatter;
                float blot = spl * smoothstep(0.2, 0.85, base);
                float combined = saturate(base + blot * 0.8);
                return combined;
            }

            // blended sampling across tiles to hide seams
            float sampleBlendedDirt(float2 uv, float finalScale, float finalSeed)
            {
                float2 warpedUV = domainWarp(uv, _DomainWarp);
                float2 p = warpedUV * finalScale;
                float2 cell = floor(p);
                float2 tuv = frac(p);

                int tilesX = max(1, (int)max(1.0, finalScale));
                int tilesY = tilesX;

                float accum = 0.0;
                float wsum = 0.0;
                float blendRadius = saturate(_TileBlend);

                for (int oy = -1; oy <= 1; ++oy)
                {
                    for (int ox = -1; ox <= 1; ++ox)
                    {
                        float2 nCell = cell + float2(ox, oy);
                        int nTileX = (int)nCell.x;
                        int nTileY = (int)nCell.y;
                        int nID = nTileX + nTileY * tilesX;

                        int usedNID = nID;
                        if (_UsePermutationTex > 0.5)
                            usedNID = permutationLookup(nID, tilesX, tilesY);

                        float2 nTuv = tuv - float2(ox, oy);
                        float w = tileWindow(frac(nTuv), blendRadius);
                        float dist = length(nTuv - 0.5);
                        w *= exp(-dist * 2.0);

                        float neighborBase = generateBase(nTuv);

                        accum += neighborBase * w;
                        wsum += w;
                    }
                }

                float blended = accum / max(1e-6, wsum);

                // speckle layer added on top
                float speck = sampleSpeckleBase(uv) * 0.6;

                return saturate(blended * _Detail + speck);
            }

            // contrast mapping
            float applyContrast(float v, float c) { v = (v - 0.5) * c + 0.5; return saturate(v); }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float finalSeed = _Seed;

                float dirt = sampleBlendedDirt(uv, _Scale, finalSeed);

                // curvature bias
                if (_UseCurvature > 0.5)
                {
                    float4 cur = SAMPLE_X(_Curvature, float3(uv, i.localTexcoord.z), i.direction);
                    float ao = cur.r;
                    float crevice = 1.0 - ao;
                    dirt *= lerp(1.0, 1.0 + crevice * _CurvStrength, _UseCurvature);
                }

                dirt = applyContrast(dirt, _Contrast);
                dirt *= _Intensity;

                // debug outputs
                if (_Debug == 1)
                {
                    float raw = fbm(frac(uv * _Scale) * _Scale, 5);
                    return float4(raw, raw, raw, 1);
                }
                if (_Debug == 2)
                {
                    float s = splatterNoise(frac(uv * _SplatterScale));
                    return float4(s, s, s, 1);
                }
                if (_Debug == 3)
                {
                    float sp = sampleSpeckleBase(uv);
                    return float4(sp, sp, sp, 1);
                }
                if (_Debug == 4)
                {
                    float4 cur = SAMPLE_X(_Curvature, float3(uv, i.localTexcoord.z), i.direction);
                    return float4(cur.r, cur.r, cur.r, 1);
                }

                return float4(saturate(dirt), saturate(dirt), saturate(dirt), 1);
            }

            ENDHLSL
        }
    }
}
