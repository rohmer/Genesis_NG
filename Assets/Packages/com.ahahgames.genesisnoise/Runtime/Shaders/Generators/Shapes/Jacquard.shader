Shader "Hidden/Genesis/Jacquard"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (4,4,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Number of weave cells inside each motif tile)] _Resolution("Resolution", Range(4,32)) = 12
        [Tooltip(Overall motif size)] _MotifSize("Motif Size", Range(0.1,1.5)) = 0.82
        [Tooltip(Thread width inside each weave cell)] _ThreadWidth("Thread Width", Range(0.05,1)) = 0.72
        [Tooltip(Satin float length)] _FloatLength("Float Length", Range(1,8)) = 4
        [Tooltip(Stepped motif density)] _StepDensity("Step Density", Range(1,12)) = 5

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.025
        [Tooltip(Woven relief amount)] _Relief("Relief", Range(0,1)) = 0.55
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.2

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.0
        [Tooltip(Random seed)] _Seed("Seed", int) = 137
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

            float  _Resolution;
            float  _MotifSize;
            float  _ThreadWidth;
            float  _FloatLength;
            float  _StepDensity;

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

            float positiveModulo(float x, float y)
            {
                return fmod(fmod(x, y) + y, y);
            }

            float stripe(float x, float width, float softness)
            {
                float d = abs(x - 0.5);
                float edge = width * 0.5;
                return smoothstep(edge + softness, edge - softness, d);
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

            float jacquard(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 tile = floor(p);
                float2 f = frac(p);

                float randomValue = hash11(tile.x + tile.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;

                float resolution = max(4.0, round(_Resolution));
                float2 weaveP = f * resolution;
                float2 weaveCell = floor(weaveP);
                float2 weaveF = frac(weaveP);

                float2 q = f * 2.0 - 1.0;
                q.x *= lerp(1.0, -1.0, fmod(abs(tile.x), 2.0));
                q.y *= lerp(1.0, -1.0, fmod(abs(tile.y), 2.0));

                float motifSize = saturate(_MotifSize + variation * 0.1);
                float softness = max(_Softness, 0.0001);
                float threadWidth = saturate(_ThreadWidth + variation * 0.08);

                float2 scaled = q / max(motifSize, 0.0001);
                float2 aq = abs(scaled);

                float medallion = fillEllipse(scaled, float2(0.42, 0.58), softness);
                float cutout = fillEllipse(scaled, float2(0.18, 0.30), softness);
                float motif = saturate(medallion - cutout * 0.55);

                float stepDensity = max(1.0, round(_StepDensity));
                float steppedDiagonal = lineMask(floor(aq.x * stepDensity) - floor((1.0 - aq.y) * stepDensity), 0.42, softness);
                float border = max(
                    lineMask(max(aq.x, aq.y) - 0.86, 0.10, softness),
                    lineMask(min(abs(aq.x - 0.52), abs(aq.y - 0.52)), 0.05, softness) * 0.65);
                motif = max(motif, max(steppedDiagonal * 0.72, border));

                float floatLength = max(1.0, round(_FloatLength));
                float satinIndex = positiveModulo(weaveCell.x + weaveCell.y * 2.0, floatLength);
                float lift = step(satinIndex, 0.5);
                float motifLift = lerp(1.0 - lift, lift, motif);

                float warp = stripe(weaveF.x, threadWidth, softness);
                float weft = stripe(weaveF.y, threadWidth, softness);
                float warpRidge = 1.0 - saturate(abs(weaveF.x - 0.5) * 2.0);
                float weftRidge = 1.0 - saturate(abs(weaveF.y - 0.5) * 2.0);

                float raisedWarp = warp * lerp(1.0, warpRidge, _Relief);
                float raisedWeft = weft * lerp(1.0, weftRidge, _Relief);
                float weave = lerp(raisedWeft * 0.68, raisedWarp, motifLift);

                float satinSheen = 0.74 + 0.26 * (0.5 + 0.5 * sin((p.x + p.y + variation) * 6.28318));
                float value = max(motif * 0.25, weave * satinSheen);

                return pow(saturate(value), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = jacquard(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
