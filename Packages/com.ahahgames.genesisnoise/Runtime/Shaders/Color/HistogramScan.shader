Shader "Hidden/Genesis/HistogramScan"
{
    Properties
    {
        _MainTex("Source Grayscale", 2D) = "white" {}

        _Position("Position", Range(0,1)) = 0.5
        _Contrast("Contrast", Range(0.001,2.0)) = 0.2
        _Invert("Invert", Range(0,1)) = 0.0
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

            sampler2D _MainTex;

            float _Position;
            float _Contrast;
            float _Invert;

            // ---------------------------------------------------------
            // Histogram Scan Function
            // ---------------------------------------------------------
            float histogramScan(float h)
            {
                // Shift by position
                float v = h - _Position;

                // Contrast controls the width of the transition
                float c = max(_Contrast, 0.0001);

                // Normalize and clamp
                v = saturate(v / c);

                // Optional invert
                v = lerp(v, 1.0 - v, _Invert);

                return v;
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float h = tex2D(_MainTex, uv).r;

                float v = histogramScan(h);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}