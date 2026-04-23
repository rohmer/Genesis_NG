Shader "Hidden/Genesis/CrystalHQ"
{
    Properties
    {
        _BaseScale("Base Scale", Float) = 4.0
        _Jitter("Base Jitter", Range(0,1)) = 0.75

        _Octaves("Worley Octaves", Range(1,8)) = 5
        _Gain("Octave Gain", Range(0,1)) = 0.5
        _Lacunarity("Lacunarity", Float) = 2.0

        _FBMScale("FBM Scale", Float) = 2.0
        _FBMIntensity("FBM Intensity", Range(0,1)) = 0.4
        _FBMOcatves("FBM Octaves", Range(1,6)) = 3

        _Sharpness("Facet Sharpness", Range(0,4)) = 1.5
        _EdgeBoost("Edge Boost", Range(0,2)) = 0.5

        [Enum(None,0, F1,1, F2,2, F3,3, FBM,4, Combined,5)]
        _Debug("Debug Mode", Float) = 0
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

            float _BaseScale;
            float _Jitter;

            float _Octaves;
            float _Gain;
            float _Lacunarity;

            float _FBMScale;
            float _FBMIntensity;
            float _FBMOcatves;

            float _Sharpness;
            float _EdgeBoost;
            float _Debug;

            // ------------------------------------------------------------
            // Deterministic hash functions
            // ------------------------------------------------------------
            float hash11(float n)
            {
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float3 hash31(float n)
            {
                return float3(
                    hash11(n),
                    hash11(n + 19.19),
                    hash11(n + 47.77)
                );
            }

            // ------------------------------------------------------------
            // Value noise for FBM
            // ------------------------------------------------------------
            float valueNoise(float3 p)
            {
                float3 ip = floor(p);
                float3 fp = frac(p);

                float n = ip.x + ip.y * 157 + ip.z * 113;

                float3 v000 = hash31(n + 0.0);
                float3 v100 = hash31(n + 1.0);
                float3 v010 = hash31(n + 157.0);
                float3 v110 = hash31(n + 158.0);
                float3 v001 = hash31(n + 113.0);
                float3 v101 = hash31(n + 114.0);
                float3 v011 = hash31(n + 270.0);
                float3 v111 = hash31(n + 271.0);

                float3 w = fp * fp * (3.0 - 2.0 * fp);

                float3 x00 = lerp(v000, v100, w.x);
                float3 x10 = lerp(v010, v110, w.x);
                float3 x01 = lerp(v001, v101, w.x);
                float3 x11 = lerp(v011, v111, w.x);

                float3 y0 = lerp(x00, x10, w.y);
                float3 y1 = lerp(x01, x11, w.y);

                return lerp(y0, y1, w.z).x;
            }

            float fbm(float3 p)
            {
                float sum = 0.0;
                float amp = 0.5;

                for (int i = 0; i < 6; i++)
                {
                    if (i >= _FBMOcatves) break;

                    sum += valueNoise(p) * amp;
                    p *= 2.0;
                    amp *= 0.5;
                }

                return sum;
            }

            // ------------------------------------------------------------
            // Worley F1/F2/F3
            // ------------------------------------------------------------
            void worleyF123(float3 p, float scale, float jitter, out float f1, out float f2, out float f3)
            {
                p *= scale;

                float3 ip = floor(p);
                float3 fp = frac(p);

                f1 = 9999.0;
                f2 = 9999.0;
                f3 = 9999.0;

                [unroll]
                for (int xo = -1; xo <= 1; xo++)
                [unroll]
                for (int yo = -1; yo <= 1; yo++)
                [unroll]
                for (int zo = -1; zo <= 1; zo++)
                {
                    float3 cell = ip + float3(xo, yo, zo);
                    float id = cell.x + cell.y * 157 + cell.z * 113;

                    float3 rnd = hash31(id);
                    float3 jittered = (rnd - 0.5) * jitter;

                    float3 pos = cell + jittered;
                    float3 d = p - pos;

                    float dist = dot(d, d);

                    if (dist < f1)
                    {
                        f3 = f2;
                        f2 = f1;
                        f1 = dist;
                    }
                    else if (dist < f2)
                    {
                        f3 = f2;
                        f2 = dist;
                    }
                    else if (dist < f3)
                    {
                        f3 = dist;
                    }
                }

                f1 = pow(f1, _Sharpness);
                f2 = pow(f2, _Sharpness);
                f3 = pow(f3, _Sharpness);
            }

            // ------------------------------------------------------------
            // Multi-octave Worley HQ
            // ------------------------------------------------------------
            float worleyHQ(float3 p)
            {
                float sum = 0.0;
                float amp = 1.0;
                float scale = _BaseScale;
                float jitter = _Jitter;

                for (int i = 0; i < 8; i++)
                {
                    if (i >= _Octaves) break;

                    float f1, f2, f3;
                    worleyF123(p, scale, jitter, f1, f2, f3);

                    float layer = (f3 - f1) * amp;
                    sum += layer;

                    scale *= _Lacunarity;
                    jitter *= 0.75;
                    amp *= _Gain;
                }

                return sum;
            }

            // ------------------------------------------------------------
            // CRT entry point
            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                // FBM distortion
                float fbmVal = fbm(uv * _FBMScale);
                float3 distortedUV = uv + fbmVal * _FBMIntensity;

                // Multi-octave HQ Worley
                float f = worleyHQ(distortedUV);

                // Debug modes
                if (_Debug == 1) return float4(f, f, f, 1);
                if (_Debug == 2) return float4(fbmVal, fbmVal, fbmVal, 1);
                if (_Debug == 3) return float4(distortedUV.xy, 0, 1);
                if (_Debug == 4) return float4(f, f, f, 1);

                // Final HQ output
                float3 col = f.xxx;

                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}
