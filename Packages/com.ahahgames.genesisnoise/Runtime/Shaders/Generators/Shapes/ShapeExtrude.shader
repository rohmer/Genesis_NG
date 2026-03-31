Shader "Hidden/Genesis/ShapeExtrude"
{
    Properties
    {
        _Shape_2D("Shape", 2D) = "white" {}
        _Shape_3D("Shape", 3D) = "white" {}
        _Shape_Cube("Shape", Cube) = "white" {}

        [Enum(Disabled,0,Enabled,1)] _UseShape("Use Shape", int) = 1

        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (1,1,0,0)

        [Tooltip(Direction in radians)] _Angle("Angle", Range(0, 6.283)) = 0.0
        [Tooltip(Extrusion distance in UV units)] _Distance("Distance", Range(0,1)) = 0.1
        [Tooltip(Number of samples along direction)] _Steps("Steps", Range(1,64)) = 16

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
            float  _Angle;
            float  _Distance;
            float  _Steps;
            float  _Contrast;
            float  _Seed;
            int    _UseShape;

            // ---------------------------------------------------------
            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a), c = cos(a);
                return float2(c*p.x - s*p.y, s*p.x + c*p.y);
            }

            // ---------------------------------------------------------
            // Shape Extrude core
            // ---------------------------------------------------------
            float shapeExtrude(float3 uv, float3 dir)
            {
                if (_UseShape == 0)
                    return 0.0;

                float2 baseUV = uv.xy * _Scale;

                float2 stepDir = float2(cos(_Angle), sin(_Angle));
                float2 delta   = stepDir * (_Distance / max(_Steps, 1.0));

                float v = 0.0;
                float2 p = baseUV;

                // Directional max sampling (shape expansion)
                [loop]
                for (int i = 0; i < (int)_Steps; i++)
                {
                    float s = SAMPLE_X(_Shape, float3(p, uv.z), dir).r;
                    v = max(v, s);
                    p += delta;
                }

                return pow(v, _Contrast);
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv  = i.localTexcoord;
                float3 dir = i.direction;

                float v = shapeExtrude(uv, dir);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}