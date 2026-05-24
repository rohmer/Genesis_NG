Shader "Hidden/Genesis/GreekKey"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (6,6,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Width of the meander stroke)] _StrokeWidth("Stroke Width", Range(0.01,0.5)) = 0.11
        [Tooltip(Internal spacing of the spiral path)] _Inset("Inset", Range(0.05,0.45)) = 0.18
        [Tooltip(Alternate mirrored tiles)] _Mirror("Mirror", Range(0,1)) = 1.0
        [Tooltip(Secondary border amount)] _Border("Border", Range(0,1)) = 0.35

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.025
        [Tooltip(Raised stroke relief)] _Relief("Relief", Range(0,1)) = 0.35
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.1

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.0
        [Tooltip(Random seed)] _Seed("Seed", int) = 181
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

            float  _StrokeWidth;
            float  _Inset;
            float  _Mirror;
            float  _Border;

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

            float segmentDistance(float2 p, float2 a, float2 b)
            {
                float2 pa = p - a;
                float2 ba = b - a;
                float h = saturate(dot(pa, ba) / max(dot(ba, ba), 0.0001));
                return length(pa - ba * h);
            }

            float strokeFromDistance(float d, float width, float softness)
            {
                float halfWidth = width * 0.5;
                return smoothstep(halfWidth + softness, halfWidth - softness, d);
            }

            float lineStroke(float2 p, float2 a, float2 b, float width, float softness)
            {
                return strokeFromDistance(segmentDistance(p, a, b), width, softness);
            }

            float boxFrame(float2 p, float inset, float width, float softness)
            {
                float2 q = abs(p - 0.5);
                float outer = smoothstep(0.5 + softness, 0.5 - softness, max(q.x, q.y));
                float inner = smoothstep(0.5 - inset + softness, 0.5 - inset - softness, max(q.x, q.y));
                return saturate(outer - inner) * smoothstep(width, width + softness, max(q.x, q.y));
            }

            float greekKey(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f = frac(p);

                float randomValue = hash11(cell.x + cell.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;
                float strokeWidth = saturate(_StrokeWidth + variation * 0.035);
                float inset = saturate(_Inset + variation * 0.035);
                float softness = max(_Softness, 0.0001);

                float mirrorTile = fmod(abs(cell.x + cell.y), 2.0) * step(0.5, _Mirror);
                f.x = lerp(f.x, 1.0 - f.x, mirrorTile);

                float a = inset;
                float b = 1.0 - inset;
                float c = 0.5;
                float d = lerp(a, c, 0.5);
                float e = lerp(c, b, 0.5);

                float motif = 0.0;
                motif = max(motif, lineStroke(f, float2(a, a), float2(b, a), strokeWidth, softness));
                motif = max(motif, lineStroke(f, float2(b, a), float2(b, b), strokeWidth, softness));
                motif = max(motif, lineStroke(f, float2(b, b), float2(d, b), strokeWidth, softness));
                motif = max(motif, lineStroke(f, float2(d, b), float2(d, d), strokeWidth, softness));
                motif = max(motif, lineStroke(f, float2(d, d), float2(e, d), strokeWidth, softness));
                motif = max(motif, lineStroke(f, float2(e, d), float2(e, e), strokeWidth, softness));
                motif = max(motif, lineStroke(f, float2(e, e), float2(c, e), strokeWidth, softness));

                float borderInset = max(0.02, strokeWidth * 0.75);
                float border = boxFrame(f, borderInset, strokeWidth, softness) * _Border;
                motif = max(motif, border);

                float2 nearestPathPoint = min(abs(f - a), abs(f - b));
                float reliefLine = 1.0 - saturate(min(nearestPathPoint.x, nearestPathPoint.y) / max(strokeWidth, 0.0001));
                float relief = lerp(1.0, 0.76 + 0.24 * reliefLine, _Relief);

                return pow(saturate(motif * relief), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = greekKey(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
