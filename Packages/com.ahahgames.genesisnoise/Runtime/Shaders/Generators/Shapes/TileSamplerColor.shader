Shader "Hidden/Genesis/TileSamplerColor"
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

        // --- Tiling ---
        [Tooltip(Tile count X,Y)] _Tiles("Tiles", Vector) = (8,8,0,0)
        [Tooltip(Global offset)] _Offset("Offset", Vector) = (0,0,0,0)

        // --- Transform jitter ---
        [Tooltip(Position jitter)] _Jitter("Jitter", Range(0,1)) = 0.25
        [Tooltip(Rotation jitter)] _RotJitter("Rotation Jitter", Range(0,6.283)) = 1.57
        [Tooltip(Scale min)] _ScaleMin("Scale Min", Range(0.01,2)) = 0.8
        [Tooltip(Scale max)] _ScaleMax("Scale Max", Range(0.01,2)) = 1.2

        // --- Color jitter ---
        [Tooltip(Hue jitter)] _HueJitter("Hue Jitter", Range(0,1)) = 0.2
        [Tooltip(Saturation jitter)] _SatJitter("Sat Jitter", Range(0,1)) = 0.2
        [Tooltip(Value jitter)] _ValJitter("Val Jitter", Range(0,1)) = 0.2
        [Tooltip(Brightness jitter)] _BrightnessJitter("Brightness Jitter", Range(0,1)) = 0.2

        // --- Blending ---
        [Tooltip(Opacity)] _Opacity("Opacity", Range(0,1)) = 1.0
        [Tooltip(Blend softness)] _BlendSoftness("Blend Softness", Range(0,1)) = 0.2
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

            float2 _Tiles;
            float2 _Offset;

            float  _Jitter;
            float  _RotJitter;
            float  _ScaleMin;
            float  _ScaleMax;

            float  _HueJitter;
            float  _SatJitter;
            float  _ValJitter;
            float  _BrightnessJitter;

            float  _Opacity;
            float  _BlendSoftness;
            int    _BlendMode;

            int    _ShapeCount;
            int    _PaletteCount;

            float  _Seed;

            // ---------------------------------------------------------
            float hash11(float n)
            {
                n += _Seed * 17.0;
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1,311.7)) + _Seed * 13.37;
                return frac(sin(float2(n,n+1.234)) * 43758.5453);
            }

            float3 hash31(float n)
            {
                return float3(hash11(n), hash11(n+17.0), hash11(n+37.0));
            }

            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a), c = cos(a);
                return float2(c*p.x - s*p.y, s*p.x + c*p.y);
            }

            // ---------------------------------------------------------
            float3 hsv2rgb(float3 c)
            {
                float4 K = float4(1.0,2.0/3.0,1.0/3.0,3.0);
                float3 p = abs(frac(c.xxx + K.xyz)*6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p-K.xxx), c.y);
            }

            // ---------------------------------------------------------
            float sampleShapeN(int idx, float2 uv, float3 dir)
            {
                if (idx == 0) return SAMPLE_X(_Shape0, float3(uv,0), dir).r;
                if (idx == 1) return SAMPLE_X(_Shape1, float3(uv,0), dir).r;
                if (idx == 2) return SAMPLE_X(_Shape2, float3(uv,0), dir).r;
                if (idx == 3) return SAMPLE_X(_Shape3, float3(uv,0), dir).r;
                return SAMPLE_X(_Shape4, float3(uv,0), dir).r;
            }

            float3 samplePaletteN(int idx, float u)
            {
                if (idx == 0) return SAMPLE_X(_Palette0, float3(u,0.5,0), 0).rgb;
                if (idx == 1) return SAMPLE_X(_Palette1, float3(u,0.5,0), 0).rgb;
                if (idx == 2) return SAMPLE_X(_Palette2, float3(u,0.5,0), 0).rgb;
                if (idx == 3) return SAMPLE_X(_Palette3, float3(u,0.5,0), 0).rgb;
                return SAMPLE_X(_Palette4, float3(u,0.5,0), 0).rgb;
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
            float4 tileSamplerColor(float3 uv, float3 dir)
            {
                float2 tiles = max(_Tiles, float2(1,1));

                float2 p = uv.xy * tiles + _Offset;

                float2 tileID = floor(p);
                float2 fp = frac(p);

                float2 rnd = hash21(tileID);
                float3 rnd3 = hash31(dot(tileID,float2(7,13)));

                // Random shape + palette
                int shapeIdx   = (int)floor(rnd.x * _ShapeCount);
                int paletteIdx = (int)floor(rnd.y * _PaletteCount);

                // Transform jitter
                float2 jitter = (rnd - 0.5) * _Jitter;
                float angle   = (rnd.x * 2.0 - 1.0) * _RotJitter;
                float scale   = lerp(_ScaleMin, _ScaleMax, rnd.y);

                float2 q = fp - 0.5 + jitter;
                q = rotate2D(q, angle);
                q /= scale;
                q += 0.5;

                float shape = sampleShapeN(shapeIdx, q, dir);

                if (shape <= 0.0)
                    return float4(0,0,0,1);

                // Palette color
                float u = rnd3.x;
                float3 col = samplePaletteN(paletteIdx, u);

                // Convert to HSV
                float maxc = max(col.r, max(col.g,col.b));
                float minc = min(col.r, min(col.g,col.b));
                float delta = maxc - minc;

                float3 hsv;
                if (delta < 1e-5) hsv.x = 0.0;
                else if (maxc == col.r) hsv.x = frac((col.g-col.b)/delta/6.0);
                else if (maxc == col.g) hsv.x = frac((col.b-col.r)/delta/6.0 + 1.0/3.0);
                else hsv.x = frac((col.r-col.g)/delta/6.0 + 2.0/3.0);

                hsv.y = (maxc < 1e-5) ? 0.0 : delta/maxc;
                hsv.z = maxc;

                // Jitter
                hsv.x = frac(hsv.x + (rnd3.x*2.0-1.0)*_HueJitter);
                hsv.y = saturate(hsv.y + (rnd3.y*2.0-1.0)*_SatJitter);
                hsv.z = saturate(hsv.z + (rnd3.z*2.0-1.0)*_ValJitter);

                float brightness = 1.0 + (rnd3.y*2.0-1.0)*_BrightnessJitter;

                float3 rgb = hsv2rgb(hsv) * brightness;

                float a = shape * _Opacity;

                return float4(rgb, a);
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float4 c = tileSamplerColor(i.localTexcoord, i.direction);

                // No background accumulation here — user blends externally
                return c;
            }

            ENDHLSL
        }
    }
}