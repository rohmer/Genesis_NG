Shader "Hidden/Genesis/WarpNoise"
{	
    Properties
    {
        [Tooltip(Use source as color input or generate from selected colors)]
        [Enum(Input,0,Generated,1)] _colorSource("Color Source",int) = 0

        [VisibleIf(_colorSource,0)]
        [InlineTexture]_Source_2D("Input", 2D) = "white" {}
        [VisibleIf(_colorSource,0)]
        [InlineTexture]_Source_3D("Input", 3D) = "white" {}
        [VisibleIf(_colorSource,0)]
        [InlineTexture]_Source_Cube("Input", Cube) = "white" {}

        [VisibleIf(_colorSource,1)]
        [Tooltip(Starting point for color curve)][GenesisColor]_colorCurve1("Color Start",Color) = (0.25,0.0,0.25,1)
        [VisibleIf(_colorSource,1)]
        [Tooltip(Ending point for color curve)][GenesisColor]_colorCurve2("Color End",Color) = (1,0.0,1,1)

        _WarpAmount     ("Warp Amount", Range(0,1)) = 0.2
        _WarpFreq       ("Warp Frequency", Float)   = 8.0
        _WarpSpeed      ("Warp Speed", Float)       = 1.0 
        _NoiseStrength  ("Noise Strength", Range(0,1)) = 0.35
        _NoiseScale     ("Noise Scale", Float)      = 2.0
        _BarrelK        ("Barrel/Pincushion K", Float) = 0.12   // >0 barrel, <0 pincushion
        _ChromaticShift ("Chromatic Shift", Range(0,2)) = 0.35
        _Center         ("Warp Center (XY)", Vector) = (0.5, 0.5, 0, 0)

        [Tooltip(Seed driving time phase of the warp)]
        _Seed("Seed", Float) = 1.0
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
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            // Textures
            TEXTURE_SAMPLER_X(_Source);

            // Properties
            float  _WarpAmount;
            float  _WarpFreq;
            float  _WarpSpeed;
            float  _NoiseStrength;
            float  _NoiseScale;
            float  _BarrelK;
            float  _ChromaticShift;
            float4 _Center;          // xy used
            float  _Seed;
            int    _colorSource;
            float4 _colorCurve1;
            float4 _colorCurve2;

            // --------------------------------------------
            // Cheap noise + fbm
            float noise_sin(float2 p)
            {
                // Extremely cheap, tileable-ish for stylized warp
                return sin(p.x) * sin(p.y);
            }

            float fbm2(float2 p)
            {
                // 4-octave cheap fbm using sin-noise
                float f = 0.0;
                float a = 0.5;
                float2x2 m = float2x2(0.80, 0.60, -0.60, 0.80);

                [unroll]
                for (int i = 0; i < 4; i++)
                {
                    f += a * noise_sin(p);
                    p = mul(m, p) * 2.02;
                    a *= 0.5;
                }

                return f * (1.0 / 0.9375);
            }

            // Barrel/Pincushion distortion in UV space
            float2 BarrelDistort(float2 uv, float k, float2 center)
            {
                float2 d = uv - center;
                float  r2 = dot(d, d);
                float  factor = 1.0 + k * r2; // positive k = barrel, negative = pincushion
                return center + d * factor;
            }

            // Core warp function
            float2 WarpUV(float2 uv, float time)
            {
                // Base directional sine warp
                float s =
                    sin((uv.xyx * float3(1, 1, 0)).x * _WarpFreq + time) *
                    cos((uv.yyx * float3(1, 1, 0)).y * (_WarpFreq * 0.9) - time * 0.7);

                float2 dir      = float2(0.7, 0.3);
                float2 sineWarp = normalize(dir) * s;

                // FBM turbulence
                float2 nCoord   = uv * _NoiseScale + time * 0.25;
                float  n1       = fbm2(nCoord);
                float  n2       = fbm2(nCoord.yx + 7.31);
                float2 fbmWarp  = float2(n1, n2) * (2.0 * _NoiseStrength); // [-something, +something]

                float2 total = uv + _WarpAmount * (sineWarp + fbmWarp);
                return total;
            }

            float4 GetColor(float2 uv, float3 dir)
            {
                return SAMPLE_X(_Source, float3(uv, 0), dir);
            }

            // Chromatic aberration sample helper
            float3 SampleChromatic(float2 uv, float2 center, float shift, float3 direction)
            {
                float2 dir = normalize((uv - center) + 1e-5);

                float2 uvR = uv + dir * (shift * 0.5);
                float2 uvG = uv;
                float2 uvB = uv - dir * (shift * 0.5);

                if (_colorSource == 0) // Modifier: sample input texture
                {
                    float r = GetColor(uvR, direction).r;
                    float g = GetColor(uvG, direction).g;
                    float b = GetColor(uvB, direction).b;
                    return float3(r, g, b);
                }

                // Generator: use warped sampling as driver for color curve
                float r2 = GetColor(uvR, direction).r;
                float g2 = GetColor(uvG, direction).g;
                float b2 = GetColor(uvB, direction).b;

                float sVal = (r2 + g2 + b2) / 3.0;
                float3 c   = lerp(_colorCurve1.rgb, _colorCurve2.rgb, sVal);

                return c;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                // Time driven by seed and warp speed
                float t = _Seed * _WarpSpeed;

                // Nonlinear radial warp (set _BarrelK = 0 to disable)
                float2 uvBarrel = BarrelDistort(uv, _BarrelK, _Center.xy);

                // Procedural UV warp
                float2 uvWarped = WarpUV(uvBarrel, t);

                // Clamp to avoid sampling outside
                uvWarped = clamp(uvWarped, 0.0, 1.0);

                // Chromatic aberration
                float3 col = SampleChromatic(uvWarped, _Center.xy, _ChromaticShift / 100.0, i.direction);

                // Subtle contrast curve
                col = saturate(col);
                col = pow(col, 1.0 / 1.05);

                return float4(col, 1.0);
            }

            ENDHLSL
        }
    }
}