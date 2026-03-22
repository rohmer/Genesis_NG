Shader "Hidden/Genesis/MakeItTilePatch"
{
    Properties
    {
        // Source texture
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        _Grid("Grid Size", Range(1, 8)) = 3
        _Feather("Feather Amount", Range(0, 0.5)) = 0.1
        _Randomness("Random Offset", Range(0, 1)) = 0.5
        _Rotate("Random Rotate", Int) = 0
        _Seed("Seed", Range(0, 9999)) = 1234
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

            float _Grid;
            float _Feather;
            float _Randomness;
            int   _Rotate;
            float _Seed;

            // ------------------------------------------------------------
            // Hash for deterministic pseudo-randomness
            float Hash21(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return frac(p.x * p.y);
            }

            float2 Hash22(float2 p)
            {
                float n = Hash21(p);
                return float2(n, Hash21(p + n));
            }

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            // ------------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                int grid = max(1, (int)_Grid);
                float cell = 1.0 / grid;

                // Which patch are we in?
                float2 patchId = floor(uv / cell);

                // Local UV inside patch
                float2 localUV = frac(uv / cell);

                // Random offset per patch
                float2 rnd = Hash22(patchId + _Seed);
                float2 offset = (rnd - 0.5) * _Randomness * cell;

                // Optional rotation
                if (_Rotate == 1)
                {
                    float ang = rnd.x * 6.2831853;
                    float s = sin(ang);
                    float c = cos(ang);
                    localUV = float2(
                        localUV.x * c - localUV.y * s,
                        localUV.x * s + localUV.y * c
                    );
                }

                // Wrap local UV to keep tiling
                localUV = frac(localUV);

                // Feathering near patch borders
                float2 edge = min(localUV, 1.0 - localUV);
                float featherMask = saturate(edge.x / _Feather) * saturate(edge.y / _Feather);

                // Final UV with patch offset
                float2 finalUV = uv + offset;

                float3 col = SampleSource(float3(finalUV,i.localTexcoord.z), i.direction);

                // Feather to avoid seams
                col *= featherMask;
                 
                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}