Shader "Hidden/Genesis/Harlequin"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (6,6,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Width of diamond outlines)] _OutlineWidth("Outline Width", Range(0,0.5)) = 0.08
        [Tooltip(Size of inner diamond accent)] _AccentSize("Accent Size", Range(0,1)) = 0.18
        [Tooltip(Tone contrast between alternating diamonds)] _ToneContrast("Tone Contrast", Range(0,1)) = 0.75
        [Tooltip(Offset every other row)] _Stagger("Stagger", Range(0,1)) = 0.5

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.025
        [Tooltip(Raised diamond relief)] _Relief("Relief", Range(0,1)) = 0.35
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.0

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.0
        [Tooltip(Random seed)] _Seed("Seed", int) = 197
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

            float  _OutlineWidth;
            float  _AccentSize;
            float  _ToneContrast;
            float  _Stagger;

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

            float diamondDistance(float2 p)
            {
                return abs(p.x) + abs(p.y);
            }

            float diamondFill(float2 p, float radius, float softness)
            {
                float d = diamondDistance(p);
                return smoothstep(radius + softness, radius - softness, d);
            }

            float diamondLine(float2 p, float radius, float width, float softness)
            {
                float d = abs(diamondDistance(p) - radius);
                float halfWidth = width * 0.5;
                return smoothstep(halfWidth + softness, halfWidth - softness, d);
            }

            float harlequin(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float row = floor(p.y);
                float rowOffset = fmod(abs(row), 2.0) * _Stagger;
                float2 tileP = float2(p.x + rowOffset, p.y);

                float2 cell = floor(tileP);
                float2 f = frac(tileP);
                float2 q = f * 2.0 - 1.0;

                float randomValue = hash11(cell.x + cell.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;
                float outlineWidth = saturate(_OutlineWidth + variation * 0.035);
                float accentSize = saturate(_AccentSize + variation * 0.05);
                float softness = max(_Softness, 0.0001);

                float toneIndex = fmod(abs(cell.x + cell.y), 2.0);
                float tone = lerp(1.0 - _ToneContrast, 1.0, toneIndex);

                float diamond = diamondFill(q, 1.0, softness);
                float outline = diamondLine(q, 1.0 - outlineWidth * 0.5, outlineWidth, softness);
                float accent = diamondFill(q, accentSize, softness);

                float ridge = 1.0 - saturate(abs(diamondDistance(q) - 0.5) * 2.0);
                float relief = lerp(1.0, 0.78 + 0.22 * ridge, _Relief);

                float value = diamond * tone * relief;
                value = max(value, outline);
                value = max(value, accent * lerp(0.0, 1.0, 1.0 - toneIndex) * 0.85);

                return pow(saturate(value), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = harlequin(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
