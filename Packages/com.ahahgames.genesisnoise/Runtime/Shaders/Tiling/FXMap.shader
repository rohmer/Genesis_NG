Shader "Hidden/Genesis/FXMap"
{
    Properties
    {
        // Global
        _Scale("Global Scale", Float) = 4.0
        _Seed("Seed (integer)", Float) = 0.0
        _NonSquare("Non Square Expansion", Float) = 0.0

        // distribution
        _Spacing("Spacing (cells)", Float) = 6.0
        _Density("Density (0-1)", Range(0,1)) = 0.85
        _Jitter("Position Jitter", Range(0,1)) = 0.45
        _TileSize("Tile Size (for tiling)", Float) = 0.0

        // brush shape fallback
        _BrushScale("Brush Scale", Float) = 1.0
        _BrushAspect("Brush Aspect (x/y)", Range(0.2,3.0)) = 1.6
        _BrushRoundness("Brush Roundness", Range(0.0,2.0)) = 1.0
        _BrushSoftness("Brush Softness", Range(0.0,1.0)) = 0.35

        // orientation & variation
        _Rotation("Base Rotation (radians)", Float) = 0.0
        _RotationJitter("Rotation Jitter", Range(0,1)) = 0.8
        _ScaleJitter("Scale Jitter", Range(0,1)) = 0.25
        _FlipChance("Flip Chance", Range(0,1)) = 0.15

        // brush texture inputs (one or more can be assigned)
        _BrushTex2D("Brush Texture 2D", 2D) = "white" {}
        _BrushTex3D("Brush Texture 3D", 3D) = "" {}
        _BrushTexCube("Brush Texture Cube", Cube) = "" {}

        _BrushTexUse("Use Brush Texture", Range(0,1)) = 1.0
        [Enum(Brush2D,0, Brush3D,1, BrushCube,2)] _BrushTexType("Brush Type", Float) = 0
        _BrushTexChannel("Brush Channel (0 R,1 G,2 B,3 A)", Range(0,3)) = 3

        // layering / blending
        _BlendMode("Blend Mode (0 Add,1 Multiply,2 Max)", Range(0,2)) = 0
        _MaskThreshold("Mask Threshold", Range(0,1)) = 0.5

        // debug
        [Enum(None,0, Points,1, Mask,2, Orientation,3, Shaded,4, Inverted,5)] _Debug("Debug", Float) = 4
    }
    SubShader { Pass {
        HLSLPROGRAM
        #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
        #pragma vertex CustomRenderTextureVertexShader
        #pragma fragment GenesisFragment
        #pragma target 3.0

        // properties
        float _Scale;
        float _Seed;
        float _NonSquare;

        float _Spacing;
        float _Density;
        float _Jitter;
        float _TileSize;

        float _BrushScale;
        float _BrushAspect;
        float _BrushRoundness;
        float _BrushSoftness;

        float _Rotation;
        float _RotationJitter;
        float _ScaleJitter;
        float _FlipChance;

        // textures declared without SamplerState; use legacy tex2D/tex3D/texCUBE sampling
        sampler2D _BrushTex2D;
        sampler3D _BrushTex3D;
        samplerCUBE _BrushTexCube;

        float _BrushTexUse;
        float _BrushTexType;
        float _BrushTexChannel;

        float _BlendMode;
        float _MaskThreshold;

        float _Debug;

        // basic tiled hash helpers (tile optional)
        float hash11_t(float n, float seed, float tile) {
            float wn = (tile > 0.0) ? fmod(floor(n) + seed, max(1e-5, tile)) : floor(n) + seed;
            return frac(sin(wn * 127.1) * 43758.5453);
        }
        float2 hash21_t(float2 p, float seed, float tile) {
            float2 ip = floor(p);
            if (tile > 0.0) ip = fmod(ip + seed, max(1e-5, tile));
            float n = dot(ip, float2(127.1,311.7));
            float2 r = frac(sin(float2(n, n+1.0) * 127.1) * 43758.5453);
            return r;
        }

        // cheap worley-like nearest point (F1) with id
        float2 cellularF1_t(float2 p, float seed, float tile) {
            float2 ip = floor(p);
            float2 fp = frac(p);
            float best = 10.0;
            float bestId = 0.0;
            for (int y=-1; y<=1; y++) {
                for (int x=-1; x<=1; x++) {
                    float2 b = float2(x,y);
                    float2 cell = ip + b;
                    float2 rp = hash21_t(cell, seed, tile);
                    float2 diff = b + rp - fp;
                    float d = dot(diff, diff);
                    if (d < best) {
                        best = d;
                        bestId = hash11_t(cell.x + cell.y*57.0, seed, tile);
                    }
                }
            }
            return float2(sqrt(best), bestId);
        }

        // --- FBM and supporting noise (non-tiled) ---
        float hash11(float n) {
            return frac(sin(n * 127.1 + _Seed) * 43758.5453);
        }
        float noise2(float2 p) {
            float2 i = floor(p);
            float2 f = frac(p);
            float a = hash11(i.x + i.y * 57.0);
            float b = hash11(i.x + 1.0 + i.y * 57.0);
            float c = hash11(i.x + (i.y + 1.0) * 57.0);
            float d = hash11(i.x + 1.0 + (i.y + 1.0) * 57.0);
            float2 u = f * f * (3.0 - 2.0 * f);
            return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
        }
        float fbm(float2 p, int octaves) {
            float v = 0.0;
            float amp = 0.5;
            float2 shift = float2(100.0, 100.0);
            for (int i = 0; i < octaves; i++) {
                v += amp * noise2(p);
                p = p * 2.0 + shift;
                amp *= 0.5;
            }
            return v;
        }
        // --- end FBM ---

        // brush fallback shape
        float brushShapeFallback(float2 local, float scale, float aspect, float roundness, float softness) {
            float2 p = local / scale;
            p.x *= aspect;
            float rx = pow(abs(p.x), max(0.001, roundness));
            float ry = pow(abs(p.y), max(0.001, roundness));
            float dist = pow(rx + ry, 1.0 / max(0.001, roundness));
            float s = smoothstep(1.0, 1.0 - softness, dist);
            return 1.0 - s;
        }

        // -------------------------
        // TEXTURE_SAMPLER_X (no SamplerState)
        // -------------------------
        // Use tex2D/tex3D/texCUBE with sampler declarations above.
        float sampleBrushTextureGeneric(float2 local, float brushSize, float aspect, float rotation, float flip, float seedOffset)
        {
            // map local to normalized brush-local coordinates centered at 0
            float2 p = local / brushSize;
            p.x *= aspect;
            // rotate back by -rotation to sample texture in its local orientation
            float c = cos(-rotation), s = sin(-rotation);
            float2 r = float2(p.x * c - p.y * s, p.x * s + p.y * c);
            r.x *= flip;
            // convert to texture UV (0..1)
            float2 uv2 = r * 0.5 + 0.5;

            int type = (int)round(_BrushTexType);
            if (type == 0) {
                // 2D: sample _BrushTex2D using tex2D
                float2 uv = saturate(uv2);
                float4 tex = tex2D(_BrushTex2D, uv);
                if (_BrushTexChannel < 0.5) return tex.r;
                else if (_BrushTexChannel < 1.5) return tex.g;
                else if (_BrushTexChannel < 2.5) return tex.b;
                return tex.a;
            } else if (type == 1) {
                // 3D: build a z coordinate from seedOffset and local position for variety
                float z = 0.5 + frac(seedOffset * 0.12345 + dot(local, float2(12.9898,78.233)))*0.5;
                float3 uv3 = float3(saturate(uv2), saturate(z));
                float4 tex = tex3D(_BrushTex3D, uv3);
                if (_BrushTexChannel < 0.5) return tex.r;
                else if (_BrushTexChannel < 1.5) return tex.g;
                else if (_BrushTexChannel < 2.5) return tex.b;
                return tex.a;
            } else {
                // Cube: interpret uv2 as a direction on the cube map
                float3 dir = normalize(float3(uv2 - 0.5, 1.0));
                float4 tex = texCUBE(_BrushTexCube, dir);
                if (_BrushTexChannel < 0.5) return tex.r;
                else if (_BrushTexChannel < 1.5) return tex.g;
                else if (_BrushTexChannel < 2.5) return tex.b;
                return tex.a;
            }
        }

        // blend helper
        float blend(float a, float b, float mode) {
            if (mode < 0.5) return saturate(a + b); // Add
            else if (mode < 1.5) return a * b; // Multiply
            else return max(a,b); // Max
        }

        float4 mixture(v2f_customrendertexture i) : SV_Target {
            float2 uv = i.localTexcoord.xy;

            // non-square compensation
            if (_NonSquare > 0.0 && i.localTexcoord.z > 0.0) {
                float aspect = i.localTexcoord.z;
                uv.x = lerp(uv.x, uv.x * aspect, _NonSquare);
            }

            // base coordinate scaled to cell grid
            float2 gridUV = uv * _Scale;

            // cell coordinate for distribution (spacing controls cell size)
            float2 cellUV = gridUV / max(1e-5, _Spacing);

            // tile and seed parameters
            float tile = _TileSize;
            float seed = floor(_Seed);

            // compute nearest point (F1) in cell grid to place a stamp
            float2 c = cellularF1_t(cellUV, seed, tile);
            float distToPoint = c.x;   // distance in cell space
            float pointId = c.y;      // id for per-point variation

            // decide whether a point exists (density)
            float presence = hash11_t(pointId * 12.9898, seed, tile);
            presence = step(1.0 - _Density, presence); // 1 if present

            // compute jittered point position inside cell
            float2 cellBase = floor(cellUV);
            float2 jitter = hash21_t(cellBase + pointId, seed + 3.0, tile) - 0.5;
            jitter *= _Jitter;
            float2 pointPos = (cellBase + 0.5 + jitter); // point in cell coordinates

            // local coordinate from uv to point (in cell units)
            float2 local = cellUV - pointPos;

            // orientation and per-point variation
            float rotNoise = hash11_t(pointId * 78.233, seed + 7.0, tile);
            float rot = _Rotation + (rotNoise - 0.5) * 6.2831853 * _RotationJitter; // radians
            float flip = (hash11_t(pointId * 45.32, seed + 11.0, tile) < _FlipChance) ? -1.0 : 1.0;
            float scaleNoise = 1.0 + (hash11_t(pointId * 99.13, seed + 13.0, tile) - 0.5) * _ScaleJitter;

            // brush size in cell units: brushScale * spacing * global scale factor
            float brushSize = _BrushScale * (_Spacing * 0.5) * scaleNoise;

            // sample brush texture if enabled using TEXTURE_SAMPLER_X abstraction (no SamplerState)
            float brushTexVal = 0.0;
            if (_BrushTexUse > 0.5) {
                brushTexVal = sampleBrushTextureGeneric(local, brushSize, _BrushAspect, rot, flip, pointId + seed);
            }

            // fallback procedural brush shape
            float brushFallback = brushShapeFallback(local, brushSize, _BrushAspect, _BrushRoundness, _BrushSoftness);

            // combine texture and fallback
            float finalBrush = lerp(brushFallback, brushTexVal * brushFallback, _BrushTexUse);

            // optionally threshold to produce binary mask
            float binary = step(_MaskThreshold, finalBrush);

            // combine multiple nearby stamps by sampling neighboring cells to allow overlap
            float accum = 0.0;
            for (int oy=-1; oy<=1; oy++) {
                for (int ox=-1; ox<=1; ox++) {
                    float2 nCell = cellBase + float2(ox, oy);
                    float2 nJ = hash21_t(nCell + pointId + 17.0, seed + 19.0, tile) - 0.5;
                    nJ *= _Jitter;
                    float2 nPoint = nCell + 0.5 + nJ;
                    float2 nLocal = cellUV - nPoint;
                    float nid = hash11_t(nCell.x + nCell.y*57.0, seed + 23.0, tile);
                    float nrotNoise = hash11_t(nid * 78.233, seed + 29.0, tile);
                    float nrot = _Rotation + (nrotNoise - 0.5) * 6.2831853 * _RotationJitter;
                    float nflip = (hash11_t(nid * 45.32, seed + 31.0, tile) < _FlipChance) ? -1.0 : 1.0;
                    float nscaleNoise = 1.0 + (hash11_t(nid * 99.13, seed + 37.0, tile) - 0.5) * _ScaleJitter;
                    float nBrushSize = _BrushScale * (_Spacing * 0.5) * nscaleNoise;

                    // sample neighbor brush texture via TEXTURE_SAMPLER_X (no SamplerState)
                    float nBrushTexVal = 0.0;
                    if (_BrushTexUse > 0.5) {
                        nBrushTexVal = sampleBrushTextureGeneric(nLocal, nBrushSize, _BrushAspect, nrot, nflip, nid + seed);
                    }
                    float nBrushFallback = brushShapeFallback(nLocal, nBrushSize, _BrushAspect, _BrushRoundness, _BrushSoftness);
                    float nFinalBrush = lerp(nBrushFallback, nBrushTexVal * nBrushFallback, _BrushTexUse);

                    float npres = step(1.0 - _Density, hash11_t(nid * 12.7, seed + 41.0, tile));
                    float nmask = nFinalBrush * npres;
                    float w = smoothstep(1.5, 0.0, length(nLocal));
                    accum = blend(accum, nmask * w, _BlendMode);
                }
            }

            // final mask (combined)
            float finalMask = saturate(accum);

            // produce orientation visualization (for debug)
            float orientVis = frac((rot + 3.1415926) / 6.2831853);

            // produce shaded output: simple height from mask plus subtle noise for variation
            float micro = fbm(cellUV * 3.0 + seed, 4);
            float shaded = saturate(finalMask * (0.9 + 0.1 * micro));

            // debug outputs
            if (_Debug == 1) { // Points presence map
                return float4(step(1.0 - _Density, hash11_t(pointId * 12.9898, seed, tile)),1,1,1);
            }
            if (_Debug == 2) { // Mask (binary)
                return float4(binary, binary, binary, 1);
            }
            if (_Debug == 3) { // Orientation visualization
                return float4(orientVis, orientVis, orientVis, 1);
            }
            if (_Debug == 5) { // Inverted
                return float4(1.0 - shaded, 1.0 - shaded, 1.0 - shaded, 1);
            }

            // default: shaded final
            return float4(shaded, shaded, shaded, 1);
        }
        ENDHLSL
    }} 
    FallBack Off
}
