Shader "Hidden/Genesis/NonSquareTransform"
{
    Properties
    {
        // Input texture
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Scale X/Y independently
        _Scale("Scale (X,Y)", Vector) = (1.0, 0.5, 0, 0)

        // Offset after scaling
        _Offset("Offset (X,Y)", Vector) = (0.0, 0.0, 0, 0)

        // Center of scaling
        _Center("Center", Vector) = (0.5, 0.5, 0.5, 0)

        // Wrap mode: 0 = Wrap, 1 = Clamp
        _Mode("Wrap Mode", Int) = 0
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

            TEXTURE_SAMPLER_X(_Source);

            float4 _Scale;
            float4 _Offset;
            float4 _Center;
            int _Mode;

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float3 WrapOrClamp(float3 uv)
            {
                if (_Mode == 0)
                    return frac(uv);
                else
                    return saturate(uv);
            }

            float3 ApplyNonSquare(float3 uv)
            {
                float3 c = _Center.xyz;

                // Move to center
                uv -= c;

                // Apply non-uniform scale
                uv *= _Scale.xyz;

                // Apply offset
                uv += _Offset.xyz;

                // Move back
                uv += c;

                return uv;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                // Apply non-square transform
                uv = ApplyNonSquare(uv);

                // Wrap or clamp
                uv = WrapOrClamp(uv);

                float3 col = SampleSource(uv, i.direction);

                return float4(col, 1);
            }

            ENDHLSL 
        }
    }
}