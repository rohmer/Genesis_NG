Shader "Hidden/Genesis/GradientLinear3"
{
    Properties
    {
        _Mask_2D("Mask", 2D) = "white" {}
        _Mask_3D("Mask", 3D) = "white" {}
        _Mask_Cube("Mask", Cube) = "white" {}

        [Enum(Disabled,0,Enabled,1)] _UseMask("Use Mask", int) = 0

        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (1,1,0,0)

        [Tooltip(Gradient direction in radians)] _Angle("Angle", Range(0, 6.283)) = 0.0
        [Tooltip(Offset along gradient axis)] _Offset("Offset", Range(-1,1)) = 0.0

        [Tooltip(Softness of interpolation)] _Softness("Softness", Range(0.01,10)) = 1.0
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.0

        [Tooltip(Position of Stop A)] _PosA("Pos A", Range(0,1)) = 0.0
        [Tooltip(Position of Stop B)] _PosB("Pos B", Range(0,1)) = 0.5
        [Tooltip(Position of Stop C)] _PosC("Pos C", Range(0,1)) = 1.0

        [Tooltip(Value at Stop A)] _ValA("Val A", Range(0,1)) = 0.0
        [Tooltip(Value at Stop B)] _ValB("Val B", Range(0,1)) = 0.5
        [Tooltip(Value at Stop C)] _ValC("Val C", Range(0,1)) = 1.0

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

            float2 _Scale;
            float  _Angle;
            float  _Offset;
            float  _Softness;
            float  _Contrast;

            float _PosA, _PosB, _PosC;
            float _ValA, _ValB, _ValC;

            float _Seed;
            int   _UseMask;

            SAMPLER_X(_Mask);

            // ---------------------------------------------------------
            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a), c = cos(a);
                return float2(c*p.x - s*p.y, s*p.x + c*p.y);
            }

            // Smooth interpolation with softness
            float smoothLerp(float a, float b, float t, float softness)
            {
                t = saturate(t);
                t = pow(t, softness);
                return lerp(a, b, t);
            }

            // ---------------------------------------------------------
            // Gradient Linear 3 core
            // ---------------------------------------------------------
            float gradientLinear3(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                float2 q = rotate2D(p, _Angle);

                float t = q.x + _Offset + 0.5;
                t = saturate(t);

                // Segment A → B
                float segAB = smoothLerp(_ValA, _ValB,
                                         saturate((t - _PosA) / max(_PosB - _PosA, 1e-4)),
                                         _Softness);

                // Segment B → C
                float segBC = smoothLerp(_ValB, _ValC,
                                         saturate((t - _PosB) / max(_PosC - _PosB, 1e-4)),
                                         _Softness);

                // Blend between the two segments
                float mid = saturate((t - _PosA) / max(_PosC - _PosA, 1e-4));
                float v = lerp(segAB, segBC, mid);

                return pow(v, _Contrast);
            }

            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv  = i.localTexcoord;
                float3 dir = i.direction;

                float v = gradientLinear3(uv.xy);

                if (_UseMask)
                    v *= SAMPLE_X(_Mask, uv, dir).r;

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}