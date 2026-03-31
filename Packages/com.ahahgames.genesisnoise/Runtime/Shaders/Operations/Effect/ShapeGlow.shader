Shader "Hidden/Genesis/ShapeGlow"
{
    Properties
    {
        // Shape mask (0–1)
        [InlineTexture]_Shape_2D("Shape", 2D) = "black" {}
        [InlineTexture]_Shape_3D("Shape", 3D) = "black" {}
        [InlineTexture]_Shape_Cube("Shape", Cube) = "black" {}

        _Radius("Glow Radius", Range(1, 64)) = 16
        _Softness("Softness", Range(0, 1)) = 0.35
        _Intensity("Intensity", Range(0, 4)) = 1.0

        _GlowColor("Glow Color", Color) = (1,1,1,1)
        _InnerGlow("Inner Glow", Int) = 0
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

            float _Radius;
            float _Softness;
            float _Intensity;
            float4 _GlowColor;
            int _InnerGlow;

            float SampleShape(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Shape, uv, dir).r;
            }

            // Soft falloff curve (Substance-like)
            float Falloff(float d)
            {
                float x = saturate(1.0 - d);
                float smooth = smoothstep(0, 1, x);
                float sharp  = pow(x, 0.35);
                return lerp(smooth, sharp, _Softness);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float shape = SampleShape(uv, i.direction);

                float glow = 0.0;

                int R = (int)_Radius;

                // Radial glow accumulation
                for (int y = -R; y <= R; y++)
                for (int x = -R; x <= R; x++)
                {
                    float2 offset = float2(x, y);
                    float dist = length(offset);

                    if (dist > R)
                        continue;

                    float2 suv = uv + offset * texel;
                    float s = SampleShape(float3(suv,0), i.direction);

                    // Outer glow: triggered by shape pixels
                    if (s > 0.5)
                    {
                        float w = Falloff(dist / R);
                        glow += w;
                    }

                    // Inner glow: triggered by empty pixels inside shape
                    if (_InnerGlow == 1 && shape > 0.5 && s < 0.5)
                    {
                        float w = Falloff(dist / R);
                        glow += w;
                    }
                }

                glow *= _Intensity / (R * R);

                float3 col = _GlowColor.rgb * glow;

                return float4(col, glow);
            } 

            ENDHLSL
        }
    }
}