Shader "Hidden/Genesis/ShapeSplatterCircularSpiral"
{
    Properties
    {
        _Shape_2D("Shape", 2D) = "white" {}
        _Shape_3D("Shape", 3D) = "white" {}
        _Shape_Cube("Shape", Cube) = "white" {}

        [Enum(Disabled,0,Enabled,1)] _UseShape("Use Shape", int) = 1

        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (1,1,0,0)

        [Tooltip(Number of shapes along spiral)] _Count("Count", Range(1,256)) = 64

        [Tooltip(Base radius at start of spiral)] _StartRadius("Start Radius", Range(0,1)) = 0.05
        [Tooltip(Radius growth per step)] _RadiusStep("Radius Step", Range(0,1)) = 0.01

        [Tooltip(Angular step per instance)] _AngleStep("Angle Step", Range(0,6.283)) = 0.25

        [Tooltip(Random radial jitter)] _RadialJitter("Radial Jitter", Range(0,1)) = 0.1
        [Tooltip(Random angular jitter)] _AngularJitter("Angular Jitter", Range(0,1)) = 0.1

        [Tooltip(Random rotation per instance)] _RotJitter("Rotation Jitter", Range(0,6.283)) = 3.14
        [Tooltip(Min scale)] _ScaleMin("Scale Min", Range(0.01,2)) = 0.5
        [Tooltip(Max scale)] _ScaleMax("Scale Max", Range(0.01,2)) = 1.2

        [Tooltip(Blend softness)] _BlendSoftness("Blend Softness", Range(0,1)) = 0.2
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
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders//GenesisFixed.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            SAMPLER_X(_Shape);

            float2 _Scale;
            float  _Count;

            float  _StartRadius;
            float  _RadiusStep;
            float  _AngleStep;

            float  _RadialJitter;
            float  _AngularJitter;

            float  _RotJitter;
            float  _ScaleMin;
            float  _ScaleMax;

            float  _BlendSoftness;
            float  _Contrast;

            float  _Seed;
            int    _UseShape;

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

            float sampleShape(float2 uv, float2 center, float angle, float scale, float3 dir)
            {
                float2 p = uv - center;
                p = rotate2D(p, angle);
                p /= scale;
                p += 0.5;

                return SAMPLE_X(_Shape, float3(p, 0), dir).r;
            }

            // ---------------------------------------------------------
            float shapeSplatterCircularSpiral(float3 uv, float3 dir)
            {
                if (_UseShape == 0)
                    return 0.0;

                float2 p = (uv.xy - 0.5) * _Scale;

                float outV = 0.0;
                float count = max(_Count, 1.0);

                [loop]
                for (int i = 0; i < (int)count; i++)
                {
                    float fi = (float)i;

                    // Spiral progression
                    float baseAngle = fi * _AngleStep;
                    float baseRadius = _StartRadius + fi * _RadiusStep;

                    // Random jitter
                    float2 rnd = hash21(float2(fi, fi * 31.0));

                    float angle = baseAngle + (rnd.x * 2.0 - 1.0) * _AngularJitter;
                    float radius = baseRadius + (rnd.y * 2.0 - 1.0) * _RadialJitter;

                    // Spiral position
                    float2 center = float2(cos(angle), sin(angle)) * radius;

                    // Random rotation
                    float rot = (rnd.x * 2.0 - 1.0) * _RotJitter;

                    // Random scale
                    float scale = lerp(_ScaleMin, _ScaleMax, rnd.y);

                    // Sample shape
                    float v = sampleShape(p, center, rot, scale, dir);

                    // Soft max blend
                    outV = max(outV, v * (1.0 - _BlendSoftness) + outV * _BlendSoftness);
                }

                return pow(outV, _Contrast);
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv  = i.localTexcoord;
                float3 dir = i.direction;

                float v = shapeSplatterCircularSpiral(uv, dir);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}