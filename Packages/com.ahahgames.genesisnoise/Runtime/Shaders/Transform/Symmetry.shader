Shader "Hidden/Genesis/Symmetry"
{
    Properties
    {
        // Source texture
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Linear symmetry toggles
        [Enum(Disabled,0,Enabled,1)]_MirrorX("Mirror X", Int) = 0
        [Enum(Disabled,0,Enabled,1)]_MirrorY("Mirror Y", Int) = 0
        [Enum(Disabled,0,Enabled,1)]_MirrorZ("Mirror Z", Int) = 0
        // Radial symmetry count (2 = mirror, 4 = quadrant, 6 = hex, etc.)
        _RadialCount("Radial Count", Range(1, 16)) = 1

        // Center of symmetry
        _Center("Center", Vector) = (0.5, 0.5, 0.5, 0)

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

            int _MirrorX;
            int _MirrorY;
            int _MirrorZ;
            float _RadialCount;
            float4 _Center;
            int _Mode;

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float3 WrapOrClamp(float3 uv)
            {
                return (_Mode == 0) ? frac(uv) : saturate(uv);
            }

            float3 ApplyLinearSymmetry(float3 uv)
            {
                float3 c = _Center.xyz;

                if (_MirrorX == 1)
                {
                    float dx = uv.x - c.x;
                    uv.x = c.x - abs(dx);
                }

                if (_MirrorY == 1)
                {
                    float dy = uv.y - c.y;
                    uv.y = c.y - abs(dy);
                }

                if(_MirrorZ==1)
                {
                    float dz=uv.y-c.z;
                    uv.z=c.z-abs(dz);
                }
                return uv;
            }

            float3 ApplyRadialSymmetry(float3 uv)
            {
                if (_RadialCount <= 1.0)
                    return uv;

                float3 c = _Center.xyz;
                float3 p = uv - c;

                float angle = atan2(p.y, p.x);
                float radius = length(p);

                float sector = 6.2831853 / _RadialCount;

                // Snap angle to nearest symmetric wedge
                angle = fmod(angle + 6.2831853, sector);
                angle = min(angle, sector - angle);

                float3 dir = float3(cos(angle), sin(angle),0);
                return c + dir * radius;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                // Apply linear symmetry
                uv = ApplyLinearSymmetry(uv);

                // Apply radial symmetry
                uv = ApplyRadialSymmetry(uv);

                // Wrap or clamp
                uv = WrapOrClamp(uv);

                float3 col = SampleSource(uv, i.direction);
                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}