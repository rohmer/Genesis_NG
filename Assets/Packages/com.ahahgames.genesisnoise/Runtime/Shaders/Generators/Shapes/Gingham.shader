Shader "Hidden/Genesis/Gingham"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (8,8,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Width of each gingham band)] _BandWidth("Band Width", Range(0.05,0.95)) = 0.5
        [Tooltip(Darkness of single direction bands)] _BandStrength("Band Strength", Range(0,1)) = 0.45
        [Tooltip(Darkness of overlapping bands)] _OverlapStrength("Overlap Strength", Range(0,1)) = 0.9
        [Tooltip(Fine woven thread detail)] _ThreadDetail("Thread Detail", Range(0,1)) = 0.35

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.025
        [Tooltip(Woven relief amount)] _Relief("Relief", Range(0,1)) = 0.35
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.0

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.0
        [Tooltip(Random seed)] _Seed("Seed", int) = 163
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
            float  _BandStrength;
            float  _OverlapStrength;
            float  _ThreadDetail;

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

            float centeredBand(float x, float width, float softness)
            {
                float d = abs(x - 0.5);
                float edge = width * 0.5;
                return smoothstep(edge + softness, edge - softness, d);
            }

            float gingham(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f = frac(p);

                float randomValue = hash11(cell.x + cell.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;
                float bandWidth = saturate(_BandWidth + variation * 0.08);
                float softness = max(_Softness, 0.0001);

                float horizontal = centeredBand(f.y, bandWidth, softness);
                float vertical = centeredBand(f.x, bandWidth, softness);
                float overlap = horizontal * vertical;
                float singleBand = saturate(max(horizontal, vertical) - overlap);

                float baseValue = 1.0;
                baseValue -= singleBand * _BandStrength;
                baseValue -= overlap * _OverlapStrength;

                float threadX = 0.5 + 0.5 * sin((p.x + variation) * 6.28318 * 4.0);
                float threadY = 0.5 + 0.5 * sin((p.y - variation) * 6.28318 * 4.0);
                float thread = (threadX * horizontal + threadY * vertical) * 0.5;
                float threadShade = lerp(1.0, 0.82 + 0.18 * thread, _ThreadDetail);

                float ridgeX = 1.0 - saturate(abs(f.x - 0.5) * 2.0);
                float ridgeY = 1.0 - saturate(abs(f.y - 0.5) * 2.0);
                float relief = lerp(1.0, 0.78 + 0.22 * max(ridgeX * vertical, ridgeY * horizontal), _Relief);

                float value = baseValue * threadShade * relief;
                return pow(saturate(value), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = gingham(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
