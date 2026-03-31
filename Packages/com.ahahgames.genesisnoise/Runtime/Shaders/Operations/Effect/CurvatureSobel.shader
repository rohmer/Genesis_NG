Shader "Hidden/Genesis/CurvatureSobel"
{
    Properties
    {
        // Normal map input (Substance Curvature Sobel uses normals)
        [InlineTexture]_Normal_2D("Normal", 2D) = "bump" {}
        [InlineTexture]_Normal_3D("Normal", 3D) = "bump" {}
        [InlineTexture]_Normal_Cube("Normal", Cube) = "bump" {}

        _Intensity("Intensity", Range(0, 4)) = 1
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

            TEXTURE_SAMPLER_X(_Normal);

            float _Intensity;
            int   _SeparateConvexConcave;

            // ------------------------------------------------------------
            float3 SampleNormal(float3 uv, float3 dir)
            {
                float3 n = SAMPLE_X(_Normal, uv, dir).xyz * 2 - 1;
                return normalize(n);
            }

            // Sobel derivative of normal field
            float ComputeCurvatureSobel(float3 uv, float3 texel, float3 dir)
            {
                float3 tl = SampleNormal(uv + float3(-texel.x, -texel.y,0), dir);
                float3  t = SampleNormal(uv + float3( 0,       -texel.y,0), dir);
                float3 tr = SampleNormal(uv + float3( texel.x, -texel.y,0), dir);

                float3 l  = SampleNormal(uv + float3(-texel.x, 0,0), dir);
                float3 r  = SampleNormal(uv + float3( texel.x, 0,0), dir);

                float3 bl = SampleNormal(uv + float3(-texel.x, texel.y,0), dir);
                float3  b = SampleNormal(uv + float3( 0,        texel.y,0), dir);
                float3 br = SampleNormal(uv + float3( texel.x,  texel.y,0), dir);

                // Sobel derivative of normal field
                float3 dx = (tr + 2*r + br) - (tl + 2*l + bl);
                float3 dy = (bl + 2*b + br) - (tl + 2*t + tr);

                // Curvature magnitude = divergence of normal field
                float curvature = dot(dx + dy, float3(1,1,1)) * 0.3333;

                return curvature * _Intensity;
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float k = ComputeCurvatureSobel(uv, texel, i.direction);

                // Map to 0–1
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