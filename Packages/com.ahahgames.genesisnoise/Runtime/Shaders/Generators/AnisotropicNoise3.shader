Shader "Hidden/Genesis/Noise3"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (3,3,0,0)
        _Flow("Flow Strength", Range(0,2)) = 0.6
        _Turbulence("Turbulence", Range(0,2)) = 1.0
        _Anisotropy("Anisotropy", Range(0,1)) = 0.5
        _Rotation("Direction (Radians)", Range(0,6.283)) = 0.0
        _Contrast("Contrast", Range(0.5,4)) = 1.3
        _Softness("Softness", Range(0.5,4)) = 1.2
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
            float  _Flow;
            float  _Turbulence;
            float  _Anisotropy;
            float  _Rotation;
            float  _Contrast;
            float  _Softness;

            // ---------------------------------------------------------
            // Hash helpers
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

            // ---------------------------------------------------------
            // Rotation
            // ---------------------------------------------------------
            float2x2 rot2(float a)
            {
                float c = cos(a);
                float s = sin(a);
                return float2x2(c, -s, s, c);
            }

            // ---------------------------------------------------------
            // Gradient noise
            // ---------------------------------------------------------
            float gradNoise(float2 p)
            {
                float2 ip = floor(p);
                float2 fp = frac(p);

                float2 g00 = hash21(ip + float2(0,0)) * 2 - 1;
                float2 g10 = hash21(ip + float2(1,0)) * 2 - 1;
                float2 g01 = hash21(ip + float2(0,1)) * 2 - 1;
                float2 g11 = hash21(ip + float2(1,1)) * 2 - 1;

                float d00 = dot(g00, fp - float2(0,0));
                float d10 = dot(g10, fp - float2(1,0));
                float d01 = dot(g01, fp - float2(0,1));
                float d11 = dot(g11, fp - float2(1,1));

                float2 u = fp * fp * (3 - 2 * fp);

                return lerp(lerp(d00, d10, u.x),
                            lerp(d01, d11, u.x),
                            u.y);
            }

            // ---------------------------------------------------------
            // Flow warp (soft, painterly)
            // ---------------------------------------------------------
            float2 flowWarp(float2 uv)
            {
                float2 n = hash21(floor(uv * 4.0));
                return (n - 0.5) * _Flow;
            }

            // ---------------------------------------------------------
            // Noise 3: Volumetric Flow Noise
            // ---------------------------------------------------------
            float noise3(float2 uv)
            {
                float2 dir = float2(1,0);
                dir = mul(dir, rot2(_Rotation));

                float2 stretch = float2(1 + _Anisotropy, 1 - _Anisotropy);

                float2x2 A = float2x2(
                    dir.x * stretch.x, -dir.y * stretch.y,
                    dir.y * stretch.x,  dir.x * stretch.y
                );

                float v = 0.0;
                float amp = 0.7;

                [unroll]
                for (int i = 0; i < 6; i++)
                {
                    float2 p = mul(uv, A);

                    // Flow warp
                    p += flowWarp(p);

                    // Turbulence warp
                    float2 t = hash21(p * 3.0);
                    p += (t - 0.5) * _Turbulence * 0.25;

                    float n = gradNoise(p);
                    n = abs(n); // soft cellular breakup

                    v += pow(n, _Softness) * amp;

                    uv *= 2.0;
                    amp *= 0.55;
                }

                return v;
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy * _Scale;

                float v = noise3(uv);

                v = v * 0.5 + 0.5;
                v = pow(v, _Contrast);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}