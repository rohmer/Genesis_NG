Shader "Hidden/Genesis/GradientLinear"
{
    Properties
    {
        [Tooltip(Gradient mode selector)]
        [GenesisGradientType]_Mode("Mode", Int) = 0
         
        [Tooltip(Angle for directional gradients)]
        _Angle("Angle", Float) = 0.0

        [Tooltip(Global scale)]
        _Scale("Scale", Float) = 1.0

        [Tooltip(Offset for gradient center)]
        _Offset("Offset", Vector) = (0.0, 0.0, 0, 0)

        [Tooltip(Softness contrast shaping)]
        _Softness("Softness", Float) = 0.0

        [Tooltip(Bands count for banded mode)]
        [VisibleIf(_Mode,11)]_Bands("Bands", Float) = 8.0

        [Tooltip(Noise modulation strength)]
        [VisibleIf(_Mode,12)]_NoiseStrength("Noise Strength", Float) = 0.0

        [Tooltip(Noise scale)]
        [VisibleIf(_Mode,12)]_NoiseScale("Noise Scale", Float) = 4.0

        [Tooltip(Bezier control point)]
        [VisibleIf(_Mode,9)]_Bezier("Bezier Control", Float) = 0.5

        [Tooltip(Multistop positions (0 to 1))]
        [VisibleIf(_Mode,10)]_StopsPos("Stops Pos", Vector) = (0.0, 0.33, 0.66, 1.0)

        [Tooltip(Multistop values (0 to 1))] 
        [VisibleIf(_Mode,10)]_StopsVal("Stops Val", Vector) = (0.0, 0.5, 1.0, 1.0)

        [Tooltip(Number of stops)]
        [VisibleIf(_Mode,10)]_StopCount("Stop Count", Int) = 4
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

            int _Mode;
            float _Angle;
            float _Scale;
            float2 _Offset;
            float _Softness;
            float _Bands;
            float _NoiseStrength;
            float _NoiseScale;
            float _Bezier;
            float4 _StopsPos;
            float4 _StopsVal;
            int _StopCount;

            // ---------------------------------------------------------
            // Helpers
            // ---------------------------------------------------------
            float2 rotate(float2 p, float a)
            {
                float s = sin(a);
                float c = cos(a);
                return float2(p.x*c - p.y*s, p.x*s + p.y*c);
            }

            float applySoftness(float g, float softness)
            {
                if (softness <= 0.0) return g;
                float s = saturate(softness);
                return pow(g, lerp(1.0, 0.25, s));
            }

            // ---------------------------------------------------------
            // Noise (for modulation)
            // ---------------------------------------------------------
            float hash(float2 p)
            {
                p = frac(p * 0.3183099 + 0.1234);
                p *= 17.0;
                return frac(p.x * p.y * (p.x + p.y));
            }

            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                float a = hash(i);
                float b = hash(i + float2(1,0));
                float c = hash(i + float2(0,1));
                float d = hash(i + float2(1,1));

                float2 u = f*f*(3.0 - 2.0*f);

                return lerp(lerp(a,b,u.x), lerp(c,d,u.x), u.y);
            }

            // ---------------------------------------------------------
            // Gradient Modes
            // ---------------------------------------------------------

            float linear1(float x) { return saturate(x); }

            float linear2(float x)
            {
                return 1.0 - abs(frac(x) * 2.0 - 1.0);
            }

            float linear3(float x)
            {
                return 0.5 - 0.5 * cos(6.2831853 * x);
            }

            float radial(float2 p)
            {
                return saturate(length(p));
            }

            float circular(float2 p)
            {
                return saturate(1.0 - length(p));
            }

            float angular(float2 p)
            {
                float a = atan2(p.y, p.x);
                return frac((a / 6.2831853) + 0.5);
            }

            float diamond(float2 p)
            {
                return saturate((abs(p.x) + abs(p.y)));
            }

            float bilinear(float2 p)
            {
                return saturate((p.x + 0.5) * (p.y + 0.5));
            }

            float quad(float2 p)
            {
                return saturate(1.0 - dot(p,p));
            }

            float bezier(float x, float c)
            {
                float u = 1.0 - x;
                return u*u*0.0 + 2.0*u*x*c + x*x*1.0;
            }

            float multiStop(float x)
            {
                float v = 0.0;
                for (int i = 0; i < _StopCount - 1; i++)
                {
                    float a = _StopsPos[i];
                    float b = _StopsPos[i+1];
                    if (x >= a && x <= b)
                    {
                        float t = saturate((x - a) / (b - a));
                        v = lerp(_StopsVal[i], _StopsVal[i+1], t);
                        break;
                    }
                }
                return v;
            }

            float bands(float x, float count)
            {
                return frac(x * count) < 0.5 ? 0.0 : 1.0;
            }

            float noiseMod(float g, float2 uv)
            {
                float n = noise(uv * _NoiseScale);
                return saturate(g + (n - 0.5) * _NoiseStrength);
            }

            // ---------------------------------------------------------
            // Main
            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i)
            {
                float3 uv = i.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float2 p = uv.xy - 0.5;
                p -= _Offset;
                p = rotate(p, radians(_Angle));

                float x = p.x * _Scale + 0.5;
                x = frac(x);

                float g = 0.0;

                if (_Mode == 0) g = linear1(x);
                else if (_Mode == 1) g = linear2(x);
                else if (_Mode == 2) g = linear3(x);
                else if (_Mode == 3) g = radial(p);
                else if (_Mode == 4) g = circular(p);
                else if (_Mode == 5) g = angular(p);
                else if (_Mode == 6) g = diamond(p);
                else if (_Mode == 7) g = bilinear(p);
                else if (_Mode == 8) g = quad(p);
                else if (_Mode == 9) g = bezier(x, _Bezier);
                else if (_Mode == 10) g = multiStop(x);
                else if (_Mode == 11) g = bands(x, _Bands);
                else if (_Mode == 12) g = noiseMod(linear1(x), uv.xy);

                g = applySoftness(g, _Softness);

                return float4(g, g, g, 1.0);
            }

            ENDHLSL
        }
    }
}
