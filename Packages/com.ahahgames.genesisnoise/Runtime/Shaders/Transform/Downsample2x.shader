Shader "Hidden/Genesis/Downsample2x"
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
            float4 _Source_TexelSize;   // Provided by Unity

            // ---------------------------------------------------------
            // 4‑tap box downsample
            // ---------------------------------------------------------
            float4 downsample4Tap(float2 uv)
            {
                float2 o = _Source_TexelSize.xy * 0.5;

                float4 c0 = tex2D(_Source, uv + float2(-o.x, -o.y));
                float4 c1 = tex2D(_Source, uv + float2( o.x, -o.y));
                float4 c2 = tex2D(_Source, uv + float2(-o.x,  o.y));
                float4 c3 = tex2D(_Source, uv + float2( o.x,  o.y));

                return (c0 + c1 + c2 + c3) * 0.25;
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

                return downsample4Tap(uv.xy);
            }

            ENDHLSL
        }
    }
}
