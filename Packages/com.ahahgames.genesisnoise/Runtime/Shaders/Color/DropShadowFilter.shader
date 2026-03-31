Shader "Hidden/Genesis/DropShadowFilter"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        _Source("Source Mask (Grayscale)", 2D) = "white" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
        [ShowInInspector][Enum(2D,0,3D,1)] _UVMode("UV Mode", Float) = 0

        _Offset("Shadow Offset", Vector) = (0.02, -0.02, 0, 0)
        _Softness("Softness", Range(0,0.2)) = 0.05
        _Opacity("Opacity", Range(0,1)) = 0.6
        _ShadowColor("Shadow Color", Color) = (0,0,0,1)
        _Inner("Inner Shadow", Range(0,1)) = 0
        _Scale("UV Scale", Float) = 1.0
        _Seed("Seed", Int) = 42
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV
            #pragma shader_feature _TILINGMODE_NONE _TILINGMODE_TILED

            TEXTURE_SAMPLER_X(_UV);
            TEXTURE2D(_Source);
            SAMPLER(sampler_Source);

            float2 _Offset;
            float _Softness;
            float _Opacity;
            float4 _ShadowColor;
            float _Inner;
            float _Scale;
            int _Seed;
            int _UVMode;

            // ------------------------------------------------------------
            // Tiling helper
            // ------------------------------------------------------------
            float2 ApplyTiling(float2 uv, float period)
            {
#ifdef _TILINGMODE_TILED
                return frac(uv * period);
#else
                return uv;
#endif
            }

            // ------------------------------------------------------------
            // Gaussian-like radial falloff
            // ------------------------------------------------------------
            float Falloff(float d, float softness)
            {
                return exp(-d * d / max(1e-5, softness * softness));
            }

            // ------------------------------------------------------------
            // Sample mask
            // ------------------------------------------------------------
            float SampleMask(float2 uv)
            {
                return SAMPLE_TEXTURE2D(_Source, sampler_Source, uv).r;
            }

            // ------------------------------------------------------------
            // Fragment
            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uvs = GetNoiseUVs(
                    i,
                    SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction),
                    _Seed
                );

                float2 uv = ApplyTiling(uvs.xy, _Scale);

                // Original mask
                float mask = SampleMask(uv);

                // Shadow sample position
                float2 suv = uv + _Offset;

                // Shadow mask
                float smask = SampleMask(suv);

                // Distance-based softness
                float d = length(_Offset);
                float soft = Falloff(d, _Softness);

                float shadow = smask * soft * _Opacity;

                // Inner shadow mode
                if (_Inner > 0.5)
                {
                    shadow *= (1.0 - mask);
                }

                float3 col = lerp(float3(0,0,0), _ShadowColor.rgb, shadow);

                return float4(col, shadow);
            }

            ENDHLSL
        }
    }
}
