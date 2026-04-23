Shader "Hidden/Genesis/ShapeSplatterCircular"
{
    Properties
    {
        _Shape_2D("Shape 2D", 2D) = "white" {}
        _Shape_3D("Shape 3D", 3D) = "white" {}
        _Shape_Cube("Shape Cube", Cube) = "white" {}

        [Enum(Disabled,0,Enabled,1)] _UseShape("Use Shape", int) = 1

        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (1,1,0,0)

        [Tooltip(Number of shapes around circle)] _Count("Count", Range(1,128)) = 32

        [Tooltip(Base radius of circle)] _Radius("Radius", Range(0.0,1.0)) = 0.35
        [Tooltip(Random radial jitter)] _RadialJitter("Radial Jitter", Range(0,1)) = 0.15
        [Tooltip(Random angular jitter)] _AngularJitter("Angular Jitter", Range(0,1)) = 0.15

        [Tooltip(Random rotation per instance)] _RotJitter("Rotation Jitter", Range(0,6.283)) = 3.14
        [Tooltip(Min scale)] _ScaleMin("Scale Min", Range(0.01,2)) = 0.5
        [Tooltip(Max scale)] _ScaleMax("Scale Max", Range(0.01,2)) = 1.2

        [Tooltip(Blend softness)] _BlendSoftness("Blend Softness", Range(0,1)) = 0.2
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.0

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
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            // Use Genesis' dimension-aware sampler naming:
            // SAMPLE_X(_Shape, ...) maps to _Shape_2D/_Shape_3D/_Shape_Cube automatically.
            SAMPLER_X(_Shape);

            float2 _Scale;
            float  _Count;
            float  _Radius;
            float  _RadialJitter;
            float  _AngularJitter;
            float  _RotJitter;
            float  _ScaleMin;
            float  _ScaleMax;
            float  _BlendSoftness;
            float  _Contrast;
            float  _Seed;
            int    _UseShape;

            // ---------------------------------------------------------
            float hash11(float n)
            {
                // keep seed influence stable
                n += _Seed * 17.0;
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7)) + _Seed * 13.37;
                return frac(sin(float2(n, n + 1.234)) * 43758.5453);
            }

            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a), c = cos(a);
                return float2(c*p.x - s*p.y, s*p.x + c*p.y);
            }

            // Sample the selected shape texture (returns red/alpha)
            float sampleShapeTex(float3 sampUV, float3 dir)
            {
                return SAMPLE_X(_Shape, sampUV, dir).r;
            }

            float sampleShape(float3 uv, float2 center, float angle, float scale, float3 dir)
            {
                // Transform uv into local splat space
                float2 p = uv.xy - center;
                p = rotate2D(p, angle);
                // avoid zero scale
                scale = max(scale, 1e-5);
                p /= scale;
                // map -0.5..0.5 -> 0..1 (assumes shape texture is centered)
                float2 texUV = p + 0.5;
                // Outside the shape rect should contribute nothing (don't clamp; that creates "blobby spheres")
                float inBounds = step(0.0, texUV.x) * step(0.0, texUV.y) * step(texUV.x, 1.0) * step(texUV.y, 1.0);
                return sampleShapeTex(float3(saturate(texUV), uv.z), dir) * inBounds;
            }

            // Smooth max (soft union) - returns smooth union of a and b with softness k
            float smoothMax(float a, float b, float k)
            {
                // k must be > 0 for smoothing; if k is tiny, fallback to hard max
                k = max(k, 1e-5);
                float h = saturate(0.5 + 0.5 * (b - a) / k);
                // lerp between b and a based on h, then add a small blending term for smoothness
                return lerp(b, a, h) + k * h * (1.0 - h);
            }

            // ---------------------------------------------------------
            float shapeSplatterCircular(float3 uv, float3 dir)
            {
                if (_UseShape == 0)
                    return 0.0;

                // Ensure sensible values
                float2 scaleUV = max(_Scale, float2(1e-6, 1e-6));
                float countF = max(_Count, 1.0);
                int count = (int)min(128.0, countF);

                // Transform UV into local space (centered)
                float2 p = (uv.xy - 0.5) * scaleUV;

                float outV = 0.0;

                // Substance-style: hard max by default; optional soft-union if BlendSoftness > 0
                float blendK = _BlendSoftness;

                [loop]
                for (int i = 0; i < count; ++i)
                {
                    float fi = (float)i;

                    // Random jitter per instance
                    float2 rnd = hash21(float2(fi, fi * 17.0));

                    // Random-but-evenly-distributed angle around the circle:
                    // (fi + rnd.x) stratifies the random so instances don't clump.
                    float angle = ((fi + rnd.x) / countF) * 6.28318530718;

                    // Radial jitter (in the same scaled space as `p`)
                    float radius = _Radius + (rnd.y * 2.0 - 1.0) * _RadialJitter;
                    radius = max(radius, 0.0);

                    // Position on circle (centered) in scaled UV space
                    float2 center = float2(cos(angle), sin(angle)) * (radius * scaleUV);

                    // Random rotation for the splat
                    float rot = (hash11(fi * 1.37) * 2.0 - 1.0) * _RotJitter;

                    // Random scale between min and max
                    float sRnd = hash11(fi * 2.71);
                    float scale = lerp(_ScaleMin, _ScaleMax, sRnd);

                    // Sample shape texture at this instance
                    float v = sampleShape(float3(p, uv.z), center, rot, scale, dir);

                    // Combine copies (Substance "Splatter Shape Grayscale" style)
                    if (blendK <= 0.0)
                        outV = max(outV, v);
                    else
                        outV = smoothMax(outV, v, max(blendK, 1e-5));
                }

                // Contrast shaping
                float result = pow(saturate(outV), max(_Contrast, 0.0001));

                return result;
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv  = GetDefaultUVs(i);
                float3 dir = i.direction;

                float v = shapeSplatterCircular(uv, dir);

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
