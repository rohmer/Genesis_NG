Shader "Hidden/Genesis/HighpassGrayscale"
{
    Properties
    {
        [Tooltip(Original grayscale input)]
        _Source("Source", 2D) = "white" {}

        [Tooltip(Blurred grayscale input)]
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
                // Substance-style contrast curve
                v = saturate(v);
                float mid = 0.5;
                return pow(abs(v - mid) * 2.0, c) * 0.5 * sign(v - mid) + mid;
            }

            float4 genesis(v2f_customrendertexture i)
            {
                float3 uv = i.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float src = tex2D(_Source, uv.xy).r;
                float blur = tex2D(_Blurred, uv.xy).r;

                // Highpass extraction
                float hp = (src - blur) * _Intensity;

                // Normalize to 0–1 if enabled
                if (_Normalize > 0.5)
                    hp = hp * 0.5 + 0.5;

                // Optional contrast shaping
                hp = ApplyContrast(hp, _Contrast);

                return hp;
            }
             
            ENDHLSL
        }
    }
}
