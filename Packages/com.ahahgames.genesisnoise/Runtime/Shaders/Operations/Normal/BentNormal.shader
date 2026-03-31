Shader "Hidden/Genesis/BentNormal"
{
    Properties
    {
        // Height map input
        [InlineTexture]_Height_2D("Height", 2D) = "gray" {}
        [InlineTexture]_Height_3D("Height", 3D) = "gray" {}
        [InlineTexture]_Height_Cube("Height", Cube) = "gray" {}

        _Radius("Scan Radius", Range(1, 64)) = 16
        _Steps("Steps Per Direction", Range(1, 32)) = 8
        _Directions("Directions", Range(4, 32)) = 16
        _Intensity("Bent Strength", Range(0, 4)) = 1.0
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

            TEXTURE_SAMPLER_X(_Height);

            float _Radius;
            float _Steps;
            float _Directions;
            float _Intensity;

            float SampleHeight(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Height, uv, dir).r;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float h0 = SampleHeight(uv, i.direction);

                float3 bent = float3(0, 0, 0);

                int dirs = max(1, (int)_Directions);
                int steps = max(1, (int)_Steps);

                // Scan around the pixel in multiple directions
                for (int d = 0; d < dirs; d++)
                {
                    float ang = (d / (float)dirs) * 6.2831853;
                    float2 dir = float2(cos(ang), sin(ang));

                    float visibility = 1.0;

                    for (int s = 1; s <= steps; s++)
                    {
                        float t = (float)s / steps;
                        float dist = t * _Radius;

                        float2 suv = uv + dir * (dist * texel);
                        float h = SampleHeight(float3(suv,0), i.direction);

                        // If neighbor is higher, reduce visibility
                        if (h > h0)
                        {
                            float delta = h - h0;
                            visibility = min(visibility, 1.0 - delta);
                        }
                    }

                    // Accumulate bent direction weighted by visibility
                    bent.xy += dir * visibility;
                }

                // Normalize and convert to tangent-space normal
                float2 xy = normalize(bent.xy + 1e-5);

                float3 n = float3(xy * _Intensity, 1.0);
                n = normalize(n);

                float3 outN = n * 0.5 + 0.5;

                return float4(outN, 1);
            }

            ENDHLSL
        }
    }
}