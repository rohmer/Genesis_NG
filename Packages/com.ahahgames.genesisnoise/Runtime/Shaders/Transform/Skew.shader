Shader "Hidden/Genesis/Skew"
{
    Properties
    {
        // Input texture
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Skew amounts
        // XSkew: how much Y affects X
        // YSkew: how much X affects Y
        _XSkew("X Skew", Range(-2, 2)) = 0.0
        _YSkew("Y Skew", Range(-2, 2)) = 0.0
        _ZSkew("Z Skew", Range(-2,2))=0.0
        // Pivot for skewing
        _Pivot("Pivot", Vector) = (0.5, 0.5, 0.5, 0)

        // Wrap mode
        [Enum(Wrap,0,Clamp,1)]_Mode("Wrap Mode", Int) = 0 // 0 = wrap, 1 = clamp
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_Source);

            float _XSkew;
            float _YSkew;
            float _ZSkew;
            float4 _Pivot;
            int _Mode;

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float3 WrapOrClamp(float3 uv)
            {
                return (_Mode == 0) ? frac(uv) : saturate(uv);
            }

            float3 ApplySkew(float3 uv)
            {
                float3 p = uv - _Pivot.xyz;

                // Skew matrix:
                // [ 1   XSkew ]
                // [ YSkew  1  ]
                float3 skewed;
                skewed.x = p.x + p.y * _XSkew;
                skewed.y = p.y + p.x * _YSkew;
                skewed.z=p.z+p.x*_ZSkew;

                return skewed + _Pivot.xyz;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                // Apply skew transform
                uv = ApplySkew(uv);

                // Wrap or clamp
                uv = WrapOrClamp(uv);

                float3 col = SampleSource(uv, i.direction);
                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}