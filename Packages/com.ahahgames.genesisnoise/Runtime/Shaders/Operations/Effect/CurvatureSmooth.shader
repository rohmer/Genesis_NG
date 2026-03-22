Shader "Hidden/Genesis/CurvatureSmooth"
{
    Properties
    {
        [InlineTexture]_Height_2D("Height", 2D) = "black" {}
        [InlineTexture]_Height_3D("Height", 3D) = "black" {}
        [InlineTexture]_Height_Cube("Height", Cube) = "black" {}

        _Radius("Curvature Radius", Range(1, 4)) = 1
        _SmoothRadius("Smoothing Radius", Range(1, 4)) = 2
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
            float _SmoothRadius;
            float _Intensity;
            int   _Invert;
            int   _SeparateConvexConcave;

            // ------------------------------------------------------------
            float SampleHeight(float3 uv, float3 dir)
            {
                float h = SAMPLE_X(_Height, uv, dir).r;
                return _Invert ? (1.0 - h) : h;
            }

            // Gaussian smoothing (3×3, radius-scaled)
            float SmoothHeight(float3 uv, float3 texel, float3 dir, int r)
            {
                const float k[3][3] = {
                    { 1, 2, 1 },
                    { 2, 4, 2 },
                    { 1, 2, 1 }
                };

                float sum = 0;
                float wSum = 0;

                for (int j = -1; j <= 1; j++)
                for (int i = -1; i <= 1; i++)
                {
                    float w = k[j+1][i+1];
                    float h = SampleHeight(uv + float3(i, j,0) * texel * r, dir);

                    sum += h * w;
                    wSum += w;
                }

                return sum / wSum;
            }

            // Laplacian curvature on smoothed height
            float ComputeCurvatureSmooth(float3 uv, float3 texel, float3 dir, int r, int smoothR)
            {
                float hC = SmoothHeight(uv, texel, dir, smoothR);

                float hL = SmoothHeight(uv - float3(texel.x, 0,0), texel, dir, smoothR);
                float hR = SmoothHeight(uv + float3(texel.x, 0,0), texel, dir, smoothR);
                float hD = SmoothHeight(uv - float3(0, texel.y,0), texel, dir, smoothR);
                float hU = SmoothHeight(uv + float3(0, texel.y,0), texel, dir, smoothR);

                float lap = (hL + hR + hD + hU - 4*hC);

                return lap * _Intensity;
            }

            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01)* _Radius;

                float k = ComputeCurvatureSmooth(uv, texel, i.direction, (int)_Radius, (int)_SmoothRadius);

                // Map to 0–1 curvature
                float curv = saturate(0.5 + k);

                if (_SeparateConvexConcave != 0)
                {
                    float convex  = saturate(-k); // peaks
                    float concave = saturate( k); // valleys

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