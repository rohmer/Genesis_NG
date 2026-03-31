Shader "Hidden/Genesis/ShapeSplatter"
{
    Properties
    {
        _Shape_2D("Shape", 2D) = "white" {}
        _Shape_3D("Shape", 3D) = "white" {}
        _Shape_Cube("Shape", Cube) = "white" {}

        [Enum(Disabled,0,Enabled,1)] _UseShape("Use Shape", int) = 1

        [Tooltip(Global tiling of splatter grid)] _Scale("Scale", Vector) = (8,8,0,0)

        [Tooltip(Number of shapes per cell)] _Density("Density", Range(1,16)) = 4

        [Tooltip(Random position jitter)] _Jitter("Jitter", Range(0,1)) = 0.4
        [Tooltip(Random rotation)] _RotJitter("Rotation Jitter", Range(0,6.283)) = 3.14
        [Tooltip(Random scale range min)] _ScaleMin("Scale Min", Range(0.01,2)) = 0.4
        [Tooltip(Random scale range max)] _ScaleMax("Scale Max", Range(0.01,2)) = 1.2

        [Tooltip(Blend softness)] _BlendSoftness("Blend Softness", Range(0.0,1.0)) = 0.2
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.0

        [Tooltip(Randomization seed)] _Seed("Seed", int) = 52
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

            SAMPLER_X(_Shape);

            float2 _Scale;
            float  _Density;
            float  _Jitter;
            float  _RotJitter;
            float  _ScaleMin;
            float  _ScaleMax;
            float  _BlendSoftness;
            float  _Contrast;
            float  _Seed;
            int    _UseShape;

            // ---------------------------------------------------------
            // Hash helpers
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

            // ---------------------------------------------------------
            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a), c = cos(a);
                return float2(c*p.x - s*p.y, s*p.x + c*p.y);
            }

            // ---------------------------------------------------------
            // Sample shape with transform
            // ---------------------------------------------------------
            float sampleShape(float2 uv, float2 center, float angle, float scale, float3 dir)
            {
                float2 p = uv - center;
                p = rotate2D(p, angle);
                p /= scale;
                p += 0.5;

                return SAMPLE_X(_Shape, float3(p, 0), dir).r;
            }

            // ---------------------------------------------------------
            // Shape Splatter core
            // ---------------------------------------------------------
            float shapeSplatter(float3 uv, float3 dir)
            {
                if (_UseShape == 0)
                    return 0.0;

                float2 p = uv.xy * _Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);

                float outV = 0.0;

                // Loop over density
                [loop]
                for (int i = 0; i < (int)_Density; i++)
                {
                    float2 seed = ip + float2(i * 17.0, i * 31.0);

                    float2 rnd = hash21(seed);

                    // Random position inside cell
                    float2 center = rnd * _Jitter + 0.5 * (1.0 - _Jitter);

                    // Random rotation
                    float angle = (rnd.x * 2.0 - 1.0) * _RotJitter;

                    // Random scale
                    float scale = lerp(_ScaleMin, _ScaleMax, rnd.y);

                    // Sample shape
                    float v = sampleShape(fp, center, angle, scale, dir);

                    // Blend (soft max)
                    outV = max(outV, v * (1.0 - _BlendSoftness) + outV * _BlendSoftness);
                }

                return pow(outV, _Contrast);
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv  = i.localTexcoord;
                float3 dir = i.direction;

                float v = shapeSplatter(uv, dir);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}