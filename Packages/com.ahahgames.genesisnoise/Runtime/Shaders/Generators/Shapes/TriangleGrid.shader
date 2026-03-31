Shader "Hidden/Genesis/TriangleGrid"
{
    Properties
    {
        _Scale("Base Scale", Vector) = (3.0, 3.0, 0, 0)
        _DetailScale("Detail Scale", Float) = 8.0
        _Octaves("FBM Octaves", Range(1,8)) = 5
        _Lacunarity("Lacunarity", Float) = 2.0
        _Gain("Gain", Float) = 0.5

        _RidgeStrength("Ridge Strength", Range(0,4)) = 1.6
        _RidgeBias("Ridge Bias", Range(-1,1)) = 0.0

        _CellularWeight("Cellular Weight", Range(0,1)) = 0.45
        _CellularScale("Cellular Scale", Float) = 6.0
        _CellularJitter("Cellular Jitter", Range(0,1)) = 0.8

        _Contrast("Contrast", Range(0.5,4.0)) = 1.2
        _Exposure("Exposure", Range(-2,2)) = 0.0
        _Invert("Invert", Range(0,1)) = 0

        _LightDir("Light Direction", Vector) = (0.6, 0.4, 0.7, 0)
        _LightIntensity("Light Intensity", Range(0,4)) = 1.2
        _Ambient("Ambient", Range(0,1)) = 0.15
        _Specular("Specular", Range(0,2)) = 0.6
        _SpecPower("Specular Power", Range(1,64)) = 16.0

        _Seed("Seed", Float) = 12.34
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
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            // Parameters
            float2 _Scale;
            float _DetailScale;
            int   _Octaves;
            float _Lacunarity;
            float _Gain;

            float _RidgeStrength;
            float _RidgeBias;

            float _CellularWeight;
            float _CellularScale;
            float _CellularJitter;

            float _Contrast;
            float _Exposure;
            float _Invert;

            float4 _LightDir;
            float _LightIntensity;
            float _Ambient;
            float _Specular;
            float _SpecPower;

            float _Seed;

            // Hash / noise helpers
            float hash11(float n)
            {
                return frac(sin(n * 127.1 + _Seed * 41.23) * 43758.5453123);
            }
            float2 hash21(float2 p)
            {
                float n = dot(p, float2(127.1, 311.7)) + _Seed * 17.0;
                return frac(sin(float2(n, n + 1.234)) * 43758.5453);
            }

            // Classic value noise
            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                float2 u = f * f * (3.0 - 2.0 * f);

                float a = hash11(i.x + i.y * 57.0);
                float b = hash11(i.x + 1.0 + i.y * 57.0);
                float c = hash11(i.x + (i.y + 1.0) * 57.0);
                float d = hash11(i.x + 1.0 + (i.y + 1.0) * 57.0);

                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            // FBM
            float fbm(float2 p)
            {
                float sum = 0.0;
                float amp = 1.0;
                float freq = 1.0;
                for (int i = 0; i < _Octaves; ++i)
                {
                    sum += amp * noise(p * freq);
                    freq *= _Lacunarity;
                    amp *= _Gain;
                }
                return sum;
            }

            // Ridged multifractal (creates sharp creases)
            float ridgedFBM(float2 p)
            {
                float sum = 0.0;
                float amp = 1.0;
                float freq = 1.0;
                for (int i = 0; i < _Octaves; ++i)
                {
                    float n = noise(p * freq);
                    float r = 1.0 - abs(n * 2.0 - 1.0); // ridge from value noise
                    r = pow(r, 1.0 + _RidgeStrength);
                    sum += r * amp;
                    freq *= _Lacunarity;
                    amp *= _Gain;
                }
                // bias and normalize
                return saturate(sum + _RidgeBias);
            }

            // Worley / cellular (F1)
            float cellularF1(float2 p)
            {
                float2 ip = floor(p);
                float2 fp = frac(p);

                float best = 1e9;
                for (int y = -1; y <= 1; ++y)
                {
                    for (int x = -1; x <= 1; ++x)
                    {
                        float2 b = float2(x, y);
                        float2 r = hash21(ip + b) * _CellularJitter;
                        float2 diff = b + r - fp;
                        float d = dot(diff, diff);
                        best = min(best, d);
                    }
                }
                return sqrt(best);
            }

            // Combine features into a height
            float buildHeight(float2 uv)
            {
                // Base scaled coordinates
                float2 baseUV = uv * _Scale;

                // Large-scale ridged structure
                float ridge = ridgedFBM(baseUV * 0.5);

                // Angular faceting: use high-frequency fbm and quantize to create planar facets
                float hf = fbm(baseUV * _DetailScale);
                // quantize to create angular facets
                float facets = floor(hf * 6.0) / 6.0;

                // Cellular detail for sharp pits and bumps
                float cell = cellularF1(baseUV * _CellularScale);

                // Blend components
                float h = ridge * 0.6 + facets * 0.35 + (1.0 - saturate(cell)) * _CellularWeight;

                // Add small micro noise
                h += (noise(baseUV * (_DetailScale * 2.0)) - 0.5) * 0.03;

                return saturate(h);
            }

            // Compute normal from height using derivatives
            float3 computeNormal(float2 uv)
            {
                float eps = 1.0 / 1024.0; // small step relative to typical texture sizes
                float h = buildHeight(uv);
                float hx = buildHeight(uv + float2(eps, 0));
                float hy = buildHeight(uv + float2(0, eps));
                float3 n = normalize(float3((hx - h), (hy - h), eps * 4.0));
                return n;
            }

            float4 genesis(v2f_customrendertexture i)
            {
                float3 uv3 = i.localTexcoord.xyz;
                float2 uv = uv3.xy;

                // Build height
                float h = buildHeight(uv);

                // Lighting
                float3 light = normalize(_LightDir.xyz);
                float3 n = computeNormal(uv);
                float ndotl = saturate(dot(n, light));
                float diffuse = ndotl * _LightIntensity;
                float3 view = normalize(float3(0,0,1));
                float3 halfv = normalize(light + view);
                float spec = pow(saturate(dot(n, halfv)), _SpecPower) * _Specular;

                float shaded = _Ambient + diffuse + spec;

                // Apply contrast and exposure to height for stronger sculpting
                float shaped = pow(saturate(h * exp2(_Exposure)), _Contrast);

                // Combine shading with height to emphasize relief (multiply)
                float outVal = saturate(shaped * shaded);

                if (_Invert > 0.5) outVal = 1.0 - outVal;

                return float4(outVal, outVal, outVal, 1.0);
            }

            ENDHLSL
        }
    }
}
