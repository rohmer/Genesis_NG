Shader "Hidden/Genesis/ScratchesGenerator"
{
    Properties
    {
        [Tooltip(Waviness of the scratch lines)]
        _Wavyness("Wavyness", Float) = 0.1

        [Tooltip(Global UV scale)]
        _Scale("Scale", Vector) = (3,3,0,0)

        [Tooltip(Global UV offset)]
        _Offset("Offset", Vector) = (0,0,0,0)

        [Tooltip(Number of scratch layers)]
        _Layers("Layers", Int) = 4

        [Tooltip(Base frequency per layer)]
        _BaseFrequency("Base Frequency", Vector) = (0.5,0.5,0,0)

        [Tooltip(Frequency increment per layer)]
        _FrequencyStep("Frequency Step", Vector) = (0.25,0.25,0,0)

        [Tooltip(Random seed)]
        _Seed("Seed", Float) = 1.0

        [Tooltip(Optional mask texture)]
        _Mask("Mask", 2D) = "white" {}

        [Tooltip(How strongly the mask affects scratches)]
        _MaskStrength("Mask Strength", Float) = 1.0
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

            float _Wavyness;
            float2 _Scale;
            float2 _Offset;
            int _Layers;
            float2 _BaseFrequency;
            float2 _FrequencyStep;
            float _Seed;

            sampler2D _Mask;
            float _MaskStrength;

            // -------------------------
            // Rotation helper
            // -------------------------
            void pR(inout float2 p, float a)
            {
                float sa = sin(a);
                float ca = cos(a);
                float2x2 m = float2x2(ca, sa, -sa, ca);
                p = mul(m, p);
            }

            // -------------------------
            // Hash-like deterministic seed mutation
            // -------------------------
            float2 mutateSeed(float2 s)
            {
                s.x = floor(sin(s.x * 51024.0 + _Seed) * 3104.0);
                s.y = floor(sin(s.y * 1324.0 + _Seed) * 554.0);
                return s;
            }

            // -------------------------
            // Single scratch generator
            // -------------------------
            float scratch(float2 uv, float2 seed)
            {
                seed = mutateSeed(seed);

                uv = uv * 2.0 - 1.0;
                pR(uv, seed.x + seed.y);
                uv += sin(seed.x - seed.y);
                uv = clamp(uv * 0.5 + 0.5, 0.0, 1.0);

                float s1 = sin(seed.x + uv.y * 3.1415) * _Wavyness;
                float s2 = sin(seed.y + uv.y * 3.1415) * _Wavyness;

                float x = sign(0.01 - abs(uv.x - 0.5 + s1 + s2));
                float yShape = (1.0 - pow(uv.y, 2.0)) * uv.y * 2.5;

                return saturate(yShape * x);
            }

            // -------------------------
            // Layer wrapper
            // -------------------------
            float layer(float2 uv, float2 freq, float2 offset, float angle)
            {
                pR(uv, angle);
                uv = uv * freq + offset;
                return scratch(frac(uv), floor(uv));
            }

            // -------------------------
            // Multi-layer scratch generator
            // -------------------------
            float scratches(float2 uv)
            {
                uv = uv * _Scale + _Offset;

                float2 freq = _BaseFrequency;
                float result = 0.0;

                for (int i = 0; i < _Layers; i++)
                {
                    float fi = (float)i;
                    result = max(result, layer(uv, freq, float2(fi, fi), fi * 3145.0));
                    freq += _FrequencyStep;
                }

                return saturate(result);
            }

            // -------------------------
            // Final CRT fragment
            // -------------------------
            float4 mixture(v2f_customrendertexture IN) : SV_Target
            {
                float3 uv = IN.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float s = scratches(uv.xy);

                // Sample mask
                float mask = tex2D(_Mask, uv.xy).r;

                // Blend scratches with mask
                // maskStrength = 1 → fully masked
                // maskStrength = 0 → no masking
                s *= lerp(1.0, mask, _MaskStrength);

                return float4(s, s, s, 1.0);
            }

            ENDHLSL
        }
    }
}
