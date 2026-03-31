Shader "Hidden/Genesis/Clone"
{
    Properties
    {
        // Source texture
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // UV offset
        _Offset("Offset (XY)", Vector) = (0.1, 0.1, 0, 0)

        // Rotation in turns (0–1)
        _Angle("Rotation", Range(0, 1)) = 0.0

        // Mirroring
        _MirrorX("Mirror X", Int) = 0
        _MirrorY("Mirror Y", Int) = 0

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

            float4 _Offset;
            float _Angle;
            int _MirrorX;
            int _MirrorY;
            int _Mode;

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float3 WrapOrClamp(float3 uv)
            {
                if (_Mode == 0)
                    return frac(uv);     // wrap
                else
                    return saturate(uv); // clamp
            }

            float2 Rotate(float2 p, float ang)
            {
                float s = sin(ang);
                float c = cos(ang);
                return float2(
                    p.x * c - p.y * s,
                    p.x * s + p.y * c
                );
            }

            float2 Mirror(float2 uv)
            {
                if (_MirrorX == 1) uv.x = 1.0 - uv.x;
                if (_MirrorY == 1) uv.y = 1.0 - uv.y;
                return uv;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                // Apply offset
                uv += _Offset.xy;

                // Apply rotation
                float ang = _Angle * 6.2831853; // turns → radians
                uv = Rotate(uv - 0.5, ang) + 0.5;

                // Apply mirroring
                uv = Mirror(uv);

                // Wrap or clamp
                uv = WrapOrClamp(float3(uv,0.0));

                float3 col = SampleSource(float3(uv,i.localTexcoord.z), i.direction);

                return float4(col, 1);
            }
             
            ENDHLSL
        }
    }
}