Shader "Hidden/Genesis/MoroccanLattice"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (4,5,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Width of lattice rails)] _RailWidth("Rail Width", Range(0.01,0.5)) = 0.10
        [Tooltip(Height of the arch curve)] _ArchHeight("Arch Height", Range(0.05,0.8)) = 0.38
        [Tooltip(Size of rounded intersections)] _JointSize("Joint Size", Range(0.01,0.7)) = 0.20
        [Tooltip(Inner ornament amount)] _Ornament("Ornament", Range(0,1)) = 0.35

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.03
        [Tooltip(Raised rail relief)] _Relief("Relief", Range(0,1)) = 0.42
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.15

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.0
        [Tooltip(Random seed)] _Seed("Seed", int) = 211
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
            float  _ArchHeight;
            float  _JointSize;
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

            float ringEllipse(float2 p, float2 radius, float width, float softness)
            {
                float d = length(p / max(radius, 0.0001));
                return lineMask(d - 1.0, width, softness);
            }

            float moroccanLattice(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f = frac(p);

                float randomValue = hash11(cell.x + cell.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;
                float railWidth = saturate(_RailWidth + variation * 0.035);
                float archHeight = saturate(_ArchHeight + variation * 0.08);
                float jointSize = saturate(_JointSize + variation * 0.06);
                float softness = max(_Softness, 0.0001);

                float mirrorTile = fmod(abs(cell.x + cell.y), 2.0);
                f.x = lerp(f.x, 1.0 - f.x, mirrorTile);

                float2 q = f * 2.0 - 1.0;
                float2 aq = abs(q);

                float ogeeLeft = ringEllipse(float2(aq.x - 0.52, q.y * (0.82 - archHeight * 0.25)), float2(0.52, 0.70), railWidth, softness);
                float ogeeTop = ringEllipse(float2(q.x * 0.72, aq.y - 0.56), float2(0.56, 0.36 + archHeight * 0.24), railWidth, softness);
                float verticalRail = lineMask(aq.x - 0.78, railWidth, softness) * smoothstep(1.0, 0.05, aq.y);
                float waistRail = lineMask(aq.y - (0.18 + archHeight * 0.18), railWidth * 0.75, softness) * smoothstep(0.84, 0.16, aq.x);

                float rails = max(max(ogeeLeft, ogeeTop), max(verticalRail, waistRail * 0.75));

                float topJoint = fillCircle(float2(q.x, aq.y - 0.92), jointSize * 0.5, softness);
                float sideJoint = fillCircle(float2(aq.x - 0.78, q.y), jointSize * 0.45, softness);
                float centerJoint = fillCircle(q, jointSize * 0.34, softness);
                float joints = max(max(topJoint, sideJoint), centerJoint);

                float opening = 1.0 - saturate(rails + joints);
                float innerArch = ringEllipse(float2(aq.x - 0.28, q.y * 0.9), float2(0.30, 0.44), railWidth * 0.55, softness);
                float innerDrop = fillCircle(float2(q.x, q.y + 0.24), 0.12, softness);
                float ornament = max(innerArch * 0.72, innerDrop) * opening * _Ornament;

                float ridge = 1.0 - saturate(min(abs(aq.x - 0.52), abs(aq.y - 0.56)) / max(railWidth, 0.0001));
                float relief = lerp(1.0, 0.74 + 0.26 * ridge, _Relief);

                float value = max(rails * relief, max(joints, ornament));
                return pow(saturate(value), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = moroccanLattice(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
