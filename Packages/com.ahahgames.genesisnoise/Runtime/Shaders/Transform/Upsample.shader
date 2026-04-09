Shader "Hidden/Genesis/Upsample"
{
    Properties
    {
        [Tooltip(Low resolution source input)]
        _Source("Source", 2D) = "white" {}

        [Tooltip(Sharpen strength)]
        _Sharpen("Sharpen", Range(0, 2)) = 0.6
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            sampler2D _Source;
            float4 _Source_TexelSize;
            float  _Sharpen;

            // ---------------------------------------------------------
            // Catmull‑Rom bicubic kernel
            // ---------------------------------------------------------
            float cubic(float x)
            {
                x = abs(x);
                if (x < 1.0)
                    return 1.0 - 2.0 * x * x + x * x * x;
                else if (x < 2.0)
                    return 4.0 - 8.0 * x + 5.0 * x * x - x * x * x;
                return 0.0;
            }

            float4 bicubicSample(sampler2D tex, float2 uv)
            {
                float2 texel = _Source_TexelSize.xy;
                float2 p = uv / texel;
                float2 f = frac(p);
                p -= f;

                float4 sum = 0.0;
                float total = 0.0;

                [unroll]
                for (int j = -1; j <= 2; j++)
                {
                    [unroll]
                    for (int i = -1; i <= 2; i++)
                    {
                        float w = cubic(i - f.x) * cubic(j - f.y);
                        float2 coord = (p + float2(i, j)) * texel;
                        sum += tex2D(tex, coord) * w;
                        total += w;
                    }
                }

                return sum / total;
            }

            // ---------------------------------------------------------
            // Contrast‑Adaptive Sharpen (CAS‑style)
            // ---------------------------------------------------------
            float4 casSharpen(float2 uv, float4 c)
            {
                float2 o = _Source_TexelSize.xy;

                float4 n = tex2D(_Source, uv + float2(0, -o.y));
                float4 s = tex2D(_Source, uv + float2(0,  o.y));
                float4 e = tex2D(_Source, uv + float2( o.x, 0));
                float4 w = tex2D(_Source, uv + float2(-o.x, 0));

                float4 minN = min(min(n, s), min(e, w));
                float4 maxN = max(max(n, s), max(e, w));

                float4 sharp = (c - minN) / (maxN - minN + 1e-5);
                sharp = saturate(sharp);

                return lerp(c, sharp, _Sharpen);
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float4 c = bicubicSample(_Source, uv.xy);
                c = casSharpen(uv.xy, c);

                return c;
            }

            ENDHLSL
        }
    }
}
