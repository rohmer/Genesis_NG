Shader "Hidden/Genesis/TriangleGrid"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (8,8,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Random flip per cell)] _FlipProb("Flip Probability", Range(0,1)) = 0.5
        [Tooltip(Random invert per cell)] _InvertProb("Invert Probability", Range(0,1)) = 0.5
        [Tooltip(Random rotation per cell)] _RotJitter("Rotation Jitter", Range(0,6.283)) = 0.0

        [Tooltip(Edge softness)] _Softness("Softness", Range(0.0,1.0)) = 0.05
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.0

        [Tooltip(Random seed)] _Seed("Seed", int) = 52
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

            float2 _Scale;
            float  _Angle;

            float  _FlipProb;
            float  _InvertProb;
            float  _RotJitter;

            float  _Softness;
            float  _Contrast;

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

            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a), c = cos(a);
                return float2(c*p.x - s*p.y, s*p.x + c*p.y);
            }

            // ---------------------------------------------------------
            float3 triCoords(float2 p)
            {
                const float2 e0 = float2(1.0, 0.0);
                const float2 e1 = float2(0.5, 0.8660254);

                float2 uv = float2(dot(p, e0), dot(p, e1));

                float2 f = frac(uv);
                float2 i = floor(uv);

                float3 b = float3(f.x, f.y, 1.0 - f.x - f.y);

                if (b.z < 0.0)
                    b = float3(1.0 - f.x, 1.0 - f.y, f.x + f.y - 1.0);

                return b;
            }

            // ---------------------------------------------------------
            float triangleGridRandom(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;

                // Base rotation
                p = rotate2D(p, _Angle);

                // Determine cell ID for randomness
                float2 cell = floor(p);

                float2 rnd = hash21(cell);

                // Random rotation
                float angle = (rnd.x * 2.0 - 1.0) * _RotJitter;
                p = rotate2D(p, angle);

                // Random flip
                bool flip = rnd.x < _FlipProb;
                if (flip)
                    p.x = -p.x;

                // Compute triangle barycentric coords
                float3 b = triCoords(p);

                float d = min(b.x, min(b.y, b.z));
                float v = smoothstep(_Softness, 0.0, d);

                // Random invert
                bool inv = rnd.y < _InvertProb;
                if (inv)
                    v = 1.0 - v;

                return pow(v, _Contrast);
            }

            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float v = triangleGridRandom(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}