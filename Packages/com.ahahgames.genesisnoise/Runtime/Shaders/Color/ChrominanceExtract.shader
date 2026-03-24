Shader "Hidden/Genesis/ChrominanceExtract"
{
    Properties
    {
        [InlineTexture]_UV_2D("Input", 2D) = "white" {}
        [InlineTexture]_UV_3D("Input", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Input", Cube) = "white" {}

        _SaturationWeight("Saturation Weight", Range(0.0, 2.0)) = 1.0
        _LumaCompensation("Luminance Compensation", Range(0.0, 2.0)) = 0.0
        _HueCenter("Hue Center (0–1)", Range(0.0, 1.0)) = 0.5
        _HueRange("Hue Range", Range(0.0, 1.0)) = 1.0
        _Softness("Softness", Range(0.0, 1.0)) = 0.25
        _Invert("Invert Output", Range(0,1)) = 0
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

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            TEXTURE_SAMPLER_X(_UV);

            float _SaturationWeight;
            float _LumaCompensation;
            float _HueCenter;
            float _HueRange;
            float _Softness;
            float _Invert;

            // RGB → HSV
            float3 rgb2hsv(float3 c)
            {
                float4 K = float4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
                float4 p = (c.g < c.b) ? float4(c.bg, K.wz) : float4(c.gb, K.xy);
                float4 q = (c.r < p.x) ? float4(p.xyw, c.r) : float4(c.r, p.yzx);

                float d = q.x - min(q.w, q.y);
                float e = 1e-10;

                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                              d / (q.x + e),
                              q.x);
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 rgb = SAMPLE_X(_UV, uv, i.dir).rgb;

                // Convert to HSV
                float3 hsv = rgb2hsv(rgb);
                float hue = hsv.x;
                float sat = hsv.y;
                float val = hsv.z;

                // Base chrominance = saturation
                float chroma = sat * _SaturationWeight;

                // Optional luminance compensation
                chroma *= lerp(1.0, 1.0 - val, _LumaCompensation);

                // Optional hue isolation
                float hueDist = abs(hue - _HueCenter);
                hueDist = min(hueDist, 1.0 - hueDist); // wrap around

                float hueMask = smoothstep(_HueRange, _HueRange - _Softness, hueDist);

                chroma *= hueMask;

                // Optional invert
                if (_Invert > 0.5)
                    chroma = 1.0 - chroma;

                chroma = saturate(chroma);

                return float4(chroma, chroma, chroma, 1.0);
            }

            ENDHLSL
        }
    }
}