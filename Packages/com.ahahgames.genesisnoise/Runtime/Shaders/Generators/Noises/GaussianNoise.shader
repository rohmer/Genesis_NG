Shader "Hidden/Genesis/GaussianNoise"
{
    Properties
    {
        [Tooltip(Global scale of the noise field)]
        _Scale("Scale", Float) = 4.0

        [Tooltip(Mean of the Gaussian distribution)]
        _Mean("Mean", Float) = 0.5

        [Tooltip(Standard deviation (spread) of the Gaussian)]
        _Variance("Variance", Float) = 0.25

        [Tooltip(Random seed)]
        _Seed("Seed", Float) = 1.0

        [Tooltip(Output RGB instead of grayscale)][Enum(Off,0, On,1)]
        _Color("Color Output", Float) = 0
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

            float _Scale;
            float _Mean;
            float _Variance;
            float _Seed;
            float _Color;

            // ---------------------------------------
            // Hash → uniform random 0–1
            // ---------------------------------------
            float hash(float2 p)
            {
                p = frac(p * 0.3183099 + _Seed * 0.1234);
                p *= 17.0;
                return frac(p.x * p.y * (p.x + p.y));
            }

            // ---------------------------------------
            // Box–Muller transform → Gaussian
            // ---------------------------------------
            float gaussian(float2 uv)
            {
                float u1 = hash(uv + 13.1);
                float u2 = hash(uv + 91.7);

                // Avoid log(0)
                u1 = max(u1, 1e-6);

                float r = sqrt(-2.0 * log(u1));
                float theta = 6.2831853 * u2;

                float g = r * cos(theta); // Gaussian N(0,1)

                // Convert to N(mean, variance)
                g = g * _Variance + _Mean;

                return saturate(g);
            }

            float3 gaussianRGB(float2 uv)
            {
                return float3(
                    gaussian(uv + float2(17.1, 3.7)),
                    gaussian(uv + float2(91.4, 11.2)),
                    gaussian(uv + float2(53.8, 27.9))
                );
            }

            // ---------------------------------------
            // Final CRT fragment
            // ---------------------------------------
            float4 mixture(v2f_customrendertexture IN) : SV_Target
            {
                float3 uv = IN.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float2 p = uv.xy * _Scale;

                if (_Color > 0.5)
                {
                    float3 c = gaussianRGB(p);
                    return float4(c, 1.0);
                }
                else
                {
                    float g = gaussian(p);
                    return float4(g, g, g, 1.0);
                }
            }

            ENDHLSL
        }
    }
}
