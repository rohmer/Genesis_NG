Shader "Hidden/Genesis/HeightBlend"
{
    Properties
    {
        [Tooltip(Height or grayscale input A)]
        _A("A", 2D) = "white" {}

        [Tooltip(Height or grayscale input B)]
        _B("B", 2D) = "white" {}

        [Tooltip(Blend amount)]
        _Blend("Blend", Float) = 0.5

        [Tooltip(Height offset for B relative to A)]
        _HeightOffset("Height Offset", Float) = 0.0
          
        [Tooltip(Height contrast shaping)]
        _Contrast("Contrast", Float) = 1.0

        [Tooltip(Softness of the transition)]
        _Softness("Softness", Float) = 0.1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            sampler2D _A;
            sampler2D _B;

            float _Blend;
            float _HeightOffset;
            float _Contrast;
            float _Softness;

            // ---------------------------------------------------------
            // Height Blend Core
            // ---------------------------------------------------------
            float heightBlend(float a, float b)
            {
                // Apply height offset to B
                b += _HeightOffset;

                // Height difference
                float h = b - a;

                // Contrast shaping (matches Substance)
                h = pow(abs(h), _Contrast) * sign(h);

                // Soft transition
                float t = smoothstep(-_Softness, _Softness, h);

                // Blend factor (user blend mixed with height blend)
                float f = lerp(_Blend, t, 1.0);

                return lerp(a, b, f);
            }

            // ---------------------------------------------------------
            // CRT fragment
            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture IN) : SV_Target
            {
                float2 uv = IN.localTexcoord.xy;

                float a = tex2D(_A, uv).r;
                float b = tex2D(_B, uv).r;

                float h = heightBlend(a, b);

                return float4(h, h, h, 1.0);
            }

            ENDHLSL
        }
    }
}
