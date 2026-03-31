Shader "Hidden/Genesis/Downsample2x"
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

                // Downsampled UV
                float2 baseUV = uv.xy * 2.0;

                // Pixel size (CRT macro handles 2D/3D/Cube)
                float3 texel = float3(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y, 1.0/_ScreenParams.z);

                // 4‑tap box filter (Substance‑style)
                float3 c =
                    tex2D(_Source, baseUV + texel * float3(-0.25, -0.25, 0)).rgb +
                    tex2D(_Source, baseUV + texel * float3( 0.25, -0.25, 0)).rgb +
                    tex2D(_Source, baseUV + texel * float3(-0.25,  0.25, 0)).rgb +
                    tex2D(_Source, baseUV + texel * float3( 0.25,  0.25, 0)).rgb;

                return float4(c * 0.25, 1.0);
            }

            ENDHLSL
        }
    }
}
