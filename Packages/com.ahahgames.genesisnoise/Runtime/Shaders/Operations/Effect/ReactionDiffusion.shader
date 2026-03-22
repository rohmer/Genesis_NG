Shader "Hidden/Genesis/ReactionDiffusion"
{
    Properties
    {
        // Initial state (usually noise)
        [InlineTexture]_Init_2D("Initial State", 2D) = "gray" {}
        [InlineTexture]_Init_3D("Initial State", 3D) = "gray" {}
        [InlineTexture]_Init_Cube("Initial State", Cube) = "gray" {}

        _Feed("Feed Rate (F)", Range(0.0, 0.1)) = 0.055
        _Kill("Kill Rate (K)", Range(0.0, 0.1)) = 0.062
        _DiffA("Diffusion A", Range(0.0, 1.0)) = 0.2
        _DiffB("Diffusion B", Range(0.0, 1.0)) = 0.1
        _Iterations("Iterations", Range(1, 64)) = 16
        _TimeStep("Time Step", Range(0.1, 2.0)) = 1.0
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

            TEXTURE_SAMPLER_X(_Init);

            float _Feed;
            float _Kill;
            float _DiffA;
            float _DiffB;
            float _Iterations;
            float _TimeStep;

            // ------------------------------------------------------------
            float2 SampleAB(float3 uv, float3 dir)
            {
                float v = SAMPLE_X(_Init, uv, dir).r;
                // A = 1 - v, B = v  (Substance uses grayscale as B seed)
                return float3(1.0 - v, v,0);
            }

            float Laplace(float3 uv, float3 dir, bool isA, float3 texel)
            {                
                float sum = 0;

                float c = isA ? SampleAB(uv, dir).x : SampleAB(uv, dir).y;

                sum += c * -1.0;
                sum += (isA ? SampleAB(uv + float3(texel.x, 0,0), dir).x : SampleAB(uv + float3(texel.x, 0,0), dir).y) * 0.2;
                sum += (isA ? SampleAB(uv + float3(-texel.x, 0,0), dir).x : SampleAB(uv + float3(-texel.x, 0,0), dir).y) * 0.2;
                sum += (isA ? SampleAB(uv + float3(0, texel.y,0), dir).x : SampleAB(uv + float3(0, texel.y,0), dir).y) * 0.2;
                sum += (isA ? SampleAB(uv + float3(0, -texel.y,0), dir).x : SampleAB(uv + float3(0, -texel.y,0), dir).y) * 0.2;

                sum += (isA ? SampleAB(uv + float3(texel.x, texel.y,0), dir).x : SampleAB(uv + float3(texel.x, texel.y,0), dir).y) * 0.05;
                sum += (isA ? SampleAB(uv + float3(-texel.x, texel.y,0), dir).x : SampleAB(uv + float3(-texel.x, texel.y,0), dir).y) * 0.05;
                sum += (isA ? SampleAB(uv + float3(texel.x, -texel.y,0), dir).x : SampleAB(uv + float3(texel.x, -texel.y,0), dir).y) * 0.05;
                sum += (isA ? SampleAB(uv + float3(-texel.x, -texel.y,0), dir).x : SampleAB(uv + float3(-texel.x, -texel.y,0), dir).y) * 0.05;

                return sum;
            }

            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float2 AB = SampleAB(uv, i.direction);
                float A = AB.x;
                float B = AB.y;

                int iters = (int)_Iterations;

                for (int k = 0; k < iters; k++)
                {
                    float lapA = Laplace(uv, i.direction, true, float3(0.01,0.01,0.01));
                    float lapB = Laplace(uv, i.direction, false, float3(0.01,0.01,0.01));

                    float reaction = A * B * B;

                    float dA = _DiffA * lapA - reaction + _Feed * (1.0 - A);
                    float dB = _DiffB * lapB + reaction - (_Kill + _Feed) * B;

                    A += dA * _TimeStep;
                    B += dB * _TimeStep;

                    A = saturate(A);
                    B = saturate(B);
                }

                // Substance outputs B (the inhibitor) as the pattern
                return float4(B.xxx, 1);
            }

            ENDHLSL
        }
    }
}