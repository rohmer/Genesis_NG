Shader "Hidden/Genesis/Trellis"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (5,5,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Width of lattice rails)] _RailWidth("Rail Width", Range(0.01,0.5)) = 0.12
        [Tooltip(Size of rounded intersections)] _JointSize("Joint Size", Range(0.01,0.8)) = 0.28
        [Tooltip(Offset between alternating rows)] _Stagger("Stagger", Range(0,1)) = 0.5
        [Tooltip(Ornament amount inside each opening)] _Ornament("Ornament", Range(0,1)) = 0.35

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.035
        [Tooltip(Rounded rail relief)] _Relief("Relief", Range(0,1)) = 0.45
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.15

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.0
        [Tooltip(Random seed)] _Seed("Seed", int) = 149
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

            float  _RailWidth;
            float  _JointSize;
            float  _Stagger;
            float  _Ornament;

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

            float trellis(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f = frac(p);
                float randomValue = hash11(cell.x + cell.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;

                float rowOffset = fmod(abs(cell.y), 2.0) * _Stagger;
                float2 local = frac(float2(p.x + rowOffset, p.y));
                float2 q = local - 0.5;

                float railWidth = saturate(_RailWidth + variation * 0.04);
                float jointSize = saturate(_JointSize + variation * 0.08);
                float softness = max(_Softness, 0.0001);

                float diagA = lineMask(q.y - q.x, railWidth, softness);
                float diagB = lineMask(q.y + q.x, railWidth, softness);
                float rails = max(diagA, diagB);

                float2 corner = abs(local - round(local));
                float jointA = fillCircle(local - 0.5, jointSize * 0.5, softness);
                float jointB = fillCircle(corner, jointSize * 0.42, softness);
                float joints = max(jointA, jointB);

                float opening = 1.0 - saturate(rails + joints);
                float cellPetal = fillCircle(abs(q) - 0.22, 0.18, softness);
                float centerDot = fillCircle(q, 0.10, softness);
                float ornament = max(cellPetal * 0.72, centerDot) * opening * _Ornament;

                float ridgeA = 1.0 - saturate(abs(q.y - q.x) / max(railWidth, 0.0001));
                float ridgeB = 1.0 - saturate(abs(q.y + q.x) / max(railWidth, 0.0001));
                float railRelief = lerp(1.0, 0.72 + 0.28 * max(ridgeA, ridgeB), _Relief);

                float value = max(rails * railRelief, max(joints, ornament));
                return pow(saturate(value), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = trellis(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
