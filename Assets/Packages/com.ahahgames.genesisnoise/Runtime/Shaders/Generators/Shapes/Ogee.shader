Shader "Hidden/Genesis/Ogee"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (4,4,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Width of ogee frame lines)] _LineWidth("Line Width", Range(0.01,0.5)) = 0.10
        [Tooltip(Height and sweep of the ogee curve)] _Curve("Curve", Range(0.05,0.9)) = 0.46
        [Tooltip(Amount of inner echo ornament)] _Echo("Echo", Range(0,1)) = 0.45
        [Tooltip(Size of rounded joints)] _JointSize("Joint Size", Range(0,0.6)) = 0.16

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.03
        [Tooltip(Raised line relief)] _Relief("Relief", Range(0,1)) = 0.38
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.15

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.0
        [Tooltip(Random seed)] _Seed("Seed", int) = 367
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

            float  _LineWidth;
            float  _Curve;
            float  _Echo;
            float  _JointSize;

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

            float fillCircle(float2 p, float radius, float softness)
            {
                return smoothstep(radius + softness, radius - softness, length(p));
            }

            float ringEllipse(float2 p, float2 radius, float width, float softness)
            {
                float d = length(p / max(radius, 0.0001));
                return lineMask(d - 1.0, width, softness);
            }

            float ogee(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f = frac(p);

                float randomValue = hash11(cell.x + cell.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;
                float lineWidth = saturate(_LineWidth + variation * 0.035);
                float curve = saturate(_Curve + variation * 0.07);
                float jointSize = saturate(_JointSize + variation * 0.04);
                float softness = max(_Softness, 0.0001);

                float mirrorTile = fmod(abs(cell.x + cell.y), 2.0);
                f.x = lerp(f.x, 1.0 - f.x, mirrorTile);

                float2 q = f * 2.0 - 1.0;
                float2 aq = abs(q);

                float sideArc = ringEllipse(
                    float2(aq.x - 0.52, q.y * (0.78 - curve * 0.20)),
                    float2(0.52, 0.62 + curve * 0.24),
                    lineWidth,
                    softness);

                float topArc = ringEllipse(
                    float2(q.x * (0.72 + curve * 0.10), aq.y - 0.55),
                    float2(0.54, 0.32 + curve * 0.24),
                    lineWidth,
                    softness);

                float waist = lineMask(aq.y - (0.10 + curve * 0.24), lineWidth * 0.72, softness) * smoothstep(0.86, 0.12, aq.x);
                float frame = max(max(sideArc, topArc), waist * 0.55);

                float echoSide = ringEllipse(float2(aq.x - 0.32, q.y * 0.82), float2(0.34, 0.48 + curve * 0.12), lineWidth * 0.55, softness);
                float echoTop = ringEllipse(float2(q.x * 0.78, aq.y - 0.34), float2(0.34, 0.22 + curve * 0.10), lineWidth * 0.50, softness);
                float echo = max(echoSide, echoTop) * _Echo;

                float topJoint = fillCircle(float2(q.x, aq.y - 0.92), jointSize * 0.48, softness);
                float sideJoint = fillCircle(float2(aq.x - 0.78, q.y), jointSize * 0.42, softness);
                float centerDrop = fillCircle(float2(q.x, q.y + 0.18), jointSize * 0.34, softness) * _Echo;
                float joints = max(max(topJoint, sideJoint), centerDrop);

                float ridge = 1.0 - saturate(min(abs(aq.x - 0.52), abs(aq.y - 0.55)) / max(lineWidth, 0.0001));
                float relief = lerp(1.0, 0.74 + 0.26 * ridge, _Relief);

                float value = max(frame * relief, max(echo * 0.72, joints));
                return pow(saturate(value), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = ogee(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
