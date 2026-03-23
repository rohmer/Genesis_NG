Shader "Hidden/Genesis/GradientLinear1"
{
    Properties
    {
        _Mask_2D("Mask", 2D) = "white" {}
        _Mask_3D("Mask", 3D) = "white" {}
        _Mask_Cube("Mask", Cube) = "white" {}

        [Enum(Disabled,0,Enabled,1)] _UseMask("Use Mask", int) = 0

        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (1,1,0,0)

        [Tooltip(Gradient direction in radians)] _Angle("Angle", Range(0, 6.283)) = 0.0
        [Tooltip(Softness of falloff)] _Softness("Softness", Range(0.1,10)) = 1.0
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.0

        [Tooltip(Offset along gradient axis)] _Offset("Offset", Range(-1,1)) = 0.0

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
            float  _Softness;
            float  _Contrast;
            float  _Offset;
            float  _Seed;
            int    _UseMask;

            SAMPLER_X(_Mask);

            // ---------------------------------------------------------
            // Rotate 2D vector
            // ---------------------------------------------------------
            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a), c = cos(a);
                return float2(c*p.x - s*p.y, s*p.x + c*p.y);
            }

            // ---------------------------------------------------------
            // Linear gradient core
            // ---------------------------------------------------------
            float gradientLinear(float2 uv)
            {
                // Scale + center
                float2 p = (uv - 0.5) * _Scale;

                // Rotate into gradient axis
                float2 q = rotate2D(p, _Angle);

                // q.x is the axis of the gradient
                float t = q.x + _Offset;

                // Normalize to 0–1
                t = saturate(t + 0.5);

                // Softness shaping (Gaussian-like)
                float g = exp(-_Softness * (1.0 - t) * (1.0 - t));

                return pow(g, _Contrast);
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv  = i.localTexcoord;
                float3 dir = i.direction;

                float v = gradientLinear(uv.xy);

                if (_UseMask)
                    v *= SAMPLE_X(_Mask, uv, dir).r;

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}