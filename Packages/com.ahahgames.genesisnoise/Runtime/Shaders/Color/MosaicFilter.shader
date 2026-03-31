Shader "Hidden/Genesis/MosaicFilter"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        _Source("Source Texture", 2D) = "white" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
        [ShowInInspector][Enum(2D,0,3D,1)] _UVMode("UV Mode", Float) = 0

        _TileCount("Tiles Per Axis", Range(2,256)) = 32
        _Jitter("Tile Jitter", Range(0,1)) = 0.25
        _EdgeWidth("Edge Width", Range(0,0.2)) = 0.05
        _EdgeDark("Edge Darkening", Range(0,2)) = 1.0
        _Warp("Shape Warp", Range(0,1)) = 0.2
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

            int _TileCount;
            float _Jitter;
            float _EdgeWidth;
            float _EdgeDark;
            float _Warp;
            float _Scale;
            int _Seed;
            int _UVMode;

            // ------------------------------------------------------------
            // Hash helpers
            // ------------------------------------------------------------
            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7));
                return frac(sin(float2(n, n + 1.2345)) * 43758.5453);
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
            // Mosaic UV computation
            // ------------------------------------------------------------
            float4 MosaicSample(float2 uv)
            {
                float tiles = max(2, (float)_TileCount);

                float2 gridUV = uv * tiles;
                float2 cell = floor(gridUV);
                float2 fracUV = frac(gridUV);

                // Per‑tile jitter
                float2 jitter = (hash21(cell + _Seed) - 0.5) * _Jitter;

                // Warp tile shape
                float2 warped = fracUV + sin(fracUV * 6.2831853 + cell * 0.3) * _Warp;

                // Clamp warp to tile
                warped = saturate(warped);

                // Sample position inside tile
                float2 sampleUV = (cell + jitter + 0.5) / tiles;

                float4 col = SAMPLE_TEXTURE2D(_Source, sampler_Source, sampleUV);

                // Edge mask
                float edge = min(min(warped.x, warped.y), min(1.0 - warped.x, 1.0 - warped.y));
                float edgeMask = smoothstep(_EdgeWidth, _EdgeWidth * 0.5, edge);

                // Darken edges
                col.rgb = lerp(col.rgb * (1.0 - _EdgeDark * 0.5), col.rgb, edgeMask);

                return col;
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

#ifdef CRT_2D
                if (_UVMode == 0)
                {
                    return MosaicSample(uv);
                }
#endif

                return MosaicSample(uv);
            }

            ENDHLSL
        }
    }
}
