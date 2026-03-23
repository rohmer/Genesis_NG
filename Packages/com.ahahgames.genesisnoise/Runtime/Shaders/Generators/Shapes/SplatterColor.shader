Shader "Hidden/Genesis/SplatterColor"
{
    Properties
    {
        _Shape_2D("Shape", 2D) = "white" {}
        _Shape_3D("Shape", 3D) = "white" {}
        _Shape_Cube("Shape", Cube) = "white" {}

        _Palette_2D("Palette", 2D) = "white" {}
        _Palette_3D("Palette", 3D) = "white" {}
        _Palette_Cube("Palette", Cube) = "white" {}

        [Enum(Disabled,0,Enabled,1)] _UseShape("Use Shape", int) = 1
        [Enum(Disabled,0,Enabled,1)] _UsePalette("Use Palette", int) = 0

        [Tooltip(Global tiling of splatter grid)] _Scale("Scale", Vector) = (1,1,0,0)

        [Tooltip(Number of shapes per cell)] _Density("Density", Range(1,16)) = 4

        [Tooltip(Random position jitter)] _Jitter("Jitter", Range(0,1)) = 0.4
        [Tooltip(Random rotation)] _RotJitter("Rotation Jitter", Range(0,6.283)) = 3.14
        [Tooltip(Random scale min)] _ScaleMin("Scale Min", Range(0.01,2)) = 0.4
        [Tooltip(Random scale max)] _ScaleMax("Scale Max", Range(0.01,2)) = 1.2

        [Tooltip(Random hue shift)] _HueJitter("Hue Jitter", Range(0,1)) = 0.2
        [Tooltip(Random saturation shift)] _SatJitter("Sat Jitter", Range(0,1)) = 0.2
        [Tooltip(Random value shift)] _ValJitter("Val Jitter", Range(0,1)) = 0.2
        [Tooltip(Random brightness)] _BrightnessJitter("Brightness Jitter", Range(0,1)) = 0.2

        [Tooltip(Blend softness)] _BlendSoftness("Blend Softness", Range(0,1)) = 0.2
        [Tooltip(Opacity)] _Opacity("Opacity", Range(0,1)) = 1.0

        [Enum(Normal,0,Add,1,Multiply,2)] _BlendMode("Blend Mode", int) = 0

        [Tooltip(Randomization seed)] _Seed("Seed", int) = 52
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

            SAMPLER_X(_Shape);
            SAMPLER_X(_Palette);

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

            float  _Seed;
            int    _UseShape;
            int    _UsePalette;

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
            float3 hsv2rgb(float3 c)
            {
                float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }

            // ---------------------------------------------------------
            float sampleShape(float2 uv, float2 center, float angle, float scale, float3 dir)
            {
                float2 p = uv - center;
                p = rotate2D(p, angle);
                p /= scale;
                p += 0.5;

                return SAMPLE_X(_Shape, float3(p, 0), dir).r;
            }

            // ---------------------------------------------------------
            float3 getColor(float2 rnd)
            {
                float3 col;

                if (_UsePalette)
                {
                    float u = rnd.x;
                    col = SAMPLE_X(_Palette, float3(u, 0.5, 0), 0).rgb;
                }
                else
                {
                    col = rnd.xxx; // grayscale fallback
                }

                // Convert to HSV
                float3 hsv;
                float maxc = max(col.r, max(col.g, col.b));
                float minc = min(col.r, min(col.g, col.b));
                float delta = maxc - minc;

                // Hue
                if (delta < 1e-5) hsv.x = 0.0;
                else if (maxc == col.r) hsv.x = frac((col.g - col.b) / delta / 6.0);
                else if (maxc == col.g) hsv.x = frac((col.b - col.r) / delta / 6.0 + 1.0/3.0);
                else hsv.x = frac((col.r - col.g) / delta / 6.0 + 2.0/3.0);

                // Sat & Val
                hsv.y = (maxc < 1e-5) ? 0.0 : delta / maxc;
                hsv.z = maxc;

                // Apply jitter
                hsv.x = frac(hsv.x + (rnd.x * 2.0 - 1.0) * _HueJitter);
                hsv.y = saturate(hsv.y + (rnd.y * 2.0 - 1.0) * _SatJitter);
                hsv.z = saturate(hsv.z + (rnd.x * 2.0 - 1.0) * _ValJitter);

                float brightness = 1.0 + (rnd.y * 2.0 - 1.0) * _BrightnessJitter;

                return hsv2rgb(hsv) * brightness;
            }

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
            float4 splatterColor(float3 uv, float3 dir)
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

                    float2 center = rnd * _Jitter + 0.5 * (1.0 - _Jitter);
                    float angle = (rnd.x * 2.0 - 1.0) * _RotJitter;
                    float scale = lerp(_ScaleMin, _ScaleMax, rnd.y);

                    float shape = sampleShape(fp, center, angle, scale, dir);

                    if (shape > 0.0)
                    {
                        float3 col = getColor(rnd);
                        float a = shape * _Opacity;

                        float4 over = float4(col, a);
                        outC = blend(outC, over);
                    }
                }

                return outC;
            }

            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv  = i.localTexcoord;
                float3 dir = i.direction;

                return splatterColor(uv, dir);
            }

            ENDHLSL
        }
    }
}