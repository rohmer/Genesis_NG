Shader "Hidden/Genesis/Mesh2"
{
    Properties
    {
        _Mask_2D("Mask", 2D) = "white" {}
        _Mask_3D("Mask", 3D) = "white" {}
        _Mask_Cube("Mask", Cube) = "white" {}

        [Enum(Disabled,0,Enabled,1)] _UseMask("Use Mask", int) = 0

        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (8,8,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Line thickness)] _LineWidth("Line Width", Range(0.001,0.5)) = 0.05
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
            float  _Angle;
            float  _LineWidth;
            float  _Contrast;
            float  _Seed;
            int    _UseMask;

            SAMPLER_X(_Mask);

            // ---------------------------------------------------------
            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a), c = cos(a);
                return float2(c*p.x - s*p.y, s*p.x + c*p.y);
            }

            // ---------------------------------------------------------
            // Hex grid coordinate transform
            // ---------------------------------------------------------
            float3 hexCoords(float2 p)
            {
                // Axial hex basis
                const float2 e0 = float2(1.0, 0.0);
                const float2 e1 = float2(0.5, 0.8660254); // sqrt(3)/2

                float2 uv = float2(dot(p, e0), dot(p, e1));

                float2 f = frac(uv);
                float2 i = floor(uv);

                // Convert to barycentric-like coords for hex edges
                float3 b = float3(f.x, f.y, 1.0 - f.x - f.y);

                // Fold into hex cell
                if (b.z < 0.0)
                {
                    b = float3(1.0 - f.x, 1.0 - f.y, f.x + f.y - 1.0);
                }

                return abs(b);
            }

            // ---------------------------------------------------------
            // Mesh 2 core (hex mesh)
            // ---------------------------------------------------------
            float mesh2(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float3 b = hexCoords(p);

                // Distance to nearest edge
                float d = min(b.x, min(b.y, b.z));

                // Line mask
                float v = smoothstep(_LineWidth, 0.0, d);

                return pow(v, _Contrast);
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv  = i.localTexcoord;
                float3 dir = i.direction;

                float v = mesh2(uv.xy);

                if (_UseMask)
                    v *= SAMPLE_X(_Mask, uv, dir).r;

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}