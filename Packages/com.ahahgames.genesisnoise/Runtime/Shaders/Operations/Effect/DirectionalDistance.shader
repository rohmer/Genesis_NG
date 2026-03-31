Shader "Hidden/Genesis/DirectionalDistance"
{
    Properties
    {
        // Binary or grayscale mask to measure distance from
        [InlineTexture]_Mask_2D("Mask", 2D) = "black" {}
        [InlineTexture]_Mask_3D("Mask", 3D) = "black" {}
        [InlineTexture]_Mask_Cube("Mask", Cube) = "black" {}

        // Direction map (angle or vector)
        [InlineTexture]_Direction_2D("Direction Map", 2D) = "black" {}
        [InlineTexture]_Direction_3D("Direction Map", 3D) = "black" {}
        [InlineTexture]_Direction_Cube("Direction Map", Cube) = "black" {}

        _MaxDistance("Max Distance (px)", Range(1, 256)) = 64
        _Threshold("Mask Threshold", Range(0, 1)) = 0.5

        _DirectionStrength("Direction Strength", Range(0, 1)) = 1
        _DirectionIsVector("Direction Is Vector", Int) = 0
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

            TEXTURE_SAMPLER_X(_Mask);
            TEXTURE_SAMPLER_X(_Direction);

            float _MaxDistance;
            float _Threshold;

            float _DirectionStrength;
            int   _DirectionIsVector;

            // ------------------------------------------------------------
            float SampleMask(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Mask, uv, dir).r;
            }

            float3 SampleDirection(float3 uv, float3 dir)
            {
                float4 d = SAMPLE_X(_Direction, uv, dir);

                if (_DirectionIsVector == 1)
                {
                    float3 v = normalize(d.xyz * 2 - 1);
                    return v;
                }
                else
                {
                    float angle = d.r * 6.2831853;
                    return float3(cos(angle), sin(angle),0);
                }
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv     = i.localTexcoord.xyz;
                float3 texel  = float3(0.01,0.01,0.01);

                float maskVal = SampleMask(uv, i.direction);

                // If already inside the mask → distance = 0
                if (maskVal > _Threshold)
                    return float4(0, 0, 0, 1);

                // Direction vector
                float3 dir = SampleDirection(uv, i.direction);
                dir = normalize(dir);

                // Blend with neutral direction if needed
                dir = normalize(lerp(float3(1,0,0), dir, _DirectionStrength));

                float dist = 0.0;
                float stepSize = 1.0; // 1 pixel per step

                // Ray march along direction
                for (int s = 1; s <= _MaxDistance; s++)
                {
                    float3 suv = uv + dir * (texel * s);

                    float m = SampleMask(suv, i.direction);

                    if (m > _Threshold)
                    {
                        dist = s;
                        break;
                    } 
                }

                // Normalize to 0–1
                float dNorm = saturate(dist / _MaxDistance);

                return float4(dNorm.xxx, 1);
            }

            ENDHLSL
        }
    }
}