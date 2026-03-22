Shader "Hidden/Genesis/NormalToHeight"
{
    Properties
    {
        // Tangent-space normal map
        [InlineTexture]_Normal_2D("Normal", 2D) = "bump" {}
        [InlineTexture]_Normal_3D("Normal", 3D) = "bump" {}
        [InlineTexture]_Normal_Cube("Normal", Cube) = "bump" {}

        _Iterations("Integration Iterations", Range(1, 64)) = 16
        _Intensity("Height Intensity", Range(0, 4)) = 1.0
        _Bias("Bias", Range(-1, 1)) = 0.0
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

            TEXTURE_SAMPLER_X(_Normal);

            float _Iterations;
            float _Intensity;
            float _Bias;

            float3 SampleNormal(float3 uv, float3 dir)
            {
                float3 n = SAMPLE_X(_Normal, uv, dir).rgb;
                return normalize(n * 2.0 - 1.0);
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float3 N = SampleNormal(uv, i.direction);

                // Convert normal to slope
                float sx = -N.x / max(N.z, 1e-5);
                float sy = -N.y / max(N.z, 1e-5);

                // Iterative integration
                float h = 0.0;
                int it = max(1, (int)_Iterations);

                for (int s = 1; s <= it; s++)
                {
                    float t = (float)s / it;

                    float2 offset = float2(-sx, -sy) * t * texel;
                    float3 n2 = SampleNormal(uv + float3(offset,0), i.direction);

                    float sx2 = -n2.x / max(n2.z, 1e-5);
                    float sy2 = -n2.y / max(n2.z, 1e-5);

                    float slope = (abs(sx2) + abs(sy2)) * 0.5;

                    h += slope;
                }

                h = (h / it) * _Intensity + _Bias;

                return float4(h.xxx, 1);
            }

            ENDHLSL
        }
    } 
}