Shader "Hidden/Genesis/Brocade"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (4,4,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Number of petals in the central motif)] _Petals("Petals", Range(2,16)) = 8
        [Tooltip(Overall motif size)] _MotifSize("Motif Size", Range(0.1,1.5)) = 0.72
        [Tooltip(Thickness of ornament lines)] _OrnamentWidth("Ornament Width", Range(0.01,0.5)) = 0.12
        [Tooltip(Thickness of diagonal vine lines)] _VineWidth("Vine Width", Range(0.01,0.5)) = 0.08

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.035
        [Tooltip(Raised woven relief)] _Relief("Relief", Range(0,1)) = 0.45
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.35

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.0
        [Tooltip(Random seed)] _Seed("Seed", int) = 91
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

            float  _Petals;
            float  _MotifSize;
            float  _OrnamentWidth;
            float  _VineWidth;

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

            float ringMask(float r, float radius, float width, float softness)
            {
                return lineMask(r - radius, width, softness);
            }

            float brocade(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f = frac(p);

                float randomValue = hash11(cell.x + cell.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;

                float2 q = f * 2.0 - 1.0;
                q.x *= lerp(1.0, -1.0, fmod(abs(cell.y), 2.0));
                q.y *= lerp(1.0, -1.0, fmod(abs(cell.x), 2.0));

                float motifSize = saturate(_MotifSize + variation * 0.12);
                float ornamentWidth = saturate(_OrnamentWidth + variation * 0.04);
                float vineWidth = saturate(_VineWidth - variation * 0.02);
                float softness = max(_Softness, 0.0001);

                float r = length(q) / max(motifSize, 0.0001);
                float angle = atan2(q.y, q.x);
                float petals = max(2.0, round(_Petals));
                float petalWave = 0.5 + 0.5 * cos(angle * petals);
                float petalRadius = lerp(0.32, 0.82, petalWave);

                float medallion = ringMask(r, 0.58, ornamentWidth, softness);
                float petalEdge = ringMask(r, petalRadius, ornamentWidth, softness);
                float center = smoothstep(0.24 + softness, 0.24 - softness, r);

                float2 aq = abs(q);
                float diagonalA = lineMask((q.x + q.y) * 0.7071 - 0.34 * sin(q.x * 3.14159), vineWidth, softness);
                float diagonalB = lineMask((q.x - q.y) * 0.7071 - 0.34 * sin(q.y * 3.14159), vineWidth, softness);
                float latticeGate = smoothstep(1.0, 0.28, max(aq.x, aq.y));
                float vines = max(diagonalA, diagonalB) * latticeGate;

                float ogee = ringMask(length(float2(abs(q.x) - 0.52, q.y * 0.72)), 0.48, ornamentWidth, softness);
                float cornerBud = smoothstep(0.24 + softness, 0.24 - softness, length(aq - 0.72));

                float ornament = max(max(medallion, petalEdge), max(center, cornerBud));
                ornament = max(ornament, max(vines * 0.82, ogee * 0.72));

                float ribX = 0.5 + 0.5 * sin((p.x + variation) * 6.28318);
                float ribY = 0.5 + 0.5 * sin((p.y - variation) * 6.28318);
                float fabricRelief = lerp(1.0, 0.72 + 0.28 * max(ribX, ribY), _Relief);

                return pow(saturate(ornament * fabricRelief), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = brocade(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
