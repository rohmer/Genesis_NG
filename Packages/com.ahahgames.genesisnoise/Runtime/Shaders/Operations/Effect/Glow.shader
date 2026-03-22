Shader "Hidden/Genesis/Glow"
{
    Properties
    {
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        _Radius("Radius", Range(1, 32)) = 8
        _Intensity("Intensity", Range(0, 4)) = 1
        _Threshold("Threshold", Range(0, 1)) = 0.5
        _Softness("Softness", Range(0, 1)) = 0.5
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

            float _Radius;
            float _Intensity;
            float _Threshold;
            float _Softness;

            float3 SampleColor(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float Luma(float3 c)
            {
                return dot(c, float3(0.299, 0.587, 0.114));
            }

            // Soft falloff curve (Substance-like)
            float Falloff(float d)
            {
                float x = saturate(1.0 - d);
                float smooth = smoothstep(0, 1, x);
                float sharp  = pow(x, 0.35);
                return lerp(smooth, sharp, _Softness);
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float3 baseColor = SampleColor(uv, i.direction);
                float  baseLuma  = Luma(baseColor);
                 
                float glow = 0.0;

                // Radial glow accumulation
                for (int y = -_Radius; y <= _Radius; y++)
                for (int x = -_Radius; x <= _Radius; x++)
                {
                    float3 offset = float3(x, y,0);
                    float dist = length(offset);

                    if (dist > _Radius)
                        continue;

                    float3 suv = uv + offset * texel;
                    float3 c = SampleColor(suv, i.direction);
                    float  l = Luma(c);

                    if (l > _Threshold)
                    {
                        float w = Falloff(dist / _Radius);
                        glow += l * w;
                    }
                }

                glow *= _Intensity / (_Radius * _Radius);

                float3 result = baseColor + glow;

                return float4(result, 1);
            }

            ENDHLSL
        }
    }
}