Shader "Hidden/Genesis/CartesianToPolar"
{
    Properties
    {
        // Input texture (optional)
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Center of the polar transform
        _Center("Center", Vector) = (0.5, 0.5, 0, 0)

        // Scaling controls
        _AngleScale("Angle Scale", Range(0.1, 4)) = 1.0
        _RadiusScale("Radius Scale", Range(0.1, 4)) = 1.0

        // Output mode: 0 = UV remap, 1 = Color sample
        [Enum(UV Remap,0,Color Sample,1)]_Mode("Output Mode", Int) = 1
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

            float4 _Center;
            float _AngleScale;
            float _RadiusScale;
            int _Mode;

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float2 CartesianToPolar(float3 p)
            {
                float2 d = p - _Center.xy;

                float angle = atan2(d.y, d.x);     // -π..π
                angle = (angle / 6.2831853) + 0.5; // → 0..1

                float radius = length(d) * _RadiusScale;

                return float2(angle * _AngleScale, radius);
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float2 polar = CartesianToPolar(uv);

                if (_Mode == 0)
                {
                    // Output the polar coordinates as a UV map
                    return float4(polar, 0, 1);
                }
                else
                {
                    // Use polar as UVs to sample the source
                    float3 sampleUV = float3(frac(polar),i.localTexcoord.z);
                    float3 col = SampleSource(sampleUV, i.direction);
                    return float4(col, 1);
                }
            }

            ENDHLSL
        }
    }
}