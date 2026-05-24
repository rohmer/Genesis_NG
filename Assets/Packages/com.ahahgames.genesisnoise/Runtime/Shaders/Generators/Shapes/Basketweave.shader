Shader "Hidden/Genesis/Basketweave"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (8,8,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Thread width inside each cell)] _Width("Width", Range(0.01,1)) = 0.62
        [Tooltip(Gap between neighboring threads)] _Gap("Gap", Range(0,1)) = 0.22
        [Tooltip(Number of adjacent threads in each over/under block)] _BlockSize("Block Size", Range(1,8)) = 2

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.5)) = 0.04
        [Tooltip(Rounded thread highlight)] _Ridge("Ridge", Range(0,1)) = 0.35
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.0

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

            float  _Width;
            float  _Gap;
            float  _BlockSize;

            float  _Softness;
            float  _Ridge;
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

            float threadRidge(float x)
            {
                return 1.0 - saturate(abs(x - 0.5) * 2.0);
            }

            float basketweave(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float2 f = frac(p);

                float randomValue = hash11(cell.x + cell.y * 31.0);
                float jitter = (randomValue - 0.5) * _Randomness;
                float width = saturate(_Width + jitter * 0.2);

                float horizontal = stripe(f.y, width, _Softness);
                float vertical = stripe(f.x, width, _Softness);

                float blockSize = max(1.0, round(_BlockSize));
                float blockX = floor(cell.x / blockSize);
                float blockY = floor(cell.y / blockSize);
                float alternation = positiveModulo(blockX + blockY, 2.0);
                float horizontalOver = 1.0 - step(1.0, alternation + 0.5);

                float hRidge = lerp(1.0, threadRidge(f.y), _Ridge);
                float vRidge = lerp(1.0, threadRidge(f.x), _Ridge);

                float overThread = horizontalOver * horizontal * hRidge + (1.0 - horizontalOver) * vertical * vRidge;
                float underThread = horizontalOver * vertical * vRidge + (1.0 - horizontalOver) * horizontal * hRidge;

                float overValue = overThread;
                float underValue = underThread * (1.0 - _Gap);
                float woven = max(overValue, underValue);

                return pow(saturate(woven), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = basketweave(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
