Shader "Hidden/Genesis/MinkowskiSausagePro"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
        [ShowInInspector][Enum(2D, 0, 3D, 1)] _UVMode("UV Mode", Float) = 0

        _Scale("Scale", Float) = 8
        _Jitter("Jitter", Range(0,1)) = 1
        _MinkowskiPower("Minkowski Power", Range(0.1,4)) = 0.5
        _Contrast("Contrast", Float) = 1
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
            float _Jitter;
            float _MinkowskiPower;
            float _Contrast;
            int   _Seed;
            int   _UVMode;

            // -----------------------------
            // Tiling (local replacement)
            // -----------------------------
            float2 ApplyTiling(float2 uv, float period)
            {
#ifdef _TILINGMODE_TILED
                return frac(uv * period);
#else
                return uv;
#endif
            }

            // -----------------------------
            // Hash
            // -----------------------------
            float2 Hash2(float2 p)
            {
                p = float2(dot(p, float2(127.1, 311.7)),
                           dot(p, float2(269.5, 183.3)));
                return frac(sin(p) * 43758.5453);
            }

            // -----------------------------
            // Minkowski distance
            // p < 1  → sausage-like shapes
            // -----------------------------
            float MinkowskiDist(float2 d, float p)
            {
                d = abs(d);
                float a = pow(d.x, p);
                float b = pow(d.y, p);
                return pow(a + b, 1.0 / p);
            }

            // -----------------------------
            // Minkowski Worley F1
            // -----------------------------
            float MinkowskiWorleyF1(float2 uv)
            {
                float2 p  = uv * _Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);

                float d = 1e9;
                float pwr = _MinkowskiPower;

                [unroll]
                for (int y = -1; y <= 1; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 cell = ip + float2(x, y);
                        float2 rnd  = Hash2(cell + _Seed);

                        float2 feature = float2(x, y) + rnd * _Jitter;
                        float2 diff    = fp - feature;

                        float dist = MinkowskiDist(diff, pwr);
                        d = min(d, dist);
                    }
                }

                return d;
            }

            // -----------------------------
            // Minkowski Sausage pattern
            // -----------------------------
            float MinkowskiSausage(float2 uv)
            {
                float d = MinkowskiWorleyF1(uv);

                // Invert & contrast for nice bands
                float v = 1.0 - saturate(d);
                v = pow(v, _Contrast);

                return v;
            }

            // -----------------------------
            // Fragment
            // -----------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uvs = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);

                float2 tiledUV = ApplyTiling(uvs.xy, _Scale);

#ifdef CRT_2D
                if (_UVMode == 0)
                {
                    float h = MinkowskiSausage(tiledUV);
                    return float4(h, h, h, 1);
                }
#endif
                // 3D mode: still use XY slice for now
                float h3 = MinkowskiSausage(tiledUV);
                return float4(h3, h3, h3, 1);
            }

            ENDHLSL
        }
    }
}
