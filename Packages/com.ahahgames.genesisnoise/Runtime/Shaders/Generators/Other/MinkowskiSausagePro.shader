Shader "Hidden/Genesis/MinkowskiSausagePro"
{
    Properties
    {
        _Iterations("Iterations", Range(100, 6000)) = 2000
        _Scale("Scale", Float) = 2.0
        _Brightness("Brightness", Float) = 1.0
        _Contrast("Contrast", Float) = 1.0

        _ColorOffset("Color Offset", Float) = 0.0
        _ColorFrequency("Color Frequency", Float) = 3.0

        _Morph("IFS Morph Amount", Range(0,1)) = 1.0
        _TimeScale("Time Scale", Float) = 0.0

        [Enum(Circle,0,Cross,1,Point,2)]_TrapType("Orbit Trap Type (0=Circle,1=Cross,2=Point)", Int) = 0
        _TrapRadius("Trap Radius", Float) = 0.25
        _TrapSoftness("Trap Softness", Float) = 4.0
        [GenesisColorProperty]_TrapColor("Trap Color", Color) = (1,0.5,0.1,1)
        _TrapIntensity("Trap Intensity", Float) = 1.0
        _Time("Time",Range(0,1024))=10
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

            float _Morph;
            float _TimeScale;

            int _TrapType;
            float _TrapRadius;
            float _TrapSoftness;
            float4 _TrapColor;
            float _TrapIntensity;
            float _Time;

            // RNG
            float hash(float2 p)
            {
                return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
            }

            // Rotation
            float2 rot(float2 p, float a)
            {
                float c = cos(a);
                float s = sin(a);
                return float2(c*p.x - s*p.y, s*p.x + c*p.y);
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

            // 6-map Minkowski IFS
            float2 minkowskiMap(float2 z, float r)
            {
                float2 base = z / 3.0;

                if (r < 1.0/6.0)
                    return base;

                if (r < 2.0/6.0)
                    return rot(base, radians(90.0)) + float2(1.0/3.0, 0.0);

                if (r < 3.0/6.0)
                    return rot(base, radians(-90.0)) + float2(1.0/3.0, 1.0/3.0);

                if (r < 4.0/6.0)
                    return base + float2(2.0/3.0, 0.0);

                if (r < 5.0/6.0)
                    return rot(base, radians(180.0)) + float2(2.0/3.0, 1.0/3.0);

                return rot(base, radians(45.0)) + float2(1.0/3.0, 2.0/3.0);
            }

            float3 Minkowski(float2 p, float time)
            {
                float2 z = p * _Scale;

                float acc = 0.0;
                float trapMin = 1e20;

                int maxIter = (int)_Iterations;

                for (int i = 0; i < 8000; i++)
                {
                    if (i >= maxIter) break;

                    float r = hash(z + i * 0.123 + time * 0.1);

                    // Normalize into [0,1]^2
                    z = frac(z);

                    // Apply IFS
                    float2 z0 = z;
                    float2 z1 = minkowskiMap(z, r);

                    // Morph between identity and full Minkowski
                    z = lerp(z0, z1, _Morph);

                    // Density accumulation
                    float d = abs(z.y - 0.5); // distance to curve centerline
                    acc += exp(-d * 40.0);

                    // Orbit trap
                    float t = orbitTrap(z);
                    trapMin = min(trapMin, t);
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

                float3 col = Minkowski(p, time);
                return float4(col, 1.0);
            }

            ENDHLSL
        }
    }
}