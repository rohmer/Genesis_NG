Shader "Hidden/Genesis/BlueNoise"
{
    Properties
    {
        [Tooltip(Frequency and tiling of the blue noise)]
        _Scale("Scale", Float) = 32.0

        [Tooltip(Offset in noise space)]
        _Offset("Offset", Vector) = (0,0,0,0)

        [Tooltip(Contrast shaping)]
        _Contrast("Contrast", Range(0.5,4)) = 1.0

        [Tooltip(Amplitude)]
        _Amplitude("Amplitude", Range(0,2)) = 1.0
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

            float _Scale;
            float4 _Offset;
            float _Contrast;
            float _Amplitude;

            // ---------------------------------------------------------
            // Blue-noise inspired hash (tile-free, decorrelated)
            float hash(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 34.345);
                return frac(p.x * p.y);
            }

            // Poisson-like blue noise kernel
            float blueNoise2D(float2 uv)
            {
                float2 p = uv * _Scale + _Offset.xy;

                float v = 0.0;
                float w = 0.0;

                // 8-tap Poisson kernel
                const float2 K[8] = {
                    float2( 0.75,  0.12),
                    float2(-0.33,  0.88),
                    float2( 0.55, -0.66),
                    float2(-0.88, -0.22),
                    float2( 0.22,  0.44),
                    float2(-0.44,  0.55),
                    float2( 0.66, -0.33),
                    float2(-0.12, -0.75)
                };

                [unroll]
                for (int i = 0; i < 8; i++)
                {
                    float h = hash(p + K[i]);
                    v += h;
                    w += 1.0;
                }

                return v / w;
            }

            // ---------------------------------------------------------
            float evaluateNoise(float3 uv)
            {
                float2 p = uv.xy;
                float v = blueNoise2D(p);

                v = pow(v, _Contrast);
                v *= _Amplitude;

                return saturate(v);
            }

            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float v = evaluateNoise(i.localTexcoord.xyz);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}