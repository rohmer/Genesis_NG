Shader "Hidden/Genesis/Curvature"
{
    Properties
    {
        [InlineTexture]_Height_2D("Height", 2D) = "black" {}
        [InlineTexture]_Height_3D("Height", 3D) = "black" {}
        [InlineTexture]_Height_Cube("Height", Cube) = "black" {}

        _Radius("Radius", Range(1, 4)) = 1
        _Intensity("Intensity", Range(0, 4)) = 1
        _Invert("Invert Height", Int) = 0
        _SeparateConvexConcave("Separate Convex/Concave", Int) = 0
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
            float _Intensity;
            int   _Invert;
            int   _SeparateConvexConcave;

            float SampleHeight(float3 uv, float3 dir)
            {
                float h = SAMPLE_X(_Height, uv, dir).r;
                return _Invert ? (1.0 - h) : h;
            }

            // Discrete Laplacian curvature (Substance-like)
            float ComputeCurvature(float3 uv, float3 texel, float3 dir, int r)
            {
                float center = SampleHeight(uv, dir);

                float sum = 0.0;
                float wSum = 0.0;

                // 3x3 Laplacian-style kernel scaled by radius
                for (int j = -r; j <= r; j++)
                {
                    for (int i = -r; i <= r; i++)
                    {
                        float3 offset = float3(i, j,0);
                        float w;

                        if (i == 0 && j == 0)
                        {
                            w = -4.0;
                        }
                        else if ((abs(i) + abs(j)) == 1)
                        {
                            w = 1.0;
                        }
                        else
                        {
                            w = 0.0;
                        }

                        if (w == 0.0)
                            continue;

                        float h = SampleHeight(uv + offset * texel, dir);
                        sum += h * w;
                        wSum += abs(w);
                    }
                }

                if (wSum > 0.0)
                    sum /= wSum;

                // sum > 0 → concave, sum < 0 → convex (depending on convention)
                return sum * _Intensity;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01) * _Radius;

                float k = ComputeCurvature(uv, texel, i.direction, (int)_Radius);

                // Map curvature to 0–1
                float curv = saturate(0.5 + k);

                if (_SeparateConvexConcave != 0)
                {
                    float convex  = saturate(-k); // peaks
                    float concave = saturate( k); // valleys

                    convex  = saturate(convex  * _Intensity);
                    concave = saturate(concave * _Intensity);

                    return float4(convex, concave, curv, 1);
                }
                else
                {
                    return float4(curv.xxx, 1);
                }
            }

            ENDHLSL
        }
    }
}