Shader "Hidden/Genesis/HeightToNormal"
{
    Properties
    {
        _MainTex("Source Heightmap", 2D) = "white" {}
        _Strength("Normal Strength", Range(0,10)) = 2.0
        _Bias("Height Bias", Range(-1,1)) = 0.0
        _Contrast("Height Contrast", Range(0.1,4.0)) = 1.0
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

            float _Strength;
            float _Bias;
            float _Contrast;

            // ---------------------------------------------------------
            // Sample height with shaping
            // ---------------------------------------------------------
            float sampleHeight(float2 uv)
            {
                float h = tex2D(_MainTex, uv).r;
                h = saturate((h + _Bias));
                h = pow(h, _Contrast);
                return h;
            }

            // ---------------------------------------------------------
            // Sobel gradient
            // ---------------------------------------------------------
            float2 sobel(float2 uv)
            {
                float2 t = _MainTex_TexelSize.xy;

                float hL = sampleHeight(uv - float2(t.x, 0));
                float hR = sampleHeight(uv + float2(t.x, 0));
                float hD = sampleHeight(uv - float2(0, t.y));
                float hU = sampleHeight(uv + float2(0, t.y));

                float dx = (hR - hL);
                float dy = (hU - hD);

                return float2(dx, dy);
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float2 g = sobel(uv) * _Strength;

                float3 n = normalize(float3(-g.x, -g.y, 1.0));

                // Convert to 0–1 range
                n = n * 0.5 + 0.5;

                return float4(n, 1.0);
            }

            ENDHLSL
        }
    }
}