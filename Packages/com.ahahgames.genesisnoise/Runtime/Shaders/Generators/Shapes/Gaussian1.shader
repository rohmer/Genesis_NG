Shader "Hidden/Genesis/Gaussian1"
{
    Properties
    {
        _Mask_2D("Mask", 2D) = "white" {}
        _Mask_3D("Mask", 3D) = "white" {}
        _Mask_Cube("Mask", Cube) = "white" {}

        [Enum(Disabled,0,Enabled,1)] _UseMask("Use Mask", int) = 0

        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (1,1,0,0)

        [Tooltip(Softness of Gaussian falloff)] _Softness("Softness", Range(0.5,10)) = 3.0
        [Tooltip(Min radius)] _RadiusMin("Radius Min", Range(0.01,1)) = 0.15
        [Tooltip(Max radius)] _RadiusMax("Radius Max", Range(0.01,1)) = 0.35

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

            float2 _Scale;
            float  _Softness;
            float  _RadiusMin;
            float  _RadiusMax;
            float  _Contrast;
            float  _Seed;
            int    _UseMask;

            SAMPLER_X(_Mask);

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
            // Gaussian falloff
            // ---------------------------------------------------------
            float gaussian(float d, float r, float softness)
            {
                float x = d / r;
                return exp(-softness * x * x);
            }

            // ---------------------------------------------------------
            // Gaussian1 core
            // ---------------------------------------------------------
            float gaussian1(float2 uv)
            {
                float2 p = uv * _Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);

                float2 rnd = hash21(ip);

                // Random radius
                float radius = lerp(_RadiusMin, _RadiusMax,
                                    hash11(dot(ip, float2(91.7, 12.3))));

                float d = distance(fp, rnd);

                float g = gaussian(d, radius, _Softness);

                return pow(g, _Contrast);
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv  = i.localTexcoord;
                float3 dir = i.direction;

                float v = gaussian1(uv.xy);

                if (_UseMask)
                    v *= SAMPLE_X(_Mask, uv, dir).r;

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        } 
    }
}