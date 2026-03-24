Shader "Hidden/Genesis/ApplyPalette"
{
    Properties
    {
        [InlineTexture]_UV_2D("Input", 2D) = "white" {}
        [InlineTexture]_UV_3D("Input", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Input", Cube) = "white" {}

        _Mode("Mode (0 = Smooth, 1 = Stepped)", Range(0,1)) = 0
        _Steps("Steps (Stepped Mode)", Range(2, 16)) = 4
        _Contrast("Contrast", Range(0.1, 4.0)) = 1.0
        _Dither("Dither Strength", Range(0.0, 1.0)) = 0.0

        [GenesisColorProperty]_Color0("Color 0", Color) = (0,0,0,1)
        [GenesisColorProperty]_Color1("Color 1", Color) = (1,1,1,1)
        [GenesisColorProperty]_Color2("Color 2", Color) = (1,0,0,1)
        [GenesisColorProperty]_Color3("Color 3", Color) = (0,1,0,1)
        [GenesisColorProperty]_Color4("Color 4", Color) = (0,0,1,1)
        [GenesisColorProperty]_Color5("Color 5", Color) = (1,1,0,1)
        [GenesisColorProperty]_Color6("Color 6", Color) = (1,0,1,1)
        [GenesisColorProperty]_Color7("Color 7", Color) = (0,1,1,1)

        _ColorCount("Color Count", Range(2,8)) = 2
        _Seed("Seed", Float) = 1
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

            float _Mode, _Steps, _Contrast, _Dither;
            float _ColorCount;
            float _Seed;

            float4 _Color0, _Color1, _Color2, _Color3;
            float4 _Color4, _Color5, _Color6, _Color7;

            float rand(float2 uv)
            {
                return frac(sin(dot(uv + _Seed, float2(12.9898, 78.233))) * 43758.5453);
            }

            float4 getColor(int index)
            {
                if (index == 0) return _Color0;
                if (index == 1) return _Color1;
                if (index == 2) return _Color2;
                if (index == 3) return _Color3;
                if (index == 4) return _Color4;
                if (index == 5) return _Color5;
                if (index == 6) return _Color6;
                return _Color7;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                // Read grayscale input
                float g = SAMPLE_X(_UV, uv, i.dir).r;

                // Optional contrast shaping
                g = pow(saturate(g), _Contrast);

                // Optional dithering
                g += (rand(uv) - 0.5) * _Dither / max(_Steps, 1);

                g = saturate(g);

                int count = (int)_ColorCount;

                float scaled = g * (count - 1);
                int idx = (int)scaled;
                float t = frac(scaled);

                // Stepped mode
                if (_Mode > 0.5)
                {
                    float stepVal = floor(g * _Steps) / (_Steps - 1);
                    scaled = stepVal * (count - 1);
                    idx = (int)scaled;
                    t = 0.0;
                }

                idx = clamp(idx, 0, count - 1);
                int idx2 = clamp(idx + 1, 0, count - 1);

                float4 c1 = getColor(idx);
                float4 c2 = getColor(idx2);

                float4 result = lerp(c1, c2, t);

                return float4(result.rgb, 1.0);
            }

            ENDHLSL
        }
    }
}