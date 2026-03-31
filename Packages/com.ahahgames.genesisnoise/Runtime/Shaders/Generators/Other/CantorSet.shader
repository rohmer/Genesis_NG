Shader "Hidden/Genesis/CantorSet"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
        [ShowInInspector][Enum(2D, 0, 3D, 1)] _UVMode("UV Mode", Float) = 0

        _Scale("Scale", Float) = 3
        [IntRange]_Iterations("Iterations", Range(1, 12)) = 3
        _Softness("Softness", Range(0, 1)) = 1
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
            int   _Iterations;
            float _Softness;
            int   _Seed;
            int   _UVMode;

            // ------------------------------------------------------------
            // Tiling (local)
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
            // 1D Cantor membership (hard mask)
            // Classic middle‑third removal in base‑3
            // ------------------------------------------------------------
            float Cantor1D(float x, int iterations)
            {
                x = frac(x);

                [loop]
                for (int i = 0; i < iterations; i++)
                {
                    x *= 3.0;
                    if (x > 1.0 && x < 2.0)
                        return 0.0;      // removed middle third
                    x = frac(x);
                }

                return 1.0;              // survives all removals
            }

            // Softened version for nicer gradients
            float Cantor1DSoft(float x, int iterations, float softness)
            {
                if (softness <= 0.0)
                    return Cantor1D(x, iterations);

                x = frac(x);
                float v = 1.0;

                [loop]
                for (int i = 0; i < iterations; i++)
                {
                    x *= 3.0;
                    float dMid = abs(x - 1.5);     // distance to center of removed band
                    float band = smoothstep(0.5 + softness, 0.5 - softness, dMid);
                    v *= band;
                    x = frac(x);
                }

                return saturate(v);
            }

            // ------------------------------------------------------------
            // 2D Cantor dust (product of two 1D sets)
            // ------------------------------------------------------------
            float CantorDust(float2 uv, int iterations, float softness)
            {
                float cx = Cantor1DSoft(uv.x, iterations, softness);
                float cy = Cantor1DSoft(uv.y, iterations, softness);
                return cx * cy;
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

                float2 tiledUV = ApplyTiling(uvs.xy, _Scale);

#ifdef CRT_2D
                if (_UVMode == 0)
                {
                    float v = CantorDust(tiledUV, _Iterations, _Softness);
                    return float4(v, v, v, 1);
                }
#endif
                // 3D / Cube: still use XY slice
                float v3 = CantorDust(tiledUV, _Iterations, _Softness);
                return float4(v3, v3, v3, 1);
            }

            ENDHLSL
        }
    }
}
