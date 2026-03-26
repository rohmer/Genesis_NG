Shader "Hidden/Genesis/TileRandom"
{
    Properties
    {
        // Pattern inputs (up to 8)
        [InlineTexture]_Pattern0_2D("Pattern 0", 2D) = "white" {}
        [InlineTexture]_Pattern0_3D("Pattern 0", 3D) = "white" {}
        [InlineTexture]_Pattern0_Cube("Pattern 0", Cube) = "white" {}

        [InlineTexture]_Pattern1_2D("Pattern 1", 2D) = "white" {}
        [InlineTexture]_Pattern1_3D("Pattern 1", 3D) = "white" {}
        [InlineTexture]_Pattern1_Cube("Pattern 1", Cube) = "white" {}

        [InlineTexture]_Pattern2_2D("Pattern 2", 2D) = "white" {}
        [InlineTexture]_Pattern2_3D("Pattern 2", 3D) = "white" {}
        [InlineTexture]_Pattern2_Cube("Pattern 2", Cube) = "white" {}

        [InlineTexture]_Pattern3_2D("Pattern 3", 2D) = "white" {}
        [InlineTexture]_Pattern3_3D("Pattern 3", 3D) = "white" {}
        [InlineTexture]_Pattern3_Cube("Pattern 3", Cube) = "white" {}

        [InlineTexture]_Pattern4_2D("Pattern 4", 2D) = "white" {}
        [InlineTexture]_Pattern4_3D("Pattern 4", 3D) = "white" {}
        [InlineTexture]_Pattern4_Cube("Pattern 4", Cube) = "white" {}

        [InlineTexture]_Pattern5_2D("Pattern 5", 2D) = "white" {}
        [InlineTexture]_Pattern5_3D("Pattern 5", 3D) = "white" {}
        [InlineTexture]_Pattern5_Cube("Pattern 5", Cube) = "white" {}

        [InlineTexture]_Pattern6_2D("Pattern 6", 2D) = "white" {}
        [InlineTexture]_Pattern6_3D("Pattern 6", 3D) = "white" {}
        [InlineTexture]_Pattern6_Cube("Pattern 6", Cube) = "white" {}

        [InlineTexture]_Pattern7_2D("Pattern 7", 2D) = "white" {}
        [InlineTexture]_Pattern7_3D("Pattern 7", 3D) = "white" {}
        [InlineTexture]_Pattern7_Cube("Pattern 7", Cube) = "white" {}

        // How many patterns are active (1..8)
        _PatternCount("Pattern Count", Float) = 1

        // Per-pattern weights
        _Weight0("Weight 0", Float) = 1
        _Weight1("Weight 1", Float) = 0
        _Weight2("Weight 2", Float) = 0
        _Weight3("Weight 3", Float) = 0
        _Weight4("Weight 4", Float) = 0
        _Weight5("Weight 5", Float) = 0
        _Weight6("Weight 6", Float) = 0
        _Weight7("Weight 7", Float) = 0

        // Tile count
        _TilesX("Tiles X", Float) = 8
        _TilesY("Tiles Y", Float) = 8

        // Randomization controls
        [Enum(Disabled,0,Enabled,1)]_RandRot("Random Rotation", int) = 1
        [Enum(Disabled,0,Enabled,1)]_RandScale("Random Scale", int) = 1
        [Enum(Disabled,0,Enabled,1)]_RandOffset("Random Offset", int) = 1
        [Enum(Disabled,0,Enabled,1)]_RandColor("Random Color", int) = 1
        [Enum(Disabled,0,Enabled,1)]_RandFlip("Random Flip", int) = 1

        // Rotation quantization
        _RotSteps("Rotation Steps (0 = continuous)", Float) = 0

        // Scale range
        _ScaleMin("Scale Min", Float) = 0.6
        _ScaleMax("Scale Max", Float) = 1.4

        // HSV variation ranges
        _HueMin("Hue Min", Float) = -0.05
        _HueMax("Hue Max", Float) = 0.05
        _SatMin("Sat Min", Float) = 0.9
        _SatMax("Sat Max", Float) = 1.1
        _ValMin("Val Min", Float) = 0.9
        _ValMax("Val Max", Float) = 1.1

        // Padding / bleed control (0..0.5)
        _Padding("Tile Padding", Float) = 0.02

        // Stochastic remap
        [Enum(Disabled,0,Enabled,1)]_Stochastic("Stochastic Remap", int) = 1

        // Bijective permutation toggle
        [Enum(Disabled,0,Enabled,1)]_Bijective("Bijective Permutation", int) = 1

        _Seed("Seed", Float) = 0.0

        // Debug
        [Enum(None,0, TileID,1, Mask,2, EdgeMask,3, RemappedID,4, PatternIndex,5)] _Debug("Debug Mode", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 250

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            // Pattern samplers
            TEXTURE_SAMPLER_X(_Pattern0);
            TEXTURE_SAMPLER_X(_Pattern1);
            TEXTURE_SAMPLER_X(_Pattern2);
            TEXTURE_SAMPLER_X(_Pattern3);
            TEXTURE_SAMPLER_X(_Pattern4);
            TEXTURE_SAMPLER_X(_Pattern5);
            TEXTURE_SAMPLER_X(_Pattern6);
            TEXTURE_SAMPLER_X(_Pattern7);

            float _PatternCount;
            float _Weight0;
            float _Weight1;
            float _Weight2;
            float _Weight3;
            float _Weight4;
            float _Weight5;
            float _Weight6;
            float _Weight7;

            float _TilesX;
            float _TilesY;

            float _RandRot;
            float _RandScale;
            float _RandOffset;
            float _RandColor;
            float _RandFlip;

            float _RotSteps;

            float _ScaleMin;
            float _ScaleMax;

            float _HueMin;
            float _HueMax;
            float _SatMin;
            float _SatMax;
            float _ValMin;
            float _ValMax;

            float _Padding;

            float _Stochastic;
            float _Bijective;
            float _Seed;

            float _Debug;

            // ------------------------------------------------------------
            // Deterministic hash (Substance-like)
            // ------------------------------------------------------------
            float hash11(float n)
            {
                return frac(sin(n * 127.1 + _Seed) * 43758.5453);
            }

            float2 hash21(float n)
            {
                float x = hash11(n);
                float y = hash11(n + 19.19);
                return float2(x, y);
            }

            float3 hash31(float n)
            {
                return float3(hash11(n), hash11(n + 19.19), hash11(n + 37.73));
            }

            // ------------------------------------------------------------
            // Integer helpers for bijection
            // ------------------------------------------------------------
            int gcd_int(int a, int b)
            {
                a = abs(a);
                b = abs(b);
                while (b != 0)
                {
                    int t = a % b;
                    a = b;
                    b = t;
                }
                return a;
            }

            // Find a multiplier 'a' coprime with m using hash seed
            int find_coprime_multiplier(int m, int seedVal)
            {
                // start from an odd candidate derived from seedVal
                int a = (seedVal * 1664525 + 1013904223) & 0x7fffffff;
                a = (a % (m - 1)) + 1;
                // ensure odd to avoid trivial even gcd with even m
                if ((a & 1) == 0) a += 1;
                // bump until coprime (should converge quickly)
                int tries = 0;
                while (gcd_int(a, m) != 1 && tries < 16)
                {
                    a += 2;
                    if (a >= m) a = (a % (m - 1)) + 1;
                    tries++;
                }
                // fallback: if still not coprime, return 1 (identity)
                if (gcd_int(a, m) != 1) return 1;
                return a;
            }

            // Bijective linear permutation: (a * x + b) % m with gcd(a,m)=1
            int bijectivePermuteInt(int x, int m, int seedVal)
            {
                if (m <= 1) return x;
                int a = find_coprime_multiplier(m, seedVal + 7);
                int b = (seedVal * 1103515245 + 12345) % m;
                int res = (int)(((int)a * (int)x + b) % m);
                if (res < 0) res += m;
                return res;
            }

            // ------------------------------------------------------------
            // Rotate UV around center
            // ------------------------------------------------------------
            float2 rotate(float2 uv, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                uv -= 0.5;
                uv = float2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
                return uv + 0.5;
            }

            // ------------------------------------------------------------
            // HSV helpers
            // ------------------------------------------------------------
            float3 rgb2hsv(float3 c)
            {
                float4 K = float4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
                float4 p = (c.g < c.b) ? float4(c.bg, K.wz) : float4(c.gb, K.xy);
                float4 q = (c.r < p.x) ? float4(p.xyw, c.r) : float4(c.r, p.yzx);
                float d = q.x - min(q.w, q.y);
                float e = 1e-10;
                float h = abs(q.z + (q.w - q.y) / (6.0 * d + e));
                float s = d / (q.x + e);
                float v = q.x;
                return float3(h, s, v);
            }

            float3 hsv2rgb(float3 c)
            {
                float3 p = abs(frac(c.x + float3(0.0, 2.0/3.0, 1.0/3.0)) * 6.0 - 3.0) - 1.0;
                return c.z * lerp(float3(1.0,1.0,1.0), saturate(p), c.y);
            }

            // ------------------------------------------------------------
            // Edge mask (soft border inside tile)
            // ------------------------------------------------------------
            float tileEdgeMask(float2 tuv, float padding)
            {
                float2 innerMin = float2(padding, padding);
                float2 innerMax = float2(1.0 - padding, 1.0 - padding);
                float2 d = saturate((tuv - innerMin) / max(1e-6, innerMax - innerMin));
                float inside = min(d.x, d.y);
                return 1.0 - inside;
            }

            // ------------------------------------------------------------
            // Quantize rotation to N steps (0 = continuous)
            // ------------------------------------------------------------
            float quantizeAngle(float angle, float steps)
            {
                if (steps <= 0.5) return angle;
                float step = 6.2831853 / max(1.0, steps);
                return floor(angle / step + 0.5) * step;
            }

            // ------------------------------------------------------------
            // Stochastic remap: cheap decorrelation (kept for compatibility)
            // ------------------------------------------------------------
            float2 stochasticRemapTile(float2 tile, float tilesX, float tilesY, float tileID)
            {
                float total = max(1.0, tilesX * tilesY);
                float r = ceil(sqrt(total) * 0.5);
                float2 rnd = hash21(tileID + 77.77) - 0.5;
                float2 off = floor(rnd * (2.0 * r + 1.0));
                float2 rem = tile + off;
                rem.x = frac(rem.x / tilesX) * tilesX;
                rem.y = frac(rem.y / tilesY) * tilesY;
                return rem;
            }

            // ------------------------------------------------------------
            // Weighted selection helper
            // ------------------------------------------------------------
            int selectWeightedIndex(float rnd, out float usedWeightSum)
            {
                // gather weights into array
                float weights[8];
                weights[0] = _Weight0;
                weights[1] = _Weight1;
                weights[2] = _Weight2;
                weights[3] = _Weight3;
                weights[4] = _Weight4;
                weights[5] = _Weight5;
                weights[6] = _Weight6;
                weights[7] = _Weight7;

                int count = (int)clamp(_PatternCount, 1.0, 8.0);
                float sum = 0.0;
                for (int i = 0; i < count; ++i) sum += max(0.0, weights[i]);
                usedWeightSum = sum;
                if (sum <= 0.0)
                {
                    // fallback: uniform selection
                    return (int)floor(rnd * count);
                }
                float v = rnd * sum;
                float acc = 0.0;
                for (int i = 0; i < count; ++i)
                {
                    float w = max(0.0, weights[i]);
                    acc += w;
                    if (v <= acc) return i;
                }
                return count - 1;
            }

            // ------------------------------------------------------------
            // Sample selected pattern by index (CRT-safe)
            // ------------------------------------------------------------
            float4 samplePatternByIndex(int idx, float3 sampUV, float direction)
            {
                if (idx == 0) return SAMPLE_X(_Pattern0, sampUV, direction);
                if (idx == 1) return SAMPLE_X(_Pattern1, sampUV, direction);
                if (idx == 2) return SAMPLE_X(_Pattern2, sampUV, direction);
                if (idx == 3) return SAMPLE_X(_Pattern3, sampUV, direction);
                if (idx == 4) return SAMPLE_X(_Pattern4, sampUV, direction);
                if (idx == 5) return SAMPLE_X(_Pattern5, sampUV, direction);
                if (idx == 6) return SAMPLE_X(_Pattern6, sampUV, direction);
                return SAMPLE_X(_Pattern7, sampUV, direction);
            }

            // ------------------------------------------------------------
            // Main Tile Random Advanced + Weighted + Bijective logic
            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                // Tile index (integer coords)
                float2 tileF = floor(uv * float2(_TilesX, _TilesY));
                int tilesX = max(1, (int)max(1.0, _TilesX));
                int tilesY = max(1, (int)max(1.0, _TilesY));
                int totalTiles = tilesX * tilesY;
                int tileXI = (int)tileF.x;
                int tileYI = (int)tileF.y;
                int tileID = tileXI + tileYI * tilesX;

                // Optionally apply stochastic remap first (decorrelation)
                int usedTileX = tileXI;
                int usedTileY = tileYI;
                int remappedID = tileID;
                if (_Stochastic > 0.5)
                {
                    float2 rem = stochasticRemapTile(tileF, (float)tilesX, (float)tilesY, (float)tileID);
                    usedTileX = (int)rem.x;
                    usedTileY = (int)rem.y;
                    remappedID = usedTileX + usedTileY * tilesX;
                }

                // Optionally apply bijective permutation to remappedID
                int permutedID = remappedID;
                if (_Bijective > 0.5)
                {
                    // derive a seedVal from remappedID and _Seed
                    int seedVal = (int)floor(frac(_Seed) * 2147483647.0) ^ remappedID;
                    permutedID = bijectivePermuteInt(remappedID, totalTiles, seedVal);
                }

                // Local UV inside tile (0..1)
                float2 tuv = frac(uv * float2(_TilesX, _TilesY));

                // Apply padding: shrink sampling domain to avoid bleed
                float pad = saturate(_Padding);
                float2 domainMin = float2(pad, pad);
                float2 domainMax = float2(1.0 - pad, 1.0 - pad);
                tuv = domainMin + tuv * (domainMax - domainMin);

                // Random values per (permuted) tile
                float2 r2 = hash21((float)permutedID + 0.123);
                float r1 = r2.x;
                float r3 = hash11((float)permutedID + 5.5);

                // Random flip
                bool flipH = false;
                bool flipV = false;
                if (_RandFlip > 0.5)
                {
                    float2 f = hash21((float)permutedID + 200.0);
                    flipH = f.x > 0.5;
                    flipV = f.y > 0.5;
                }
                if (flipH) tuv.x = 1.0 - tuv.x;
                if (flipV) tuv.y = 1.0 - tuv.y;

                // Random rotation (quantized)
                if (_RandRot > 0.5)
                {
                    float angle = (r1 * 6.2831853);
                    angle = quantizeAngle(angle, _RotSteps);
                    tuv = rotate(tuv, angle);
                }

                // Random scale
                float scale = lerp(_ScaleMin, _ScaleMax, r2.y);
                scale = lerp(1.0, scale, _RandScale);
                tuv = (tuv - 0.5) / scale + 0.5;

                // Random offset (jitter)
                if (_RandOffset > 0.5)
                {
                    float2 off = (hash21((float)permutedID + 99.99) - 0.5) * 0.5;
                    tuv += off * _RandOffset;
                }

                // Weighted multi-input selection
                float rndSel = hash11((float)permutedID + 999.0);
                float usedWeightSum;
                int selIndex = selectWeightedIndex(rndSel, usedWeightSum);

                // If weights sum is zero, fallback to uniform across active patterns
                if (usedWeightSum <= 0.0)
                {
                    int count = (int)clamp(_PatternCount, 1.0, 8.0);
                    selIndex = (int)floor(rndSel * count);
                }

                // Sample selected pattern (CRT-safe)
                float3 sampUV3 = float3(tuv, i.localTexcoord.z);
                float4 col = samplePatternByIndex(selIndex, sampUV3, i.direction);

                // Random color variation (HSV)
                if (_RandColor > 0.5)
                {
                    float3 hv = hash31((float)permutedID + 123.456);
                    float hueShift = lerp(_HueMin, _HueMax, hv.x) * _RandColor;
                    float satMul = lerp(_SatMin, _SatMax, hv.y) * _RandColor;
                    float valMul = lerp(_ValMin, _ValMax, hv.z) * _RandColor;

                    float3 hsv = rgb2hsv(col.rgb);
                    hsv.x = frac(hsv.x + hueShift);
                    hsv.y = saturate(hsv.y * satMul);
                    hsv.z = saturate(hsv.z * valMul);
                    col.rgb = hsv2rgb(hsv);
                }

                // Edge mask for blending / debug
                float edge = tileEdgeMask(frac(uv * float2(tilesX, tilesY)), pad);

                // Debug modes
                if (_Debug == 1) // Tile ID normalized
                {
                    float norm = frac((float)tileID / 256.0);
                    return float4(norm, 0, 0, 1);
                }
                if (_Debug == 2) // UV mask
                {
                    return float4(frac(uv * float2(tilesX, tilesY)), 0, 1);
                }
                if (_Debug == 3) // Edge mask
                {
                    return float4(edge, edge, edge, 1);
                }
                if (_Debug == 4) // Remapped ID normalized
                {
                    float norm = frac((float)permutedID / 256.0);
                    return float4(norm, 0, 0, 1);
                }
                if (_Debug == 5) // Pattern index visualized
                {
                    float v = (selIndex + 1) / max(1.0, _PatternCount);
                    return float4(v, v * 0.5, 0, 1);
                }

                return col;
            }

            ENDHLSL
        }
    }
}
