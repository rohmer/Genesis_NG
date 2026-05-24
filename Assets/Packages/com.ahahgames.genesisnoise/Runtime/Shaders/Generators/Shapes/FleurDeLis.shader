Shader "Hidden/Genesis/FleurDeLis"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (4,4,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Overall motif size)] _MotifSize("Motif Size", Range(0.1,1.5)) = 0.82
        [Tooltip(Size of side petals)] _PetalSize("Petal Size", Range(0.05,1.0)) = 0.48
        [Tooltip(Width of the central spear)] _SpearWidth("Spear Width", Range(0.02,0.6)) = 0.22
        [Tooltip(Width of cross band and outline)] _BandWidth("Band Width", Range(0.01,0.4)) = 0.08

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.035
        [Tooltip(Embossed relief amount)] _Relief("Relief", Range(0,1)) = 0.42
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.15

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.0
        [Tooltip(Random seed)] _Seed("Seed", int) = 269
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
            float  _PetalSize;
            float  _SpearWidth;
            float  _BandWidth;

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

            float fillEllipse(float2 p, float2 radius, float softness)
            {
                float d = length(p / max(radius, 0.0001));
                return smoothstep(1.0 + softness, 1.0 - softness, d);
            }

            float fillDiamond(float2 p, float radius, float softness)
            {
                float d = abs(p.x) + abs(p.y);
                return smoothstep(radius + softness, radius - softness, d);
            }

            float fleurDeLis(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f = frac(p);

                float randomValue = hash11(cell.x + cell.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;
                float motifSize = saturate(_MotifSize + variation * 0.1);
                float petalSize = saturate(_PetalSize + variation * 0.06);
                float spearWidth = saturate(_SpearWidth + variation * 0.04);
                float bandWidth = saturate(_BandWidth + variation * 0.025);
                float softness = max(_Softness, 0.0001);

                float mirrorTile = fmod(abs(cell.x + cell.y), 2.0);
                f.x = lerp(f.x, 1.0 - f.x, mirrorTile);

                float2 q = (f * 2.0 - 1.0) / max(motifSize, 0.0001);
                float2 aq = abs(q);

                float centerSpear = fillDiamond(float2(q.x / max(spearWidth, 0.0001), q.y - 0.28), 0.78, softness);
                centerSpear *= smoothstep(-0.32, 0.92, q.y);

                float centralBulb = fillEllipse(float2(q.x, q.y + 0.06), float2(spearWidth * 0.92, 0.34), softness);
                float sidePetal = fillEllipse(float2(aq.x - 0.36, q.y + 0.02), float2(petalSize * 0.54, petalSize * 0.30), softness);
                sidePetal *= smoothstep(0.70, -0.22, q.y);

                float curledTip = fillEllipse(float2(aq.x - 0.58, q.y - 0.10), float2(petalSize * 0.28, petalSize * 0.20), softness);
                float petalCut = fillEllipse(float2(aq.x - 0.24, q.y + 0.00), float2(petalSize * 0.16, petalSize * 0.34), softness);
                float sideShape = saturate(max(sidePetal, curledTip) - petalCut * 0.28);

                float band = lineMask(q.y + 0.30, bandWidth, softness) * smoothstep(0.78, 0.18, aq.x);
                float stem = strokeSegment(q, float2(0.0, -0.78), float2(0.0, -0.20), bandWidth * 0.82, softness);
                float footLeft = strokeSegment(q, float2(0.0, -0.70), float2(-0.32, -0.92), bandWidth * 0.75, softness);
                float footRight = strokeSegment(q, float2(0.0, -0.70), float2(0.32, -0.92), bandWidth * 0.75, softness);
                float foot = max(stem, max(footLeft, footRight));

                float outline = lineMask(abs(q.x) + abs(q.y + 0.05) - 0.98, bandWidth * 0.55, softness) * smoothstep(0.92, 0.18, aq.y);
                float motif = max(max(centerSpear, centralBulb), max(sideShape, band));
                motif = max(motif, max(foot, outline * 0.72));

                float reliefRidge = 1.0 - saturate(min(aq.x, abs(q.y + 0.30)) / max(bandWidth + spearWidth * 0.2, 0.0001));
                float fabric = 0.78 + 0.22 * (0.5 + 0.5 * sin((p.x + p.y * 1.7 + variation) * 6.28318));
                float relief = lerp(1.0, max(fabric, reliefRidge), _Relief);

                return pow(saturate(motif * relief), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = fleurDeLis(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
