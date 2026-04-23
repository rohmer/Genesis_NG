Shader "Hidden/Genesis/SphynxFractal"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
        [ShowInInspector][Enum(2D, 0, 3D, 1)] _UVMode("UV Mode", Float) = 0

        [IntRange]_Iterations("Iterations", Range(1, 200)) = 80
        _Scale("Scale", Float) = 3
        _Jitter("Jitter", Range(0,1)) = 0.1
        _DensityFalloff("Density Falloff", Float) = 6
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

            int   _Iterations;
            float _Scale;
            float _Jitter;
            float _DensityFalloff;
            int   _Seed;
            int   _UVMode;

            // ------------------------------------------------------------
            // Tiling
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
            // Sphynx-like IFS (triangular / sphinx-style tiling)
            // 4 affine maps, chosen by hash
            // ------------------------------------------------------------
            float SphynxFractal(float2 uv)
            {
                // Center in [0,1]^2
                float2 p = uv * 2.0 - 1.0;
                float density = 0.0;

                [loop]
                for (int i = 0; i < _Iterations; i++)
                {
                    float h = Hash(p + _Seed);

                    if (h < 0.25)
                    {
                        // Lower-left
                        p = 0.5 * p + float2(-0.25, -0.25);
                    }
                    else if (h < 0.5)
                    {
                        // Lower-right
                        p = 0.5 * p + float2(0.25, -0.25);
                    }
                    else if (h < 0.75)
                    {
                        // Upper-left skew
                        float2 q;
                        q.x = 0.5 * p.x - 0.25 * p.y;
                        q.y = 0.25 * p.x + 0.5 * p.y;
                        p = q + float2(-0.125, 0.25);
                    }
                    else
                    {
                        // Upper-right skew (mirror)
                        float2 q;
                        q.x = 0.5 * p.x + 0.25 * p.y;
                        q.y = -0.25 * p.x + 0.5 * p.y;
                        p = q + float2(0.125, 0.25);
                    }

                    // Jitter for organic variation
                    p += (Hash2(p + _Seed * 13.37) - 0.5) * _Jitter;

                    // Orbit density around origin
                    float r2 = dot(p, p);
                    density += exp(-r2 * _DensityFalloff);
                }

                return saturate(density / _Iterations);
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

                float2 tiledUV = ApplyTiling(uvs.xy, _Scale);

#ifdef CRT_2D
                if (_UVMode == 0)
                {
                    float v = SphynxFractal(tiledUV);
                    return float4(v, v, v, 1);
                }
#endif
                float v3 = SphynxFractal(tiledUV);
                return float4(v3, v3, v3, 1);
            }

            ENDHLSL
        }
    }
}
