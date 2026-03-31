Shader "Hidden/Genesis/ShapeMapper"
{
    Properties
    {
        _Shape_2D("Shape", 2D) = "white" {}
        _Shape_3D("Shape", 3D) = "white" {}
        _Shape_Cube("Shape", Cube) = "white" {}

        [Enum(Disabled,0,Enabled,1)] _UseShape("Use Shape", int) = 1

        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (1,1,0,0)

        // Input stops
        _InA("In A", Range(0,1)) = 0.00
        _InB("In B", Range(0,1)) = 0.25
        _InC("In C", Range(0,1)) = 0.50
        _InD("In D", Range(0,1)) = 0.75
        _InE("In E", Range(0,1)) = 1.00

        // Output stops
        _OutA("Out A", Range(0,1)) = 0.00
        _OutB("Out B", Range(0,1)) = 0.25
        _OutC("Out C", Range(0,1)) = 0.50
        _OutD("Out D", Range(0,1)) = 0.75
        _OutE("Out E", Range(0,1)) = 1.00

        [Tooltip(Softness of interpolation)] _Softness("Softness", Range(0.01,10)) = 1.0
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

            float _InA, _InB, _InC, _InD, _InE;
            float _OutA, _OutB, _OutC, _OutD, _OutE;

            float _Softness;
            float _Contrast;
            float _Seed;
            int   _UseShape;

            // ---------------------------------------------------------
            float smoothLerp(float a, float b, float t, float softness)
            {
                t = saturate(t);
                t = pow(t, softness);
                return lerp(a, b, t);
            }

            // ---------------------------------------------------------
            // 5‑segment remap
            // ---------------------------------------------------------
            float remap5(float v)
            {
                // Segment A → B
                float tAB = saturate((v - _InA) / max(_InB - _InA, 1e-4));
                float segAB = smoothLerp(_OutA, _OutB, tAB, _Softness);

                // Segment B → C
                float tBC = saturate((v - _InB) / max(_InC - _InB, 1e-4));
                float segBC = smoothLerp(_OutB, _OutC, tBC, _Softness);

                // Segment C → D
                float tCD = saturate((v - _InC) / max(_InD - _InC, 1e-4));
                float segCD = smoothLerp(_OutC, _OutD, tCD, _Softness);

                // Segment D → E
                float tDE = saturate((v - _InD) / max(_InE - _InD, 1e-4));
                float segDE = smoothLerp(_OutD, _OutE, tDE, _Softness);

                // Blend segments based on global position
                float t = saturate((v - _InA) / max(_InE - _InA, 1e-4));

                // Weighted blend across segments
                float v1 = lerp(segAB, segBC, saturate((v - _InA) / max(_InC - _InA, 1e-4)));
                float v2 = lerp(segCD, segDE, saturate((v - _InC) / max(_InE - _InC, 1e-4)));

                float mid = saturate((v - _InC) / max(_InE - _InA, 1e-4));
                float outV = lerp(v1, v2, mid);

                return pow(outV, _Contrast);
            }

            // ---------------------------------------------------------
            float shapeMapper5(float3 uv, float3 dir)
            {
                if (_UseShape == 0)
                    return 0.0;

                float2 p = uv.xy * _Scale;
                float v = SAMPLE_X(_Shape, float3(p, uv.z), dir).r;

                return remap5(v);
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv  = i.localTexcoord;
                float3 dir = i.direction;

                float v = shapeMapper5(uv, dir);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}