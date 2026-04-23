Shader "Hidden/Genesis/CartoonFilter"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        _Source("Source Texture", 2D) = "white" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
        [ShowInInspector][Enum(2D,0,3D,1)] _UVMode("UV Mode", Float) = 0

        _Posterize("Posterize Levels", Range(2,32)) = 6
        _EdgeStrength("Edge Strength", Range(0,4)) = 2.0
        _EdgeThreshold("Edge Threshold", Range(0,1)) = 0.2
        _Halftone("Halftone Amount", Range(0,1)) = 0.0
        _HalftoneScale("Halftone Scale", Float) = 120.0

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
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV
            #pragma shader_feature _TILINGMODE_NONE _TILINGMODE_TILED

            TEXTURE_SAMPLER_X(_UV);
            TEXTURE2D(_Source);
            SAMPLER(sampler_Source);

            float _Posterize;
            float _EdgeStrength;
            float _EdgeThreshold;
            float _Halftone;
            float _HalftoneScale;
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
            // Posterization
            // ------------------------------------------------------------
            float3 Posterize(float3 c, float levels)
            {
                return floor(c * levels) / levels;
            }

            // ------------------------------------------------------------
            // Sobel edge detection
            // ------------------------------------------------------------
            float Edge(float2 uv)
            {
                float2 texel = float2(1.0 / 1024.0, 1.0 / 1024.0);

                float3 tl = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + texel * float2(-1,  1)).rgb;
                float3  l = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + texel * float2(-1,  0)).rgb;
                float3 bl = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + texel * float2(-1, -1)).rgb;

                float3  t = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + texel * float2( 0,  1)).rgb;
                float3  b = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + texel * float2( 0, -1)).rgb;

                float3 tr = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + texel * float2( 1,  1)).rgb;
                float3  r = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + texel * float2( 1,  0)).rgb;
                float3 br = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + texel * float2( 1, -1)).rgb;

                float3 gx = -tl - 2*l - bl + tr + 2*r + br;
                float3 gy =  tl + 2*t + tr - bl - 2*b - br;

                float g = length(gx) + length(gy);
                return saturate(g * _EdgeStrength);
            }

            // ------------------------------------------------------------
            // Halftone dots
            // ------------------------------------------------------------
            float Halftone(float2 uv)
            {
                float2 p = uv * _HalftoneScale;
                float2 cell = frac(p) - 0.5;
                float d = length(cell);
                return smoothstep(0.5, 0.2, d);
            }

            // ------------------------------------------------------------
            // Fragment
            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uvs = GetNoiseUVs(
                    i,
                    SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction),
                    _Seed
                );

                float2 uv = ApplyTiling(uvs.xy, _Scale);

                float3 src = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv).rgb;

                // 1. Posterize colors
                float3 toon = Posterize(src, _Posterize);

                // 2. Edge mask
                float e = Edge(uv);
                float edgeMask = step(_EdgeThreshold, e);

                // 3. Halftone overlay
                float h = Halftone(uv);
                toon = lerp(toon, toon * h, _Halftone);

                // 4. Composite: dark edges on top
                toon = lerp(toon, float3(0,0,0), edgeMask);

                return float4(toon, 1.0);
            }

            ENDHLSL
        }
    }
}
