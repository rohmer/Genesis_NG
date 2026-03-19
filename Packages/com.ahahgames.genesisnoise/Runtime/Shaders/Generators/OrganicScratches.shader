Shader "Hidden/Genesis/OrganicScratches"
{
    Properties
    {
        [InlineTexture]_Mask_2D("Mask", 2D) = "white" {}
        [InlineTexture]_Mask_3D("Mask", 3D) = "white" {}
        [InlineTexture]_Mask_Cube("Mask", Cube) = "white" {}

        [Tooltip(Waviness of the scratches)] uWavyness("Waviness", Range(0, 1)) = 0.1
        [GenesisVector2]Scale("Scale", Vector) = (3,3,0,0)
        uLayers("Layers", Range(1,20)) = 4
        [GenesisVector2]uBaseFrequency("Base Frequency", Vector) = (0.5,0.5,0,0)
        [GenesisVector2]uFrequencyStep("Frequency Step", Vector) = (0.25,0.25,0,0)
        aaLevel("Antialias Level", Range(1,6)) = 4
        _Seed("Seed", Range(0,65536)) = 1234
        [GenesisVector2]uOffset("Offset", Vector) = (0,0,0,0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET_API
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            // Optional: mask if you want to use it later
            TEXTURE_SAMPLER_X(_Mask);

            float uWavyness;
            float2 Scale;
            float2 uBaseFrequency, uFrequencyStep;
            float2 uOffset;
            int _Seed;
            int uLayers;
            int aaLevel;
            float2 dxdy : register(c0);

            // Rotation: GLSL mat2(ca, sa, -sa, ca)
            void pR(inout float2 p, float a)
            {
                float sa = sin(a);
                float ca = cos(a);

                float2 rp;
                rp.x = ca * p.x + sa * p.y;
                rp.y = -sa * p.x + ca * p.y;

                p = rp;
            }

            float scratch(float2 uv, float2 seed)
            {
                seed.x = floor(sin(seed.x * 51024.0) * 3104.0);
                seed.y = floor(sin(seed.y * 1324.0) * 554.0);

                uv = uv * 2.0 - 1.0;

                pR(uv, seed.x + seed.y);

                uv += sin(seed.x - seed.y) * 0.01; // keep this small
                uv = clamp(uv * 0.5 + 0.5, 0.0, 1.0);

                float s1 = sin(seed.x + uv.y * 3.1415) * uWavyness;
                float s2 = sin(seed.y + uv.y * 3.1415) * uWavyness;

                float x = sign(0.01 - abs(uv.x - 0.5 + s2 + s1));

                return clamp(((1.0 - pow(uv.y, 2.0)) * uv.y) * 2.5 * x, 0.0, 1.0);
            }

            float layer(float2 uv, float2 frequency, float2 offset, float angle)
            {
                pR(uv, angle);
                uv = uv * frequency + offset;
                return scratch(frac(uv), floor(uv));
            }

            float scratches(float2 uv)
            {
                uv *= Scale;
                uv += uOffset;

                float2 frequency = uBaseFrequency;
                float scratches = 0.0;

                for (int i = 0; i < uLayers; ++i)
                {
                    float fi = float(i);
                    scratches = max(scratches, layer(uv, frequency, float2(fi, fi), fi * 3145.0));
                    frequency += uFrequencyStep;
                }

                return clamp(scratches, 0.0, 1.0);
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                // Seed drives offset; you can also add time here if desired
                uOffset = float2(_Seed, 0.0);

                float2 uv = i.localTexcoord.xy;

                int AA2 = aaLevel * aaLevel;
                float col = 0.0;

                // AA step in UV space
                float2 pix = dxdy / aaLevel;

                for (int s = 0; s < AA2; ++s)
                {
                    float k = (float)s;
                    float2 jitter = float2(floor(k / aaLevel), fmod(k, aaLevel));
                    float2 uvOffs = uv + jitter * pix;
                    col += scratches(uvOffs);
                }

                col /= (aaLevel * aaLevel);

                return float4(col, col, col, 1.0);
            }

            ENDHLSL
        }
    }
}