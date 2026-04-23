Shader "Hidden/Genesis/Simplex2D"
{
    Properties
    {
        [Tooltip(Frequency and tiling)] _Scale("Scale", Vector) = (4,4,0,0)
        [Tooltip(Offset in noise space)] _Offset("Offset", Vector) = (0,0,0,0)

        [Tooltip(Amplitude)] _Amplitude("Amplitude", Range(0,2)) = 1.0
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.0
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
            float2 _Offset;
            float  _Amplitude;
            float  _Contrast;

            // ---------------------------------------------------------
            // IQ hash (converted from GLSL)
            float2 hashIQ(float2 p)
            {
                float2 q = float2(
                    dot(p, float2(127.1, 311.7)),
                    dot(p, float2(269.5, 183.3))
                );

                return -1.0 + 2.0 * frac(sin(q) * 43758.5453123);
            }

            // ---------------------------------------------------------
            // IQ Simplex Noise 2D (converted from GLSL)
            float simplexIQ(float2 p)
            {
                const float K1 = 0.366025404; // (sqrt(3)-1)/2
                const float K2 = 0.211324865; // (3-sqrt(3))/6

                float2 i = floor(p + (p.x + p.y) * K1);
                float2 a = p - i + (i.x + i.y) * K2;

                float m = step(a.y, a.x);
                float2 o = float2(m, 1.0 - m);

                float2 b = a - o + K2;
                float2 c = a - 1.0 + 2.0 * K2;

                float3 h = max(0.5 - float3(
                    dot(a, a),
                    dot(b, b),
                    dot(c, c)
                ), 0.0);

                h = h * h;
                h = h * h;

                float3 g = float3(
                    dot(a, hashIQ(i + 0.0)),
                    dot(b, hashIQ(i + o)),
                    dot(c, hashIQ(i + 1.0))
                );

                return dot(h, g) * 70.0;
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;
                float2 p = uv * _Scale + _Offset;

                float v = simplexIQ(p);

                v = 0.5 + 0.5 * v;       // normalize to [0,1]
                v *= _Amplitude;
                v = saturate(pow(v, _Contrast));

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}