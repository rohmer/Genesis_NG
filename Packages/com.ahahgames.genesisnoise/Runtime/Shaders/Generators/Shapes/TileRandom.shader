Shader "Hidden/Genesis/TileRandom"
{
    Properties
    {
        // --- Shape array ---
        _ShapeCount("Shape Count", int) = 3

        _Shape0_2D("Shape 0", 2D) = "white" {}
        _Shape1_2D("Shape 1", 2D) = "white" {}
        _Shape2_2D("Shape 2", 2D) = "white" {}
        _Shape3_2D("Shape 3", 2D) = "white" {}
        _Shape4_2D("Shape 4", 2D) = "white" {}

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
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            // --- Shape samplers ---
            SAMPLER_X(_Shape0);
            SAMPLER_X(_Shape1);
            SAMPLER_X(_Shape2);
            SAMPLER_X(_Shape3);
            SAMPLER_X(_Shape4);

            float2 _Tiles;
            float2 _Offset;

            float  _Jitter;
            float  _RotJitter;
            float  _ScaleMin;
            float  _ScaleMax;

            float  _Contrast;
            float  _Seed;

            int    _ShapeCount;

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
            float sampleShapeN(int idx, float2 uv, float3 dir)
            {
                if (idx == 0) return SAMPLE_X(_Shape0, float3(uv,0), dir).r;
                if (idx == 1) return SAMPLE_X(_Shape1, float3(uv,0), dir).r;
                if (idx == 2) return SAMPLE_X(_Shape2, float3(uv,0), dir).r;
                if (idx == 3) return SAMPLE_X(_Shape3, float3(uv,0), dir).r;
                return SAMPLE_X(_Shape4, float3(uv,0), dir).r;
            }

            // ---------------------------------------------------------
            float tileRandom(float3 uv, float3 dir)
            {
                float2 tiles = max(_Tiles, float2(1,1));

                float2 p = uv.xy * tiles + _Offset;

                float2 tileID = floor(p);
                float2 fp = frac(p);

                // Random selection per tile
                float2 rnd = hash21(tileID);

                int shapeIdx = (int)floor(rnd.x * _ShapeCount);

                // Random jitter
                float2 jitter = (rnd - 0.5) * _Jitter;

                // Random rotation
                float angle = (rnd.x * 2.0 - 1.0) * _RotJitter;

                // Random scale
                float scale = lerp(_ScaleMin, _ScaleMax, rnd.y);

                // Apply transforms
                float2 q = fp - 0.5 + jitter;
                q = rotate2D(q, angle);
                q /= scale;
                q += 0.5;

                float v = sampleShapeN(shapeIdx, q, dir);

                return pow(v, _Contrast);
            }

            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float v = tileRandom(i.localTexcoord, i.direction);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}