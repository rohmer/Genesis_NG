Shader "Hidden/Genesis/Histogram"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        _Source("Source Texture", 2D) = "white" {}
        [IntRange]_Bins("Bins", Range(1, 512)) = 64
        [IntRange]_Samples("Samples per Bin", Range(1, 1024)) = 128
        _Seed("Seed", Int) = 42
        _LumaWeight("Luma Weights (R,G,B)", Vector) = (0.299,0.587,0.114,0)
        _Scale("UV Scale", Float) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV
            #pragma shader_feature _TILINGMODE_NONE _TILINGMODE_TILED

            TEXTURE_SAMPLER_X(_UV);

            // Source texture
            TEXTURE2D(_Source);
            SAMPLER(sampler_Source);

            int _Bins;
            int _Samples;
            int _Seed;
            float4 _LumaWeight;
            float _Scale;
            int _UVMode;

            // ------------------------------------------------------------
            // Simple hash helpers (deterministic sample positions)
            // ------------------------------------------------------------
            float hash11(float n)
            {
                return frac(sin(n) * 43758.5453123);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7));
                return frac(sin(float2(n, n + 1.2345)) * 43758.5453123);
            }

            // Stratified sample generator: returns a sample position in [0,1]^2
            float2 SamplePoint(int sampleIndex, int binIndex, int seed)
            {
                // combine indices into a float seed
                float s = sampleIndex * 1.0 + binIndex * 131.5423 + seed * 17.0;
                // jittered grid: use low-discrepancy like pattern via hash
                float2 h = hash21(float2(s, s * 1.6180339));
                // stratify by sampleIndex to reduce clumping
                float inv = 1.0 / max(1, _Samples);
                float2 strat = float2(frac(sampleIndex * 0.6180339), frac(sampleIndex * 1.3247));
                return frac(h + strat * inv);
            }

            // Luminance helper
            float Luma(float3 c)
            {
                return dot(c, _LumaWeight.xyz);
            }

            // ------------------------------------------------------------
            // Main fragment: compute histogram frequency for this bin
            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                // Get canonical UVs (0..1)
                float3 uvs = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);
                float2 uv = uvs.xy * _Scale;

                // Determine which bin this pixel corresponds to (use x)
                // clamp to [0, _Bins-1]
                float fx = saturate(uv.x);
                int bin = (int)floor(fx * max(1, _Bins));
                bin = clamp(bin, 0, max(1, _Bins) - 1);

                // Accumulate counts
                float count = 0.0;

                // Loop over samples (use [loop] to allow dynamic count)
                [loop]
                for (int s = 0; s < _Samples; s++)
                {
                    // generate sample position in source texture space
                    float2 sp = SamplePoint(s, bin, _Seed);

                    // Optionally scale sample distribution across source UVs
                    // Here we sample across the full source texture
                    float2 sampleUV = sp;

                    // read source color
                    float4 src = SAMPLE_TEXTURE2D(_Source, sampler_Source, sampleUV);

                    // compute luminance and map to bin
                    float lum = Luma(src.rgb);
                    int sampleBin = (int)floor(saturate(lum) * max(1, _Bins));
                    sampleBin = clamp(sampleBin, 0, max(1, _Bins) - 1);

                    if (sampleBin == bin)
                        count += 1.0;
                }
                 
                // normalize frequency
                float freq = count / max(1.0, (float)_Samples);

                // optional smoothing for nicer curve (comment out if not wanted)
                // freq = smoothstep(0.0, 1.0, freq);

                // Output: R = frequency, G = frequency, B = frequency, A = 1
                return float4(freq, freq, freq, 1.0);
            }

            ENDHLSL
        }
    }
}
