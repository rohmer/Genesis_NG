Shader "Hidden/Genesis/SlopeBlurGrayscale"
{
    Properties
    {
        _Source("Source Heightmap", 2D) = "white" {}
        _Slope("Slope Map", 2D) = "gray" {}

        _Radius("Blur Radius", Range(0,10)) = 3.0
        _Strength("Slope Strength", Range(0,2)) = 1.0

        _Bias("Height Bias", Range(-1,1)) = 0.0
        _Contrast("Height Contrast", Range(0.1,4.0)) = 1.0

        [GenesisSlopeBlurBlend]_Mode("Blend Mode", Float) = 2
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
            sampler2D _Slope;
            float4 _Source_TexelSize;

            float _Radius;
            float _Strength;

            float _Bias;
            float _Contrast;

            float _Mode;

            // ---------------------------------------------------------
            // Height sampling with shaping
            // ---------------------------------------------------------
            float sampleHeight(sampler2D tex, float2 uv)
            {
                float h = tex2D(tex, uv).r;
                h = saturate(h + _Bias);
                h = pow(h, _Contrast);
                return h;
            }

            // ---------------------------------------------------------
            // Compute slope direction from slope map
            // ---------------------------------------------------------
            float2 slopeDir(float2 uv)
            {
                float2 t = _Source_TexelSize.xy;

                float sL = tex2D(_Slope, uv - float2(t.x, 0)).r;
                float sR = tex2D(_Slope, uv + float2(t.x, 0)).r;
                float sD = tex2D(_Slope, uv - float2(0, t.y)).r;
                float sU = tex2D(_Slope, uv + float2(0, t.y)).r;

                float2 g = float2(sR - sL, sU - sD);
                g *= _Strength;

                // Avoid zero-length
                return normalize(g + 1e-5);
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
            // Slope blur (7 taps)
            // ---------------------------------------------------------
            float slopeBlur(float2 uv)
            {
                float2 dir = slopeDir(uv);
                float2 t = _Source_TexelSize.xy;

                float r = _Radius;

                float h0 = sampleHeight(_Source, uv);

                float h1 = sampleHeight(_Source, uv + dir * t * r * 0.33);
                float h2 = sampleHeight(_Source, uv + dir * t * r * 0.66);
                float h3 = sampleHeight(_Source, uv + dir * t * r * 1.00);

                float h4 = sampleHeight(_Source, uv - dir * t * r * 0.33);
                float h5 = sampleHeight(_Source, uv - dir * t * r * 0.66);
                float h6 = sampleHeight(_Source, uv - dir * t * r * 1.00);

                float v = h0;
                v = blend(v, h1);
                v = blend(v, h2);
                v = blend(v, h3);
                v = blend(v, h4);
                v = blend(v, h5);
                v = blend(v, h6);

                return v;
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float v = slopeBlur(uv);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}