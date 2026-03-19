Shader "Hidden/Genesis/TriangleGrid"
{
    Properties
    {
        [GenesisVector2]_Scale("Grid Scale", Vector) = (8,8,0,0)

        _LineWidth("Line Width", Range(0.0005,0.1)) = 0.02
        _EdgeSoftness("Edge Softness", Range(0.5,20.0)) = 8.0

        _JitterAmount("Jitter Amount", Range(0,1)) = 0.15
        _JitterScale("Jitter Scale", Range(1,20)) = 6.0

        _Invert("Invert", Range(0,1)) = 0.0
        _Contrast("Contrast", Range(0.5,4.0)) = 1.4
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

            float2 _Scale;

            float _LineWidth;
            float _EdgeSoftness;

            float _JitterAmount;
            float _JitterScale;

            float _Invert;
            float _Contrast;

            // ---------------------------------------------------------
            // Hash + Noise
            // ---------------------------------------------------------
            float hash11(float n)
            {
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7));
                return frac(sin(float2(n, n + 1.234)) * 43758.5453);
            }

            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                float2 u = f * f * (3.0 - 2.0 * f);

                float a = hash11(i.x + i.y * 57.0);
                float b = hash11(i.x + 1.0 + i.y * 57.0);
                float c = hash11(i.x + (i.y + 1.0) * 57.0);
                float d = hash11(i.x + 1.0 + (i.y + 1.0) * 57.0);

                return lerp(lerp(a,b,u.x), lerp(c,d,u.x), u.y);
            }

            // ---------------------------------------------------------
            // Triangle grid distance
            // Based on projecting into a skewed (hex/tri) lattice.
            // ---------------------------------------------------------
            float triGridDistance(float2 uv)
            {
                // Equilateral triangle lattice basis
                const float2 e0 = float2(1.0, 0.0);
                const float2 e1 = float2(0.5, 0.8660254); // cos60, sin60

                // Transform into lattice space
                float2 p = uv * _Scale;

                // Build matrix inverse for [e0 e1]
                float2x2 M = float2x2(e0.x, e1.x,
                                      e0.y, e1.y);
                float det = M._11 * M._22 - M._12 * M._21;
                float2x2 Minv = float2x2( M._22, -M._12,
                                         -M._21,  M._11) / det;

                float2 q = mul(Minv, p);

                float2 iq = floor(q);
                float2 fq = frac(q);

                // Optional jitter per cell
                if (_JitterAmount > 0.0)
                {
                    float2 j = hash21(iq * _JitterScale);
                    fq += (j - 0.5) * _JitterAmount;
                    fq = frac(fq);
                }

                // Distance to triangle edges in barycentric-like space
                float d0 = fq.x;
                float d1 = fq.y;
                float d2 = 1.0 - fq.x - fq.y;

                float d = min(d0, min(d1, d2));
                d = abs(d);

                return d;
            }

            // ---------------------------------------------------------
            // Line mask from distance
            // ---------------------------------------------------------
            float triGridMask(float2 uv)
            {
                float d = triGridDistance(uv);

                float w = _LineWidth;
                float s = _EdgeSoftness;

                float edge = 1.0 - smoothstep(w, w + w / s, d);
                return edge;
            }

            // ---------------------------------------------------------
            // Genesis CRT entry
            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float g = triGridMask(uv);

                // Invert option (lines vs cells)
                g = lerp(g, 1.0 - g, _Invert);

                g = pow(saturate(g), _Contrast);

                return float4(g, g, g, 1.0);
            }

            ENDHLSL
        }
    }
}