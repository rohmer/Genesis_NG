Shader "Hidden/Genesis/TextureOffset3DColor"
{
    Properties
    {
        // Source texture (2D / 3D / Cube)
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        _Offset("Offset XYZ", Vector) = (0.1, 0.1, 0.1, 0)
        _Scale("Scale", Range(0.1, 10)) = 1.0

        // 0 = Wrap, 1 = Clamp
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

            float4 _Offset;
            float _Scale;
            int _Mode;

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float3 SampleSource3D(float3 uvw)
            {
                #if defined(CRT_3D)
                    return SAMPLE_X(_Source, uvw, float3(0)).rgb;
                #elif defined(CRT_CUBE)
                    return SAMPLE_X(_Source, uvw, float3(0)).rgb;
                #else
                    return SAMPLE_X(_Source, uvw.xyz, float3(0)).rgb;
                #endif
            }

            float3 WrapOrClamp(float3 p)
            {
                if (_Mode == 0)
                    return frac(p);     // wrap
                else
                    return saturate(p); // clamp
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                // Base UVW
                float3 uvw;

                #if defined(CRT_3D)
                    uvw = float3(uv, i.direction.z);
                #elif defined(CRT_CUBE)
                    uvw = i.direction; // cube sampling uses direction vector
                #else
                    uvw = uv;
                #endif

                // Apply scale + offset
                uvw = uvw * _Scale + _Offset.xyz;

                // Wrap or clamp 
                uvw = WrapOrClamp(uvw);

                float3 col = SampleSource3D(uvw);

                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}