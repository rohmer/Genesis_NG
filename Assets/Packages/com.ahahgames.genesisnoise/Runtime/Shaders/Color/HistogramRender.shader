Shader "Hidden/Genesis/HistogramRender"
{
    Properties
    {
        [InlineTexture]_UV_2D("Input", 2D) = "white" {}
        [InlineTexture]_UV_3D("Input", 3D) = "white" {}
        [InlineTexture]_UV_Cube("Input", Cube) = "white" {}

        _Bins("Histogram Bins", Range(16, 256)) = 128
        _Intensity("Intensity", Range(0.1, 10.0)) = 2.0
        _Smooth("Smoothing", Range(0.0, 1.0)) = 0.25
        _LogScale("Log Scale", Range(0,1)) = 0
        _Cumulative("Cumulative Histogram", Range(0,1)) = 0
        _BarWidth("Bar Width", Range(0.1, 1.0)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET_API
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            TEXTURE_SAMPLER_X(_UV);

            float _Bins;
            float _Intensity;
            float _Smooth;
            float _LogScale;
            float _Cumulative;
            float _BarWidth;

            // Simple luminance
            float luminance(float3 c)
            {
                return dot(c, float3(0.299, 0.587, 0.114));
            }

            // Approximate histogram by sampling along a fixed grid
            float computeBinValue(float bin, float3 uv, float3 dir)
            {
                float count = 0.0;
                float total = 0.0;

                float2 texel = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y);

                // Sample a grid of pixels to approximate histogram
                for (int x = 0; x < 16; x++)
                {
                    for (int y = 0; y < 16; y++)
                    {
                        float3 o = float3(x / 15.0, y / 15.0, uv.z);
                        float3 col = SAMPLE_X(_UV, o,dir).rgb;
                        float g = luminance(col);

                        float b = floor(g * _Bins);

                        if (abs(b - bin) < 0.5)
                            count += 1.0;

                        total += 1.0;
                    }
                }

                float v = count / total;

                // Optional log scale
                if (_LogScale > 0.5)
                    v = log(1.0 + v * 10.0);

                return v;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                // X = histogram bin
                float binF = uv.x * _Bins;
                float bin = floor(binF);

                // Compute histogram value
                float v = computeBinValue(bin, uv, i.direction);

                // Optional cumulative histogram
                if (_Cumulative > 0.5)
                {
                    float sum = 0.0;
                    for (int b = 0; b <= bin; b++)
                        sum += computeBinValue(b, uv, i.direction);

                    v = sum / _Bins;
                }

                // Smoothing
                if (_Smooth > 0.01)
                {
                    float left  = computeBinValue(max(0, bin - 1), uv, i.direction);
                    float right = computeBinValue(min(_Bins - 1, bin + 1), uv,i.direction);
                    v = lerp(v, (left + v + right) / 3.0, _Smooth);
                }

                // Render histogram bars
                float barHeight = saturate(v * _Intensity);

                float bar = step(uv.y, barHeight);

                // Bar width shaping
                float bw = _BarWidth * (1.0 / _Bins);
                float center = frac(binF);
                float mask = smoothstep(0.5 - bw, 0.5, center) *
                             (1.0 - smoothstep(0.5, 0.5 + bw, center));

                float final = bar * mask;

                return float4(final, final, final, 1.0);
            }

            ENDHLSL
        }
    }
}