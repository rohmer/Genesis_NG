Shader "Hidden/Genesis/Mosaic"
{
    Properties
    {
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        _CellCount("Cell Count", Range(2, 256)) = 32
        _Jitter("Jitter", Range(0, 1)) = 0.5
        _EdgeWidth("Edge Width", Range(0, 0.5)) = 0.05
        _EdgeSoftness("Edge Softness", Range(0, 1)) = 0.25
        _Seed("Seed", Range(0, 1000)) = 0

        _UseSource("Use Source Color", Range(0, 1)) = 1
        _SourceBlend("Source Blend", Range(0, 1)) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_Source);

            float _CellCount;
            float _Jitter;
            float _EdgeWidth;
            float _EdgeSoftness;
            float _Seed;

            float _UseSource;
            float _SourceBlend;

            // ------------------------------------------------------------
            float Hash11(float x)
            {
                x = frac(x * 0.1031 + _Seed * 0.017);
                x *= x + 33.33;
                x *= x + x;
                return frac(x);
            }

            float2 Hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7));
                return frac(sin(float2(n, n + 1.0)) * 43758.5453);
            }

            float3 HashColor(float id)
            {
                return float3(Hash11(id), Hash11(id + 17.1), Hash11(id + 91.7));
            }

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float3 gridUV = uv * _CellCount;
                float3 cell = floor(gridUV);

                float minDist = 1e9;
                float2 bestCell = 0;
                float2 bestCenter = 0;

                // Search 3×3 neighborhood
                for (int y = -1; y <= 1; y++)
                for (int x = -1; x <= 1; x++)
                {
                    float2 c = cell + float2(x, y);

                    float2 jitter = (Hash21(c) * 2 - 1) * _Jitter;
                    float2 center = c + 0.5 + jitter;

                    float2 diff = gridUV - center;
                    float d = dot(diff, diff);

                    if (d < minDist)
                    {
                        minDist = d;
                        bestCell = c;
                        bestCenter = center;
                    }
                }

                // Cell ID
                float id = Hash11(dot(bestCell, float2(17.13, 91.77)));

                // Random color per cell
                float3 randCol = HashColor(id);

                // Source sampling at the cell center (Substance behavior)
                float2 centerUV = bestCenter / _CellCount;
                float3 c=float3(centerUV.x,centerUV.y,0);
                float3 srcCol = SampleSource(c, i.direction);

                // Blend between random color and source color
                float3 cellColor = lerp(randCol, srcCol, _UseSource * _SourceBlend);

                // Edge mask
                float2 nearest = frac(gridUV) - 0.5;
                float edgeDist = min(abs(nearest.x), abs(nearest.y));

                float edge = smoothstep(_EdgeWidth + _EdgeSoftness,
                                        _EdgeWidth,
                                        edgeDist);

                float3 result = cellColor * edge;

                return float4(result, 1);
            }

            ENDHLSL
        }
    }
}