Shader "Hidden/Genesis/AnisotropicNoise2"
{
    Properties
    {
        [GenesisVector2]_Scale("Base Scale", Vector) = (4,4,0,0)
        _Anisotropy("Anisotropy", Range(0,1)) = 0.85
        _Rotation("Direction (Radians)", Range(0,6.283)) = 0.0
        _Warp("Warp Amount", Range(0,1)) = 0.55
        _Turbulence("Turbulence", Range(0,2)) = 0.8
        _MicroDetail("Micro Detail Strength", Range(0,1)) = 0.6
        _Contrast("Contrast", Range(0.5,4)) = 1.5
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
            float  _Anisotropy;
            float  _Rotation;
            float  _Warp;
            float  _Turbulence;
            float  _MicroDetail;
            float  _Contrast;

            float hash11(float n)
            {
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7));
                return frac(sin(float2(n, n + 1.234)) * 43758.5453);
            }

            float2x2 rot2(float a)
            {
                float c = cos(a);
                float s = sin(a);
                return float2x2(c, -s, s, c);
            }

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

            float anisotropicFBM2(float2 uv)
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

                    float2 warpN = hash21(p * 2.5);
                    p += (warpN - 0.5) * _Warp * (1.0 + _Turbulence * 0.5);

                    float n = gradNoise(p);
                    n = abs(n);
                    v += n * amp;

                    uv *= 2.0;
                    amp *= 0.55;
                }

                return v;
            }

            float microFibers2(float2 uv)
            {
                float2 p = uv;
                p = mul(p, rot2(_Rotation));
                p *= float2(48, 3);

                float f = gradNoise(p * 1.3);
                f = abs(f);
                f = pow(f, 2.5);

                return f * _MicroDetail;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy * _Scale;

                float base = anisotropicFBM2(uv);
                float micro = microFibers2(uv);

                float v = base + micro;

                v = v * 0.5 + 0.5;
                v = pow(v, _Contrast);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}