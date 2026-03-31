Shader "Hidden/Genesis/Clouds4"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (4,4,0,0)

        _Direction("Direction XY", Vector) = (1,0,0,0)
        _Anisotropy("Anisotropy", Range(1,20)) = 8.0

        _WarpAmount("Warp Amount", Range(0,1)) = 0.35
        _WarpScale("Warp Scale", Range(1,20)) = 6.0

        _Softness("Softness", Range(1,8)) = 2.0
        _Contrast("Contrast", Range(0.5,4.0)) = 1.4
        _Offset("Value Offset", Range(-1,1)) = 0.0
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
            #pragma shader_feature _ USE_CUSTOM_UV

            float2 _Scale;

            float4 _Direction;
            float _Anisotropy;

            float _WarpAmount;
            float _WarpScale;

            float _Softness;
            float _Contrast;
            float _Offset;

            // ---------------------------------------------------------
            // Hash + Noise
            // ---------------------------------------------------------
            float hash11(float n)
            {
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7));
                return frac(sin(float2(n, n + 1.234)) * 43758.5453);
            }

            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                float2 u = f * f * (3.0 - 2.0 * f);

                float a = hash11(i.x + i.y * 57.0);
                float b = hash11(i.x + 1.0 + i.y * 57.0);
                float c = hash11(i.x + (i.y + 1.0) * 57.0);
                float d = hash11(i.x + 1.0 + (i.y + 1.0) * 57.0);

                return lerp(lerp(a,b,u.x), lerp(c,d,u.x), u.y);
            }

            // ---------------------------------------------------------
            // Directional anisotropic FBM (Clouds 4 style)
            // ---------------------------------------------------------
            float fbm_clouds4(float2 p)
            {
                float2 dir = normalize(_Direction.xy + 1e-5);
                float2 nrm = float2(-dir.y, dir.x);

                // Stretch along direction
                float2 ap = float2(
                    dot(p, dir) * _Anisotropy,
                    dot(p, nrm)
                );

                float v = 0.0;
                float a = 0.55;
                float f = 1.0;

                [unroll]
                for (int i = 0; i < 5; i++)
                {
                    v += noise(ap * f) * a;
                    f *= 2.0;
                    a *= 0.55;
                }

                return v;
            }

            // ---------------------------------------------------------
            // Warp (adds turbulent wisps)
            // ---------------------------------------------------------
            float2 warp(float2 uv)
            {
                float w = fbm_clouds4(uv * _WarpScale);
                return (w - 0.5) * _WarpAmount * 0.5;
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy * _Scale;

                // Apply directional warp
                uv += warp(uv);

                float n = fbm_clouds4(uv);

                // Soft shaping
                n = pow(n, _Softness);

                // Offset + contrast
                n = saturate(n + _Offset);
                n = pow(n, _Contrast);

                return float4(n, n, n, 1.0);
            }

            ENDHLSL
        }
    }
}