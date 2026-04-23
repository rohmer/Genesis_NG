Shader "Hidden/Genesis/NonUniformRotation"
{
    Properties
    {
        // Input texture
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Rotation angles in turns (0–1)
        _AngleX("Rotation X", Range(0, 1)) = 0.0
        _AngleY("Rotation Y", Range(0, 1)) = 0.0

        // Center of rotation
        _Center("Center", Vector) = (0.5, 0.5, 0.5, 0)

        // Wrap mode: 0 = Wrap, 1 = Clamp
        [Enum(Wrap,0,Clamp,1)]_Mode("Wrap Mode", Int) = 0
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

            float _AngleX;
            float _AngleY;
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

            float2 Rotate(float2 p, float ang)
            {
                float s = sin(ang);
                float c = cos(ang);
                return float2(
                    p.x * c - p.y * s,
                    p.x * s + p.y * c
                );
            }

            float3 ApplyNonUniformRotation(float2 uv)
            {
                float3 c = _Center.xyz;

                // Move to center
                uv -= c;

                // Convert turns → radians
                float ax = _AngleX * 6.2831853;
                float ay = _AngleY * 6.2831853;

                // Apply rotation to each axis independently
                float3 rotated;
                rotated.x = Rotate(float2(uv.x, uv.y), ax).x;
                rotated.y = Rotate(float2(uv.y, uv.x), ay).x;
                rotated.z=0;

                // Move back
                return rotated + c;
            }
             
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                // Apply anisotropic rotation
                uv = ApplyNonUniformRotation(uv);

                // Wrap or clamp
                uv = WrapOrClamp(uv);

                float3 col = SampleSource(uv, i.direction);

                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}