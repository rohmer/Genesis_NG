Shader "Hidden/Genesis/Downsample4x"
{
    Properties
    {
        [Tooltip(Input texture)]
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
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            sampler2D _Source;

            float4 genesis(v2f_customrendertexture i)
            {
                float3 uv = i.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                // Downsampled UV (4x)
                float2 baseUV = uv.xy * 4.0;

                // Pixel size
                
                float2 texel = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y);

                // Offsets for 4x4 grid
                float2 o = texel * 0.5;

                float3 c = 0.0;

                // 16‑tap box filter
                [unroll]
                for (int y = -1; y <= 2; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 2; x++)
                    {
                        float2 offset = float2(x, y) * o;
                        c += tex2D(_Source, baseUV + offset).rgb;
                    }
                }

                c *= 1.0 / 16.0;

                return float4(c, 1.0);
            }

            ENDHLSL
        }
    }
}
