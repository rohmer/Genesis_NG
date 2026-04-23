Shader "Hidden/Genesis/TileSampler"
{
    Properties
    {
        _Pattern_2D("Pattern", 2D) = "white" {}
        _Pattern_3D("Pattern", 3D) = "white" {}
        _Pattern_Cube("Pattern", Cube) = "white" {}

        _Mask_2D("Mask", 2D) = "white" {}
        _Mask_3D("Mask", 3D) = "white" {}
        _Mask_Cube("Mask", Cube) = "white" {}

        _Distribution_2D("Distribution", 2D) = "white" {}
        _Distribution_3D("Distribution", 3D) = "white" {}
        _Distribution_Cube("Distribution", Cube) = "white" {}

        [GenesisTilePattern] _PatternType("Pattern Type", int) = 0

        [Enum(Disabled,0,Enabled,1)] _UsePattern("Use Pattern", int) = 1
        [Enum(Disabled,0,Enabled,1)] _UseMask("Use Mask", int) = 0
        [Enum(Disabled,0,Enabled,1)] _UseDistribution("Use Distribution", int) = 1

        [Tooltip(Number of tiles in X,Y)] _Tiling("Tiling", Vector) = (8,8,0,0)
        [Tooltip(Global UV offset)] _Offset("Offset", Vector) = (0,0,0,0)

        [Tooltip(Shapes per tile)] _PatternAmount("Pattern Amount", Range(1,16)) = 1

        [Tooltip(Random position offset inside tile)] _PositionRandom("Position Random", Range(0,1)) = 0.0
        [Tooltip(Random rotation amount in radians)] _RotationRandom("Rotation Random", Range(0,6.28318)) = 0.0
        [Tooltip(Min random scale)] _ScaleMin("Scale Min", Range(0.01,4.0)) = 1.0
        [Tooltip(Max random scale)] _ScaleMax("Scale Max", Range(0.01,4.0)) = 1.0
        [Tooltip(Global pattern scale)] _PatternScale("Pattern Scale", Range(0.01,8.0)) = 1.0

        [Tooltip(Blending mode)][Enum(KeepStrongest,0,Additive,1)]_Blending("Blending", Range(0,1)) = 0.0
        [Tooltip(Mask influence on output)] _MaskInfluence("Mask Influence", Range(0,1)) = 1.0

        [Header(Distribution)]
        [Tooltip(Distribution map influence on spawn probability)] _DistributionInfluence("Distribution Influence", Range(0,1)) = 1.0
        [Tooltip(Minimum distribution value needed to spawn)] _DistributionThreshold("Distribution Threshold", Range(0,1)) = 0.0
        [Tooltip(Contrast on distribution map)] _DistributionContrast("Distribution Contrast", Range(0.1,8.0)) = 1.0
        [Tooltip(Distribution map affects scale)] _DistributionScaleInfluence("Distribution Scale Influence", Range(0,2)) = 0.0
        [Tooltip(Distribution map affects rotation)] _DistributionRotationInfluence("Distribution Rotation Influence", Range(0,6.28318)) = 0.0
        [Tooltip(Distribution map affects position)] _DistributionPositionInfluence("Distribution Position Influence", Range(0,1)) = 0.0

        [Header(Procedural Pattern Controls)]
        [Tooltip(Edge hardness and exponent shaping)] _PatternHardness("Pattern Hardness", Range(0.1,16.0)) = 2.0
        [Tooltip(Aspect ratio X,Y for procedural patterns)] _PatternAspect("Pattern Aspect", Vector) = (1,1,0,0)
        [Tooltip(Brick width fraction)] _BrickWidth("Brick Width", Range(0.05,1.0)) = 0.8
        [Tooltip(Brick height fraction)] _BrickHeight("Brick Height", Range(0.05,1.0)) = 0.5
        [Tooltip(Gradiation direction in radians)] _GradientAngle("Gradient Angle", Range(0,6.28318)) = 0.0
        [Tooltip(Thorn sharpness)] _ThornSharpness("Thorn Sharpness", Range(0.1,16.0)) = 6.0

        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.1,8.0)) = 1.0
        [Tooltip(Output clamp)] _ClampOutput("Clamp Output", Range(0,1)) = 1.0

        [Tooltip(Random seed)] _Seed("Seed", int) = 1
        [Enum(Horizontal,0,Vertical,1,Radial,2)] _GradiationMode("Gradiation Mode", int) = 0

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

            SAMPLER_X(_Pattern);
            SAMPLER_X(_Mask);
            SAMPLER_X(_Distribution);

            int    _PatternType;
            int    _UsePattern;
            int    _UseMask;
            int    _UseDistribution;
            int _GradiationMode;
            float2 _Tiling;
            float2 _Offset;
            float  _PatternAmount;
            float  _PositionRandom;
            float  _RotationRandom;
            float  _ScaleMin;
            float  _ScaleMax;
            float  _PatternScale;
            float  _Blending;
            float  _MaskInfluence;

            float  _DistributionInfluence;
            float  _DistributionThreshold;
            float  _DistributionContrast;
            float  _DistributionScaleInfluence;
            float  _DistributionRotationInfluence;
            float  _DistributionPositionInfluence;

            float  _PatternHardness;
            float2 _PatternAspect;
            float  _BrickWidth;
            float  _BrickHeight;
            float  _GradientAngle;
            float  _ThornSharpness;

            float  _Contrast;
            float  _ClampOutput;
            float  _Seed;

            float hash11(float n)
            {
                n += _Seed * 19.19;
                return frac(sin(n * 127.1) * 43758.5453123);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7)) + _Seed * 13.37;
                return frac(sin(float2(n, n + 1.2345)) * 43758.5453123);
            }

            float3 hash31(float2 p)
            {
                float n = dot(p, float2(269.5, 183.3)) + _Seed * 7.77;
                return frac(sin(float3(n, n + 1.0, n + 2.0)) * 43758.5453123);
            }

            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a);
                float c = cos(a);
                return float2(c * p.x - s * p.y, s * p.x + c * p.y);
            }

            float remap01(float v, float lo, float hi)
            {
                return saturate((v - lo) / max(hi - lo, 1e-5));
            }

            float contrastValue(float v, float c)
            {
                v = saturate(v);
                return pow(v, c);
            }

            float2 toPatternSpace(float2 p)
            {
                p = (p - 0.5) * 2.0;
                p /= max(_PatternAspect, 1e-5);
                return p;
            }

            float gaussianPattern(float2 uv)
            {
                float2 p = toPatternSpace(uv);
                float r2 = dot(p, p);
                return exp(-r2 * _PatternHardness);
            }

            float bellPattern(float2 uv)
            {
                float2 p = toPatternSpace(uv);
                float r = length(p);
                float v = saturate(1.0 - r);
                return pow(v, _PatternHardness);
            }

            float paraboloidPattern(float2 uv)
            {
                float2 p = toPatternSpace(uv);
                float r2 = dot(p, p);
                return saturate(1.0 - r2);
            }

            float discPattern(float2 uv)
            {
                float2 p = toPatternSpace(uv);
                float r = length(p);
                float edge = saturate(1.0 - r);
                return saturate(pow(edge * 2.0, _PatternHardness));
            }

            float squarePattern(float2 uv)
            {
                float2 p = abs(toPatternSpace(uv));
                float d = max(p.x, p.y);
                return saturate(pow(saturate(1.0 - d), _PatternHardness * 0.5));
            }

            float thornPattern(float2 uv)
            {
                float2 p = toPatternSpace(uv);
                float angle = atan2(p.y, p.x);
                float r = length(p);

                float spike = abs(cos(angle * max(_ThornSharpness, 1.0)));
                float body = saturate(1.0 - r);
                float v = body * pow(spike, max(_PatternHardness, 0.1));
                return saturate(v);
            }

            float pyramidPattern(float2 uv)
            {
                float2 p = abs(toPatternSpace(uv));
                float d = max(p.x, p.y);
                return saturate(1.0 - d);
            }

            float brickPattern(float2 uv)
            {
                float2 p = uv;
                float2 size = float2(saturate(_BrickWidth), saturate(_BrickHeight));

                float2 d = abs(p - 0.5) / max(size * 0.5, 1e-5);
                float edge = max(d.x, d.y);
                return saturate(1.0 - edge);
            }

            float gradiationPattern(float2 uv)
            {
                float2 p = uv - 0.5;

                // Horizontal: left -> right
                if (_GradiationMode == 0)
                {
                    return saturate(uv.x);
                }

                // Vertical: bottom -> top
                if (_GradiationMode == 1)
                {
                    return saturate(uv.y);
                }

                // Radial: center -> edge
                if (_GradiationMode == 2)
                {
                    float2 ap = toPatternSpace(uv);
                    float r = length(ap);
                    return saturate(r);
                }

                return saturate(uv.x);
            }

            float sampleProceduralPattern(float2 uv)
            {
                if (any(uv < 0.0) || any(uv > 1.0))
                    return 0.0;

                if (_PatternType == 1) return gaussianPattern(uv);
                if (_PatternType == 2) return bellPattern(uv);
                if (_PatternType == 3) return paraboloidPattern(uv);
                if (_PatternType == 4) return discPattern(uv);
                if (_PatternType == 5) return squarePattern(uv);
                if (_PatternType == 6) return thornPattern(uv);
                if (_PatternType == 7) return pyramidPattern(uv);
                if (_PatternType == 8) return brickPattern(uv);
                if (_PatternType == 9) return gradiationPattern(uv);

                return 0.0;
            }

            float samplePattern(float2 uv, float2 center, float angle, float scale, float3 dir)
            {
                float2 p = uv - center;
                p = rotate2D(p, angle);
                p /= max(scale, 1e-5);
                p /= max(_PatternScale, 1e-5);
                p += 0.5;

                if (_PatternType == 0)
                {
                    if (any(p < 0.0) || any(p > 1.0))
                        return 0.0;

                    return SAMPLE_X(_Pattern, float3(p, 0), dir).r;
                }

                return sampleProceduralPattern(p);
            }

            float sampleMask(float3 uv, float3 dir)
            {
                if (_UseMask == 0)
                    return 1.0;

                return SAMPLE_X(_Mask, uv, dir).r;
            }

            float sampleDistribution(float3 uv, float3 dir)
            {
                if (_UseDistribution == 0)
                    return 1.0;

                float v = SAMPLE_X(_Distribution, uv, dir).r;
                return contrastValue(v, _DistributionContrast);
            }

            float blendLegacy(float baseValue, float newValue)
            {
                float strongest = max(baseValue, newValue);
                float additive = baseValue + newValue;
                return lerp(strongest, additive, _Blending);
            }

            float spawnFromDistribution(float distributionValue, float randomValue)
            {
                float prob = lerp(1.0, distributionValue, _DistributionInfluence);
                prob = remap01(prob, _DistributionThreshold, 1.0);
                return step(randomValue, prob);
            }

            float tileSamplerLegacy(float3 uv, float3 dir)
            {
                if (_UsePattern == 0)
                    return 0.0;

                float3 uvOffset = uv;
                uvOffset.xy += _Offset;

                float2 tiledUV = uvOffset.xy * _Tiling;
                float2 tileID = floor(tiledUV);
                float2 tileUV = frac(tiledUV);

                float outV = 0.0;

                [loop]
                for (int oy = -1; oy <= 1; oy++)
                {
                    [loop]
                    for (int ox = -1; ox <= 1; ox++)
                    {
                        float2 neighborTile = tileID + float2(ox, oy);

                        [loop]
                        for (int i = 0; i < (int)_PatternAmount; i++)
                        {
                            float2 perTileSeed = neighborTile + float2(i * 23.0, i * 47.0);
                            float3 rnd = hash31(perTileSeed);

                            float2 distLocalUV = frac(float2(i * 0.6180339, i * 0.41421356) + rnd.xy);
                            float2 distWorldUV = (neighborTile + distLocalUV) / max(_Tiling, 1e-5);
                            float3 distUV = float3(distWorldUV + _Offset, uv.z);

                            float distValue = sampleDistribution(distUV, dir);

                            float spawn = spawnFromDistribution(distValue, rnd.x);
                            if (spawn < 0.5)
                                continue;

                            float2 randomOffset = (rnd.xy * 2.0 - 1.0) * 0.5 * _PositionRandom;
                            float angle = (rnd.z * 2.0 - 1.0) * _RotationRandom;
                            float scale = lerp(_ScaleMin, _ScaleMax, rnd.y);

                            float2 distOffsetDir = normalize((rnd.xy * 2.0 - 1.0) + 1e-5.xx);
                            float2 distOffset = distOffsetDir * ((distValue * 2.0 - 1.0) * 0.5) * _DistributionPositionInfluence;

                            float2 center = 0.5 + randomOffset + distOffset + float2(ox, oy);

                            scale *= lerp(1.0, max(distValue, 1e-3), _DistributionScaleInfluence);
                            angle += (distValue * 2.0 - 1.0) * _DistributionRotationInfluence;

                            float patternValue = samplePattern(tileUV, center, angle, scale, dir);

                            float2 maskUV = (neighborTile + 0.5) / max(_Tiling, 1e-5);
                            float3 fullMaskUV = float3(maskUV + _Offset, uv.z);
                            float maskValue = lerp(1.0, sampleMask(fullMaskUV, dir), _MaskInfluence);

                            patternValue *= maskValue;
                            outV = blendLegacy(outV, patternValue);
                        }
                    }
                }

                outV = pow(max(outV, 0.0), _Contrast);

                if (_ClampOutput > 0.5)
                    outV = saturate(outV);

                return outV;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord;
                float3 dir = i.direction;

                float v = tileSamplerLegacy(uv, dir);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}