Shader "Hidden/Genesis/Sky"
{	
    Properties
    {		
        [InlineTexture]_UV_2D("Input Noise", 2D) = "white" {}
        [InlineTexture]_UV_3D("Input Noise", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Input Noise", Cube) = "white" {}

        [Tooltip(Scale of the clouds, larger is bigger clouds)]
        _cloudScale("Cloud Scale", Range(0.1,100.0)) = .25
        _cloudDark("Dark Clouds", Range(0.0,1.0)) = 0.5
        _cloudLight("Light Clouds", Range(0.0,1.0)) = 0.3
        _cloudCover("% Cloud Cover", Range(0.0,1.0)) = 0.3
        _cloudAlpha("Cloud Transparancy", Range(0.1,25)) = 8.0
        _skyTint("Tint of Sky", Range(0.0,1.0)) = 0.5
        [GenesisColorProperty]_skyColor1("Sky Color 1", Color) = (0.2,0.4,0.6,1.0)
        [GenesisColorProperty]_skyColor2("Sky Color 2", Color) = (0.4,0.7,1.0,1.0)
        _Seed("Seed", Float) = 52
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

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            TEXTURE_SAMPLER_X(_UV);

            float _cloudCover, _cloudDark, _cloudLight, _cloudScale, _skyTint, _cloudAlpha;
            float4 _skyColor1, _skyColor2;
            float _Seed;

            static const float K1 = 0.366025404f;
            static const float K2 = 0.211324865f;

            static const float2x2 m = float2x2(1.6, 1.2,
                                               -1.2, 1.6);

            float2 hash(float2 p)
            {
                p = float2(
                    dot(p, float2(127.1, 311.7)),
                    dot(p, float2(269.5, 183.3))
                );
                return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
            }

            float noise(float2 p)
            {
                float2 i = floor(p + (p.x + p.y) * K1);
                float2 a = p - i + (i.x + i.y) * K2;

                float2 o = (a.x > a.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
                float2 b = a - o + K2;
                float2 c = a - 1.0 + 2.0 * K2;

                float3 h = max(0.5 - float3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
                float3 h4 = h * h * h * h;

                float3 n = h4 * float3(
                    dot(a, hash(i + float2(0.0, 0.0))),
                    dot(b, hash(i + o)),
                    dot(c, hash(i + float2(1.0, 1.0)))
                );

                return dot(n, float3(70.0, 70.0, 70.0));
            }

            float fbm(float2 n)
            {
                float total = 0.0;
                float amplitude = 0.1;

                for (int i = 0; i < 7; i++)
                {
                    total += noise(n) * amplitude;
                    n = mul(m, n);
                    amplitude *= 0.4;
                }

                return total;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 p = i.localTexcoord.xy;      // 0–1 UV
                float2 uv = p * 2.0;

                float time = _Seed * 0.01;

                float q = fbm(uv * _cloudScale * 0.5);

                float r = 0.0;
                uv *= _cloudScale;
                uv -= q - time;

                float weight = 0.8;
                for (int j = 0; j < 8; j++)
                {
                    r += abs(weight * noise(uv));
                    uv = mul(m, uv) + time;
                    weight *= 0.7;
                }

                float f = 0.0;
                uv = p * 2.0;
                uv *= _cloudScale;
                uv -= q - time;
                weight = 0.7;
                for (int j = 0; j < 8; j++)
                {
                    f += weight * noise(uv);
                    uv = mul(m, uv) + time;
                    weight *= 0.6;
                }
                f *= r + f;

                float c = 0.0;
                time = _Seed * 0.01;
                uv = p * 2.0;
                uv *= _cloudScale * 2.0;
                uv -= q - time;
                weight = 0.4;
                for (int j = 0; j < 7; j++)
                {
                    c += weight * noise(uv);
                    uv = mul(m, uv) + time;
                    weight *= 0.6;
                }

                float c1 = 0.0;
                time = _Seed * (1.0 / 80.0);
                uv = p * 2.0;
                uv *= _cloudScale * 3.0;
                uv -= q - time;
                weight = 0.4;
                for (int j = 0; j < 7; j++)
                {
                    c1 += abs(weight * noise(uv));
                    uv = mul(m, uv) + time;
                    weight *= 0.6;
                }
                c += c1;

                float3 skyColor = lerp(_skyColor2.rgb, _skyColor1.rgb, p.y);
                float3 cloudColor = float3(1.1, 1.1, 0.9) * saturate(_cloudDark + _cloudLight * c);

                f = _cloudCover + _cloudAlpha * f * r;

                float3 result = lerp(
                    skyColor,
                    saturate(_skyTint * skyColor + cloudColor),
                    saturate(f + c)
                );

                return float4(result, 1.0);
            }

            ENDHLSL
        }				
    }
}