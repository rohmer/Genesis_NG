Shader "Hidden/Genesis/Tile"
{
    Properties
    {
        _Input_2D("Input", 2D) = "white" {}
        _Input_3D("Input", 3D) = "white" {}
        _Input_Cube("Input", Cube) = "white" {}

        [Enum(Disabled,0,Enabled,1)] _UseInput("Use Input", int) = 1

        [Tooltip(Tile count X,Y)] _Tiles("Tiles", Vector) = (4,4,0,0)
        [Tooltip(Global offset)] _Offset("Offset", Vector) = (0,0,0,0)

        [Tooltip(Random position jitter)] _Jitter("Jitter", Range(0,1)) = 0.0
        [Tooltip(Random rotation jitter)] _RotJitter("Rotation Jitter", Range(0,6.283)) = 0.0
        [Tooltip(Random scale min)] _ScaleMin("Scale Min", Range(0.01,2)) = 1.0
        [Tooltip(Random scale max)] _ScaleMax("Scale Max", Range(0.01,2)) = 1.0

        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.0

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
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            SAMPLER_X(_Input);

            float2 _Tiles;
            float2 _Offset;

            float  _Jitter;
            float  _RotJitter;
            float  _ScaleMin;
            float  _ScaleMax;

            float  _Contrast;
            float  _Seed;
            int    _UseInput;

            // ---------------------------------------------------------
            float hash11(float n)
            {
                n += _Seed * 17.0;
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7)) + _Seed * 13.37;
                return frac(sin(float2(n, n + 1.234)) * 43758.5453);
            }

            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a), c = cos(a);
                return float2(c*p.x - s*p.y, s*p.x + c*p.y);
            }

            // ---------------------------------------------------------
            float sampleTile(float2 uv, float2 tileID, float3 dir)
            {
                float2 rnd = hash21(tileID);

                // Random jitter
                float2 jitter = (rnd - 0.5) * _Jitter;

                // Random rotation
                float angle = (rnd.x * 2.0 - 1.0) * _RotJitter;

                // Random scale
                float scale = lerp(_ScaleMin, _ScaleMax, rnd.y);

                // Apply transforms
                float2 p = uv - 0.5 + jitter;
                p = rotate2D(p, angle);
                p /= scale;
                p += 0.5;

                return SAMPLE_X(_Input, float3(p, 0), dir).r;
            }

            // ---------------------------------------------------------
            float tile(float3 uv, float3 dir)
            {
                if (_UseInput == 0)
                    return 0.0;

                float2 tiles = max(_Tiles, float2(1,1));

                float2 p = uv.xy * tiles + _Offset;

                float2 tileID = floor(p);
                float2 fp = frac(p);

                float v = sampleTile(fp, tileID, dir);

                return pow(v, _Contrast);
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = tile(i.localTexcoord, i.direction);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}