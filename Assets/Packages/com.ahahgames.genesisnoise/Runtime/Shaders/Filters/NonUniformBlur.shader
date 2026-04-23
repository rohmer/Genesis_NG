Shader "Hidden/Genesis/NonUniformBlur"
{
    Properties
    {
        _Source("Source Heightmap", 2D) = "white" {}
        _Intensity("Intensity Map", 2D) = "gray" {}

        _MaxRadius("Max Blur Radius", Range(0,10)) = 3.0
        [GenesisSlopeBlurBlend]_Mode("Blend Mode (0=min,1=max,2=avg)", Range(0,2)) = 2

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
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            sampler2D _Source;
            sampler2D _Intensity;
            float4 _Source_TexelSize;

            float _MaxRadius;
            float _Mode;

            float _Bias;
            float _Contrast;

            // ---------------------------------------------------------
            // Height sampling with shaping
            // ---------------------------------------------------------
            float sampleHeight(float2 uv)
            {
                float h = tex2D(_Source, uv).r;
                h = saturate(h + _Bias);
                h = pow(h, _Contrast);
                return h;
            }

            // ---------------------------------------------------------
            // Blend modes
            // ---------------------------------------------------------
            float blend(float a, float b)
            {
                if (_Mode < 0.5)      return min(a, b);   // min
                else if (_Mode < 1.5) return max(a, b);   // max
                else                  return (a + b) * 0.5; // avg
            }

            // ---------------------------------------------------------
            // Non-uniform blur (9 taps)
            // ---------------------------------------------------------
            float nonUniformBlur(float2 uv)
            {
                float2 t = _Source_TexelSize.xy;

                // Intensity controls radius per pixel
                float intensity = tex2D(_Intensity, uv).r;
                float r = intensity * _MaxRadius;

                // 9-tap kernel offsets
                float2 o[9] = {
                    float2( 0,  0),
                    float2( 1,  0),
                    float2(-1,  0),
                    float2( 0,  1),
                    float2( 0, -1),
                    float2( 1,  1),
                    float2(-1,  1),
                    float2( 1, -1),
                    float2(-1, -1)
                };

                float v = sampleHeight(uv);

                [unroll]
                for (int i = 1; i < 9; i++)
                {
                    float2 uv2 = uv + o[i] * t * r;
                    float h = sampleHeight(uv2);
                    v = blend(v, h);
                }

                return v;
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float v = nonUniformBlur(uv);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}