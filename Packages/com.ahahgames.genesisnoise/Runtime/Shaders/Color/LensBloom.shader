Shader "Hidden/Genesis/LensBloom"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        _Source("Source Texture", 2D) = "white" {}
        _LensDirt("Lens Dirt Mask", 2D) = "white" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
        [ShowInInspector][Enum(2D,0,3D,1)] _UVMode("UV Mode", Float) = 0

        _Threshold("Bloom Threshold", Range(0,2)) = 1.0
        _SoftKnee("Soft Knee", Range(0,1)) = 0.5
        _Intensity("Bloom Intensity", Range(0,4)) = 1.5

        _Radius1("Radius Small", Float) = 1.5
        _Radius2("Radius Medium", Float) = 4.0
        _Radius3("Radius Large", Float) = 12.0

        _Chromatic("Chromatic Shift", Range(0,1)) = 0.1
        _DirtStrength("Lens Dirt Strength", Range(0,2)) = 1.0

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

            TEXTURE2D(_LensDirt);
            SAMPLER(sampler_LensDirt);

            float _Threshold;
            float _SoftKnee;
            float _Intensity;
            float _Radius1;
            float _Radius2;
            float _Radius3;
            float _Chromatic;
            float _DirtStrength;
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
            // Bright-pass extraction with soft knee
            // ------------------------------------------------------------
            float3 BrightPass(float3 c)
            {
                float br = max(c.r, max(c.g, c.b));
                float knee = _Threshold * _SoftKnee;
                float soft = saturate((br - _Threshold + knee) / (knee + 1e-5));
                return c * soft;
            }

            // ------------------------------------------------------------
            // Gaussian blur sample (single direction)
            // ------------------------------------------------------------
            float3 Blur(float2 uv, float radius)
            {
                float2 texel = float2(1.0 / 1024.0, 1.0 / 1024.0);

                float3 c = float3(0,0,0);
                c += SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + texel * radius * float2( 1, 0)).rgb * 0.25;
                c += SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + texel * radius * float2(-1, 0)).rgb * 0.25;
                c += SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + texel * radius * float2( 0, 1)).rgb * 0.25;
                c += SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + texel * radius * float2( 0,-1)).rgb * 0.25;

                return c;
            }

            // ------------------------------------------------------------
            // Chromatic shift
            // ------------------------------------------------------------
            float3 ChromaticShift(float2 uv, float amount)
            {
                float2 shift = float2(amount / 1024.0, 0);

                float r = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + shift).r;
                float g = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv).g;
                float b = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv - shift).b;

                return float3(r,g,b);
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

                // Source color
                float3 src = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv).rgb;

                // 1. Bright-pass
                float3 bright = BrightPass(src);

                // 2. Multi-radius bloom
                float3 b1 = Blur(uv, _Radius1);
                float3 b2 = Blur(uv, _Radius2);
                float3 b3 = Blur(uv, _Radius3);

                float3 bloom = (b1 + b2 + b3) * _Intensity;

                // 3. Chromatic bloom
                bloom += ChromaticShift(uv, _Chromatic) * 0.5;

                // 4. Lens dirt mask
                float dirt = SAMPLE_TEXTURE2D(_LensDirt, sampler_LensDirt, uv).r;
                bloom *= lerp(1.0, dirt, _DirtStrength);

                // 5. Combine with original
                float3 final = src + bloom;

                return float4(final, 1.0);
            }

            ENDHLSL
        }
    }
}
