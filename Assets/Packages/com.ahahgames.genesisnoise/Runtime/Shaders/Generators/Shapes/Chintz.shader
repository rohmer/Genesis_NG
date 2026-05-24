Shader "Hidden/Genesis/Chintz"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (5,5,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Width of stem strokes)] _StemWidth("Stem Width", Range(0.01,0.3)) = 0.055
        [Tooltip(Size of flowers)] _FlowerSize("Flower Size", Range(0.02,0.5)) = 0.16
        [Tooltip(Size of leaves)] _LeafSize("Leaf Size", Range(0.05,0.8)) = 0.30
        [Tooltip(Filler flower amount)] _Filler("Filler", Range(0,1)) = 0.55

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.035
        [Tooltip(Print or fabric relief)] _Relief("Relief", Range(0,1)) = 0.28
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.15

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.0
        [Tooltip(Random seed)] _Seed("Seed", int) = 251
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

            float  _StemWidth;
            float  _FlowerSize;
            float  _LeafSize;
            float  _Filler;

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

            float flower(float2 p, float radius, float softness)
            {
                float center = fillCircle(p, radius * 0.25, softness);
                float petals = 0.0;
                petals = max(petals, fillEllipse(p - float2(radius * 0.45, 0.0), float2(radius * 0.36, radius * 0.22), softness));
                petals = max(petals, fillEllipse(p + float2(radius * 0.45, 0.0), float2(radius * 0.36, radius * 0.22), softness));
                petals = max(petals, fillEllipse(p - float2(0.0, radius * 0.45), float2(radius * 0.22, radius * 0.36), softness));
                petals = max(petals, fillEllipse(p + float2(0.0, radius * 0.45), float2(radius * 0.22, radius * 0.36), softness));
                petals = max(petals, fillEllipse(rotate2D(p, 0.785398), float2(radius * 0.52, radius * 0.16), softness));
                return max(center, petals);
            }

            float leaf(float2 p, float2 dir, float size, float softness)
            {
                float angle = atan2(dir.y, dir.x);
                float2 local = rotate2D(p, -angle);
                float body = fillEllipse(local, float2(size * 0.54, size * 0.20), softness);
                float notch = fillEllipse(local - float2(size * 0.24, 0.0), float2(size * 0.16, size * 0.12), softness);
                return saturate(body - notch * 0.22);
            }

            float chintz(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f = frac(p);

                float randomValue = hash11(cell.x + cell.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;
                float stemWidth = saturate(_StemWidth + variation * 0.02);
                float flowerSize = saturate(_FlowerSize + variation * 0.04);
                float leafSize = saturate(_LeafSize + variation * 0.05);
                float softness = max(_Softness, 0.0001);

                float mirrorTile = fmod(abs(cell.x + cell.y), 2.0);
                f.x = lerp(f.x, 1.0 - f.x, mirrorTile);
                float2 q = f * 2.0 - 1.0;

                float stemCurve = q.x + 0.22 * sin((q.y + 0.18) * 3.14159);
                float mainStem = lineMask(stemCurve, stemWidth, softness) * smoothstep(1.0, -0.9, q.y);
                float sideStemA = strokeSegment(q, float2(-0.02, -0.28), float2(-0.46, 0.18), stemWidth * 0.7, softness);
                float sideStemB = strokeSegment(q, float2(0.04, -0.08), float2(0.46, 0.30), stemWidth * 0.7, softness);
                float sideStemC = strokeSegment(q, float2(0.0, 0.22), float2(-0.34, 0.58), stemWidth * 0.55, softness);
                float stems = max(max(mainStem, sideStemA), max(sideStemB, sideStemC));

                float leaves = 0.0;
                leaves = max(leaves, leaf(q - float2(-0.30, 0.02), float2(-1.0, 0.55), leafSize, softness));
                leaves = max(leaves, leaf(q - float2(0.28, 0.16), float2(1.0, 0.55), leafSize * 0.88, softness));
                leaves = max(leaves, leaf(q - float2(-0.20, 0.46), float2(-0.8, 0.6), leafSize * 0.70, softness));
                leaves = max(leaves, leaf(q - float2(0.10, -0.42), float2(0.8, -0.3), leafSize * 0.66, softness));

                float flowers = 0.0;
                flowers = max(flowers, flower(q - float2(0.02, 0.70), flowerSize, softness));
                flowers = max(flowers, flower(q - float2(-0.52, 0.22), flowerSize * 0.86, softness));
                flowers = max(flowers, flower(q - float2(0.52, 0.34), flowerSize * 0.76, softness));

                float filler = 0.0;
                filler = max(filler, flower(q - float2(-0.62, -0.58), flowerSize * 0.42, softness));
                filler = max(filler, flower(q - float2(0.64, -0.44), flowerSize * 0.36, softness));
                filler = max(filler, fillCircle(q - float2(-0.08, -0.70), flowerSize * 0.18, softness));
                filler *= _Filler;

                float motif = max(max(stems * 0.78, leaves * 0.84), max(flowers, filler * 0.68));
                float fabric = 0.84 + 0.16 * (0.5 + 0.5 * sin((p.x * 1.7 + p.y * 2.3 + variation) * 6.28318));
                float relief = lerp(1.0, fabric, _Relief);

                return pow(saturate(motif * relief), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = chintz(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
