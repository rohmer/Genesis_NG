Shader "Hidden/Genesis/VectorMorph"
{
    Properties
    {
        // Shape mask (0–1)
        [InlineTexture]_Shape_2D("Shape", 2D) = "black" {}
        [InlineTexture]_Shape_3D("Shape", 3D) = "black" {}
        [InlineTexture]_Shape_Cube("Shape", Cube) = "black" {}

        // Vector field (RG = XY direction)
        [InlineTexture]_Vector_2D("Vector Field", 2D) = "gray" {}
        [InlineTexture]_Vector_3D("Vector Field", 3D) = "gray" {}
        [InlineTexture]_Vector_Cube("Vector Field", Cube) = "gray" {}

        _Amount("Morph Amount", Range(-32, 32)) = 8
        _Softness("Softness", Range(0, 1)) = 0.35
        _Iterations("Iterations", Range(1, 32)) = 8
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
            TEXTURE_SAMPLER_X(_Vector);

            float _Amount;
            float _Softness;
            float _Iterations;

            float SampleShape(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Shape, uv, dir).r;
            }

            float2 SampleVector(float3 uv, float3 dir)
            {
                float2 v = SAMPLE_X(_Vector, uv, dir).rg;
                return v * 2.0 - 1.0; // remap 0–1 → -1..1
            }

            // Soft falloff curve (Substance-like)
            float Falloff(float x)
            {
                float smooth = smoothstep(0, 1, x);
                float sharp  = pow(x, 0.35);
                return lerp(smooth, sharp, _Softness);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float shape = SampleShape(uv, i.direction);

                float2 v = SampleVector(uv, i.direction);
                float len = length(v);

                if (len < 1e-5)
                    return float4(shape.xxx, 1);

                float2 dir = normalize(v);

                int iters = max(1, (int)_Iterations);
                float accum = 0.0;

                for (int s = 1; s <= iters; s++)
                {
                    float t = (float)s / iters;

                    float dist = t * _Amount;
                    float2 suv = uv - dir * (dist * texel);

                    float sVal = SampleShape(float3(suv,0), i.direction);

                    float w = Falloff(1.0 - t);

                    accum = max(accum, sVal * w);
                }
                 
                float result = max(shape, accum);

                return float4(result.xxx, 1);
            }

            ENDHLSL
        }
    }
}