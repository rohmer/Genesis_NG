Shader "Hidden/Genesis/DiffusionAnisotropic"
{
    Properties
    {
        // Color to diffuse
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Height for edge‑preserving diffusion
        [InlineTexture]_Height_2D("Height", 2D) = "black" {}
        [InlineTexture]_Height_3D("Height", 3D) = "black" {}
        [InlineTexture]_Height_Cube("Height", Cube) = "black" {}

        // Direction map (angle or vector)
        [InlineTexture]_Direction_2D("Direction Map", 2D) = "black" {}
        [InlineTexture]_Direction_3D("Direction Map", 3D) = "black" {}
        [InlineTexture]_Direction_Cube("Direction Map", Cube) = "black" {}

        _Radius("Radius", Range(1, 8)) = 3
        _Iterations("Iterations", Range(1, 8)) = 4

        _HeightSensitivity("Height Sensitivity", Range(0, 4)) = 1
        _Falloff("Falloff", Range(0, 1)) = 0.5

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

            TEXTURE_SAMPLER_X(_Source);
            TEXTURE_SAMPLER_X(_Height);
            TEXTURE_SAMPLER_X(_Direction);

            float _Radius;
            float _Iterations;
            float _HeightSensitivity;
            float _Falloff;

            float _DirectionStrength;
            int   _DirectionIsVector;

            // ------------------------------------------------------------
            float3 SampleColor(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float SampleHeight(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Height, uv, dir).r;
            }

            float2 SampleDirection(float3 uv, float3 dir)
            {
                float4 d = SAMPLE_X(_Direction, uv, dir);

                if (_DirectionIsVector == 1)
                {
                    float2 v = normalize(d.xy * 2 - 1);
                    return v;
                }
                else
                {
                    float angle = d.r * 6.2831853;
                    return float2(cos(angle), sin(angle));
                }
            }

            // Height‑guided weight
            float HeightWeight(float hC, float hS)
            {
                float dh = abs(hS - hC);
                float w = exp(-dh * _HeightSensitivity);
                return pow(w, _Falloff * 4.0);
            }

            // Directional weight (anisotropy)
            float DirectionWeight(float2 dir, float2 offset)
            {
                float2 o = normalize(offset);
                float a = max(0.0, dot(dir, o)); // directional alignment
                return lerp(1.0, a, _DirectionStrength);
            }

            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float3 color = SampleColor(uv, i.direction);
                float  hC    = SampleHeight(uv, i.direction);

                float2 dir = SampleDirection(uv, i.direction);

                // Iterative anisotropic diffusion
                for (int iter = 0; iter < _Iterations; iter++)
                {
                    float3 accum = 0;
                    float  wSum  = 0;

                    for (int j = -_Radius; j <= _Radius; j++)
                    for (int k = -_Radius; k <= _Radius; k++)
                    {
                        float3 offset = float3(k, j,0);
                        float3 suv = uv + offset * texel;

                        float3 cS = SampleColor(suv, i.direction);
                        float  hS = SampleHeight(suv, i.direction);

                        float wH = HeightWeight(hC, hS);
                        float wD = DirectionWeight(dir, offset);
                         
                        float w = wH * wD;

                        accum += cS * w;
                        wSum  += w;
                    }

                    if (wSum > 0)
                        color = accum / wSum;
                }

                return float4(color, 1);
            }

            ENDHLSL
        }
    }
}