Shader "Hidden/Genesis/Poliginization"
{
    Properties
    {
        [InlineTexture]_Source_2D("Source_2D", 2D) = "white" {}

        [Tooltip(Number of cells used to triangulate the source image)]_CellDensity("Cell Density", Range(4, 256)) = 28
        [Tooltip(Random offset applied to each triangle vertex)]_Jitter("Vertex Jitter", Range(0, 1)) = 0.7
        [Tooltip(Blends between barycentric vertex colors and a flat triangle color)]_FlatShading("Flat Shading", Range(0, 1)) = 1
        [Tooltip(Darkens the seams between triangles)]_EdgeDarkness("Edge Darkness", Range(0, 1)) = 0.25
        [Tooltip(Thickness of the triangle seams)]_EdgeWidth("Edge Width", Range(0, 0.2)) = 0.05
        [Tooltip(Softens the triangle seam transition)]_EdgeSoftness("Edge Softness", Range(0, 0.2)) = 0.02
        [Tooltip(Seed used for the vertex jitter pattern)]_Seed("Seed", Range(0, 1000)) = 0
    }

    SubShader 
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        { 
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            TEXTURE2D(_Source_2D);
            SAMPLER(sampler_Source_2D);

            float _CellDensity;
            float _Jitter;
            float _FlatShading;
            float _EdgeDarkness;
            float _EdgeWidth;
            float _EdgeSoftness;
            float _Seed;

            float Hash12(float2 p)
            {
                float h = dot(p, float2(127.1, 311.7));
                return frac(sin(h + _Seed * 19.19) * 43758.5453123);
            }

            float2 Hash22(float2 p)
            {
                return float2(Hash12(p + 13.17), Hash12(p + 71.73));
            }

            float2 JitteredVertex(float2 gridVertex)
            {
                float2 offset = (Hash22(gridVertex) * 2.0 - 1.0) * (0.45 * _Jitter);
                return gridVertex + offset;
            }

            bool ComputeBarycentric(float2 p, float2 a, float2 b, float2 c, out float3 barycentric)
            {
                float denominator = (b.y - c.y) * (a.x - c.x) + (c.x - b.x) * (a.y - c.y);
                if (abs(denominator) < 1e-5)
                {
                    barycentric = float3(1, 0, 0);
                    return false;
                }

                float w0 = ((b.y - c.y) * (p.x - c.x) + (c.x - b.x) * (p.y - c.y)) / denominator;
                float w1 = ((c.y - a.y) * (p.x - c.x) + (a.x - c.x) * (p.y - c.y)) / denominator;
                float w2 = 1.0 - w0 - w1;

                barycentric = float3(w0, w1, w2);
                return all(barycentric >= -1e-4) && all(barycentric <= 1.0001);
            }

            float4 SampleSource(float2 uv)
            {
                return SAMPLE_TEXTURE2D_LOD(_Source_2D, sampler_Source_2D, saturate(uv), 0);
            }

            float4 genesis(v2f_customrendertexture i)
            {
                float2 uv = i.localTexcoord.xy;
                float cellDensity = max(2.0, _CellDensity);
                float2 gridPosition = uv * cellDensity;
                float2 cell = floor(gridPosition);
                float2 localPosition = gridPosition;

                float2 p00 = JitteredVertex(cell);
                float2 p10 = JitteredVertex(cell + float2(1, 0));
                float2 p01 = JitteredVertex(cell + float2(0, 1));
                float2 p11 = JitteredVertex(cell + float2(1, 1));

                float2 v0;
                float2 v1;
                float2 v2;
                float3 barycentric;
                bool insideTriangle = false;

                if (Hash12(cell + 0.5) < 0.5)
                {
                    insideTriangle = ComputeBarycentric(localPosition, p00, p10, p11, barycentric);
                    if (insideTriangle)
                    {
                        v0 = p00;
                        v1 = p10;
                        v2 = p11;
                    }
                    else
                    {
                        ComputeBarycentric(localPosition, p00, p11, p01, barycentric);
                        v0 = p00;
                        v1 = p11;
                        v2 = p01;
                    }
                }
                else
                {
                    insideTriangle = ComputeBarycentric(localPosition, p00, p10, p01, barycentric);
                    if (insideTriangle)
                    {
                        v0 = p00;
                        v1 = p10;
                        v2 = p01;
                    }
                    else
                    {
                        ComputeBarycentric(localPosition, p10, p11, p01, barycentric);
                        v0 = p10;
                        v1 = p11;
                        v2 = p01;
                    }
                }

                float2 uv0 = v0 / cellDensity;
                float2 uv1 = v1 / cellDensity;
                float2 uv2 = v2 / cellDensity;
                float2 centroidUv = (v0 + v1 + v2) / (3.0 * cellDensity);

                float4 c0 = SampleSource(uv0);
                float4 c1 = SampleSource(uv1);
                float4 c2 = SampleSource(uv2);
                float4 smoothColor = c0 * barycentric.x + c1 * barycentric.y + c2 * barycentric.z;
                float4 flatColor = SampleSource(centroidUv);
                float4 result = lerp(smoothColor, flatColor, _FlatShading);

                float seamDistance = min(barycentric.x, min(barycentric.y, barycentric.z));
                float seamMask = 1.0 - smoothstep(_EdgeWidth, _EdgeWidth + max(_EdgeSoftness, 1e-4), seamDistance);
                result.rgb *= lerp(1.0, 1.0 - _EdgeDarkness, seamMask);

                return result;
            }
            ENDHLSL
        }
    }
}
