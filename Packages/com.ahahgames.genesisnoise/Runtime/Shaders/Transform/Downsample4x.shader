Shader "Hidden/Genesis/Downsample4X"
{
    Properties
    {
        [Tooltip(Source texture to downsample)]
        _Source("Source", 2D) = "white" {}
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

            // ---------------------------------------------------------
            // 16‑tap box downsample (4× reduction)
            // ---------------------------------------------------------
            float4 downsample16Tap(float2 uv)
            {
                // Half‑texel offsets for a 4×4 grid
                float2 o = _Source_TexelSize.xy * 0.5;

                float4 sum = 0.0;

                [unroll]
                for (int y = -1; y <= 2; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 2; x++)
                    {
                        float2 offset = float2(x, y) * o;
                        sum += tex2D(_Source, uv + offset);
                    }
                }

                return sum * (1.0 / 16.0);
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

                return downsample16Tap(uv.xy);
            }

            ENDHLSL
        }
    }
}
