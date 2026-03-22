Shader "Hidden/Genesis/PolarToCartesian"
{
    Properties
    {
        // Optional source texture (for sampling after remap)
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Center of the transform
        _Center("Center", Vector) = (0.5, 0.5, 0.5, 0)

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

            float3 PolarToCartesian(float3 polar)
            {
                float angle = polar.x / _AngleScale;   // undo angle scale
                float radius = polar.y / _RadiusScale; // undo radius scale

                // Convert 0–1 angle → 0–2π
                float ang = (angle - 0.5) * 6.2831853;

                float3 dir = float3(cos(ang), sin(ang),0);

                return _Center.xyz + dir * radius;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 polar = i.localTexcoord.xyz;

                // Convert polar → cartesian UV
                float3 uv = PolarToCartesian(polar);

                if (_Mode == 0)
                {
                    // Output UV remap
                    return float4(uv.x, uv.y, uv.z, 1);
                }
                else
                {
                    // Sample source using reconstructed UV
                    float3 col = SampleSource(uv, i.direction);
                    return float4(col, 1);
                }
            } 

            ENDHLSL
        }
    }
}