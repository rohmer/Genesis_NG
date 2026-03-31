Shader "Hidden/Genesis/Erosion"
{
    Properties
    {
        _MainTex("Source Heightmap", 2D) = "white" {}
        _Strength("Erosion Strength", Range(0,10)) = 2.0
        _Bias("Height Bias", Range(-1,1)) = 0.0
        _Contrast("Height Contrast", Range(0.1,4.0)) = 1.0
        _SlopeWeight("Slope Weight", Range(0,4)) = 1.0
        _DeltaWeight("Delta Weight", Range(0,4)) = 1.0
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
            float _SlopeWeight;
            float _DeltaWeight;

            // ---------------------------------------------------------
            float sampleHeight(float2 uv)
            {
                float h = tex2D(_MainTex, uv).r;
                h = saturate(h + _Bias);
                h = pow(h, _Contrast);
                return h;
            }

            // ---------------------------------------------------------
            float2 sobel(float2 uv)
            {
                float2 t = _MainTex_TexelSize.xy;

                float hL = sampleHeight(uv - float2(t.x, 0));
                float hR = sampleHeight(uv + float2(t.x, 0));
                float hD = sampleHeight(uv - float2(0, t.y));
                float hU = sampleHeight(uv + float2(0, t.y));

                float dx = hR - hL;
                float dy = hU - hD;

                return float2(dx, dy);
            }

            // ---------------------------------------------------------
            float localDelta(float2 uv)
            {
                float2 t = _MainTex_TexelSize.xy;

                float hC = sampleHeight(uv);
                float hAvg =
                    ( sampleHeight(uv + float2( t.x, 0)) +
                      sampleHeight(uv + float2(-t.x, 0)) +
                      sampleHeight(uv + float2(0,  t.y)) +
                      sampleHeight(uv + float2(0, -t.y)) ) * 0.25;

                return hC - hAvg; // positive = peak, negative = valley
            }

            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float2 g = sobel(uv);
                float slope = length(g) * _SlopeWeight;

                float delta = abs(localDelta(uv)) * _DeltaWeight;

                float erosion = (slope + delta) * _Strength;

                erosion = saturate(erosion);

                return float4(erosion, erosion, erosion, 1.0);
            }

            ENDHLSL
        }
    }
}