Shader "Hidden/Genesis/ViewColorPalette"
{
    Properties
    {
        _Count("Color Count", Range(1,16)) = 5

        [GenesisColorProperty]_Color0("Color 0", Color) = (1,0,0,1)
        [GenesisColorProperty]_Color1("Color 1", Color) = (0,1,0,1)
        [GenesisColorProperty]_Color2("Color 2", Color) = (0,0,1,1)
        [GenesisColorProperty]_Color3("Color 3", Color) = (1,1,0,1)
        [GenesisColorProperty]_Color4("Color 4", Color) = (1,0,1,1)
        [GenesisColorProperty]_Color5("Color 5", Color) = (0,1,1,1)
        [GenesisColorProperty]_Color6("Color 6", Color) = (0.5,0.5,0.5,1)
        [GenesisColorProperty]_Color7("Color 7", Color) = (1,0.5,0,1)
        [GenesisColorProperty]_Color8("Color 8", Color) = (0.2,0.8,0.4,1)
        [GenesisColorProperty]_Color9("Color 9", Color) = (0.8,0.2,0.4,1)
        [GenesisColorProperty]_Color10("Color 10", Color) = (0.3,0.3,0.9,1)
        [GenesisColorProperty]_Color11("Color 11", Color) = (0.9,0.3,0.3,1)
        [GenesisColorProperty]_Color12("Color 12", Color) = (0.3,0.9,0.3,1)
        [GenesisColorProperty]_Color13("Color 13", Color) = (0.9,0.9,0.3,1)
        [GenesisColorProperty]_Color14("Color 14", Color) = (0.3,0.9,0.9,1)
        [GenesisColorProperty]_Color15("Color 15", Color) = (0.9,0.3,0.9,1)

        _Vertical("Vertical Layout", Range(0,1)) = 0
        _Padding("Padding", Range(0,0.2)) = 0.02

        _BorderSize("Border Size", Range(0,0.05)) = 0.005
        [GenesisColorProperty]_BorderColor("Border Color", Color) = (0,0,0,1)
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

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            float _Count;
            float _Vertical;
            float _Padding;
            float _BorderSize;
            float4 _BorderColor;

            float4 _Color0, _Color1, _Color2, _Color3;
            float4 _Color4, _Color5, _Color6, _Color7;
            float4 _Color8, _Color9, _Color10, _Color11;
            float4 _Color12, _Color13, _Color14, _Color15;

            float4 getColor(int i)
            {
                if (i == 0) return _Color0;
                if (i == 1) return _Color1;
                if (i == 2) return _Color2;
                if (i == 3) return _Color3;
                if (i == 4) return _Color4;
                if (i == 5) return _Color5;
                if (i == 6) return _Color6;
                if (i == 7) return _Color7;
                if (i == 8) return _Color8;
                if (i == 9) return _Color9;
                if (i == 10) return _Color10;
                if (i == 11) return _Color11;
                if (i == 12) return _Color12;
                if (i == 13) return _Color13;
                if (i == 14) return _Color14;
                return _Color15;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                int count = (int)_Count;
                count = clamp(count, 1, 16);

                float idxF = _Vertical > 0.5 ? uv.y * count : uv.x * count;
                int idx = clamp((int)idxF, 0, count - 1);

                float2 local = _Vertical > 0.5 ?
                    float2(uv.x, frac(idxF)) :
                    float2(frac(idxF), uv.y);

                // Border mask
                float borderMask =
                    step(local.x, _BorderSize) +
                    step(1.0 - local.x, _BorderSize) +
                    step(local.y, _BorderSize) +
                    step(1.0 - local.y, _BorderSize);

                if (borderMask > 0.0)
                    return _BorderColor;

                // Padding mask
                float pad = _Padding;
                if (local.x < pad || local.x > 1.0 - pad ||
                    local.y < pad || local.y > 1.0 - pad)
                {
                    return float4(0,0,0,0);
                }

                return getColor(idx);
            }

            ENDHLSL
        }
    }
}