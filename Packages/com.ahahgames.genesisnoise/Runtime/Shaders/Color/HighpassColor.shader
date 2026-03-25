Shader "Hidden/Genesis/HighpassColor"
{
    Properties
    {
        [Tooltip(Original color input)]
        _Source("Source", 2D) = "white" {}

        [Tooltip(Blurred color input)]
        _Blurred("Blurred", 2D) = "gray" {}

        [Tooltip(Highpass intensity)]
        _Intensity("Intensity", Float) = 1.0

        [Tooltip(Contrast shaping)]
        _Contrast("Contrast", Float) = 1.0

        [Tooltip(Normalize output 0 to 1)][Enum(Off,0, On,1)]
        _Normalize("Normalize", Float) = 1
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

            sampler2D _Source;
            sampler2D _Blurred;

            float _Intensity;
            float _Contrast;
            float _Normalize;

            float ApplyContrast(float v, float c)
            {
                // Substance-style mid-pivot contrast
                v = saturate(v);
                float mid = 0.5;
                return pow(abs(v - mid) * 2.0, c) * 0.5 * sign(v - mid) + mid;
            }

            float3 ApplyContrastRGB(float3 v, float c)
            {
                return float3(
                    ApplyContrast(v.r, c),
                    ApplyContrast(v.g, c),
                    ApplyContrast(v.b, c)
                );
            }

            float4 mixture(v2f_customrendertexture IN) : SV_Target
            {
                float3 uv = IN.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float3 src = tex2D(_Source, uv.xy).rgb;
                float3 blur = tex2D(_Blurred, uv.xy).rgb;

                // Highpass per channel
                float3 hp = (src - blur) * _Intensity;

                // Normalize to 0–1 if enabled
                if (_Normalize > 0.5)
                    hp = hp * 0.5 + 0.5;

                // Optional contrast shaping
                hp = ApplyContrastRGB(hp, _Contrast);

                return float4(hp, 1.0);
            }

            ENDHLSL
        }
    }
}
