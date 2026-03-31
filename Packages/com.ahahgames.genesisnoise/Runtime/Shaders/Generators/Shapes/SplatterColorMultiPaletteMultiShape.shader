Shader "Hidden/Genesis/SplatterColorMultiPaletteMultiShape"
{
    Properties
    {
        // --- Shape array ---
        _ShapeCount("Shape Count", int) = 3

        _Shape0_2D("Shape 0", 2D) = "white" {}
        _Shape1_2D("Shape 1", 2D) = "white" {}
        _Shape2_2D("Shape 2", 2D) = "white" {}
        _Shape3_2D("Shape 3", 2D) = "white" {}
        _Shape4_2D("Shape 4", 2D) = "white" {}

        // --- Palette array ---
        _PaletteCount("Palette Count", int) = 3

        _Palette0_2D("Palette 0", 2D) = "white" {}
        _Palette1_2D("Palette 1", 2D) = "white" {}
        _Palette2_2D("Palette 2", 2D) = "white" {}
        _Palette3_2D("Palette 3", 2D) = "white" {}
        _Palette4_2D("Palette 4", 2D) = "white" {}

        // --- Core splatter controls ---
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (8,8,0,0)
        [Tooltip(Instances per cell)] _Density("Density", Range(1,32)) = 8

        [Tooltip(Position jitter)] _Jitter("Jitter", Range(0,1)) = 0.4
        [Tooltip(Rotation jitter)] _RotJitter("Rotation Jitter", Range(0,6.283)) = 3.14
        [Tooltip(Scale min)] _ScaleMin("Scale Min", Range(0.01,2)) = 0.4
        [Tooltip(Scale max)] _ScaleMax("Scale Max", Range(0.01,2)) = 1.2

        // --- Color jitter ---
        [Tooltip(Hue jitter)] _HueJitter("Hue Jitter", Range(0,1)) = 0.2
        [Tooltip(Saturation jitter)] _SatJitter("Sat Jitter", Range(0,1)) = 0.2
        [Tooltip(Value jitter)] _ValJitter("Val Jitter", Range(0,1)) = 0.2
        [Tooltip(Brightness jitter)] _BrightnessJitter("Brightness Jitter", Range(0,1)) = 0.2

        // --- Blending ---
        [Tooltip(Blend softness)] _BlendSoftness("Blend Softness", Range(0,1)) = 0.2
        [Tooltip(Opacity)] _Opacity("Opacity", Range(0,1)) = 1.0
        [Enum(Normal,0,Add,1,Multiply,2)] _BlendMode("Blend Mode", int) = 0

        // --- Random seed ---
        _Seed("Seed", int) = 52
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

            // --- Shape samplers ---
            SAMPLER_X(_Shape0);
            SAMPLER_X(_Shape1);
            SAMPLER_X(_Shape2);
            SAMPLER_X(_Shape3);
            SAMPLER_X(_Shape4);

            // --- Palette samplers ---
            SAMPLER_X(_Palette0);
            SAMPLER_X(_Palette1);
            SAMPLER_X(_Palette2);
            SAMPLER_X(_Palette3);
            SAMPLER_X(_Palette4);

            // --- Parameters ---
            float2 _Scale;
            float  _Density;

            float  _Jitter;
            float  _RotJitter;
            float  _ScaleMin;
            float  _ScaleMax;

            float  _HueJitter;
            float  _SatJitter;
            float  _ValJitter;
            float  _BrightnessJitter;

            float  _BlendSoftness;
            float  _Opacity;
            int    _BlendMode;

            int    _ShapeCount;
            int    _PaletteCount;

            float  _Seed;

            // ---------------------------------------------------------
            // Hash helpers
            // ---------------------------------------------------------
            float hash11(float n)
            {
                n += _Seed * 17.0;
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7)) + _Seed * 13.37;
                return frac(sin(float2(n, n + 1.234)) * 43758.5453);
            }

            float3 hash31(float n)
            {
                return float3(hash11(n), hash11(n + 17.0), hash11(n + 37.0));
            }

            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a), c = cos(a);
                return float2(c*p.x - s*p.y, s*p.x + c*p.y);
            }

            // ---------------------------------------------------------
            // HSV → RGB
            // ---------------------------------------------------------
            float3 hsv2rgb(float3 c)
            {
                float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }

            // ---------------------------------------------------------
            // Shape selection
            // ---------------------------------------------------------
            float sampleShapeN(int idx, float2 uv, float3 dir)
            {
                if (idx == 0) return SAMPLE_X(_Shape0, float3(uv,0), dir).r;
                if (idx == 1) return SAMPLE_X(_Shape1, float3(uv,0), dir).r;
                if (idx == 2) return SAMPLE_X(_Shape2, float3(uv,0), dir).r;
                if (idx == 3) return SAMPLE_X(_Shape3, float3(uv,0), dir).r;
                return SAMPLE_X(_Shape4, float3(uv,0), dir).r;
            }

            // ---------------------------------------------------------
            // Palette selection
            // ---------------------------------------------------------
            float3 samplePaletteN(int idx, float u)
            {
                if (idx == 0) return SAMPLE_X(_Palette0, float3(u,0.5,0), 0).rgb;
                if (idx == 1) return SAMPLE_X(_Palette1, float3(u,0.5,0), 0).rgb;
                if (idx == 2) return SAMPLE_X(_Palette2, float3(u,0.5,0), 0).rgb;
                if (idx == 3) return SAMPLE_X(_Palette3, float3(u,0.5,0), 0).rgb;
                return SAMPLE_X(_Palette4, float3(u,0.5,0), 0).rgb;
            }

            // ---------------------------------------------------------
            // Blend modes
            // ---------------------------------------------------------
            float4 blend(float4 base, float4 over)
            {
                if (_BlendMode == 0) // Normal
                    return lerp(base, over, over.a);

                if (_BlendMode == 1) // Add
                    return float4(base.rgb + over.rgb * over.a, 1.0);

                // Multiply
                return float4(base.rgb * (1.0 - over.a) + base.rgb * over.rgb * over.a, 1.0);
            }

            // ---------------------------------------------------------
            // Main splatter
            // ---------------------------------------------------------
            float4 splatter(float3 uv, float3 dir)
            {
                float2 p = uv.xy * _Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);

                float4 outC = float4(0,0,0,1);

                [loop]
                for (int i = 0; i < (int)_Density; i++)
                {
                    float2 seed = ip + float2(i * 17.0, i * 31.0);
                    float2 rnd = hash21(seed);
                    float3 rnd3 = hash31(i + dot(ip, float2(7,13)));

                    // --- Random shape selection ---
                    int shapeIdx = (int)floor(rnd.x * _ShapeCount);

                    // --- Random palette selection ---
                    int paletteIdx = (int)floor(rnd.y * _PaletteCount);

                    // --- Transform ---
                    float2 center = rnd * _Jitter + 0.5 * (1.0 - _Jitter);
                    float angle = (rnd.x * 2.0 - 1.0) * _RotJitter;
                    float scale = lerp(_ScaleMin, _ScaleMax, rnd.y);

                    float2 uvS = fp - center;
                    uvS = rotate2D(uvS, angle);
                    uvS /= scale;
                    uvS += 0.5;

                    float shape = sampleShapeN(shapeIdx, uvS, dir);

                    if (shape > 0.0)
                    {
                        // --- Color ---
                        float u = rnd3.x;
                        float3 col = samplePaletteN(paletteIdx, u);

                        // Convert to HSV
                        float maxc = max(col.r, max(col.g, col.b));
                        float minc = min(col.r, min(col.g, col.b));
                        float delta = maxc - minc;

                        float3 hsv;
                        if (delta < 1e-5) hsv.x = 0.0;
                        else if (maxc == col.r) hsv.x = frac((col.g - col.b) / delta / 6.0);
                        else if (maxc == col.g) hsv.x = frac((col.b - col.r) / delta / 6.0 + 1.0/3.0);
                        else hsv.x = frac((col.r - col.g) / delta / 6.0 + 2.0/3.0);

                        hsv.y = (maxc < 1e-5) ? 0.0 : delta / maxc;
                        hsv.z = maxc;

                        // Apply jitter
                        hsv.x = frac(hsv.x + (rnd3.x * 2.0 - 1.0) * _HueJitter);
                        hsv.y = saturate(hsv.y + (rnd3.y * 2.0 - 1.0) * _SatJitter);
                        hsv.z = saturate(hsv.z + (rnd3.z * 2.0 - 1.0) * _ValJitter);

                        float brightness = 1.0 + (rnd3.y * 2.0 - 1.0) * _BrightnessJitter;

                        float3 rgb = hsv2rgb(hsv) * brightness;

                        float a = shape * _Opacity;

                        float4 over = float4(rgb, a);
                        outC = blend(outC, over);
                    }
                }

                return outC;
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                return splatter(i.localTexcoord, i.direction);
            }

            ENDHLSL
        }
    }
}