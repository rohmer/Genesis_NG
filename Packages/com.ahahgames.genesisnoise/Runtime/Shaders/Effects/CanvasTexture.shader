Shader "Hidden/Genesis/CanvasTexture"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
        [ShowInInspector][Enum(2D,0,3D,1)] _UVMode("UV Mode", Float) = 0

        _Scale("Scale", Float) = 8.0
        _WeaveStrength("Weave Strength", Range(0,1)) = 0.55
        _FiberNoise("Fiber Noise", Range(0,1)) = 0.35
        _Roughness("Roughness", Range(0,1)) = 0.4
        _Tint("Tint", Color) = (0.95,0.92,0.88,1)
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

            float _Scale;
            float _WeaveStrength;
            float _FiberNoise;
            float _Roughness;
            float4 _Tint;
            int _Seed;
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
            // Fiber noise (FBM)
            // ------------------------------------------------------------
            float fbm(float2 p)
            {
                float v = 0.0;
                float a = 0.5;
                float f = 1.0;

                [unroll]
                for (int i = 0; i < 5; i++)
                {
                    float2 h = hash21(p * f + float2(i, i * 1.7));
                    v += (h.x * 2.0 - 1.0) * a;
                    f *= 2.0;
                    a *= 0.5;
                }
                return v;
            }

            // ------------------------------------------------------------
            // Canvas weave pattern (warp/weft)
            // ------------------------------------------------------------
            float Weave(float2 uv)
            {
                float2 p = uv * _Scale;

                float warp = abs(sin(p.x * 6.2831853));
                float weft = abs(sin(p.y * 6.2831853));

                float weave = max(warp, weft);

                return weave;
            }

            // ------------------------------------------------------------
            // Final canvas texture
            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uvs = GetNoiseUVs(
                    i,
                    SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction),
                    _Seed
                );

                float2 uv = ApplyTiling(uvs.xy, _Scale);

                // Base weave
                float weave = Weave(uv) * _WeaveStrength;

                // Fiber noise
                float fiber = fbm(uv * 12.0) * _FiberNoise;

                // Micro roughness
                float rough = fbm(uv * 40.0) * _Roughness;

                float canvas = weave + fiber + rough;

                // Normalize
                canvas = canvas * 0.5 + 0.5;

                // Tint
                float3 col = _Tint.rgb * canvas;

                return float4(col, 1.0);
            }

            ENDHLSL
        }
    }
}
