Shader "Hidden/Genesis/Simplex3D"
{
    Properties
    {
        [Tooltip(Frequency and tiling)] _Scale("Scale", Vector) = (4,4,4,0)
        [Tooltip(Offset in noise space)] _Offset("Offset", Vector) = (0,0,0,0)

        [Enum(Simplex,0,FBM,1)][Tooltip(Use FBM instead of raw simplex)] _UseFBM("Use FBM", int) = 1

        [Tooltip(Amplitude)] _Amplitude("Amplitude", Range(0,2)) = 1.0
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.0
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

            float3 _Scale;
            float3 _Offset;
            float  _Amplitude;
            float  _Contrast;
            int    _UseFBM;

            float4 _MainTex_TexelSize;

            // ---------------------------------------------------------
            // noise3D → gradient seed (converted from GLSL)
            float noise3D(float3 p)
            {
                return frac(sin(dot(p, float3(12.9898, 78.233, 128.852))) * 43758.5453) * 2.0 - 1.0;
            }

            // ---------------------------------------------------------
            // simplex3D (converted from GLSL)
            float simplex3D(float3 p)
            {
                const float f3 = 1.0 / 3.0;
                float s = (p.x + p.y + p.z) * f3;

                int i = (int)floor(p.x + s);
                int j = (int)floor(p.y + s);
                int k = (int)floor(p.z + s);

                const float g3 = 1.0 / 6.0;
                float t = (float)(i + j + k) * g3;

                float x0 = p.x - ((float)i - t);
                float y0 = p.y - ((float)j - t);
                float z0 = p.z - ((float)k - t);

                int i1, j1, k1;
                int i2, j2, k2;

                if (x0 >= y0)
                {
                    if (y0 >= z0) { i1=1; j1=0; k1=0; i2=1; j2=1; k2=0; }
                    else if (x0 >= z0) { i1=1; j1=0; k1=0; i2=1; j2=0; k2=1; }
                    else { i1=0; j1=0; k1=1; i2=1; j2=0; k2=1; }
                }
                else
                {
                    if (y0 < z0) { i1=0; j1=0; k1=1; i2=0; j2=1; k2=1; }
                    else if (x0 < z0) { i1=0; j1=1; k1=0; i2=0; j2=1; k2=1; }
                    else { i1=0; j1=1; k1=0; i2=1; j2=1; k2=0; }
                }

                float x1 = x0 - (float)i1 + g3;
                float y1 = y0 - (float)j1 + g3;
                float z1 = z0 - (float)k1 + g3;

                float x2 = x0 - (float)i2 + 2.0 * g3;
                float y2 = y0 - (float)j2 + 2.0 * g3;
                float z2 = z0 - (float)k2 + 2.0 * g3;

                float x3 = x0 - 1.0 + 3.0 * g3;
                float y3 = y0 - 1.0 + 3.0 * g3;
                float z3 = z0 - 1.0 + 3.0 * g3;

                float3 ijk0 = float3(i, j, k);
                float3 ijk1 = float3(i+i1, j+j1, k+k1);
                float3 ijk2 = float3(i+i2, j+j2, k+k2);
                float3 ijk3 = float3(i+1, j+1, k+1);

                float3 gr0 = normalize(float3(noise3D(ijk0), noise3D(ijk0*2.01), noise3D(ijk0*2.02)));
                float3 gr1 = normalize(float3(noise3D(ijk1), noise3D(ijk1*2.01), noise3D(ijk1*2.02)));
                float3 gr2 = normalize(float3(noise3D(ijk2), noise3D(ijk2*2.01), noise3D(ijk2*2.02)));
                float3 gr3 = normalize(float3(noise3D(ijk3), noise3D(ijk3*2.01), noise3D(ijk3*2.02)));

                float n0=0, n1=0, n2=0, n3=0;

                float t0 = 0.5 - x0*x0 - y0*y0 - z0*z0;
                if (t0 >= 0.0) { t0 *= t0; n0 = t0 * t0 * dot(gr0, float3(x0,y0,z0)); }

                float t1 = 0.5 - x1*x1 - y1*y1 - z1*z1;
                if (t1 >= 0.0) { t1 *= t1; n1 = t1 * t1 * dot(gr1, float3(x1,y1,z1)); }

                float t2 = 0.5 - x2*x2 - y2*y2 - z2*z2;
                if (t2 >= 0.0) { t2 *= t2; n2 = t2 * t2 * dot(gr2, float3(x2,y2,z2)); }

                float t3 = 0.5 - x3*x3 - y3*y3 - z3*z3;
                if (t3 >= 0.0) { t3 *= t3; n3 = t3 * t3 * dot(gr3, float3(x3,y3,z3)); }

                return 96.0 * (n0 + n1 + n2 + n3);
            }

            // ---------------------------------------------------------
            // FBM (converted from GLSL)
            float fbm(float3 p)
            {
                float f = 0.5 * simplex3D(p); p *= 2.01;
                f += 0.25 * simplex3D(p);    p *= 2.02;
                f += 0.125 * simplex3D(p);   p *= 2.03;
                f += 0.0625 * simplex3D(p);  p *= 2.04;
                f += 0.03125 * simplex3D(p);

                return f * 0.5 + 0.5;
            }

            // ---------------------------------------------------------
            float evaluateNoise(float3 uv)
            {
                float3 p = uv * _Scale + _Offset;

                #if defined(CRT_3D) || defined(CRT_CUBE)
                    return (_UseFBM != 0) ? fbm(p) : simplex3D(p);
                #else
                    float3 p2 = float3(p.xy, 0);
                    return (_UseFBM != 0) ? fbm(p2) : simplex3D(p2);
                #endif
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = evaluateNoise(i.localTexcoord);

                v *= _Amplitude;
                v = saturate(pow(v, _Contrast));

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}