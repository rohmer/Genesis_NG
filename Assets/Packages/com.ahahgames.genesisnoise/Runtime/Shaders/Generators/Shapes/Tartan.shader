Shader "Hidden/Genesis/Tartan"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (4,4,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Width of broad tartan bands)] _BandWidth("Band Width", Range(0.02,0.8)) = 0.26
        [Tooltip(Width of thin pinstripes)] _PinWidth("Pin Width", Range(0.005,0.2)) = 0.035
        [Tooltip(Spacing of secondary bands)] _Repeat("Repeat", Range(2,12)) = 4
        [Tooltip(Darkness where bands cross)] _OverlapStrength("Overlap Strength", Range(0,1)) = 0.72

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.02
        [Tooltip(Woven thread detail)] _ThreadDetail("Thread Detail", Range(0,1)) = 0.45
        [Tooltip(Woven relief amount)] _Relief("Relief", Range(0,1)) = 0.38
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.0

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.0
        [Tooltip(Random seed)] _Seed("Seed", int) = 283
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

            float  _BandWidth;
            float  _PinWidth;
            float  _Repeat;
            float  _OverlapStrength;

            float  _Softness;
            float  _ThreadDetail;
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

            float stripe(float x, float center, float width, float softness)
            {
                float d = abs(frac(x - center + 0.5) - 0.5);
                float halfWidth = width * 0.5;
                return smoothstep(halfWidth + softness, halfWidth - softness, d);
            }

            float tartanAxis(float x, float repeatCount, float bandWidth, float pinWidth, float softness)
            {
                float broadA = stripe(x, 0.0, bandWidth, softness);
                float broadB = stripe(x, 0.5, bandWidth * 0.58, softness);

                float p = x * repeatCount;
                float pinA = stripe(p, 0.18, pinWidth * repeatCount, softness * repeatCount);
                float pinB = stripe(p, 0.82, pinWidth * repeatCount, softness * repeatCount);
                float centerPin = stripe(x, 0.5, pinWidth * 0.72, softness);

                return saturate(max(max(broadA, broadB * 0.74), max(max(pinA, pinB) * 0.82, centerPin)));
            }

            float tartan(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f = frac(p);

                float randomValue = hash11(cell.x + cell.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;
                float bandWidth = saturate(_BandWidth + variation * 0.05);
                float pinWidth = saturate(_PinWidth + variation * 0.015);
                float repeatCount = max(2.0, round(_Repeat));
                float softness = max(_Softness, 0.0001);

                float vertical = tartanAxis(f.x, repeatCount, bandWidth, pinWidth, softness);
                float horizontal = tartanAxis(f.y, repeatCount, bandWidth, pinWidth, softness);
                float overlap = vertical * horizontal;

                float value = 1.0;
                value -= vertical * 0.34;
                value -= horizontal * 0.34;
                value -= overlap * _OverlapStrength;

                float threadX = 0.5 + 0.5 * sin((p.x + variation) * 6.28318 * 8.0);
                float threadY = 0.5 + 0.5 * sin((p.y - variation) * 6.28318 * 8.0);
                float thread = (threadX * vertical + threadY * horizontal) * 0.5;
                float threadShade = lerp(1.0, 0.82 + 0.18 * thread, _ThreadDetail);

                float ridgeX = 1.0 - saturate(abs(frac(f.x * repeatCount) - 0.5) * 2.0);
                float ridgeY = 1.0 - saturate(abs(frac(f.y * repeatCount) - 0.5) * 2.0);
                float relief = lerp(1.0, 0.76 + 0.24 * max(ridgeX * vertical, ridgeY * horizontal), _Relief);

                return pow(saturate(value * threadShade * relief), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = tartan(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
