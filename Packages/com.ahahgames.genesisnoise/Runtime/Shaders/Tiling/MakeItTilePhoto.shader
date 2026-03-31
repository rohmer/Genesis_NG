Shader "Hidden/Genesis/MakeItTilePhoto"
{
    Properties
    {
        // Source image
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        _Feather("Feather Width", Range(0, 0.5)) = 0.15
        _Offset("Random Offset", Range(0, 1)) = 0.25
        _Seed("Seed", Range(0, 9999)) = 1234

        // Optional patch jitter
        _PatchJitter("Patch Jitter", Range(0, 1)) = 0.0
        _Grid("Grid Size", Range(1, 8)) = 3
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

            float _Feather;
            float _Offset;
            float _Seed;
            float _PatchJitter;
            float _Grid;

            // ------------------------------------------------------------
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

            // Mirror tiling (critical for Make It Tile Photo)
            float2 Mirror(float2 uv)
            {
                uv = abs(frac(uv) * 2.0 - 1.0);
                return uv;
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                // Random global offset
                float2 rnd = Hash22(_Seed);
                float2 offset = (rnd - 0.5) * _Offset;

                // Apply offset
                float2 uvOff = uv + offset;

                // Mirror to remove seams
                float2 uvMir = Mirror(uvOff);

                // Patch jitter (optional)
                if (_PatchJitter > 0.0)
                {
                    int grid = max(1, (int)_Grid);
                    float cell = 1.0 / grid;

                    float2 pid = floor(uv * grid);
                    float2 jitter = (Hash22(pid + _Seed) - 0.5) * _PatchJitter * cell;

                    uvMir += jitter;
                }

                // Feathering near borders
                float2 edge = min(uvMir, 1.0 - uvMir);
                float featherMask = saturate(edge.x / _Feather) * saturate(edge.y / _Feather);

                float3 col = SampleSource(float3(uvMir,i.localTexcoord.z), i.direction);

                // Blend toward mirrored center to hide seams
                col *= featherMask;

                return float4(col, 1);
            }

            ENDHLSL
        }
    } 
}