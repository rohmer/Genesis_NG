Shader "Hidden/Genesis/Tiling"
{
    Properties
    {
        [Tooltip(Tile count X,Y)]
        _TileCount("Tile Count", Vector) = (4,4,0,0)

        [Tooltip(Global scale of tiles)]
        _TileScale("Tile Scale", Float) = 1.0

        [Tooltip(Padding between tiles)]
        _Padding("Padding", Float) = 0.05

        [Tooltip(Global rotation)]
        _Rotation("Rotation", Float) = 0.0

        [Tooltip(Random rotation per tile)]
        _RandRot("Random Rotation", Float) = 0.0 

        [Tooltip(Random scale per tile)]
        _RandScale("Random Scale", Float) = 0.0

        [Tooltip(Random position jitter)]
        _RandOffset("Random Offset", Float) = 0.0

        [Tooltip(Shape type]
        [Enum(Rect,0,Ellipse,1,Polygon,2)]_ShapeType("Shape Type", Int) = 0

        [Tooltip(Polygon sides)]
        [VisibleIf(_ShapeType,2)]_Sides("Sides", Int) = 6

        [Tooltip(Random seed)]
        _Seed("Seed", Float) = 1.0

        [Tooltip(Optional mask)]
        _Mask("Mask", 2D) = "white" {} 

        [Tooltip(Mask strength)]
        _MaskStrength("Mask Strength", Float) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            float2 _TileCount;
            float _TileScale;
            float _Padding;
            float _Rotation;
            float _RandRot;
            float _RandScale;
            float _RandOffset;
            int _ShapeType;
            int _Sides;
            float _Seed;

            sampler2D _Mask;
            float _MaskStrength;

            // ---------------------------------------------------------
            // Hash
            // ---------------------------------------------------------
            float hash(float2 p)
            {
                p = frac(p * 0.3183099 + _Seed * 0.1234);
                p *= 17.0;
                return frac(p.x * p.y * (p.x + p.y));
            }

            float2 hash2(float2 p)
            {
                return float2(hash(p), hash(p + 13.37));
            }

            // ---------------------------------------------------------
            // Rotation
            // ---------------------------------------------------------
            float2 rotate(float2 p, float a)
            {
                float s = sin(a);
                float c = cos(a);
                return float2(p.x*c - p.y*s, p.x*s + p.y*c);
            }

            // ---------------------------------------------------------
            // Shapes (SDF)
            // ---------------------------------------------------------
            float sdRect(float2 p)
            {
                float2 d = abs(p) - 0.5;
                return max(d.x, d.y);
            }

            float sdEllipse(float2 p)
            {
                return (length(p / float2(0.5,0.5)) - 1.0);
            }

            float sdPolygon(float2 p, int n)
            {
                float a = atan2(p.y, p.x);
                float r = length(p);
                float sector = 6.2831853 / n;
                float d = cos(floor(0.5 + a / sector) * sector - a) * r;
                return d - 0.5;
            }

            float shape(float2 p)
            {
                if (_ShapeType == 0) return sdRect(p);
                if (_ShapeType == 1) return sdEllipse(p);
                return sdPolygon(p, _Sides);
            }

            // ---------------------------------------------------------
            // Tile Generator
            // ---------------------------------------------------------
            float tileValue(float2 uv)
            {
                float2 grid = uv * _TileCount;

                float2 cell = floor(grid);
                float2 local = frac(grid) - 0.5;

                // Random per-tile
                float2 rnd = hash2(cell);
                float rRot = (rnd.x - 0.5) * _RandRot * 6.2831853;
                float rScale = 1.0 + (rnd.y - 0.5) * _RandScale;
                float2 rOff = (rnd - 0.5) * _RandOffset;

                // Apply jitter
                local += rOff;

                // Apply global + random rotation
                local = rotate(local, radians(_Rotation) + rRot);

                // Apply scale
                local /= (_TileScale * rScale);

                // Padding
                local /= (1.0 + _Padding);

                // Evaluate shape
                float d = shape(local);

                return saturate(1.0 - smoothstep(0.0, 0.01, d));
            }

            // ---------------------------------------------------------
            // Final CRT fragment
            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture IN) : SV_Target
            {
                float3 uv = IN.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float2 baseUV = uv.xy;

                float t = tileValue(baseUV);

                // Mask
                float m = tex2D(_Mask, baseUV).r;
                t *= lerp(1.0, m, _MaskStrength);

                return float4(t, t, t, 1.0);
            }

            ENDHLSL
        }
    }
}
