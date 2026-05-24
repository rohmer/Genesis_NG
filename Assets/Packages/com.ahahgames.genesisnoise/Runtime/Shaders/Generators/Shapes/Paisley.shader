Shader "Hidden/Genesis/Paisley"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (4,4,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Overall paisley motif size)] _MotifSize("Motif Size", Range(0.1,1.5)) = 0.82
        [Tooltip(Width of outer and inner ornament lines)] _LineWidth("Line Width", Range(0.01,0.35)) = 0.075
        [Tooltip(Amount of inner curl detail)] _Curl("Curl", Range(0,1)) = 0.65
        [Tooltip(Amount of seed dot ornament)] _SeedDots("Seed Dots", Range(0,1)) = 0.55

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.035
        [Tooltip(Printed or woven relief)] _Relief("Relief", Range(0,1)) = 0.36
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.15

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.25
        [Tooltip(Random seed)] _Seed("Seed", int) = 353
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

            float  _MotifSize;
            float  _LineWidth;
            float  _Curl;
            float  _SeedDots;

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

            float ringEllipse(float2 p, float2 radius, float width, float softness)
            {
                float d = length(p / max(radius, 0.0001));
                return lineMask(d - 1.0, width, softness);
            }

            float paisley(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f = frac(p);

                float randomValue = hash11(cell.x + cell.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;
                float motifSize = saturate(_MotifSize + variation * 0.10);
                float lineWidth = saturate(_LineWidth + variation * 0.025);
                float softness = max(_Softness, 0.0001);

                float mirrorTile = fmod(abs(cell.x + cell.y), 2.0);
                f.x = lerp(f.x, 1.0 - f.x, mirrorTile);

                float2 q = (f * 2.0 - 1.0) / max(motifSize, 0.0001);
                q = rotate2D(q, -0.38 + variation * 0.35);

                float body = fillEllipse(q - float2(-0.05, -0.08), float2(0.48, 0.72), softness);
                float neck = fillEllipse(q - float2(0.30, 0.48), float2(0.28, 0.36), softness);
                float tipCut = fillEllipse(q - float2(0.48, 0.68), float2(0.24, 0.30), softness);
                float notch = fillEllipse(q - float2(0.16, 0.26), float2(0.22, 0.34), softness);
                float filledBoteh = saturate(max(body, neck) - notch * 0.36 - tipCut * 0.18);

                float outer = ringEllipse(q - float2(-0.05, -0.08), float2(0.48, 0.72), lineWidth, softness);
                float neckRing = ringEllipse(q - float2(0.30, 0.48), float2(0.28, 0.36), lineWidth, softness);
                float outline = max(outer, neckRing) * smoothstep(1.02, 0.02, length(q));

                float angle = atan2(q.y + 0.04, q.x + 0.02);
                float radius = length(q + float2(0.02, 0.04));
                float spiral = lineMask(radius - (0.12 + 0.12 * angle), lineWidth * 0.82, softness);
                spiral *= smoothstep(0.70, 0.12, radius) * _Curl;

                float vein = strokeSegment(q, float2(-0.36, -0.44), float2(0.28, 0.48), lineWidth * 0.65, softness);
                float leafA = fillEllipse(rotate2D(q - float2(-0.22, -0.08), 0.65), float2(0.20, 0.07), softness);
                float leafB = fillEllipse(rotate2D(q - float2(0.06, 0.18), -0.58), float2(0.18, 0.06), softness);

                float dots = 0.0;
                dots = max(dots, fillCircle(q - float2(-0.22, 0.30), 0.055, softness));
                dots = max(dots, fillCircle(q - float2(-0.06, -0.18), 0.045, softness));
                dots = max(dots, fillCircle(q - float2(0.20, -0.26), 0.040, softness));
                dots *= _SeedDots * filledBoteh;

                float motif = max(outline, max(spiral, max(vein * 0.78, max(max(leafA, leafB) * 0.72, dots))));
                motif = max(motif, filledBoteh * 0.22);

                float fabric = 0.82 + 0.18 * (0.5 + 0.5 * sin((p.x * 2.1 + p.y * 3.7 + variation) * 6.28318));
                float relief = lerp(1.0, fabric, _Relief);

                return pow(saturate(motif * relief), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = paisley(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
