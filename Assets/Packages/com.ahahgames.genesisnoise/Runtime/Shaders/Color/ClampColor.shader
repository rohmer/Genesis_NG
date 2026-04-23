Shader "Hidden/Genesis/ClampColor"
{
    Properties
    {
        [InlineTexture]_UV_2D("Input", 2D) = "white" {}
        [InlineTexture]_UV_3D("Input", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Input", Cube) = "white" {}

        // Per-channel min/max
        _MinR("Min R", Range(0,1)) = 0
        _MaxR("Max R", Range(0,1)) = 1

        _MinG("Min G", Range(0,1)) = 0
        _MaxG("Max G", Range(0,1)) = 1

        _MinB("Min B", Range(0,1)) = 0
        _MaxB("Max B", Range(0,1)) = 1

        _MinA("Min A", Range(0,1)) = 0
        _MaxA("Max A", Range(0,1)) = 1

        // Optional global clamp
        _GlobalClamp("Global Clamp 0–1", Range(0,1)) = 1

        // Optional luminance clamp
        [Enum(Disabled,0,Enabled,1)]_LumaClamp("Clamp Luminance",Int) = 0
        [Enum(Disabled,0,Enabled,1)]_LumaMin("Luma Min", Int) = 0
        [Enum(Disabled,0,Enabled,1)]_LumaMax("Luma Max", Int) = 1
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

            TEXTURE_SAMPLER_X(_UV);

            float _MinR, _MaxR, _MinG, _MaxG, _MinB, _MaxB, _MinA, _MaxA;
            float _GlobalClamp;
            float _LumaClamp, _LumaMin, _LumaMax;

            float luminance(float3 c)
            {
                return dot(c, float3(0.299, 0.587, 0.114));
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float4 c = SAMPLE_X(_UV, uv, i.dir);

                // Per-channel clamp
                c.r = clamp(c.r, _MinR, _MaxR);
                c.g = clamp(c.g, _MinG, _MaxG);
                c.b = clamp(c.b, _MinB, _MaxB);
                c.a = clamp(c.a, _MinA, _MaxA);

                // Optional global clamp
                if (_GlobalClamp > 0.5)
                {
                    c = saturate(c);
                }

                // Optional luminance clamp (Substance-style)
                if (_LumaClamp > 0.5)
                {
                    float l = luminance(c.rgb);
                    l = clamp(l, _LumaMin, _LumaMax);

                    // Re-normalize color to match new luminance
                    float oldL = max(1e-5, luminance(c.rgb));
                    c.rgb *= (l / oldL);
                }

                return c;
            }

            ENDHLSL
        }
    }
}