Shader "Hidden/Genesis/Leopard"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (7,7,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Size of main rosettes)] _SpotSize("Spot Size", Range(0.05,0.8)) = 0.36
        [Tooltip(Thickness of rosette rings)] _RingWidth("Ring Width", Range(0.01,0.35)) = 0.11
        [Tooltip(Amount of broken ring gaps)] _Breakup("Breakup", Range(0,1)) = 0.55
        [Tooltip(Amount of small filler spots)] _Filler("Filler", Range(0,1)) = 0.45

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.035
        [Tooltip(Furlike tonal grain)] _FurDetail("Fur Detail", Range(0,1)) = 0.35
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.2

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.65
        [Tooltip(Random seed)] _Seed("Seed", int) = 307
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

            float  _SpotSize;
            float  _RingWidth;
            float  _Breakup;
            float  _Filler;

            float  _Softness;
            float  _FurDetail;
            float  _Contrast;

            float  _Randomness;
            float  _Seed;

            float hash11(float n)
            {
                n += _Seed * 17.0;
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float n)
            {
                return frac(sin(float2(n * 127.1, n * 311.7) + _Seed * 17.0) * 43758.5453);
            }

            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a);
                float c = cos(a);
                return float2(c * p.x - s * p.y, s * p.x + c * p.y);
            }

            float fillEllipse(float2 p, float2 radius, float softness)
            {
                float d = length(p / max(radius, 0.0001));
                return smoothstep(1.0 + softness, 1.0 - softness, d);
            }

            float ringEllipse(float2 p, float2 radius, float width, float softness)
            {
                float d = length(p / max(radius, 0.0001));
                float halfWidth = width * 0.5;
                return smoothstep(halfWidth + softness, halfWidth - softness, abs(d - 1.0));
            }

            float rosette(float2 p, float size, float ringWidth, float breakup, float softness, float seed)
            {
                float angle = atan2(p.y, p.x);
                float wobble = 1.0 + 0.14 * sin(angle * 3.0 + seed) + 0.09 * sin(angle * 7.0 + seed * 1.7);
                float2 radius = float2(size * wobble, size * (0.72 + 0.14 * sin(seed)));
                float ring = ringEllipse(p, radius, ringWidth, softness);

                float gaps = 0.5 + 0.5 * sin(angle * 5.0 + seed * 2.1);
                float gapMask = smoothstep(breakup, 1.0, gaps);
                float center = fillEllipse(p + hash21(seed + 13.0) * 0.08 - 0.04, radius * 0.34, softness) * 0.48;
                return max(ring * lerp(1.0, gapMask, breakup), center);
            }

            float leopard(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 baseCell = floor(p);
                float2 f = frac(p);
                float softness = max(_Softness, 0.0001);
                float value = 0.0;

                [unroll]
                for (int y = -1; y <= 1; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 neighbor = float2(x, y);
                        float2 cell = baseCell + neighbor;
                        float id = cell.x + cell.y * 57.0;
                        float2 rnd = hash21(id);
                        float jitter = _Randomness;
                        float2 center = neighbor + rnd * jitter + (1.0 - jitter) * 0.5;
                        float2 local = f - center;

                        float rot = (hash11(id + 19.0) - 0.5) * 3.14159;
                        local = rotate2D(local, rot);

                        float size = _SpotSize * lerp(0.72, 1.28, hash11(id + 7.0));
                        float width = _RingWidth * lerp(0.72, 1.22, hash11(id + 11.0));
                        value = max(value, rosette(local, size, width, _Breakup, softness, id));

                        float2 fillerCenter = neighbor + hash21(id + 41.0);
                        float2 fillerLocal = f - fillerCenter;
                        float fillerSize = _SpotSize * lerp(0.12, 0.26, hash11(id + 43.0));
                        float filler = fillEllipse(fillerLocal, float2(fillerSize, fillerSize * lerp(0.65, 1.25, hash11(id + 47.0))), softness);
                        value = max(value, filler * _Filler * step(0.36, hash11(id + 53.0)));
                    }
                }

                float fur = 0.82 + 0.18 * (0.5 + 0.5 * sin((p.x * 2.3 + p.y * 5.1 + _Seed) * 6.28318));
                float shaded = value * lerp(1.0, fur, _FurDetail);
                return pow(saturate(shaded), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = leopard(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
