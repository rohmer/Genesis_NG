Shader "Hidden/Genesis/Shape"
{
    Properties
    {
        [Tooltip(Shape type)]
        [GenesisShapeType]_ShapeType("Shape Type", Int) = 0

        [Tooltip(Number of sides for polygon or star)]
        _Sides("Sides", Int) = 6

        [Tooltip(Star inner radius multiplier)]
        [VisibleIf(_ShapeType,4)]_StarInner("Star Inner", Float) = 0.5

        [Tooltip(Superellipse exponent)]
        [VisibleIf(_ShapeType,7)]_SuperExp("Superellipse Exponent", Float) = 4.0

        [Tooltip(Shape scale)]
        _Scale("Scale", Vector) = (0.5, 0.5, 0, 0)

        [Tooltip(Shape offset)]
        _Offset("Offset", Vector) = (0.5, 0.5, 0, 0)

        [Tooltip(Rotation in degrees)]
        _Rotation("Rotation", Float) = 0

        [Tooltip(Softness (edge falloff))]
        _Softness("Softness", Float) = 0.01 

        [Tooltip(Rounded corner radius)]
        _Radius("Radius", Float) = 0.1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            int _ShapeType;
            int _Sides;
            float _StarInner;
            float _SuperExp;
            float2 _Scale;
            float2 _Offset;
            float _Rotation;
            float _Softness;
            float _Radius;

            float2 rotate(float2 p, float a)
            {
                float s = sin(a);
                float c = cos(a);
                return float2(p.x*c - p.y*s, p.x*s + p.y*c);
            }

            float sdRect(float2 p, float2 b)
            {
                float2 d = abs(p) - b;
                return max(d.x, d.y);
            }

            float sdEllipse(float2 p, float2 r)
            {
                return (length(p / r) - 1.0) * min(r.x, r.y);
            }

            float sdPolygon(float2 p, int n)
            {
                float a = atan2(p.y, p.x);
                float r = length(p);
                float sector = 6.2831853 / n;
                float d = cos(floor(0.5 + a / sector) * sector - a) * r;
                return d - 0.5;
            }

            float sdRoundedRect(float2 p, float2 b, float r)
            {
                float2 q = abs(p) - b + r;
                return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
            }

            float sdStar(float2 p, int n, float inner)
            {
                float a = atan2(p.y, p.x);
                float r = length(p);

                float sector = 3.14159265 / n;
                float k = floor(a / sector);
                float even = fmod(k, 2.0);

                float target = (even < 0.5) ? 1.0 : inner;
                float angle = k * sector;

                float2 dir = float2(cos(angle), sin(angle));
                float d = dot(p, dir) / target;

                return d - 0.5;
            }

            float sdCapsule(float2 p, float2 a, float2 b, float r)
            {
                float2 pa = p - a;
                float2 ba = b - a;
                float h = saturate(dot(pa, ba) / dot(ba, ba));
                return length(pa - ba * h) - r;
            }

            float sdParaboloid(float2 p)
            {
                float d = p.x*p.x + p.y*p.y;
                return d - 0.5;
            }

            float sdSuperellipse(float2 p, float2 r, float n)
            {
                float2 q = abs(p / r);
                return pow(pow(q.x, n) + pow(q.y, n), 1.0/n) - 1.0;
            }

            float sdHeart(float2 p)
            {
                p.y += 0.25;
                float a = atan2(p.x, p.y) / 3.14159265;
                float r = length(p);
                float h = r - (0.3 + 0.7 * pow(abs(a), 0.5));
                return h;
            }

            float sdDiamond(float2 p)
            {
                return (abs(p.x) + abs(p.y)) - 0.5;
            }

            float sdTeardrop(float2 p)
            {
                p.y -= 0.25;
                float r = length(p);
                float angle = atan2(p.y, p.x);
                float shape = 0.5 + 0.3 * sin(angle);
                return r - shape;
            }

            float softMask(float d, float softness)
            {
                return saturate(1.0 - smoothstep(0.0, softness, d));
            }

            float4 genesis(v2f_customrendertexture i)
            {
                float3 uv = i.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float2 p = (uv.xy - _Offset) / _Scale;
                p = rotate(p, radians(_Rotation));

                float d = 0.0;

                if (_ShapeType == 0) d = sdRect(p, float2(0.5, 0.5));
                else if (_ShapeType == 1) d = sdEllipse(p, float2(0.5, 0.5));
                else if (_ShapeType == 2) d = sdPolygon(p, _Sides);
                else if (_ShapeType == 3) d = sdRoundedRect(p, float2(0.5, 0.5), _Radius);
                else if (_ShapeType == 4) d = sdStar(p, _Sides, _StarInner);
                else if (_ShapeType == 5) d = sdCapsule(p, float2(-0.3,0), float2(0.3,0), 0.2);
                else if (_ShapeType == 6) d = sdParaboloid(p);
                else if (_ShapeType == 7) d = sdSuperellipse(p, float2(0.5,0.5), _SuperExp);
                else if (_ShapeType == 8) d = sdHeart(p);
                else if (_ShapeType == 9) d = sdDiamond(p);
                else if (_ShapeType == 10) d = sdTeardrop(p);

                float m = softMask(d, _Softness);

                return float4(m, m, m, 1.0);
            }

            ENDHLSL
        }
    }
}
