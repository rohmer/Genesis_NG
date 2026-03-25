Shader "Hidden/Genesis/BlurHQ"
{
    Properties
    {
        [Tooltip(Original input)]
        _Source("Source", 2D) = "white" {}

        [Tooltip(Downsample x2 input)]
        _Down1("Downsample 1", 2D) = "gray" {}

        [Tooltip(Downsample x4 input)]
        _Down2("Downsample 2", 2D) = "gray" {}

        [Tooltip(Blend strength of HQ blur)]
        _Intensity("Intensity", Float) = 1.0

        [Tooltip(Sharpness of upsample blending)]
        _Sharpness("Sharpness", Float) = 0.5
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
            sampler2D _Down1;
            sampler2D _Down2;

            float _Intensity;
            float _Sharpness;

            float3 SampleHQ(sampler2D tex, float2 uv)
            {
                // 3x3 Gaussian kernel
                float2 o = 1.0 / float2(1024,1024); // replaced by CRT macro if needed

                float3 c = 0;
                c += tex2D(tex, uv + o * float2(-1,-1)).rgb * 1.0;
                c += tex2D(tex, uv + o * float2( 0,-1)).rgb * 2.0;
                c += tex2D(tex, uv + o * float2( 1,-1)).rgb * 1.0;

                c += tex2D(tex, uv + o * float2(-1, 0)).rgb * 2.0;
                c += tex2D(tex, uv + o * float2( 0, 0)).rgb * 4.0;
                c += tex2D(tex, uv + o * float2( 1, 0)).rgb * 2.0;

                c += tex2D(tex, uv + o * float2(-1, 1)).rgb * 1.0;
                c += tex2D(tex, uv + o * float2( 0, 1)).rgb * 2.0;
                c += tex2D(tex, uv + o * float2( 1, 1)).rgb * 1.0;

                return c / 16.0;
            }

            float4 mixture(v2f_customrendertexture IN) : SV_Target
            {
                float3 uv = IN.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float2 uv2 = uv.xy;

                // Base level
                float3 base = SampleHQ(_Source, uv2);

                // Downsample level 1 (2x)
                float3 low1 = SampleHQ(_Down1, uv2 * 0.5);

                // Downsample level 2 (4x)
                float3 low2 = SampleHQ(_Down2, uv2 * 0.25);

                // Reconstruct pyramid
                float3 up1 = lerp(low1, base, _Sharpness);
                float3 up2 = lerp(low2, up1, _Sharpness);

                float3 result = lerp(base, up2, _Intensity);

                return float4(result, 1.0);
            }

            ENDHLSL
        }
    }
}
