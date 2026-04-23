Shader "Hidden/Genesis/WoodGrain"
{
    Properties
    {
        [Header(Mapping)]
        [Tooltip(Global UV scale)] _Scale("Scale", Vector) = (8,8,0,0)
        [Tooltip(Global UV offset)] _Offset("Offset", Vector) = (0,0,0,0)
        [Tooltip(Wood axis direction in radians)] _Direction("Direction", Range(0,6.2831853)) = 0.0

        [Header(Rings)]
        [Tooltip(Base ring frequency)] _RingFrequency("Ring Frequency", Range(0.1,128.0)) = 14.0
        [Tooltip(Ring contrast sharpness)] _RingSharpness("Ring Sharpness", Range(0.1,16.0)) = 4.0
        [Tooltip(Ring irregularity amount)] _RingWarp("Ring Warp", Range(0.0,4.0)) = 0.75
        [Tooltip(Ring noise scale)] _RingWarpScale("Ring Warp Scale", Range(0.1,32.0)) = 3.0
        [Tooltip(Earlywood latewood balance)] _RingBalance("Ring Balance", Range(0.01,0.99)) = 0.55

        [Header(Grain)]
        [Tooltip(Long fiber anisotropy)] _Anisotropy("Anisotropy", Range(0.25,32.0)) = 12.0
        [Tooltip(Long grain intensity)] _GrainStrength("Grain Strength", Range(0.0,2.0)) = 0.8
        [Tooltip(Fiber frequency)] _GrainFrequency("Grain Frequency", Range(1.0,128.0)) = 24.0
        [Tooltip(Fiber width)] _GrainWidth("Grain Width", Range(0.1,8.0)) = 2.2
        [Tooltip(Fiber detail amount)] _GrainDetail("Grain Detail", Range(0.0,2.0)) = 0.6

        [Header(Pores)]
        [Tooltip(Pore density)] _PoreDensity("Pore Density", Range(1.0,128.0)) = 38.0
        [Tooltip(Pore size)] _PoreSize("Pore Size", Range(0.01,1.0)) = 0.18
        [Tooltip(Pore contrast)] _PoreStrength("Pore Strength", Range(0.0,2.0)) = 0.45

        [Header(Rays)]
        [Tooltip(Wood ray intensity)] _RayStrength("Ray Strength", Range(0.0,2.0)) = 0.25
        [Tooltip(Wood ray frequency)] _RayFrequency("Ray Frequency", Range(1.0,128.0)) = 12.0

        [Header(Warp)]
        [Tooltip(Global domain warp strength)] _WarpStrength("Warp Strength", Range(0.0,2.0)) = 0.25
        [Tooltip(Global domain warp scale)] _WarpScale("Warp Scale", Range(0.1,32.0)) = 2.0

        [Header(Output)]
        [Tooltip(Final contrast)] _Contrast("Contrast", Range(0.1,8.0)) = 1.2
        [Tooltip(Final gain)] _Gain("Gain", Range(0.0,4.0)) = 1.0
        [Tooltip(Final bias)] _Bias("Bias", Range(-1.0,1.0)) = 0.0
        [Tooltip(Invert output)] _Invert("Invert", Range(0,1)) = 0

        [Tooltip(Random seed)] _Seed("Seed", int) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET_API
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            float2 _Scale;
            float2 _Offset;
            float  _Direction;

            float  _RingFrequency;
            float  _RingSharpness;
            float  _RingWarp;
            float  _RingWarpScale;
            float  _RingBalance;

            float  _Anisotropy;
            float  _GrainStrength;
            float  _GrainFrequency;
            float  _GrainWidth;
            float  _GrainDetail;

            float  _PoreDensity;
            float  _PoreSize;
            float  _PoreStrength;

            float  _RayStrength;
            float  _RayFrequency;

            float  _WarpStrength;
            float  _WarpScale;

            float  _Contrast;
            float  _Gain;
            float  _Bias;
            float  _Invert;

            float  _Seed;

            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a);
                float c = cos(a);
                return float2(c * p.x - s * p.y, s * p.x + c * p.y);
            }

            float hash12(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7)) + _Seed * 17.137;
                return frac(sin(n) * 43758.5453123);
            }

            float2 hash22(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7)) + _Seed * 11.731;
                return frac(sin(float2(n, n + 1.2345)) * 43758.5453123);
            }

            float fade(float t)
            {
                return t * t * (3.0 - 2.0 * t);
            }

            float valueNoise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                float a = hash12(i + float2(0, 0));
                float b = hash12(i + float2(1, 0));
                float c = hash12(i + float2(0, 1));
                float d = hash12(i + float2(1, 1));

                float2 u = float2(fade(f.x), fade(f.y));

                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            float2 valueNoise2(float2 p)
            {
                return float2(
                    valueNoise(p + float2(13.7, 91.3)),
                    valueNoise(p + float2(47.2, 19.8))
                ) * 2.0 - 1.0;
            }

            float fbm(float2 p, int octaves, float lacunarity, float persistence)
            {
                float total = 0.0;
                float amplitude = 1.0;
                float frequency = 1.0;
                float norm = 0.0;

                [loop]
                for (int i = 0; i < octaves; i++)
                {
                    total += valueNoise(p * frequency) * amplitude;
                    norm += amplitude;
                    frequency *= lacunarity;
                    amplitude *= persistence;
                }

                return (norm > 0.0) ? total / norm : 0.0;
            }

            float ridge(float v, float sharpness)
            {
                v = abs(v * 2.0 - 1.0);
                v = 1.0 - v;
                return pow(saturate(v), sharpness);
            }

            float strandBands(float x, float width, float sharpness)
            {
                float fx = frac(x);
                float d = abs(fx - 0.5) * 2.0;
                float v = saturate(1.0 - d * width);
                return pow(v, sharpness);
            }

            float ringProfile(float x)
            {
                float fx = frac(x);

                // asymmetric earlywood / latewood profile
                float early = saturate(fx / max(_RingBalance, 1e-5));
                float late  = saturate((1.0 - fx) / max(1.0 - _RingBalance, 1e-5));

                float v = min(early, late);
                return pow(saturate(v), _RingSharpness);
            }

            float cellularPores(float2 p)
            {
                float2 g = floor(p);
                float2 f = frac(p);

                float minDist = 1e9;

                [unroll]
                for (int y = -1; y <= 1; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 cell = g + float2(x, y);
                        float2 rnd = hash22(cell);
                        float2 pos = float2(x, y) + rnd;
                        float2 d = pos - f;
                        float dist = length(d);
                        minDist = min(minDist, dist);
                    }
                }

                float pore = 1.0 - smoothstep(_PoreSize, _PoreSize * 1.6, minDist);
                return pore;
            }

            float wood(float3 uv, float3 dir)
            {
                float2 p = uv.xy * _Scale + _Offset;

                // align wood grain direction
                float2 q = rotate2D(p, -_Direction);

                // stretch along length axis for long fibers
                q.x /= max(_Anisotropy, 1e-5);

                // global warp
                float2 warp = valueNoise2(q * _WarpScale);
                q += warp * _WarpStrength;

                // ring distortion
                float ringNoiseA = fbm(q * _RingWarpScale, 4, 2.0, 0.5);
                float ringNoiseB = fbm(float2(q.x * 0.35, q.y * 1.6) * _RingWarpScale + 19.7, 3, 2.0, 0.5);
                float ringCoord = q.y * _RingFrequency
                                + (ringNoiseA * 2.0 - 1.0) * _RingWarp
                                + (ringNoiseB * 2.0 - 1.0) * (_RingWarp * 0.5);

                float rings = ringProfile(ringCoord);

                // anisotropic grain fibers
                float lengthMod = fbm(float2(q.x * 1.2, q.y * 0.25), 4, 2.0, 0.5);
                float grainCoord = q.y * _GrainFrequency + (lengthMod * 2.0 - 1.0) * 0.8;

                float grainA = strandBands(grainCoord, _GrainWidth, 4.0);
                float grainB = strandBands(grainCoord * 2.3 + ringNoiseA * 0.7, _GrainWidth * 1.5, 5.5) * 0.5;

                float grainBody = ridge(fbm(float2(q.x * 2.0, q.y * 0.6), 4, 2.0, 0.5), 2.0);
                float grainDetail = ridge(valueNoise(float2(q.x * (_GrainFrequency * 0.25), q.y * (_GrainFrequency * 1.2))), 3.0);

                float grain = max(grainA, grainB);
                grain *= lerp(0.5, 1.0, grainBody);
                grain *= lerp(1.0, grainDetail, saturate(_GrainDetail));
                grain *= _GrainStrength;

                // pores, elongated slightly along grain direction
                float2 poreP = float2(q.x * (_PoreDensity * 0.35), q.y * _PoreDensity);
                float pores = cellularPores(poreP) * _PoreStrength;

                // medullary-ray-ish breakup: faint cross features
                float rayNoise = ridge(valueNoise(float2(q.x * _RayFrequency, q.y * 0.75)), 4.0);
                float rays = rayNoise * _RayStrength;

                // combine:
                // rings as base tonal structure
                // grain adds streaky variation
                // pores carve darker holes
                // rays add mild cross breakup
                float woodV = rings;
                woodV = lerp(woodV, woodV * (0.75 + grain * 0.5), saturate(_GrainStrength));
                woodV += rays * 0.2;
                woodV -= pores * 0.65;

                // subtle extra natural irregularity
                float macro = fbm(q * 0.8 + 41.2, 3, 2.0, 0.5);
                woodV *= lerp(0.85, 1.15, macro);

                woodV = saturate(woodV);
                woodV = pow(woodV, _Contrast);
                woodV = woodV * _Gain + _Bias;
                woodV = saturate(woodV);

                if (_Invert > 0.5)
                    woodV = 1.0 - woodV;

                return woodV;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv  = i.localTexcoord;
                float3 dir = i.direction;

                float v = wood(uv, dir);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
