Shader "Hidden/Genesis/Kaleidoscope"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        _Source("Source Texture", 2D) = "white" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
        [ShowInInspector][Enum(2D,0,3D,1)] _UVMode("UV Mode", Float) = 0

        _Segments("Segments", Range(1,32)) = 6
        _Rotation("Rotation", Range(0,6.283)) = 0
        _Center("Center Offset", Vector) = (0.5,0.5,0,0)

        _FractalZoom("Fractal Zoom Strength", Range(0,2)) = 0.8
        _FractalSpeed("Fractal Zoom Speed", Float) = 0.4
        _FractalWarp("Fractal Warp", Range(0,1)) = 0.3

        _Swirl("Swirl Amount", Range(0,1)) = 0.2
        _Scale("Scale", Float) = 1.0
        _Time("Time", Float) = 0
        _Seed("Seed", Int) = 42
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV
            #pragma shader_feature _TILINGMODE_NONE _TILINGMODE_TILED

            TEXTURE_SAMPLER_X(_UV);
            TEXTURE2D(_Source);
            SAMPLER(sampler_Source);

            int _Segments;
            float _Rotation;
            float2 _Center;
            float _FractalZoom;
            float _FractalSpeed;
            float _FractalWarp;
            float _Swirl;
            float _Scale;
            float _Time;
            int _Seed;
            int _UVMode;

            float2 ApplyTiling(float2 uv, float period)
            {
#ifdef _TILINGMODE_TILED
                return frac(uv * period);
#else
                return uv;
#endif
            }

            float2x2 rot2(float a)
            {
                float c = cos(a);
                float s = sin(a);
                return float2x2(c, -s, s, c);
            }

            // ------------------------------------------------------------
            // Kaleidoscope folding
            // ------------------------------------------------------------
            float2 Kaleido(float2 uv, float2 center, int seg, float rot, float swirl)
            {
                float2 p = uv - center;

                float r = length(p);
                float a = atan2(p.y, p.x);

                a += rot;

                float segAngle = 6.2831853 / max(1, seg);
                a = fmod(a, segAngle);
                a = abs(a - segAngle * 0.5);

                a += sin(r * 6.0) * swirl;

                return float2(cos(a), sin(a)) * r + center;
            }

            // ------------------------------------------------------------
            // Fractal zoom warp (Mandelbrot‑style radial zoom)
            // ------------------------------------------------------------
            float2 FractalZoom(float2 uv, float2 center, float zoomStrength, float speed, float warp, float time)
            {
                float2 p = uv - center;

                float r = length(p);
                float a = atan2(p.y, p.x);

                float zoom = exp(time * speed * zoomStrength);

                r *= zoom;

                r += sin(a * 3.0 + time * 0.7) * warp * 0.1;
                a += sin(r * 2.0 + time * 0.4) * warp * 0.2;

                return float2(cos(a), sin(a)) * r + center;
            }

            // ------------------------------------------------------------
            // Fragment
            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uvs = GetNoiseUVs(
                    i,
                    SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction),
                    _Seed
                );

                float2 uv = ApplyTiling(uvs.xy, _Scale);

                // 1. Fractal zoom warp
                uv = FractalZoom(uv, _Center, _FractalZoom, _FractalSpeed, _FractalWarp, _Time);

                // 2. Kaleidoscope fold
                uv = Kaleido(uv, _Center, _Segments, _Rotation, _Swirl);

                // 3. Sample source
                float4 col = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv);

                return col;
            }

            ENDHLSL
        }
    }
}
