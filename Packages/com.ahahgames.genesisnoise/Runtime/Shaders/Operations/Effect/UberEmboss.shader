Shader "Hidden/Genesis/UberEmboss"
{
    Properties
    {
        // Binary or grayscale shape mask
        [InlineTexture]_Shape_2D("Shape", 2D) = "black" {}
        [InlineTexture]_Shape_3D("Shape", 3D) = "black" {}
        [InlineTexture]_Shape_Cube("Shape", Cube) = "black" {}

        _Height("Height Amount", Range(0, 1)) = 0.25
        _Softness("Softness", Range(0, 1)) = 0.35

        // 0 = Outer, 1 = Inner, 2 = Both
        _Mode("Emboss Mode", Int) = 0

        // Light direction in turns (0–1)
        _Angle("Light Angle", Range(0, 1)) = 0.125

        _Intensity("Intensity", Range(0, 4)) = 1.0
        _Profile("Profile", Range(0, 1)) = 0.5
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

            TEXTURE_SAMPLER_X(_Shape);

            float _Height;
            float _Softness;
            int   _Mode;
            float _Angle;
            float _Intensity;
            float _Profile;

            float SampleShape(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Shape, uv, dir).r;
            }

            float2 DirFromAngle(float a)
            {
                float ang = a * 6.2831853;
                return float2(cos(ang), sin(ang));
            }

            // Profile shaping (Substance-like)
            float ProfileCurve(float x)
            {
                float smooth = smoothstep(0, 1, x);
                float sharp  = pow(x, 0.35);
                return lerp(smooth, sharp, _Profile);
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float s0 = SampleShape(uv, i.direction);

                // Light direction
                float2 L = DirFromAngle(_Angle);

                // Sample neighbors for gradient
                float sx1 = SampleShape(uv + float3(texel.x, 0,0), i.direction);
                float sx2 = SampleShape(uv - float3(texel.x, 0,0), i.direction);
                float sy1 = SampleShape(uv + float3(0, texel.y,0), i.direction);
                float sy2 = SampleShape(uv - float3(0, texel.y,0), i.direction);

                float gx = (sx1 - sx2) * 0.5;
                float gy = (sy1 - sy2) * 0.5;

                float2 grad = float2(gx, gy);

                // Dot with light direction
                float emboss = dot(grad, -L);

                // Mode handling
                if (_Mode == 0) // Outer
                {
                    emboss *= (1.0 - s0);
                }
                else if (_Mode == 1) // Inner
                {
                    emboss *= s0;
                }
                // Mode 2 = both → no mask

                // Height scaling
                emboss *= _Height;

                // Softness shaping
                emboss = ProfileCurve(emboss * 0.5 + 0.5) * 2.0 - 1.0;

                // Intensity
                emboss *= _Intensity;

                // Final grayscale height output
                float h = emboss * 0.5 + 0.5;

                return float4(h.xxx, 1);
            } 

            ENDHLSL
        }
    }
}