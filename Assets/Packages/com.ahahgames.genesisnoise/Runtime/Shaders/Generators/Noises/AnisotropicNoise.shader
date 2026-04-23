Shader "Hidden/Genesis/AnisotropicNoise"
{
    Properties
    {
        [Tooltip(Global UV scale)] _Scale("Scale", Vector) = (8,8,0,0)
        [Tooltip(Global UV offset)] _Offset("Offset", Vector) = (0,0,0,0)

        [Tooltip(Fiber direction in radians)] _Direction("Direction", Range(0,6.2831853)) = 0.0
        [Tooltip(Longitudinal stretch. Higher means longer fibers)] _Anisotropy("Anisotropy", Range(0.25,32.0)) = 10.0

        [Header(Fiber Shape)]
        [Tooltip(Base fiber density repetition)] _FiberFrequency("Fiber Frequency", Range(1.0,128.0)) = 28.0
        [Tooltip(Fiber width shaping)] _FiberWidth("Fiber Width", Range(0.05,8.0)) = 2.5
        [Tooltip(Ridge sharpness)] _RidgeSharpness("Ridge Sharpness", Range(0.1,16.0)) = 5.0
        [Tooltip(Fiber contrast)] _FiberContrast("Fiber Contrast", Range(0.1,16.0)) = 2.0

        [Header(Variation)]
        [Tooltip(Longitudinal intensity variation)] _LengthVariation("Length Variation", Range(0.0,4.0)) = 1.25
        [Tooltip(Cross fiber breakup amount)] _CrossVariation("Cross Variation", Range(0.0,4.0)) = 0.8
        [Tooltip(Micro detail amount)] _DetailStrength("Detail Strength", Range(0.0,2.0)) = 0.5
        [Tooltip(Micro detail frequency)] _DetailFrequency("Detail Frequency", Range(1.0,256.0)) = 64.0

        [Header(Warp)]
        [Tooltip(Domain warp strength)] _WarpStrength("Warp Strength", Range(0.0,2.0)) = 0.25
        [Tooltip(Domain warp scale)] _WarpScale("Warp Scale", Range(0.1,32.0)) = 3.0
        [Tooltip(Secondary directional warp)] _DirectionalWarp("Directional Warp", Range(0.0,2.0)) = 0.2

        [Header(Octaves)]
        [Tooltip(Number of fBm octaves)] _Octaves("Octaves", Range(1,8)) = 4
        [Tooltip(Frequency multiplier)] _Lacunarity("Lacunarity", Range(1.0,4.0)) = 2.0
        [Tooltip(Amplitude multiplier)] _Persistence("Persistence", Range(0.0,1.0)) = 0.5

        [Header(Output)]
        [Tooltip(Final contrast shaping)] _Contrast("Contrast", Range(0.1,8.0)) = 1.0
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
            float  _Anisotropy;

            float  _FiberFrequency;
            float  _FiberWidth;
            float  _RidgeSharpness;
            float  _FiberContrast;

            float  _LengthVariation;
            float  _CrossVariation;
            float  _DetailStrength;
            float  _DetailFrequency;

            float  _WarpStrength;
            float  _WarpScale;
            float  _DirectionalWarp;

            float  _Octaves;
            float  _Lacunarity;
            float  _Persistence;

            float  _Contrast;
            float  _Gain;
            float  _Bias;
            float  _Invert;

            float  _Seed;

            // ---------------------------------------------------------
            // Helpers
            // ---------------------------------------------------------
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

            // Thin repeated bands in one axis
            float strandBands(float x, float width, float sharpness)
            {
                float fx = frac(x);
                float d = abs(fx - 0.5) * 2.0; // 0 at center of band, 1 at edges
                float v = saturate(1.0 - d * width);
                return pow(v, sharpness);
            }

            // ---------------------------------------------------------
            // Fiber synthesis
            // ---------------------------------------------------------
            float anisotropicFibers(float3 uv, float3 dir)
            {
                float2 p = uv.xy * _Scale + _Offset;

                // Align to user direction
                float2 q = rotate2D(p, -_Direction);

                // Stretch along the fiber axis so structures become longer
                q.x /= max(_Anisotropy, 1e-5);

                // Base warp
                float2 warp = valueNoise2(q * _WarpScale);
                q += warp * _WarpStrength;

                // Directional warp along the cross axis to make fibers meander
                float flow = fbm(float2(q.x * 0.7, q.y * 2.0), 3, 2.0, 0.5);
                q.y += (flow * 2.0 - 1.0) * _DirectionalWarp;

                // Build base strands primarily from cross-axis repetition
                float bandCoord = q.y * _FiberFrequency;

                // Break straightness with longitudinal modulation
                float lengthMod = fbm(float2(q.x * _LengthVariation, q.y * 0.35), (int)_Octaves, _Lacunarity, _Persistence);
                float crossMod  = fbm(float2(q.x * 0.35, q.y * _CrossVariation), max(2, (int)_Octaves - 1), _Lacunarity, _Persistence);

                bandCoord += (lengthMod * 2.0 - 1.0) * 0.85;
                bandCoord += (crossMod  * 2.0 - 1.0) * 0.35;

                float strands = strandBands(bandCoord, _FiberWidth, _RidgeSharpness);

                // Longitudinal breakup so fibers are not uniformly bright along their length
                float fiberBody = fbm(float2(q.x * (_FiberFrequency * 0.15), q.y * 0.5), (int)_Octaves, _Lacunarity, _Persistence);
                fiberBody = ridge(fiberBody, 2.0);
                fiberBody = lerp(0.45, 1.0, fiberBody);

                // Micro detail
                float detailA = ridge(valueNoise(float2(q.x * (_DetailFrequency * 0.25), q.y * _DetailFrequency)), 3.0);
                float detailB = ridge(valueNoise(float2(q.x * (_DetailFrequency * 0.15) + 31.7, q.y * (_DetailFrequency * 1.7) + 8.2)), 4.0);
                float detail = lerp(1.0, saturate(detailA * 0.7 + detailB * 0.3), _DetailStrength);

                // Secondary fine fiber layering
                float fineBandCoord = q.y * (_FiberFrequency * 2.3) + (lengthMod * 2.0 - 1.0) * 0.4;
                float fineStrands = strandBands(fineBandCoord, _FiberWidth * 1.6, _RidgeSharpness * 1.4) * 0.5;

                float fibers = max(strands, fineStrands);
                fibers *= fiberBody;
                fibers *= detail;

                // Additional contrast shaping
                fibers = pow(saturate(fibers), _FiberContrast);

                // Final output shaping
                fibers = pow(saturate(fibers), _Contrast);
                fibers = fibers * _Gain + _Bias;
                fibers = saturate(fibers);

                if (_Invert > 0.5)
                    fibers = 1.0 - fibers;

                return fibers;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv  = i.localTexcoord;
                float3 dir = i.direction;

                float v = anisotropicFibers(uv, dir);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}