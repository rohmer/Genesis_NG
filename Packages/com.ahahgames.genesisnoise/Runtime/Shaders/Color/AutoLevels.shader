Shader "Hidden/Genesis/AutoLevels"
{
    Properties
    {
        [Tooltip(Input source)]_MainTex("Source Grayscale", 2D) = "white" {}

        [Tooltip(The lowest level, below this level the pixels will return black)]_Min("Min Value", Range(0,1)) = 0.0
        [Tooltip(The upper level, above this level the pixels will return black)]_Max("Max Value", Range(0,1)) = 1.0

        [Tooltip(Auto estimate min and max with a cheap 9 sample probe)]_AutoEstimate("Estimate Min/Max", Range(0,1)) = 0.0

        [Tooltip(Higher levels will push increase the contrast)]_Contrast("Contrast", Range(0.5,4.0)) = 1.0
        [Tooltip(1 will invert the results)]_Invert("Invert", Range(0,1)) = 0.0
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
            float4 _MainTex_TexelSize;

            float _Min;
            float _Max;
            float _AutoEstimate;

            float _Contrast;
            float _Invert;

            // ---------------------------------------------------------
            // Sample grayscale
            // ---------------------------------------------------------
            float sampleGray(float2 uv)
            {
                return tex2D(_MainTex, uv).r;
            }

            // ---------------------------------------------------------
            // Auto-estimate min/max using a cheap 9-sample probe
            // ---------------------------------------------------------
            void estimateMinMax(float2 uv, out float mn, out float mx)
            {
                float2 t = _MainTex_TexelSize.xy;

                float v0 = sampleGray(uv);
                float v1 = sampleGray(uv + float2( t.x, 0));
                float v2 = sampleGray(uv + float2(-t.x, 0));
                float v3 = sampleGray(uv + float2(0,  t.y));
                float v4 = sampleGray(uv + float2(0, -t.y));
                float v5 = sampleGray(uv + float2( t.x,  t.y));
                float v6 = sampleGray(uv + float2(-t.x,  t.y));
                float v7 = sampleGray(uv + float2( t.x, -t.y));
                float v8 = sampleGray(uv + float2(-t.x, -t.y));

                mn = min(min(min(v0,v1),min(v2,v3)),min(min(v4,v5),min(v6,min(v7,v8))));
                mx = max(max(max(v0,v1),max(v2,v3)),max(max(v4,v5),max(v6,max(v7,v8))));
            }

            // ---------------------------------------------------------
            // Auto-levels remap
            // ---------------------------------------------------------
            float autoLevels(float h, float mn, float mx)
            {
                float range = max(mx - mn, 0.0001);
                float v = (h - mn) / range;

                // Contrast shaping
                v = pow(saturate(v), _Contrast);

                // Optional invert
                v = lerp(v, 1.0 - v, _Invert);

                return v;
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float h = sampleGray(uv);

                float mn = _Min;
                float mx = _Max;

                // Auto-estimate mode
                if (_AutoEstimate > 0.5)
                {
                    estimateMinMax(uv, mn, mx);
                }

                float v = autoLevels(h, mn, mx);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}