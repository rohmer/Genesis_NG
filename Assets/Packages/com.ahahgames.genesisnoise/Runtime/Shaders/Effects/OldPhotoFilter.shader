Shader "Hidden/Genesis/OldPhotoFilter"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        _Source("Source Texture", 2D) = "white" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
        [ShowInInspector][Enum(2D,0,3D,1)] _UVMode("UV Mode", Float) = 0

        _Sepia("Sepia Strength", Range(0,1)) = 0.8
        _Fade("Fade Amount", Range(0,1)) = 0.4
        _Vignette("Vignette Strength", Range(0,2)) = 1.2
        _Grain("Film Grain", Range(0,1)) = 0.35
        _Dust("Dust Amount", Range(0,1)) = 0.25
        _Scratches("Scratches Amount", Range(0,1)) = 0.3
        _PaperTint("Paper Tint", Color) = (0.95,0.88,0.75,1)

        _Scale("UV Scale", Float) = 1.0
        _Seed("Seed", Int) = 42
        _Time("Time", Float) = 0
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

            float _Sepia;
            float _Fade;
            float _Vignette;
            float _Grain;
            float _Dust;
            float _Scratches;
            float4 _PaperTint;
            float _Scale;
            int _Seed;
            float _Time;
            int _UVMode;

            // ------------------------------------------------------------
            // Hash helpers
            // ------------------------------------------------------------
            float hash11(float n)
            {
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7));
                return frac(sin(float2(n, n + 1.234)) * 43758.5453);
            }

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
            // Film grain (animated)
            // ------------------------------------------------------------
            float Grain(float2 uv)
            {
                float2 h = hash21(uv * 800.0 + float2(_Time * 12.3, _Seed));
                return h.x * 2.0 - 1.0;
            }

            // ------------------------------------------------------------
            // Dust specks
            // ------------------------------------------------------------
            float Dust(float2 uv)
            {
                float2 p = floor(uv * 600.0);
                float d = hash11(dot(p, float2(12.9898, 78.233)));
                return step(0.995, d); // sparse white specks
            }

            // ------------------------------------------------------------
            // Vertical scratches
            // ------------------------------------------------------------
            float Scratches(float2 uv)
            {
                float x = frac(uv.x * 40.0);
                float s = smoothstep(0.02, 0.0, abs(x - 0.5));
                float flicker = hash11(_Time * 0.5 + uv.y * 10.0);
                return s * flicker;
            }

            // ------------------------------------------------------------
            // Sepia tone
            // ------------------------------------------------------------
            float3 Sepia(float3 c)
            {
                float3 s;
                s.r = dot(c, float3(0.393, 0.769, 0.189));
                s.g = dot(c, float3(0.349, 0.686, 0.168));
                s.b = dot(c, float3(0.272, 0.534, 0.131));
                return lerp(c, s, _Sepia);
            }

            // ------------------------------------------------------------
            // Vignette
            // ------------------------------------------------------------
            float VignetteMask(float2 uv)
            {
                float2 p = uv * 2.0 - 1.0;
                float d = dot(p, p);
                return 1.0 - smoothstep(0.4, 1.0, d * _Vignette);
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

                // 1. Fade (old film loses contrast)
                src = lerp(src, float3(0.5,0.5,0.5), _Fade);

                // 2. Sepia tone
                src = Sepia(src);

                // 3. Paper tint
                src *= _PaperTint.rgb;

                // 4. Grain
                float g = Grain(uv) * _Grain;
                src += g * 0.1;

                // 5. Dust
                float d = Dust(uv) * _Dust;
                src += d;

                // 6. Scratches
                float s = Scratches(uv) * _Scratches;
                src += s * 0.2;

                // 7. Vignette
                float v = VignetteMask(uv);
                src *= v;

                return float4(saturate(src), 1.0);
            }

            ENDHLSL
        }
    }
}
