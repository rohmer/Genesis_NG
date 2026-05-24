Shader "Hidden/Genesis/Chinoiserie"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (3,4,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Width of branch strokes)] _BranchWidth("Branch Width", Range(0.01,0.4)) = 0.075
        [Tooltip(Size of blossoms)] _BlossomSize("Blossom Size", Range(0.02,0.5)) = 0.13
        [Tooltip(Cloud amount)] _Clouds("Clouds", Range(0,1)) = 0.35
        [Tooltip(Pagoda accent amount)] _Pagoda("Pagoda", Range(0,1)) = 0.4

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.035
        [Tooltip(Paint or woven relief)] _Relief("Relief", Range(0,1)) = 0.35
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.15

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.0
        [Tooltip(Random seed)] _Seed("Seed", int) = 229
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

            float2 _Scale;
            float  _Angle;

            float  _BranchWidth;
            float  _BlossomSize;
            float  _Clouds;
            float  _Pagoda;

            float  _Softness;
            float  _Relief;
            float  _Contrast;

            float  _Randomness;
            float  _Seed;

            float hash11(float n)
            {
                n += _Seed * 17.0;
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a);
                float c = cos(a);
                return float2(c * p.x - s * p.y, s * p.x + c * p.y);
            }

            float lineMask(float d, float width, float softness)
            {
                float halfWidth = width * 0.5;
                return smoothstep(halfWidth + softness, halfWidth - softness, abs(d));
            }

            float segmentDistance(float2 p, float2 a, float2 b)
            {
                float2 pa = p - a;
                float2 ba = b - a;
                float h = saturate(dot(pa, ba) / max(dot(ba, ba), 0.0001));
                return length(pa - ba * h);
            }

            float strokeSegment(float2 p, float2 a, float2 b, float width, float softness)
            {
                return lineMask(segmentDistance(p, a, b), width, softness);
            }

            float fillCircle(float2 p, float radius, float softness)
            {
                return smoothstep(radius + softness, radius - softness, length(p));
            }

            float fillEllipse(float2 p, float2 radius, float softness)
            {
                float d = length(p / max(radius, 0.0001));
                return smoothstep(1.0 + softness, 1.0 - softness, d);
            }

            float blossom(float2 p, float radius, float softness)
            {
                float core = fillCircle(p, radius * 0.34, softness);
                float petals = 0.0;
                petals = max(petals, fillEllipse(p - float2(radius * 0.46, 0.0), float2(radius * 0.42, radius * 0.26), softness));
                petals = max(petals, fillEllipse(p + float2(radius * 0.46, 0.0), float2(radius * 0.42, radius * 0.26), softness));
                petals = max(petals, fillEllipse(p - float2(0.0, radius * 0.46), float2(radius * 0.26, radius * 0.42), softness));
                petals = max(petals, fillEllipse(p + float2(0.0, radius * 0.46), float2(radius * 0.26, radius * 0.42), softness));
                return max(core, petals);
            }

            float roof(float2 p, float y, float width, float height, float softness)
            {
                float roofLine = lineMask(p.y - y + abs(p.x) * height / max(width, 0.0001), 0.055, softness);
                return roofLine * smoothstep(width + softness, width - softness, abs(p.x));
            }

            float chinoiserie(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f = frac(p);

                float randomValue = hash11(cell.x + cell.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;
                float branchWidth = saturate(_BranchWidth + variation * 0.03);
                float blossomSize = saturate(_BlossomSize + variation * 0.04);
                float softness = max(_Softness, 0.0001);

                float mirrorTile = fmod(abs(cell.x), 2.0);
                f.x = lerp(f.x, 1.0 - f.x, mirrorTile);
                float2 q = f * 2.0 - 1.0;

                float branchCurve = q.y + 0.48 - 0.38 * sin((q.x + 0.22) * 2.25);
                float trunk = lineMask(branchCurve, branchWidth, softness) * smoothstep(1.05, -0.95, q.x);
                float twigA = strokeSegment(q, float2(-0.24, -0.18), float2(0.35, 0.34), branchWidth * 0.72, softness);
                float twigB = strokeSegment(q, float2(-0.02, -0.02), float2(-0.46, 0.42), branchWidth * 0.58, softness);
                float twigC = strokeSegment(q, float2(0.18, 0.18), float2(0.64, 0.04), branchWidth * 0.52, softness);
                float branches = max(max(trunk, twigA), max(twigB, twigC));

                float blossoms = 0.0;
                blossoms = max(blossoms, blossom(q - float2(0.38, 0.34), blossomSize, softness));
                blossoms = max(blossoms, blossom(q - float2(-0.48, 0.42), blossomSize * 0.85, softness));
                blossoms = max(blossoms, blossom(q - float2(0.64, 0.04), blossomSize * 0.72, softness));
                blossoms = max(blossoms, blossom(q - float2(-0.12, -0.10), blossomSize * 0.68, softness));

                float cloudA = fillEllipse(q - float2(-0.52, -0.62), float2(0.30, 0.10), softness);
                float cloudB = fillEllipse(q - float2(-0.30, -0.58), float2(0.22, 0.13), softness);
                float cloudC = fillEllipse(q - float2(-0.12, -0.63), float2(0.28, 0.09), softness);
                float clouds = max(max(cloudA, cloudB), cloudC) * _Clouds;

                float pagoda = 0.0;
                pagoda = max(pagoda, roof(q - float2(0.48, -0.46), 0.12, 0.26, 0.18, softness));
                pagoda = max(pagoda, roof(q - float2(0.48, -0.46), -0.02, 0.20, 0.14, softness));
                pagoda = max(pagoda, strokeSegment(q, float2(0.42, -0.62), float2(0.42, -0.30), 0.045, softness));
                pagoda = max(pagoda, strokeSegment(q, float2(0.54, -0.62), float2(0.54, -0.30), 0.045, softness));
                pagoda *= _Pagoda;

                float motif = max(max(branches, blossoms), max(clouds * 0.68, pagoda * 0.82));

                float paperGrain = 0.82 + 0.18 * (0.5 + 0.5 * sin((p.x * 2.0 + p.y + variation) * 6.28318));
                float relief = lerp(1.0, paperGrain, _Relief);
                return pow(saturate(motif * relief), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = chinoiserie(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
