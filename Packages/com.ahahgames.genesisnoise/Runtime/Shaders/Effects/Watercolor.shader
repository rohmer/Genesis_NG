Shader "Hidden/Genesis/Watercolor"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
        [ShowInInspector][Enum(2D, 0, 3D, 1)] _UVMode("UV Mode", Float) = 0

        _Scale("Scale", Vector) = (4,4,0,0)
        [IntRange]_Layers("Layers", Range(1, 24)) = 8
        _Bleed("Bleed", Range(0,1)) = 0.45
        _Flow("Flow Strength", Range(0,1)) = 0.35
        _EdgeDark("Edge Darkening", Range(0,2)) = 1.2
        _PaperGrain("Paper Grain", Range(0,1)) = 0.25
        _GrainScale("Grain Scale", Float) = 120.0
        _Saturation("Saturation", Range(0,2)) = 1.1
        _Tint("Tint", Color) = (0.6,0.2,0.15,1)
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

            float2 _Scale;
            int _Layers;
            float _Bleed;
            float _Flow;
            float _EdgeDark;
            float _PaperGrain;
            float _GrainScale;
            float _Saturation;
            float4 _Tint;
            int _Seed;
            int _UVMode;

            float hash11(float n)
            {
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7));
                return frac(sin(float2(n, n + 1.2345)) * 43758.5453);
            }

            float2 ApplyTiling(float2 uv, float2 period)
            {
#ifdef _TILINGMODE_TILED
                return frac(uv * period);
#else
                return uv;
#endif
            }

            float2x2 rot2(float a)
            {
                float c = cos(a);
                float s = sin(a);
                return float2x2(c, -s, s, c);
            }

            float2 worleyF1F2(float2 uv, float scale)
            {
                float2 p = uv * scale;
                float2 ip = floor(p);
                float2 fp = frac(p);

                float best = 1e9;
                float second = 1e9;

                [unroll]
                for (int y = -1; y <= 1; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 cell = ip + float2(x, y);
                        float2 rnd = hash21(cell + _Seed);
                        float2 feature = float2(x, y) + rnd;
                        float2 diff = fp - feature;
                        float d = dot(diff, diff);
                        if (d < best)
                        {
                            second = best;
                            best = d;
                        }
                        else if (d < second)
                        {
                            second = d;
                        }
                    }
                }

                return float2(sqrt(best), sqrt(second));
            }

            float fbm(float2 p)
            {
                float v = 0.0;
                float a = 0.5;
                float f = 1.0;
                [unroll]
                for (int i = 0; i < 5; i++)
                {
                    v += a * (hash21(p * f + float2(i, i*1.7)).x * 2.0 - 1.0);
                    f *= 2.0;
                    a *= 0.5;
                }
                return v;
            }

            float2 flowField(float2 p)
            {
                float2 h = hash21(floor(p * 1.5) + _Seed);
                float angle = h.x * 6.2831853;
                float mag = h.y * 2.0 - 1.0;
                return float2(cos(angle), sin(angle)) * mag;
            }

            void blotchLayer(float2 uv, float2 offset, out float pigment, out float edge)
            {
                float2 p = uv + offset;

                float2 q = p;
                [unroll]
                for (int i = 0; i < 3; i++)
                {
                    q += flowField(q * 2.0 + float2(i, i*1.3)) * _Flow * 0.12;
                }

                float2 d = worleyF1F2(q, 1.0);
                float d1 = d.x;
                float d2 = d.y;

                float radius = 0.35 + hash21(offset).x * 0.25;
                float mask = smoothstep(radius + _Bleed, radius - _Bleed * 0.5, d1);

                float edgeFactor = saturate((d2 - d1) * 3.0);
                edgeFactor = pow(edgeFactor, 0.6);

                pigment = mask;
                edge = edgeFactor;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 raw = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);
                float2 uv = ApplyTiling(raw.xy, _Scale);

                float3 paper = float3(0.96, 0.95, 0.9);
                float3 accum = paper;
                float3 tint = _Tint.rgb * _Saturation;

                [loop]
                for (int L = 0; L < _Layers; L++)
                {
                    float2 offset = hash21(float2(L, _Seed)) - 0.5;
                    offset *= 0.6;

                    float pigment, edge;
                    blotchLayer(uv, offset, pigment, edge);

                    float3 layerColor = tint * (0.8 + hash21(offset + float2(7.7, 3.3)).x * 0.4);
                    layerColor *= lerp(1.0, 1.0 + _EdgeDark * 0.6, edge);

                    float layerA = pigment * (1.0 - float(L) / max(1, _Layers)) * 0.9;

                    accum = lerp(accum, accum * (1.0 - layerA) + layerColor * layerA, layerA);
                }

                float grain = fbm(uv * _GrainScale) * 0.5 + 0.5;
                accum = lerp(accum, accum * (1.0 - _PaperGrain) + accum * grain * _PaperGrain, _PaperGrain);

                return float4(saturate(accum), 1.0);
            }

            ENDHLSL
        }
    }
}
