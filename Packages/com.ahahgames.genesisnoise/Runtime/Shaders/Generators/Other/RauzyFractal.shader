Shader "Hidden/Genesis/RauzyFractal"
{
    Properties
    {
        _Iterations("Iterations", Range(100, 5000)) = 1200
        _Scale("Scale", Float) = 1.8
        _Brightness("Brightness", Float) = 1.0
        _Contrast("Contrast", Float) = 1.0

        _ColorOffset("Color Offset", Float) = 0.0
        _ColorFrequency("Color Frequency", Float) = 3.0

        [Enum(Classic,0,Pisano,1,Tribonacci,2,Custom)]_Mode("Rauzy Mode", Int) = 0

        _CustomA("Custom Matrix A", Vector) = (0.5, -0.3, 0.3, 0.5)
        _CustomT1("Custom T1", Vector) = (1.0, 0.0, 0, 0)
        _CustomT2("Custom T2", Vector) = (0.3, 0.8, 0, 0)
        _CustomT3("Custom T3", Vector) = (-0.6, 0.4, 0, 0)

        [Enum(Circle,0,Cross,1,Point,2)]_TrapType("Orbit Trap Type", Int) = 0
        _TrapRadius("Trap Radius", Float) = 0.25
        _TrapSoftness("Trap Softness", Float) = 4.0
        [GenesisColorProperty]_TrapColor("Trap Color", Color) = (1,0.5,0.1,1)
        _TrapIntensity("Trap Intensity", Float) = 1.0

        _Morph("IFS Morph Amount", Range(0,1)) = 0.0
        _TimeScale("Time Scale", Float) = 0.0
        _Time("Time",Range(0,256))=10
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

            float _Iterations;
            float _Scale;
            float _Brightness;
            float _Contrast;
            float _ColorOffset;
            float _ColorFrequency;

            int _Mode;
            float4 _CustomA;
            float4 _CustomT1;
            float4 _CustomT2;
            float4 _CustomT3;

            int _TrapType;
            float _TrapRadius;
            float _TrapSoftness;
            float4 _TrapColor;
            float _TrapIntensity;

            float _Morph;
            float _TimeScale;
            float _Time;

            // RNG
            float hash(float2 p)
            {
                return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
            }

            // Orbit traps
            float trapCircle(float2 z) { return abs(length(z) - _TrapRadius); }
            float trapCross(float2 z)  { return min(abs(z.x), abs(z.y)); }
            float trapPoint(float2 z)  { return length(z); }

            float orbitTrap(float2 z)
            {
                if (_TrapType < 0.5) return trapCircle(z);
                if (_TrapType < 1.5) return trapCross(z);
                return trapPoint(z);
            }

            // Rauzy matrices
            float2x2 A_classic = float2x2(0.5, -0.3, 0.3, 0.5);
            float2x2 A_pisano  = float2x2(0.618, -0.2, 0.2, 0.618);
            float2x2 A_trib    = float2x2(0.55, -0.25, 0.25, 0.55);

            float2x2 getMatrix()
            {
                if (_Mode < 0.5) return A_classic;
                if (_Mode < 1.5) return A_pisano;
                if (_Mode < 2.5) return A_trib;
                return float2x2(_CustomA.x, _CustomA.y, _CustomA.z, _CustomA.w);
            }

            float2 getT(int idx)
            {
                if (_Mode < 2.5)
                {
                    if (idx == 0) return float2(1.0, 0.0);
                    if (idx == 1) return float2(0.3, 0.8);
                    return float2(-0.6, 0.4);
                }
                if (idx == 0) return _CustomT1.xy;
                if (idx == 1) return _CustomT2.xy;
                return _CustomT3.xy;
            }

            float3 Rauzy(float2 p, float time)
            {
                float2 z = p * _Scale;

                float acc = 0.0;
                float trapMin = 1e20;

                float2x2 A = getMatrix();

                int maxIter = (int)_Iterations;

                for (int i = 0; i < 6000; i++)
                {
                    if (i >= maxIter) break;

                    float r = hash(z + i * 0.123 + time * 0.1);

                    int idx = (int)(r * 3.0);
                    float2 t = getT(idx);

                    // Morphing between identity and A
                    float2x2 M = lerp(float2x2(1,0,0,1), A, _Morph);

                    z = mul(M, z) + t;

                    // Density accumulation
                    acc += exp(-dot(z, z) * 0.8);

                    // Orbit trap
                    float d = orbitTrap(z);
                    trapMin = min(trapMin, d);
                }

                float v = acc / maxIter;

                // Base palette
                float3 baseCol =
                    0.5 + 0.5 * cos(_ColorOffset + v * _ColorFrequency + float3(0.0, 2.0, 4.0));

                baseCol = pow(saturate(baseCol * _Brightness), _Contrast);

                // Trap color
                float trapMask = exp(-trapMin * _TrapSoftness);
                float3 trapCol = _TrapColor.rgb * trapMask * _TrapIntensity;

                return baseCol + trapCol;
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;
                float2 p = uv * 2.0 - 1.0;
                p.x *= _ScreenParams.x / _ScreenParams.y;

                float time = _Time * _TimeScale;

                float3 col = Rauzy(p, time);
                return float4(col, 1.0);
            }

            ENDHLSL
        }
    }
}
