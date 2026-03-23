Shader "Hidden/Genesis/ValueVoronoiSuite2D"
{
    Properties
    {
        [Tooltip(FBM Value 0, Ridge Value 1, Billow Value 2, Turbulence Value 3, FBM Voronoi 4, BIllow Voronoi 5, Turbulence Voronoi 6, Warping Value 7)]
        [Enum(FBMValue,0,RidgeValue,1,BillowValue,2,TurbulenceValue,3,FBMVoronoi,4,BillowVoronoi,5,TurbulenceVoronoi,6,WarpingValue,7)]_Mode("Mode", int) = 0

        [Tooltip(Frequency and tiling)]
        _Scale("Scale", Vector) = (4,4,0,0)

        [Tooltip(Offset in noise space)]
        _Offset("Offset", Vector) = (0,0,0,0)

        [Tooltip(Octaves)]
        _Octaves("Octaves", Range(1,8)) = 5

        [Tooltip(Base amplitude)]
        _BaseAmplitude("Base Amplitude", Range(0,2)) = 1.0

        [Tooltip(Lacunarity (amplitude multiplier))]
        _Lacunarity("Lacunarity", Range(0,1)) = 0.5

        [Tooltip(Ridge and Billow power)]
        _Power("Ridge/Billow Power", Range(0.1,8)) = 1.0

        [Tooltip(Warp shift)]
        _WarpShift("Warp Shift", Float) = 1.0

        [Tooltip(Warp rotation angle (radians))]
        _WarpAngle("Warp Angle", Float) = 0.5

        [Tooltip(Output amplitude)]
        _OutAmplitude("Output Amplitude", Range(0,2)) = 1.0

        [Tooltip(Output contrast)]
        _OutContrast("Output Contrast", Range(0.5,4)) = 1.0
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

            int    _Mode;
            float2 _Scale;
            float2 _Offset;
            int    _Octaves;
            float  _BaseAmplitude;
            float  _Lacunarity;
            float  _Power;
            float  _WarpShift;
            float  _WarpAngle;
            float  _OutAmplitude;
            float  _OutContrast;

            // ---------------------------------------------------------
            // Hashes (hash12, hash22)
            float hash12(float2 p)
            {
                float3 p3 = frac(float3(p.x, p.y, p.x) * 0.1031);
                p3 += dot(p3, p3.yzx + 19.19);
                return frac((p3.x + p3.y) * p3.z);
            }

            float2 hash22(float2 p)
            {
                float3 p3 = frac(float3(p.x, p.y, p.x) * 0.1031);
                p3 += dot(p3, p3.yzx + 19.19);
                return frac(float2(
                    (p3.x + p3.y) * p3.z,
                    (p3.x + p3.z) * p3.y
                ));
            }

            // ---------------------------------------------------------
            // Value noise 2D
            float valueNoise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                float a = hash12(i);
                float b = hash12(i + float2(1.0, 0.0));
                float c = hash12(i + float2(0.0, 1.0));
                float d = hash12(i + float2(1.0, 1.0));

                float2 u = f * f * (3.0 - 2.0 * f);

                return lerp(a, b, u.x) +
                       (c - a) * u.y * (1.0 - u.x) +
                       (d - b) * u.x * u.y;
            }

            float fbmValueNoise(float2 p)
            {
                float value = 0.0;
                float amplitude = _BaseAmplitude;

                [loop]
                for (int i = 0; i < 16; i++)
                {
                    if (i >= _Octaves) break;
                    value += amplitude * (valueNoise(p) * 2.0 - 1.0);
                    p *= 2.0;
                    amplitude *= _Lacunarity;
                }
                return value;
            }

            float ridgeValueNoise(float2 p, float power)
            {
                float n = 1.0 - abs(fbmValueNoise(p));
                return pow(saturate(n), power);
            }

            float billowValueNoise(float2 p, float power)
            {
                float n = abs(fbmValueNoise(p));
                return pow(saturate(n), power);
            }

            float turbulenceValueNoise(float2 p)
            {
                float value = 0.0;
                float amplitude = _BaseAmplitude;

                [loop]
                for (int i = 0; i < 16; i++)
                {
                    if (i >= _Octaves) break;
                    value += amplitude * abs(valueNoise(p) * 2.0 - 1.0);
                    p *= 2.0;
                    amplitude *= _Lacunarity;
                }
                return value;
            }

            // ---------------------------------------------------------
            // Voronoi 2D
            float voronoiNoise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                float minDist = 1.0;

                [unroll]
                for (int y = -1; y <= 1; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 neighbor = float2((float)x, (float)y);
                        float2 cellPoint = hash22(i + neighbor);
                        float2 diff = neighbor + cellPoint - f;
                        float dist = length(diff);
                        minDist = min(minDist, dist);
                    }
                }

                return minDist;
            }

            float fbmVoronoiNoise(float2 p)
            {
                float value = 0.0;
                float amplitude = 1.0;

                [loop]
                for (int i = 0; i < 3; i++)
                {
                    value += amplitude * (voronoiNoise(p) * 2.0 - 1.0);
                    p *= 2.0;
                    amplitude *= 0.5;
                }
                return value;
            }

            float billowVoronoiNoise(float2 p, float power)
            {
                float n = abs(fbmVoronoiNoise(p));
                return pow(saturate(n), power);
            }

            float turbulenceVoronoiNoise(float2 p)
            {
                float value = 0.0;
                float amplitude = _BaseAmplitude;

                [loop]
                for (int i = 0; i < 16; i++)
                {
                    if (i >= _Octaves) break;
                    value += amplitude * abs(voronoiNoise(p) * 2.0 - 1.0);
                    p *= 2.0;
                    amplitude *= _Lacunarity;
                }
                return value;
            }

            // ---------------------------------------------------------
            // Warping value noise (static, no time)
            float warpingValueNoise(float2 p, float shift)
            {
                float value = 0.0;
                float amplitude = _BaseAmplitude;

                float c = cos(_WarpAngle);
                float s = sin(_WarpAngle);
                float2x2 rot = float2x2(c, s, -s, c);

                [loop]
                for (int i = 0; i < 16; i++)
                {
                    if (i >= _Octaves) break;
                    value += amplitude * (valueNoise(p) * 2.0 - 1.0);
                    p = mul(rot, p) * 2.0 + shift;
                    amplitude *= _Lacunarity;
                }

                return value;
            }

            float warpingValueNoiseChain(float2 p, float shift)
            {
                float2 q;
                q.x = warpingValueNoise(p, shift);
                q.y = warpingValueNoise(p + float2(1.0, 0.0), shift);

                float2 r;
                r.x = warpingValueNoise(p + q + float2(1.7, 9.2), shift);
                r.y = warpingValueNoise(p + q + float2(8.3, 2.8), shift);

                return warpingValueNoise(p + r, shift);
            }

            // ---------------------------------------------------------
            float evaluate(float2 uv)
            {
                float2 p = uv * _Scale + _Offset;

                if      (_Mode == 0) return fbmValueNoise(p) * 0.5 + 0.5;
                else if (_Mode == 1) return ridgeValueNoise(p, _Power);
                else if (_Mode == 2) return billowValueNoise(p, _Power);
                else if (_Mode == 3) return turbulenceValueNoise(p);
                else if (_Mode == 4) return fbmVoronoiNoise(p) * 0.5 + 0.5;
                else if (_Mode == 5) return billowVoronoiNoise(p, _Power);
                else if (_Mode == 6) return turbulenceVoronoiNoise(p);
                else                 return warpingValueNoiseChain(p, _WarpShift) * 0.5 + 0.5;
            }

            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float v = evaluate(i.localTexcoord.xy);

                v *= _OutAmplitude;
                v = saturate(pow(v, _OutContrast));

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}