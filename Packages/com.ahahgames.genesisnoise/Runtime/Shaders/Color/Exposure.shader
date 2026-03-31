Shader "Hidden/Genesis/Exposure"
{
    Properties
    {
        _MainTex("Input Texture", 2D) = "white" {}
        _Exposure("Exposure (EV)", Range(-8, 8)) = 0.0
        _Bias("Brightness Bias", Range(-1, 1)) = 0.0
        _Contrast("Contrast", Range(0.1, 4.0)) = 1.0
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

            float _Exposure;
            float _Bias;
            float _Contrast;

            // ---------------------------------------------------------
            float3 applyExposure(float3 c)
            {
                // Exposure: multiply by 2^EV
                float exposureFactor = exp2(_Exposure);
                c *= exposureFactor;

                // Bias
                c += _Bias;

                // Contrast shaping
                c = pow(saturate(c), _Contrast);

                return c;
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float3 c = tex2D(_MainTex, uv).rgb;

                float3 outC = applyExposure(c);

                return float4(outC, 1.0);
            }

            ENDHLSL
        }
    }
}