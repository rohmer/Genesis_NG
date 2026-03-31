Shader "Hidden/Genesis/Cobblestone"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
        [ShowInInspector][Enum(2D, 0, 3D, 1)] _UVMode("UV Mode", Float) = 0

        _Scale("Scale (stones per unit)", Float) = 6
        _CellJitter("Cell Jitter", Range(0,1)) = 0.6
        _StoneRoundness("Stone Roundness", Range(0.0,2.0)) = 1.0
        _StoneRadius("Base Stone Radius", Range(0.1,0.6)) = 0.35
        _RadiusVariation("Radius Variation", Range(0,0.5)) = 0.12
        _MortarWidth("Mortar Width", Range(0.0,0.5)) = 0.08
        _StoneHeight("Stone Height", Float) = 0.6
        _MortarDepth("Mortar Depth", Float) = 0.0
        _MicroDetail("Micro Detail", Float) = 0.12
        _MicroFreq("Micro Frequency", Float) = 8.0
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
            float _CellJitter;
            float _StoneRoundness;
            float _StoneRadius;
            float _RadiusVariation;
            float _MortarWidth;
            float _StoneHeight;
            float _MortarDepth;
            float _MicroDetail;
            float _MicroFreq;
            int   _Seed;
            int   _UVMode;

            // ------------------------------------------------------------
            // Local tiling replacement (no SetupNoiseTiling)
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
            // Hash helpers
            // ------------------------------------------------------------
            float Hash(float2 p)
            {
                p = float2(dot(p, float2(127.1, 311.7)),
                           dot(p, float2(269.5, 183.3)));
                return frac(sin(p.x + p.y) * 43758.5453);
            }

            float2 Hash2(float2 p)
            {
                p = float2(dot(p, float2(127.1, 311.7)),
                           dot(p, float2(269.5, 183.3)));
                float h = frac(sin(p.x + p.y) * 43758.5453);
                return float2(frac(h * 95.43), frac(h * 12.97));
            }

            // 2D rotated ellipse distance for stone roundness control
            float StoneDistance(float2 diff, float roundness)
            {
                // roundness < 1 -> elongated; >1 -> more circular/exponential
                // use a p-norm style distance to control shape
                float rx = abs(diff.x);
                float ry = abs(diff.y);
                // p-norm exponent derived from roundness
                float p = lerp(2.0, 0.5, saturate((roundness - 1.0) * 0.8 + 0.5));
                // avoid zero
                p = max(0.2, p);
                return pow(pow(rx, p) + pow(ry, p), 1.0 / p);
            }

            // ------------------------------------------------------------
            // Cellular (Worley) based cobblestone generator
            // Returns: height (0..1), edgeMask (0..1 where 1 is stone center)
            // ------------------------------------------------------------
            void CobbleCellular(float2 uv, out float height, out float edgeMask)
            {
                // Scale UV into cell grid
                float2 p = uv * _Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);

                float bestD = 1e9;
                float secondD = 1e9;
                float2 bestFeature = float2(0,0);
                float bestRadius = 0.0;
                float bestSeed = 0.0;

                // search 3x3 neighborhood
                [unroll]
                for (int y = -1; y <= 1; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 cell = ip + float2(x, y);
                        float2 rnd = Hash2(cell + _Seed);

                        // jittered feature point inside cell
                        float2 feature = float2(x, y) + (rnd - 0.5) * _CellJitter + 0.5;
                        float2 diff = fp - feature;

                        float d = dot(diff, diff); // squared distance

                        if (d < bestD)
                        {
                            secondD = bestD;
                            bestD = d;
                            bestFeature = feature;
                            // per-cell radius variation
                            bestRadius = _StoneRadius + (rnd.x - 0.5) * _RadiusVariation;
                            bestSeed = rnd.y;
                        }
                        else if (d < secondD)
                        {
                            secondD = d;
                        }
                    }
                }

                // convert squared distance to linear distance
                float dist = sqrt(bestD);

                // stone shape control: use StoneDistance with local coordinates
                float2 local = fp - bestFeature;
                // normalize local by cell scale (cells are 1 unit)
                float stoneDist = StoneDistance(local, _StoneRoundness);

                // map stoneDist to radius space
                float r = saturate(bestRadius);
                // edge mask: how far inside stone vs mortar
                float inside = smoothstep(r, r - _MortarWidth, stoneDist);

                // create stone height: center raised, mortar lower
                float stoneH = lerp(_MortarDepth, _StoneHeight, inside);

                // micro detail using a cheap FBM-like sum of hashed worley distances
                float micro = 0.0;
                float amp = 1.0;
                float freq = _MicroFreq;
                [unroll]
                for (int i = 0; i < 3; i++)
                {
                    // sample a small hash-based noise using the feature position to keep variation per stone
                    float2 samplePos = (bestFeature + ip) * freq * pow(2.0, i);
                    float h = Hash(samplePos + _Seed * 17.0);
                    micro += (h - 0.5) * amp;
                    amp *= 0.5;
                }
                micro *= _MicroDetail;

                height = saturate(stoneH + micro);
                edgeMask = inside;
            }

            // ------------------------------------------------------------
            // Normal from height (finite difference)
            // ------------------------------------------------------------
            float3 ComputeNormal(float2 uv)
            {
                float eps = 1.0 / 1024.0;
                float h0, m0;
                CobbleCellular(uv, h0, m0);

                float hx, hy;
                float h1, m1, h2, m2;
                CobbleCellular(uv + float2(eps, 0), h1, m1);
                CobbleCellular(uv + float2(0, eps), h2, m2);

                hx = h1 - h0;
                hy = h2 - h0;

                float3 n = normalize(float3(-hx, -hy, 1.0));
                return n;
            }

            // ------------------------------------------------------------
            // Fragment
            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                // get UVs using Genesis helper (keeps CRT conventions)
                float3 uvs = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);

                // apply tiling locally
                float2 tiledUV = ApplyTiling(uvs.xy, _Scale);

                // compute height and edge mask
                float h, edge;
    #ifdef CRT_2D
                if (_UVMode == 0)
                {
                    CobbleCellular(tiledUV, h, edge);
                }
                else
    #endif
                {
                    // 3D/Cube fallback: use XY slice
                    CobbleCellular(tiledUV, h, edge);
                }

                // compute normal
                float3 n = ComputeNormal(tiledUV);

                // pack outputs:
                // R = height, G = normal.x * 0.5 + 0.5, B = normal.y * 0.5 + 0.5, A = edge mask (stone center)
                float4 outCol = float4(h, n.x * 0.5 + 0.5, n.y * 0.5 + 0.5, edge);

                return outCol;
            }

            ENDHLSL
        }
    }
}
