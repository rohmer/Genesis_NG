Shader "Hidden/Genesis/Weave2"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (8,8,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Width of horizontal threads)] _WidthH("Width H", Range(0.01,1)) = 0.4
        [Tooltip(Width of vertical threads)]   _WidthV("Width V", Range(0.01,1)) = 0.4

        [Tooltip(Gap between threads)] _Gap("Gap", Range(0,1)) = 0.1

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.5)) = 0.05
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.0

        [Tooltip(Twill diagonal shift per row)] _Shift("Shift", Range(-1,1)) = 0.25

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.0
        [Tooltip(Random seed)] _Seed("Seed", int) = 52
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

            float  _WidthH;
            float  _WidthV;
            float  _Gap;

            float  _Softness;
            float  _Contrast;

            float  _Shift;

            float  _Randomness;
            float  _Seed;

            // ---------------------------------------------------------
            float hash11(float n)
            {
                n += _Seed * 17.0;
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a), c = cos(a);
                return float2(c*p.x - s*p.y, s*p.x + c*p.y);
            }

            float stripe(float x, float width, float softness)
            {
                float d = abs(x - 0.5);
                float edge = width * 0.5;
                return smoothstep(edge + softness, edge - softness, d);
            }

            // ---------------------------------------------------------
            float weave2(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f    = frac(p);

                // Twill diagonal shift
                float2 shiftedF = f;
                shiftedF.x = frac(f.x + cell.y * _Shift);

                // Random per-cell variation
                float r = hash11(cell.x + cell.y * 31.0);
                float jitter = (r - 0.5) * _Randomness;

                float widthH = saturate(_WidthH + jitter * 0.2);
                float widthV = saturate(_WidthV - jitter * 0.2);

                // Horizontal thread
                float h = stripe(shiftedF.y, widthH, _Softness);

                // Vertical thread
                float v = stripe(shiftedF.x, widthV, _Softness);

                // Twill over/under pattern
                bool over = ((int)cell.x + (int)cell.y) & 1;

                float result = over ? max(h, v * (1.0 - _Gap))
                                    : max(v, h * (1.0 - _Gap));

                return pow(result, _Contrast);
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = weave2(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}