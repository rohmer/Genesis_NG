Shader "Hidden/Genesis/GrungeDirt3"
{
    Properties
    {
        // Preset selector
        [Enum(Default,0, Coastal,1, Urban,2, Rusty,3, FineSpeckle,4, LongStreaks,5, HeavyCrevice,6, Painterly,7)] _Preset("Preset", int) = 0

        // Core controls
        _Scale("Scale", Float) = 8.0
        _Intensity("Intensity", Float) = 1.0
        _Spread("Spread", Range(0.01,1.0)) = 0.35

        _Angle("Angle", Range(0,1)) = 0.0
        _Aniso("Anisotropy", Range(0,1)) = 0.6
        _Smear("Smear", Range(0,1)) = 0.5

        _EdgeOnly("Edge Only", Float) = 1.0
        _EdgeBoost("Edge Boost", Float) = 1.6
        _EdgeScale("Edge Scale", Float) = 2.0

        _Padding("Padding", Float) = 0.02
        _TileOffset("Tile Offset", Vector) = (0,0,0,0)
        _NonSquare("Non Square Expansion", Float) = 0.0

        // Per-tile randomization controls
        [Enum(Disabled,0,Enabled,1)] _PerTileRandom("Per Tile Randomization", Float) = 1
        _PerTileAngleJitter("Per Tile Angle Jitter", Range(0,1)) = 0.25
        _PerTileAspectJitter("Per Tile Aspect Jitter", Range(0,1)) = 0.25

        // Bijective permutation for tiled patterns
        [Enum(Disabled,0,Enabled,1)] _Bijective("Bijective Permutation", Float) = 0

        // Curvature / AO input (optional)
        [InlineTexture]_Curvature_2D("Curvature / AO", 2D) = "white" {}
        [Enum(Disabled,0,Enabled,1)] _UseCurvature("Use Curvature Input", Float) = 0
        _CurvatureStrength("Curvature Strength", Range(0,2)) = 1.0

        _Seed("Seed", Float) = 0.0

        [Enum(None,0, RawNoise,1, EdgeMask,2, Directional,3, Final,4, TileID,5)] _Debug("Debug Mode", Float) = 4
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        Pass
        {
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            // Curvature sampler
            TEXTURE_SAMPLER_X(_Curvature);

            // Properties
            float _Preset;
            float _Scale;
            float _Intensity;
            float _Spread;

            float _Angle;
            float _Aniso;
            float _Smear;

            float _EdgeOnly;
            float _EdgeBoost;
            float _EdgeScale;

            float _Padding;
            float4 _TileOffset;
            float _NonSquare;

            float _PerTileRandom;
            float _PerTileAngleJitter;
            float _PerTileAspectJitter;

            float _Bijective;

            float _UseCurvature;
            float _CurvatureStrength;

            float _Seed;
            float _Debug;

            // ------------------------------------------------------------
            // Deterministic hash and helpers
            // ------------------------------------------------------------
            float hash11(float n)
            {
                return frac(sin(n * 127.1 + _Seed) * 43758.5453);
            }
            float2 hash21(float n)
            {
                return float2(hash11(n), hash11(n + 19.19));
            }
            float3 hash31(float n)
            {
                return float3(hash11(n), hash11(n + 19.19), hash11(n + 37.73));
            }

            // ------------------------------------------------------------
            // Integer helpers for bijection (same approach used earlier)
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

            int find_coprime_multiplier(int m, int seedVal)
            {
                int a = (seedVal * 1664525 + 1013904223) & 0x7fffffff;
                a = (a % (m - 1)) + 1;
                if ((a & 1) == 0) a += 1;
                int tries = 0;
                while (gcd_int(a, m) != 1 && tries < 32)
                {
                    a += 2;
                    if (a >= m) a = (a % (m - 1)) + 1;
                    tries++;
                }
                if (gcd_int(a, m) != 1) return 1;
                return a;
            }

            int bijectivePermuteInt(int x, int m, int seedVal)
            {
                if (m <= 1) return x;
                int a = find_coprime_multiplier(m, seedVal + 7);
                int b = (seedVal * 1103515245 + 12345) % m;
                int prod = (int)a * (int)x + b;
                int res = (int)(prod % m);
                if (res < 0) res += m;
                return res;
            }

            // ------------------------------------------------------------
            // Noise / FBM
            // ------------------------------------------------------------
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

            float fbm(float2 p)
            {
                float v = 0.0;
                float amp = 0.5;
                float2 shift = float2(12.9898, 78.233);
                for (int i = 0; i < 6; ++i)
                {
                    v += amp * valueNoise(p);
                    p = p * 2.0 + shift;
                    amp *= 0.5;
                }
                return v;
            }

            // ------------------------------------------------------------
            // Rotate 2D point around center
            // ------------------------------------------------------------
            float2 rotate2(float2 p, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                return float2(p.x * c - p.y * s, p.x * s + p.y * c);
            }

            // ------------------------------------------------------------
            // Edge/curvature detector (cheap Laplacian on fbm)
            // ------------------------------------------------------------
            float edgeDetector(float2 uv, float scale)
            {
                float2 p = uv * scale;
                float c = fbm(p);
                float n1 = fbm(p + float2(1.0/scale, 0.0));
                float n2 = fbm(p + float2(-1.0/scale, 0.0));
                float n3 = fbm(p + float2(0.0, 1.0/scale));
                float n4 = fbm(p + float2(0.0, -1.0/scale));
                float lap = (n1 + n2 + n3 + n4 - 4.0 * c);
                return saturate(smoothstep(-0.02, 0.02, -lap));
            }

            // ------------------------------------------------------------
            // Directional smear (anisotropic sampling)
            // ------------------------------------------------------------
            float directionalSmear(float2 uv, float angle, float length, float aniso)
            {
                int taps = 7;
                float2 dir = float2(cos(angle), sin(angle));
                dir *= lerp(1.0, 1.0 + aniso * 4.0, aniso);
                float sum = 0.0;
                float wsum = 0.0;
                for (int t = - (taps/2); t <= (taps/2); ++t)
                {
                    float ft = (float)t;
                    float w = exp(- (ft * ft) / (2.0 * (length * length + 1e-6)));
                    float2 samp = uv + dir * (ft / max(1.0, length));
                    sum += w * fbm(samp * _Scale);
                    wsum += w;
                }
                return sum / max(1e-6, wsum);
            }

            // ------------------------------------------------------------
            // Preset bank (applyPreset sets the working parameters)
            // ------------------------------------------------------------
            void applyPreset(int p, out float outScale, out float outIntensity, out float outSpread, out float outAngle, out float outAniso, out float outSmear, out float4 outTileOffset, out float outNonSquare, out float outSeed)
            {
                // Default fallback
                outScale = 8.0; outIntensity = 1.0; outSpread = 0.35; outAngle = 0.0; outAniso = 0.6; outSmear = 0.5; outTileOffset = float4(0,0,0,0); outNonSquare = 0.0; outSeed = 0.0;

                if (p == 0)  { outScale=8.0;  outIntensity=1.0; outSpread=0.35; outAngle=0.05; outAniso=0.6; outSmear=0.45; outTileOffset=float4(0,0,0,0); outNonSquare=0.0; outSeed=0.0; } // Default
                else if (p == 1)  { outScale=10.0; outIntensity=1.1; outSpread=0.28; outAngle=0.12; outAniso=0.7; outSmear=0.6; outTileOffset=float4(0.02,0.01,0,0); outNonSquare=0.0; outSeed=42.0; } // Coastal
                else if (p == 2)  { outScale=6.0;  outIntensity=0.9; outSpread=0.4;  outAngle=0.6;  outAniso=0.5; outSmear=0.35; outTileOffset=float4(0.0,0.03,0,0); outNonSquare=0.0; outSeed=7.0; } // Urban
                else if (p == 3)  { outScale=4.0;  outIntensity=1.2; outSpread=0.2;  outAngle=0.75; outAniso=0.85; outSmear=0.8; outTileOffset=float4(0,0,0,0); outNonSquare=1.0; outSeed=13.0; } // Rusty
                else if (p == 4)  { outScale=18.0; outIntensity=0.8; outSpread=0.5;  outAngle=0.02; outAniso=0.2; outSmear=0.2; outTileOffset=float4(0.1,0.05,0,0); outNonSquare=0.0; outSeed=99.0; } // FineSpeckle
                else if (p == 5)  { outScale=2.5;  outIntensity=1.4; outSpread=0.15; outAngle=0.7;  outAniso=0.95; outSmear=0.95; outTileOffset=float4(0,0,0,0); outNonSquare=1.0; outSeed=5.0; } // LongStreaks
                else if (p == 6)  { outScale=9.0;  outIntensity=1.3; outSpread=0.22; outAngle=0.4;  outAniso=0.4; outSmear=0.5; outTileOffset=float4(0.03,0.02,0,0); outNonSquare=0.0; outSeed=21.0; } // HeavyCrevice
                else if (p == 7)  { outScale=12.0; outIntensity=0.95; outSpread=0.33; outAngle=0.18; outAniso=0.3; outSmear=0.4; outTileOffset=float4(0.06,0.03,0,0); outNonSquare=0.0; outSeed=64.0; } // Painterly
            }

            // ------------------------------------------------------------
            // Main Dirt 3 Advanced logic
            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                // Apply preset (reads _Preset and returns working params)
                int presetIndex = (int)round(_Preset);
                float workScale, workIntensity, workSpread, workAngle, workAniso, workSmear, workNonSquare, workSeed;
                float4 workTileOffset;
                applyPreset(presetIndex, workScale, workIntensity, workSpread, workAngle, workAniso, workSmear, workTileOffset, workNonSquare, workSeed);

                // Allow user overrides: if user changed core properties, prefer them (non-zero or different)
                // (We keep simple rule: inspector values override preset when not equal to default sentinel)
                // For clarity: if user left defaults, preset dominates; otherwise inspector values are used.
                // Here we treat inspector values as authoritative if they differ from the shader defaults.
                // (This keeps presets as starting points but allows tweaking.)
                float finalScale = (_Scale != 8.0) ? _Scale : workScale;
                float finalIntensity = (_Intensity != 1.0) ? _Intensity : workIntensity;
                float finalSpread = (_Spread != 0.35) ? _Spread : workSpread;
                float finalAngle = (_Angle != 0.0) ? _Angle : workAngle;
                float finalAniso = (_Aniso != 0.6) ? _Aniso : workAniso;
                float finalSmear = (_Smear != 0.5) ? _Smear : workSmear;
                float finalNonSquare = (_NonSquare != 0.0) ? _NonSquare : workNonSquare;
                float2 finalTileOffset=float2(0,0);
                if(_TileOffset.x=0 && _TileOffset.y==0)
                {
                    finalTileOffset.xy=workTileOffset;
                }
                float finalSeed = (_Seed != 0.0) ? _Seed : workSeed;

                // Use finalSeed to influence hashing
                float seedBackup = _Seed;
                _Seed = finalSeed;

                float2 uv = i.localTexcoord.xy;

                // non-square compensation
                if (finalNonSquare > 0.0)
                {
                    float aspect = i.localTexcoord.z;
                    uv.x = lerp(uv.x, uv.x * aspect, finalNonSquare);
                }

                // tile offset
                uv += finalTileOffset.xy;

                // compute integer tile coords for per-tile randomization and bijection
                float2 tileF = floor(uv * float2(finalScale, finalScale));
                int tilesX = max(1, (int)max(1.0, finalScale));
                int tilesY = tilesX; // square grid assumption for bijection; if non-square tiles desired, extend logic
                int totalTiles = tilesX * tilesY;
                int tileXI = (int)tileF.x;
                int tileYI = (int)tileF.y;
                int tileID = tileXI + tileYI * tilesX;

                // Optionally apply bijective permutation to tileID
                int permutedID = tileID;
                if (_Bijective > 0.5)
                {
                    int seedVal = (int)floor(frac(finalSeed) * 2147483647.0) ^ tileID;
                    permutedID = bijectivePermuteInt(tileID, totalTiles, seedVal);
                }

                // Per-tile randomization: derive angle and aspect per tile (deterministic)
                float perTileAngle = finalAngle * 6.2831853;
                float perTileAspect = 1.0;
                if (_PerTileRandom > 0.5)
                {
                    float2 r = hash21((float)permutedID + 13.37);
                    // angle jitter around base angle
                    float jitterA = (r.x - 0.5) * _PerTileAngleJitter * 6.2831853;
                    perTileAngle += jitterA;
                    // aspect jitter around 1.0
                    float jitterAsp = 1.0 + (r.y - 0.5) * _PerTileAspectJitter * 2.0;
                    perTileAspect = max(0.1, jitterAsp);
                }
                else
                {
                    perTileAngle = finalAngle * 6.2831853;
                    perTileAspect = 1.0;
                }

                // local padding domain to avoid bleed
                float pad = saturate(_Padding);
                float2 tuv = saturate((uv - floor(uv)) * (1.0 - 2.0 * pad) + pad);

                // base fbm noise
                float base = fbm(tuv * finalScale);

                // directional smear component using per-tile angle and aspect
                float smearLen = lerp(0.5, 4.0, finalSmear);
                // incorporate perTileAspect into anisotropy
                float anisoCombined = lerp(finalAniso, finalAniso * perTileAspect, perTileAspect);
                float dirComp = directionalSmear(tuv, perTileAngle, smearLen, anisoCombined);

                // combine base and directional with smear control
                float combined = lerp(base, dirComp, saturate(finalSmear));

                // apply spread (softness)
                combined = smoothstep(0.0, 1.0, pow(combined, 1.0 / max(1e-6, finalSpread)));

                // edge emphasis (procedural)
                float edge = edgeDetector(tuv, finalScale * _EdgeScale);
                float edgeMask = lerp(1.0, edge * _EdgeBoost, saturate(_EdgeOnly));

                // curvature / AO input bias (optional)
                float curvatureBias = 1.0;
                if (_UseCurvature > 0.5)
                {
                    // sample curvature map using CRT-safe sampler; use same tuv and direction
                    float4 curSamp = SAMPLE_X(_Curvature, float3(tuv, i.localTexcoord.z), i.direction);
                    // assume curvature/AO is in R channel; stronger in darker areas -> invert if needed
                    float ao = curSamp.r;
                    // bias: more dirt in crevices (low AO) -> invert ao
                    float crevice = 1.0 - ao;
                    curvatureBias = lerp(1.0, 1.0 + crevice * _CurvatureStrength, _UseCurvature);
                }

                // final mask
                float mask = combined * edgeMask * curvatureBias;

                // intensity
                float outVal = saturate(mask * finalIntensity);

                // restore original _Seed (avoid side effects)
                _Seed = seedBackup;

                // Debug modes
                if (_Debug == 1) return float4(base, base, base, 1);         // raw fbm
                if (_Debug == 2) return float4(edge, edge, edge, 1);         // edge mask
                if (_Debug == 3) return float4(dirComp, dirComp, dirComp, 1); // directional component
                if (_Debug == 5) // Tile ID visualization (normalized)
                {
                    float norm = frac((float)permutedID / 256.0);
                    return float4(norm, 0, 0, 1);
                }

                // final
                return float4(outVal, outVal, outVal, 1);
            }

            ENDHLSL
        }
    }
}