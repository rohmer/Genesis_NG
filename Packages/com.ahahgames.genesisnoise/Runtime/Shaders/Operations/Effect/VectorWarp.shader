Shader "Hidden/Genesis/VectorWarp"
{
    Properties
    {
        // Source to warp
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Vector field (RG = XY)
        [InlineTexture]_Vector_2D("Vector Field", 2D) = "gray" {}
        [InlineTexture]_Vector_3D("Vector Field", 3D) = "gray" {}
        [InlineTexture]_Vector_Cube("Vector Field", Cube) = "gray" {}

        _Intensity("Intensity", Range(-1, 1)) = 0.25
        _Scale("Vector Scale", Range(0, 10)) = 1.0
        _Softness("Softness", Range(0, 1)) = 0.0
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
            TEXTURE_SAMPLER_X(_Vector);

            float _Intensity;
            float _Scale;
            float _Softness;

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float2 SampleVector(float3 uv, float3 dir)
            {
                float2 v = SAMPLE_X(_Vector, uv, dir).rg;
                return v * 2.0 - 1.0; // remap 0–1 → -1..1
            }

            // Optional softness shaping (Substance-like)
            float Falloff(float x)
            {
                float smooth = smoothstep(0, 1, x);
                float sharp  = pow(x, 0.35);
                return lerp(smooth, sharp, _Softness);
            }
             
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                // Vector field sample
                float2 v = SampleVector(uv, i.direction);

                // Softness falloff (optional)
                float mag = length(v);
                float f = Falloff(mag);

                // Final warp offset
                float2 offset = v * _Intensity * _Scale * f;

                // Convert to texel space
                offset *= texel;

                float3 col = SampleSource(uv + float3(offset,0), i.direction);

                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}