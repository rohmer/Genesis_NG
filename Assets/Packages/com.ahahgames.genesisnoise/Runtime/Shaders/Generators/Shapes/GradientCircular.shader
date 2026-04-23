Shader "Hidden/Genesis/GradientCircular"
{
    Properties
    {
        _Mask_2D("Mask", 2D) = "white" {}
        _Mask_3D("Mask", 3D) = "white" {}
        _Mask_Cube("Mask", Cube) = "white" {}

        [Enum(Disabled,0,Enabled,1)] _UseMask("Use Mask", int) = 0

        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (1,1,0,0)

        [Tooltip(Center of gradient)] [GenesisVector2]_Center("Center", Vector) = (0.5,0.5,0,0)

        [Tooltip(Radius of gradient)] _Radius("Radius", Range(0.01,2)) = 0.5
        [Tooltip(Softness of falloff)] _Softness("Softness", Range(0.1,10)) = 3.0
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
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            float2 _Scale;
            float2 _Center;
            float  _Radius;
            float  _Softness;
            float  _Contrast;
            float  _Seed;
            int    _UseMask;

            SAMPLER_X(_Mask);

            // ---------------------------------------------------------
            // Radial gradient falloff
            // ---------------------------------------------------------
            float radialGradient(float2 uv)
            {
                float2 p = (uv - _Center) * _Scale;
                float d = length(p);

                float x = saturate(d / max(_Radius, 1e-4));

                // Gaussian‑style smooth falloff
                float g = exp(-_Softness * x * x);

                return pow(g, _Contrast);
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv  = i.localTexcoord;
                float3 dir = i.direction;

                float v = radialGradient(uv.xy);

                if (_UseMask)
                    v *= SAMPLE_X(_Mask, uv, dir).r;

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}