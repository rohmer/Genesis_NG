Shader "Hidden/Genesis/GrungeDirtFine"
{
    Properties
    {
        _Scale("Scale (speckle frequency)", Float) = 200.0
        _Density("Density (0..1)", Range(0,1)) = 0.65
        _Size("Size (0..1)", Range(0.001,0.2)) = 0.012
        _SizeVar("Size Variation", Range(0,1)) = 0.6
        _Brightness("Brightness", Range(0,4)) = 1.0
        _Contrast("Contrast", Range(0.1,4)) = 1.0
        _Softness("Edge Softness", Range(0.0,0.5)) = 0.02

        // Motion blur controls
        [Enum(Disabled,0,Enabled,1)] _MotionEnabled("Motion Blur Enabled", Float) = 0
        _MotionAngle("Motion Angle (0..1)", Range(0,1)) = 0.0
        _MotionLength("Motion Length (taps)", Range(0.0,8.0)) = 2.0
        _MotionSamples("Motion Samples (odd)", Range(1,15)) = 7
        _MotionJitter("Motion Jitter", Range(0,1)) = 0.15

        _Seed("Seed", Float) = 0.0

        [InlineTexture]_Curvature_2D("Curvature AO (optional)", 2D) = "white" {}
        [Enum(Disabled,0,Enabled,1)] _UseCurvature("Use Curvature Input", Float) = 0
        _CurvatureStrength("Curvature Strength", Range(0,2)) = 1.0

        // Bijective permutation for tiled patterns
        [Enum(Disabled,0,Enabled,1)] _Bijective("Bijective Tile Permutation", Float) = 0

        [Enum(None,0, RawNoise,1, Mask,2, Final,3, Motion,4, TileID,5)] _Debug("Debug Mode", Float) = 3
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 250

        Pass
        {
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            TEXTURE_SAMPLER_X(_Curvature);

            float _Scale;
            float _Density;
            float _Size;
            float _SizeVar;
            float _Brightness;
            float _Contrast;
            float _Softness;

            float _MotionEnabled;
            float _MotionAngle;
            float _MotionLength;
            float _MotionSamples;
            float _MotionJitter;

            float _Seed;

            float _UseCurvature;
            float _CurvatureStrength;

            float _Bijective;

            float _Debug;

            // ------------------------------------------------------------
            // Deterministic hash
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

            // ------------------------------------------------------------
            // Gaussian falloff for a speck
            // ------------------------------------------------------------
            float gaussian(float r, float sigma)
            {
                float s = max(1e-6, sigma);
                return exp(- (r * r) / (2.0 * s * s));
            }

            // ------------------------------------------------------------
            // Integer helpers for bijection (32-bit)
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

            // find a multiplier 'a' coprime with m using seed-derived candidate
            int find_coprime_multiplier(int m, int seedVal)
            {
                if (m <= 2) return 1;
                int a = (seedVal * 1664525 + 1013904223) & 0x7fffffff;
                a = (a % (m - 1)) + 1;
                if ((a & 1) == 0) a += 1;
                int tries = 0;
                while (gcd_int(a, m) != 1 && tries < 64)
                {
                    a += 2;
                    if (a >= m) a = (a % (m - 1)) + 1;
                    tries++;
                }
                if (gcd_int(a, m) != 1) return 1;
                return a;
            }

            // bijective linear permutation: (a * x + b) % m with gcd(a,m)=1
            int bijectivePermuteInt(int x, int m, int seedVal)
            {
                if (m <= 1) return x;
                int a = find_coprime_multiplier(m, seedVal + 7);
                int b = (seedVal * 1103515245 + 12345) % m;
                // use unsigned multiplication to reduce overflow issues
                uint ua = (uint)a;
                uint ux = (uint)x;
                uint um = (uint)m;
                uint res = (ua * ux + (uint)b) % um;
                return (int)res;
            }

            // ------------------------------------------------------------
            // Speck generation per cell
            // ------------------------------------------------------------
            float speckAtCell(float2 cellCoord, float2 local, float cellId)
            {
                float2 r = hash21(cellId);
                if (r.x > _Density) return 0.0;

                // center jitter inside cell
                float2 center = float2(0.5, 0.5) + (r - 0.5) * 0.9;

                // size variation
                float sizeNoise = lerp(1.0 - _SizeVar, 1.0 + _SizeVar, r.y);
                float size = max(1e-4, _Size * sizeNoise);

                // distance from local to center (local in 0..1)
                float2 d = (local - center) / size;
                float dist = length(d);

                // softness scaled by size
                float sigma = max(0.001, _Softness / max(1e-6, size));
                float g = gaussian(dist, sigma);

                // brightness per speck
                float bright = lerp(0.6, 1.4, hash11(cellId + 7.7)) * _Brightness;

                return g * bright;
            }

            // ------------------------------------------------------------
            // Sample speckle from a single cell (with optional bijection)
            // ------------------------------------------------------------
            float sampleCellSpeck(float2 cell, float2 local, int tilesX, int tilesY)
            {
                // compute cell id (float) for hashing; use large stride to reduce collisions
                int cellXI = (int)cell.x;
                int cellYI = (int)cell.y;
                int tileID = cellXI + cellYI * tilesX;

                int usedID = tileID;
                if (_Bijective > 0.5)
                {
                    int seedVal = (int)floor(frac(_Seed) * 2147483647.0) ^ tileID;
                    usedID = bijectivePermuteInt(tileID, tilesX * tilesY, seedVal);
                }

                float cellIdF = (float)usedID + (cell.x - floor(cell.x)) * 0.0001 + (cell.y - floor(cell.y)) * 0.00001;
                return speckAtCell(cell, local, cellIdF);
            }

            // ------------------------------------------------------------
            // Accumulate specks from neighborhood (3x3)
            // ------------------------------------------------------------
            float sampleSpeckleBase(float2 uv)
            {
                float2 p = uv * _Scale;
                float2 cell = floor(p);
                float2 local = frac(p);

                int tilesX = max(1, (int)max(1.0, _Scale));
                int tilesY = tilesX;

                float sum = 0.0;
                for (int y = -1; y <= 1; ++y)
                {
                    for (int x = -1; x <= 1; ++x)
                    {
                        float2 c = cell + float2(x, y);
                        float2 localPos = local - float2(x, y);
                        sum += sampleCellSpeck(c, localPos, tilesX, tilesY);
                    }
                }
                return sum;
            }

            // ------------------------------------------------------------
            // Motion blur: sample along direction and average
            // ------------------------------------------------------------
            float sampleMotionBlurredSpeckle(float2 uv)
            {
                // if motion disabled, return base
                if (_MotionEnabled < 0.5) return sampleSpeckleBase(uv);

                // direction vector
                float angle = _MotionAngle * 6.2831853;
                float2 dir = float2(cos(angle), sin(angle));

                // number of samples (ensure odd)
                int samples = max(1, (int)round(_MotionSamples));
                if ((samples & 1) == 0) samples += 1;
                float half = (samples - 1) * 0.5;

                float length = max(0.0, _MotionLength);
                float sum = 0.0;
                float wsum = 0.0;

                // jitter per-pixel to reduce banding
                float jitter = hash11(uv.x * 12.9898 + uv.y * 78.233 + _Seed) * _MotionJitter;

                for (int i = 0; i < samples; ++i)
                {
                    float t = (float(i) - half) / max(1.0, half); // -1..1
                    float offset = t * length + jitter * (t);
                    float2 sampUV = uv + dir * offset / _Scale; // scale offset into UV space
                    float val = sampleSpeckleBase(sampUV);
                    // gaussian weight across taps for smoother falloff
                    float w = exp(- (t * t) * 2.0);
                    sum += val * w;
                    wsum += w;
                }

                return sum / max(1e-6, wsum);
            }

            // ------------------------------------------------------------
            // Contrast curve
            // ------------------------------------------------------------
            float applyContrast(float v, float c)
            {
                v = (v - 0.5) * c + 0.5;
                return saturate(v);
            }

            // ------------------------------------------------------------
            // Fragment
            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                // compute speckle with motion blur
                float s = sampleMotionBlurredSpeckle(uv);

                // optional curvature/AO bias
                if (_UseCurvature > 0.5)
                {
                    float4 cur = SAMPLE_X(_Curvature, float3(uv, i.localTexcoord.z), i.direction);
                    float ao = cur.r;
                    float crevice = 1.0 - ao;
                    float bias = 1.0 + crevice * _CurvatureStrength;
                    s *= bias;
                }

                // apply contrast
                s = applyContrast(s, _Contrast);

                // debug modes
                if (_Debug == 1) // raw base (no motion)
                {
                    float raw = saturate(sampleSpeckleBase(uv));
                    return float4(raw, raw, raw, 1);
                }
                if (_Debug == 2) // binary mask
                {
                    float mask = step(0.5, s);
                    return float4(mask, mask, mask, 1);
                }
                if (_Debug == 4) // motion preview (difference between blurred and base)
                {
                    float base = saturate(sampleSpeckleBase(uv));
                    float motion = saturate(s);
                    float diff = saturate(motion - base);
                    return float4(diff, diff, diff, 1);
                }
                if (_Debug == 5) // tile id visualization (if bijective enabled)
                {
                    // visualize a hashed tile id
                    float2 p = uv * _Scale;
                    int tx = (int)floor(p.x);
                    int ty = (int)floor(p.y);
                    int tilesX = max(1, (int)max(1.0, _Scale));
                    int tileID = tx + ty * tilesX;
                    int usedID = tileID;
                    if (_Bijective > 0.5)
                    {
                        int seedVal = (int)floor(frac(_Seed) * 2147483647.0) ^ tileID;
                        usedID = bijectivePermuteInt(tileID, tilesX * tilesX, seedVal);
                    }
                    float norm = frac((float)usedID / 256.0);
                    return float4(norm, 0, 0, 1);
                }

                // final output: black background, white specks
                return float4(s, s, s, 1);
            }

            ENDHLSL
        }
    }
}