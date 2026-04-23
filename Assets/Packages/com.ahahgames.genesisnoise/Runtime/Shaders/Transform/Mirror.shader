Shader "Hidden/Genesis/Mirror"
{
    Properties
    {
        // Source texture
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Mirror toggles
        _MirrorX("Mirror X", Int) = 1
        _MirrorY("Mirror Y", Int) = 0

        // Mirror center
        _Center("Center", Vector) = (0.5, 0.5, 0, 0)

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
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_Source);

            int _MirrorX;
            int _MirrorY;
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

            float3 MirrorUV(float3 uv)
            {
                float2 c = _Center.xy;

                if (_MirrorX == 1)
                {
                    float dx = uv.x - c.x;
                    uv.x = c.x - dx;
                }

                if (_MirrorY == 1)
                {
                    float dy = uv.y - c.y;
                    uv.y = c.y - dy;
                }

                return uv;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                // Mirror around center
                uv = MirrorUV(uv);
                 
                // Wrap or clamp
                uv = WrapOrClamp(uv);

                float3 col = SampleSource(uv, i.direction);

                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}