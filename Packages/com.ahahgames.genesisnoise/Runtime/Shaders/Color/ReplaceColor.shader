Shader "Hidden/Genesis/ReplaceColor"
{
    Properties
    {
        [InlineTexture]_UV_2D("Input", 2D) = "white" {}
        [InlineTexture]_UV_3D("Input", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Input", Cube) = "white" {}

        [GenesisColorProperty]_TargetColor("Target Color", Color) = (1,0,0,1)
        [GenesisColorProperty]_ReplaceColor("Replace With", Color) = (0,1,0,1)

        _HueRange("Hue Range", Range(0,1)) = 0.1
        _SatRange("Saturation Range", Range(0,1)) = 0.2
        _ValRange("Value Range", Range(0,1)) = 0.2

        _Fuzziness("Fuzziness", Range(0,1)) = 0.25
        _Blend("Blend Amount", Range(0,1)) = 1.0

        _PreserveLum("Preserve Luminance", Range(0,1)) = 0
        _PreserveSat("Preserve Saturation", Range(0,1)) = 0

        _Contrast("Mask Contrast", Range(0.1, 4.0)) = 1.0
        _Invert("Invert Mask", Range(0,1)) = 0
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

            float4 _TargetColor;
            float4 _ReplaceColor;

            float _HueRange, _SatRange, _ValRange;
            float _Fuzziness, _Blend;
            float _PreserveLum, _PreserveSat;
            float _Contrast, _Invert;

            // RGB <-> HSV
            float3 rgb2hsv(float3 c)
            {
                float4 K = float4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
                float4 p = (c.g < c.b) ? float4(c.bg, K.wz) : float4(c.gb, K.xy);
                float4 q = (c.r < p.x) ? float4(p.xyw, c.r) : float4(c.r, p.yzx);

                float d = q.x - min(q.w, q.y);
                float e = 1e-10;

                return float3(
                    abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                    d / (q.x + e),
                    q.x
                );
            }

            float3 hsv2rgb(float3 c)
            {
                float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }

            float hueDistance(float h1, float h2)
            {
                float d = abs(h1 - h2);
                return min(d, 1.0 - d); // wrap around
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float3 col = SAMPLE_X(_UV, uv,i.direction).rgb;

                float3 hsv = rgb2hsv(col);
                float3 targetHSV = rgb2hsv(_TargetColor.rgb);
                float3 replaceHSV = rgb2hsv(_ReplaceColor.rgb);

                // Compute per-channel distances
                float dh = hueDistance(hsv.x, targetHSV.x) / max(_HueRange, 1e-5);
                float ds = abs(hsv.y - targetHSV.y) / max(_SatRange, 1e-5);
                float dv = abs(hsv.z - targetHSV.z) / max(_ValRange, 1e-5);

                // Combine distances
                float dist = max(max(dh, ds), dv);

                // Convert to mask
                float mask = 1.0 - smoothstep(0.0, _Fuzziness, dist);
                mask = pow(mask, _Contrast);

                if (_Invert > 0.5)
                    mask = 1.0 - mask;

                // Build replacement color
                float3 newHSV = replaceHSV;

                if (_PreserveLum > 0.5)
                    newHSV.z = hsv.z;

                if (_PreserveSat > 0.5)
                    newHSV.y = hsv.y;

                float3 newRGB = hsv2rgb(newHSV);

                // Blend between original and replaced
                float3 final = lerp(col, newRGB, mask * _Blend);

                return float4(final, 1.0);
            }

            ENDHLSL
        }
    }
}