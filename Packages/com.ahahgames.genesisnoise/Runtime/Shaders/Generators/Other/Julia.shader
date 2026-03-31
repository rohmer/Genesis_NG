Shader "Hidden/Genesis/Julia"
{
    Properties
    {
        _Center("Center", Vector) = (0.0, 0.0, 0, 0)
        _Scale("Scale", Float) = 2.5
        _Iterations("Iterations", Range(16, 1024)) = 256

        _JuliaC("Julia Constant (c)", Vector) = (-0.8, 0.156, 0, 0)

        _ColorOffset("Color Offset", Float) = 0.0
        _ColorFrequency("Color Frequency", Float) = 0.15
        _Brightness("Brightness", Float) = 1.0
        _Contrast("Contrast", Float) = 1.0

        _TrapType("Orbit Trap Type (0=Circle,1=Cross,2=Point)", Range(0,2)) = 0
        _TrapRadius("Trap Radius", Float) = 0.25
        _TrapSoftness("Trap Softness", Float) = 4.0
        [GenesisColorProperty]_TrapColor("Trap Color", Color) = (1,0.5,0.1,1)
        _TrapIntensity("Trap Intensity", Float) = 1.0
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

            float4 _Center;
            float _Scale;
            float _Iterations;

            float4 _JuliaC;

            float _ColorOffset;
            float _ColorFrequency;
            float _Brightness;
            float _Contrast;

            float _TrapType;
            float _TrapRadius;
            float _TrapSoftness;
            float4 _TrapColor;
            float _TrapIntensity;

            // Orbit trap distance functions
            float trapCircle(float2 z)
            {
                return abs(length(z) - _TrapRadius);
            }

            float trapCross(float2 z)
            {
                float d1 = abs(z.x);
                float d2 = abs(z.y);
                return min(d1, d2);
            }

            float trapPoint(float2 z)
            {
                return length(z);
            }

            float orbitTrap(float2 z)
            {
                if (_TrapType < 0.5) return trapCircle(z);
                if (_TrapType < 1.5) return trapCross(z);
                return trapPoint(z);
            }

            float3 JuliaColor(float2 p)
            {
                float2 z = _Center.xy + p * _Scale;
                float2 c = _JuliaC.xy;

                const float B = 10.0;
                int maxIter = (int)_Iterations;
                int i = 0;

                float trapMin = 1e20;

                for (int j = 0; j < 2048; j++)
                {
                    if (j >= maxIter) break;

                    float re2 = z.x * z.x;
                    float im2 = z.y * z.y;
                    float reim = z.x * z.y;

                    if (re2 + im2 > B * B)
                    {
                        i = j;
                        break;
                    }

                    z = float2(re2 - im2, 2.0 * reim) + c;

                    // Orbit trap distance
                    float d = orbitTrap(z);
                    trapMin = min(trapMin, d);

                    i = j;
                }

                float it = (float)i;
                float maxIt = (float)maxIter;

                // Smooth iteration count
                float mag2 = dot(z, z);
                float smooth = it - log2(log2(mag2)) + 4.0;

                // Base palette
                float3 baseCol =
                    0.5 + 0.5 * cos(_ColorOffset + smooth * _ColorFrequency + float3(0.0, 2.0, 4.0));

                baseCol = pow(saturate(baseCol * _Brightness), _Contrast);

                // Orbit trap contribution
                float trapMask = exp(-trapMin * _TrapSoftness);
                float3 trapCol = _TrapColor.rgb * trapMask * _TrapIntensity;

                float3 col = baseCol + trapCol;

                // Inside set → dark
                float inside = step(B * B, mag2);
                col *= inside;

                return col;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                float2 p = (uv * 2.0 - 1.0);
                p.x *= _ScreenParams.x / _ScreenParams.y;

                float3 col = JuliaColor(p);
                return float4(col, 1.0);
            }

            ENDHLSL
        }
    }
}