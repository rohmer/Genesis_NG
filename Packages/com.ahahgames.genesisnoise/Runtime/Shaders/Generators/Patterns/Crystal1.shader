Shader "Hidden/Genesis/Crystal1"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 0
        [ShowInInspector][Enum(2D, 0, 3D, 1)] _UVMode("UV Mode", Float) = 0

        _Scale("Scale", Float) = 8
        _Jitter("Jitter", Range(0,1)) = 1
        _FacetSharpness("Facet Sharpness", Float) = 2
        _MicroDetail("Micro Detail", Float) = 0.25
        _MicroFreq("Micro Frequency", Float) = 4
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
            float _FacetSharpness;
            float _MicroDetail;
            float _MicroFreq;
            int _Seed;
            int _UVMode;
            float _Lacunarity, _Frequency;
            // ------------------------------------------------------------
            // Tiling replacement for SetupNoiseTiling
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
            float2 Hash2(float2 p)
            {
                p = float2(dot(p, float2(127.1, 311.7)),
                           dot(p, float2(269.5, 183.3)));
                return frac(sin(p) * 43758.5453);
            }

            // ------------------------------------------------------------
            // Worley F1
            // ------------------------------------------------------------
            float WorleyF1(float2 uv)
            {
                float2 p = uv * _Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);

                float d = 1e9;

                [unroll]
                for (int y = -1; y <= 1; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 cell = ip + float2(x, y);
                        float2 rnd = Hash2(cell + _Seed);

                        float2 feature = float2(x, y) + rnd * _Jitter;
                        float2 diff = fp - feature;

                        d = min(d, dot(diff, diff));
                    }
                }

                return sqrt(d);
            }

            // ------------------------------------------------------------
            // Micro FBM
            // ------------------------------------------------------------
            float MicroFBM(float2 uv)
            {
                float sum = 0;
                float a = 0.5;
                float f = 1;

                [unroll]
                for (int i = 0; i < 3; i++)
                {
                    sum += a * WorleyF1(uv * f + _Seed * 13.37);
                    f *= 2;
                    a *= 0.5;
                }

                return sum;
            }

            // ------------------------------------------------------------
            // Crystal 1 Height
            // ------------------------------------------------------------
            float Crystal1(float2 uv)
            {
                float h = WorleyF1(uv);

                // Facet shaping (Substance Crystal 1 signature)
                h = pow(h, _FacetSharpness);

                // Micro breakup
                h += MicroFBM(uv * _MicroFreq) * _MicroDetail;

                return h;
            }

            // ------------------------------------------------------------
            // Fragment
            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uvs = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);

                float2 tiledUV = ApplyTiling(uvs.xy, _Scale);

#ifdef CRT_2D
                if (_UVMode == 0)
                {
                    float h = Crystal1(tiledUV);
                    return float4(h, h, h, 1);
                }
#endif

                // 3D mode: use XY plane
                float h3 = Crystal1(tiledUV);
                return float4(h3, h3, h3, 1);
            }

            ENDHLSL
        }
    }
}
