Shader "Hidden/Genesis/RauzyFractal"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
        [ShowInInspector][Enum(2D, 0, 3D, 1)] _UVMode("UV Mode", Float) = 0

        _Iterations("Iterations", Range(1, 200)) = 60
        _Contraction("Contraction", Range(0.1, 0.9)) = 0.72
        _Jitter("Jitter", Range(0,1)) = 0.15
        _Seed("Seed", Int) = 42
        _Scale("Scale", Float) = 4
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

            int _Iterations;
            float _Contraction;
            float _Jitter;
            float _Scale;
            int _Seed;
            int _UVMode;

            // ------------------------------------------------------------
            // Tiling (local replacement for SetupNoiseTiling)
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
            // Hash
            // ------------------------------------------------------------
            float Hash(float2 p)
            {
                p = float2(dot(p, float2(127.1, 311.7)),
                           dot(p, float2(269.5, 183.3)));
                return frac(sin(p.x + p.y) * 43758.5453);
            }

            float2 Hash2(float2 p)
            {
                float h = Hash(p);
                return float2(frac(h * 95.43), frac(h * 12.97));
            }

            // ------------------------------------------------------------
            // Rauzy IFS (Tribonacci Rauzy)
            // Three affine maps with contraction < 1
            // ------------------------------------------------------------
            float Rauzy(float2 uv)
            {
                float2 p = uv;
                float density = 0;

                float c = _Contraction;

                [loop]
                for (int i = 0; i < _Iterations; i++)
                {
                    float h = Hash(p + _Seed);

                    // Select one of three affine maps
                    if (h < 0.33)
                    {
                        p = float2(c * p.x,
                                   c * p.y);
                    }
                    else if (h < 0.66)
                    {
                        p = float2(c * p.x + (1 - c),
                                   c * p.y);
                    }
                    else
                    {
                        p = float2(c * p.x,
                                   c * p.y + (1 - c));
                    }

                    // Jitter for organic variation
                    p += (Hash2(p + _Seed * 13.37) - 0.5) * _Jitter;

                    // Density accumulation
                    density += exp(-dot(p, p) * 4.0);
                }

                return saturate(density / _Iterations);
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
                    float v = Rauzy(tiledUV);
                    return float4(v, v, v, 1);
                }
#endif

                float v3 = Rauzy(tiledUV);
                return float4(v3, v3, v3, 1);
            }

            ENDHLSL
        }
    }
}
