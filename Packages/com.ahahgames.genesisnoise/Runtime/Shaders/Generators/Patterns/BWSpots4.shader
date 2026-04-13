Shader "Hidden/Genesis/BWSpots4"
{
    Properties
    {
        _Density("Macro Density", Range(0.0, 1.0)) = 0.45
        _MicroDensity("Micro Density", Range(0.0, 1.0)) = 0.65
        _Scale("Macro Scale", Range(1.0, 64.0)) = 8.0
        _MicroScale("Micro Scale", Range(4.0, 128.0)) = 32.0
        _Softness("Softness", Range(1.0, 12.0)) = 7.0
        _Warp("Warp Amount", Range(0.0, 1.0)) = 0.45
        _Flow("Flow Distortion", Range(0.0, 2.0)) = 0.35
        _Contrast("Contrast", Range(0.5, 4.0)) = 1.1
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

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            float _Density;
            float _MicroDensity;
            float _Scale;
            float _MicroScale;
            float _Softness;
            float _Warp;
            float _Flow;
            float _Contrast;

            // -------------------------------
            // Hash helpers
            // -------------------------------
            float hash11(float n)
            {
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7));
                return frac(sin(float2(n, n + 1.234)) * 43758.5453);
            }

            // -------------------------------
            // Soft falloff
            // -------------------------------
            float falloff(float d, float r, float s)
            {
                float x = saturate(1.0 - d / r);
                return pow(x, s);
            }

            // -------------------------------
            // Flow warp (gives watercolor diffusion)
            // -------------------------------
            float2 flowWarp(float2 uv)
            {
                float2 n = hash21(floor(uv * 8.0));
                return (n - 0.5) * _Flow;
            }

            // -------------------------------
            // Macro + Micro Spots (BW Spots 4)
            // -------------------------------
            float bwSpots4(float2 uv)
            {
                float macro = 0.0;
                float micro = 0.0;

                // -------------------------------
                // Macro layer (large blots)
                // -------------------------------
                {
                    float2 p = uv * _Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);

                    [unroll]
                    for (int y = -1; y <= 1; y++)
                    {
                        [unroll]
                        for (int x = -1; x <= 1; x++)
                        {
                            float2 cell = ip + float2(x, y);
                            float2 rnd = hash21(cell);

                            if (rnd.x > _Density)
                                continue;

                            float2 center = rnd;

                            float radius = lerp(0.25, 1.2,
                                hash11(dot(cell, float2(91.7, 12.3))));

                            float soft = lerp(_Softness * 0.8,
                                              _Softness * 1.4,
                                              rnd.y);

                            float2 warp = (rnd - 0.5) * _Warp;
                            float2 fp2 = fp + float2(x, y) + warp + flowWarp(uv);

                            float d = distance(fp2, center);
                            float s = falloff(d, radius, soft);

                            macro = max(macro, s);
                        }
                    }
                }

                // -------------------------------
                // Micro layer (fine speckles)
                // -------------------------------
                {
                    float2 p = uv * _MicroScale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);

                    [unroll]
                    for (int y = -1; y <= 1; y++)
                    {
                        [unroll]
                        for (int x = -1; x <= 1; x++)
                        {
                            float2 cell = ip + float2(x, y);
                            float2 rnd = hash21(cell);

                            if (rnd.x > _MicroDensity)
                                continue;

                            float2 center = rnd;

                            float radius = lerp(0.02, 0.12,
                                hash11(dot(cell, float2(13.7, 77.3))));

                            float soft = lerp(_Softness * 0.5,
                                              _Softness * 0.9,
                                              rnd.y);

                            float2 fp2 = fp + float2(x, y);

                            float d = distance(fp2, center);
                            float s = falloff(d, radius, soft);

                            micro = max(micro, s);
                        }
                    }
                }

                // Combine macro + micro
                float v = max(macro, micro);

                // Gentle contrast shaping
                v = pow(v, _Contrast);

                return v;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float v = bwSpots4(uv);
                v=smoothstep(0,1,v);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}