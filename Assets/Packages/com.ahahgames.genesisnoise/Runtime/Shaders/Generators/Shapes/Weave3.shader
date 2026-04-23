Shader "Hidden/Genesis/Weave3"
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

        [Tooltip(Number of horizontal overs)] _OverCount("Over Count", Range(1,8)) = 2
        [Tooltip(Number of horizontal unders)] _UnderCount("Under Count", Range(1,8)) = 1

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

            float  _OverCount;
            float  _UnderCount;

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
            float weave3(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f    = frac(p);

                // Random per-cell variation
                float r = hash11(cell.x + cell.y * 31.0);
                float jitter = (r - 0.5) * _Randomness;

                float widthH = saturate(_WidthH + jitter * 0.2);
                float widthV = saturate(_WidthV - jitter * 0.2);

                // Horizontal + vertical threads
                float h = stripe(f.y, widthH, _Softness);
                float v = stripe(f.x, widthV, _Softness);

                // Complex twill pattern: N-over, M-under
                int cycle = (int)(_OverCount + _UnderCount);
                int idx = ((int)cell.x + (int)cell.y) % cycle;

                bool over = idx < (int)_OverCount;

                float result = over ? max(h, v * (1.0 - _Gap))
                                    : max(v, h * (1.0 - _Gap));

                return pow(result, _Contrast);
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = weave3(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}