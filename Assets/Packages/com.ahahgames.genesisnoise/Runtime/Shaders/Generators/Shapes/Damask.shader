Shader "Hidden/Genesis/Damask"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (3,4,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Overall motif size)] _MotifSize("Motif Size", Range(0.1,1.5)) = 0.88
        [Tooltip(Thickness of ornamental lines)] _OrnamentWidth("Ornament Width", Range(0.01,0.5)) = 0.10
        [Tooltip(Leaf width)] _LeafWidth("Leaf Width", Range(0.05,1.0)) = 0.42
        [Tooltip(Scroll intensity)] _Scroll("Scroll", Range(0,1)) = 0.55

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.035
        [Tooltip(Woven tonal relief)] _Relief("Relief", Range(0,1)) = 0.4
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.25

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.0
        [Tooltip(Random seed)] _Seed("Seed", int) = 113
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
            float  _OrnamentWidth;
            float  _LeafWidth;
            float  _Scroll;

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

            float damask(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f = frac(p);

                float randomValue = hash11(cell.x + cell.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;

                float2 q = f * 2.0 - 1.0;
                q.x *= lerp(1.0, -1.0, fmod(abs(cell.x), 2.0));
                q.y *= lerp(1.0, -1.0, fmod(abs(cell.y), 2.0));

                float motifSize = saturate(_MotifSize + variation * 0.1);
                float ornamentWidth = saturate(_OrnamentWidth + variation * 0.035);
                float leafWidth = saturate(_LeafWidth + variation * 0.08);
                float softness = max(_Softness, 0.0001);

                float2 scaled = q / max(motifSize, 0.0001);
                float2 aq = abs(scaled);

                float ogeeLeft = ringEllipse(float2(aq.x - 0.48, scaled.y * 0.78), float2(0.48, 0.74), ornamentWidth, softness);
                float ogeeTop = ringEllipse(float2(scaled.x * 0.78, aq.y - 0.58), float2(0.64, 0.42), ornamentWidth, softness);
                float ogee = max(ogeeLeft, ogeeTop);

                float leafTop = fillEllipse(float2(scaled.x, scaled.y - 0.28), float2(leafWidth * 0.45, 0.48), softness);
                float leafBottom = fillEllipse(float2(scaled.x, scaled.y + 0.32), float2(leafWidth * 0.32, 0.34), softness);
                float leafCut = fillEllipse(float2(scaled.x, scaled.y - 0.10), float2(leafWidth * 0.18, 0.62), softness);
                float leaves = saturate(max(leafTop, leafBottom) - leafCut * 0.35);

                float scrollPhase = _Scroll * 0.45;
                float scrollA = lineMask((aq.y - 0.18) - 0.30 * sin((aq.x + scrollPhase) * 6.28318), ornamentWidth, softness);
                float scrollB = lineMask((aq.x - 0.20) - 0.24 * sin((aq.y + scrollPhase) * 6.28318), ornamentWidth * 0.85, softness);
                float scrollGate = smoothstep(0.95, 0.16, max(aq.x, aq.y));
                float scrollwork = max(scrollA, scrollB) * scrollGate;

                float centerStem = lineMask(scaled.x, ornamentWidth * 0.72, softness) * smoothstep(0.82, 0.08, abs(scaled.y));
                float centerBud = fillEllipse(scaled, float2(0.16, 0.18), softness);
                float cornerFlourish = fillEllipse(aq - float2(0.74, 0.74), float2(0.16, 0.24), softness);

                float ornament = max(ogee, leaves * 0.78);
                ornament = max(ornament, max(scrollwork * 0.86, centerStem));
                ornament = max(ornament, max(centerBud, cornerFlourish * 0.72));

                float ribX = 0.5 + 0.5 * sin((p.x + variation) * 6.28318);
                float ribY = 0.5 + 0.5 * sin((p.y - variation) * 6.28318);
                float fabricRelief = lerp(1.0, 0.70 + 0.30 * (ribX * 0.45 + ribY * 0.55), _Relief);

                return pow(saturate(ornament * fabricRelief), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = damask(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
