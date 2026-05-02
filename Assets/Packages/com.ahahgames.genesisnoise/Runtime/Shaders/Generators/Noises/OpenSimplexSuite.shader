Shader "Hidden/Genesis/OpenSimplexSuite"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        [HideInInspector] _Variant("Variant", Float) = 0
        [Enum(2D,0,3D,1)] _Dim("Noise Dimension", Float) = 0
        [Enum(Noise,0,Derivative Vector,1,Normalized Derivative,2,Slope,3)] _Output("Output", Float) = 0
        _Scale("Scale", Vector) = (4,4,4,0)
        _Offset("Offset", Vector) = (0,0,0,0)
        [IntRange] _Octaves("Octaves", Range(1,8)) = 4
        _Lacunarity("Lacunarity", Float) = 2
        _Gain("Gain", Range(0,1)) = 0.5
        _Amplitude("Amplitude", Range(0,2)) = 1
        _Contrast("Contrast", Range(0.5,4)) = 1
        _DerivativeScale("Derivative Scale", Range(0,4)) = 0.5
        _Seed("Seed", Int) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET_API
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            TEXTURE_SAMPLER_X(_UV);

            float _Variant;
            float _Dim;
            float _Output;
            float4 _Scale;
            float4 _Offset;
            float _Octaves;
            float _Lacunarity;
            float _Gain;
            float _Amplitude;
            float _Contrast;
            float _DerivativeScale;
            int _Seed;

            struct OpenSimplexResult
            {
                float3 derivative;
                float value;
            };

            float4 Mod289(float4 x)
            {
                return x - floor(x * (1.0 / 289.0)) * 289.0;
            }

            float4 PermuteSimplex(float4 t)
            {
                return t * (t * 34.0 + 133.0);
            }

            float3 OpenSimplexGradient(float hash, float scaleConstant)
            {
                float3 cube = fmod(floor(hash / float3(1.0, 2.0, 4.0)), 2.0) * 2.0 - 1.0;
                float3 cuboct = cube;

                int index = (int)(hash / 16.0);
                if (index == 0)
                    cuboct.x = 0.0;
                else if (index == 1)
                    cuboct.y = 0.0;
                else
                    cuboct.z = 0.0;

                float type = fmod(floor(hash / 8.0), 2.0);
                float3 rhomb = lerp(cube, cuboct + cross(cube, cuboct), type);
                float3 grad = cuboct * 1.22474487139 + rhomb;
                grad *= (1.0 - 0.042942436724648037 * type) * scaleConstant;
                return grad;
            }

            void AccumulateContribution(inout OpenSimplexResult result, float3 dx, float hash, float kernelRadius, float gradientScale)
            {
                float3 gradient = OpenSimplexGradient(hash, gradientScale);
                float extrapolation = dot(dx, gradient);
                float a = max(kernelRadius - dot(dx, dx), 0.0);
                float aa = a * a;
                float aaaa = aa * aa;

                result.derivative += (-8.0 * (aa * a * extrapolation) * dx) + (aaaa * gradient);
                result.value += aaaa * extrapolation;
            }

            OpenSimplexResult OpenSimplex2Base(float3 X)
            {
                OpenSimplexResult result;
                result.derivative = 0.0;
                result.value = 0.0;

                float3 vx0 = round(X);
                float3 dx0 = X - vx0;
                float3 score0 = abs(dx0);
                float3 dir0 = step(max(score0.yzx, score0.zxy), score0);
                float3 vx1 = vx0 + dir0 * sign(dx0);
                float3 dx1 = X - vx1;

                float3 X2 = X + 144.5;
                float3 vx2 = round(X2);
                float3 dx2 = X2 - vx2;
                float3 score1 = abs(dx2);
                float3 dir1 = step(max(score1.yzx, score1.zxy), score1);
                float3 vx3 = vx2 + dir1 * sign(dx2);
                float3 dx3 = X2 - vx3;

                float4 hashes = PermuteSimplex(Mod289(float4(vx0.x, vx1.x, vx2.x, vx3.x)));
                hashes = PermuteSimplex(Mod289(hashes + float4(vx0.y, vx1.y, vx2.y, vx3.y)));
                hashes = fmod(PermuteSimplex(Mod289(hashes + float4(vx0.z, vx1.z, vx2.z, vx3.z))), 48.0);

                AccumulateContribution(result, dx0, hashes.x, 0.5, 32.80201376986577);
                AccumulateContribution(result, dx1, hashes.y, 0.5, 32.80201376986577);
                AccumulateContribution(result, dx2, hashes.z, 0.5, 32.80201376986577);
                AccumulateContribution(result, dx3, hashes.w, 0.5, 32.80201376986577);

                return result;
            }

            OpenSimplexResult OpenSimplex2ImproveXY(float3 X)
            {
                float3x3 orthonormalMap = float3x3(
                    0.788675134594813, -0.211324865405187, -0.577350269189626,
                    -0.211324865405187, 0.788675134594813, -0.577350269189626,
                    0.577350269189626, 0.577350269189626, 0.577350269189626
                );

                OpenSimplexResult result = OpenSimplex2Base(mul(X, orthonormalMap));
                result.derivative = mul(orthonormalMap, result.derivative);
                return result;
            }

            OpenSimplexResult OpenSimplex2SPart(float3 X)
            {
                OpenSimplexResult result;
                result.derivative = 0.0;
                result.value = 0.0;

                float3 b = floor(X);
                float4 i4 = float4(X - b, 2.5);

                float3 vx0 = b + floor(dot(i4, float4(0.25, 0.25, 0.25, 0.25)));
                float3 vx1 = b + float3(1.0, 0.0, 0.0) + float3(-1.0, 1.0, 1.0) * floor(dot(i4, float4(-0.25, 0.25, 0.25, 0.35)));
                float3 vx2 = b + float3(0.0, 1.0, 0.0) + float3(1.0, -1.0, 1.0) * floor(dot(i4, float4(0.25, -0.25, 0.25, 0.35)));
                float3 vx3 = b + float3(0.0, 0.0, 1.0) + float3(1.0, 1.0, -1.0) * floor(dot(i4, float4(0.25, 0.25, -0.25, 0.35)));

                float4 hashes = PermuteSimplex(Mod289(float4(vx0.x, vx1.x, vx2.x, vx3.x)));
                hashes = PermuteSimplex(Mod289(hashes + float4(vx0.y, vx1.y, vx2.y, vx3.y)));
                hashes = fmod(PermuteSimplex(Mod289(hashes + float4(vx0.z, vx1.z, vx2.z, vx3.z))), 48.0);

                AccumulateContribution(result, X - vx0, hashes.x, 0.75, 3.5946317686139184);
                AccumulateContribution(result, X - vx1, hashes.y, 0.75, 3.5946317686139184);
                AccumulateContribution(result, X - vx2, hashes.z, 0.75, 3.5946317686139184);
                AccumulateContribution(result, X - vx3, hashes.w, 0.75, 3.5946317686139184);

                return result;
            }

            OpenSimplexResult OpenSimplex2SImproveXY(float3 X)
            {
                float3x3 orthonormalMap = float3x3(
                    0.788675134594813, -0.211324865405187, -0.577350269189626,
                    -0.211324865405187, 0.788675134594813, -0.577350269189626,
                    0.577350269189626, 0.577350269189626, 0.577350269189626
                );

                float3 rotated = mul(X, orthonormalMap);
                OpenSimplexResult first = OpenSimplex2SPart(rotated);
                OpenSimplexResult second = OpenSimplex2SPart(rotated + 144.5);

                OpenSimplexResult result;
                result.derivative = mul(orthonormalMap, first.derivative + second.derivative);
                result.value = first.value + second.value;
                return result;
            }

            OpenSimplexResult EvaluateFractal(float3 coordinate)
            {
                OpenSimplexResult total;
                total.derivative = 0.0;
                total.value = 0.0;

                float amplitude = 1.0;
                float frequency = 1.0;
                float totalAmplitude = 0.0;

                [loop]
                for (int octave = 0; octave < 8; octave++)
                {
                    if (octave >= (int)_Octaves)
                        break;

                    OpenSimplexResult sample;
                    if (_Variant < 0.5)
                        sample = OpenSimplex2ImproveXY(coordinate * frequency);
                    else
                        sample = OpenSimplex2SImproveXY(coordinate * frequency);

                    total.derivative += sample.derivative * amplitude;
                    total.value += sample.value * amplitude;

                    totalAmplitude += amplitude;
                    amplitude *= _Gain;
                    frequency *= _Lacunarity;
                }

                total.derivative /= max(totalAmplitude, 0.0001);
                total.value /= max(totalAmplitude, 0.0001);
                return total;
            }

            float3 GetOpenSimplexCoordinate(v2f_customrendertexture i, inout int seed)
            {
                float3 baseUv;

                #ifdef USE_CUSTOM_UV
                    baseUv = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), seed);
                #else
                    baseUv = GetDefaultUVs(i);
                #endif

                if (_Dim < 0.5)
                    return float3(baseUv.xy * _Scale.xy + _Offset.xy, _Offset.z);

                return baseUv * _Scale.xyz + _Offset.xyz;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                int localSeed = _Seed;
                float3 coordinate = GetOpenSimplexCoordinate(i, localSeed);
                OpenSimplexResult result = EvaluateFractal(coordinate);

                float value = clamp(result.value, -1.0, 1.0);
                float3 derivative = result.derivative;

                if (_Output < 0.5)
                {
                    float v = saturate(0.5 + 0.5 * value * _Amplitude);
                    v = saturate(pow(v, _Contrast));
                    return float4(v, v, v, 1.0);
                }

                if (_Output < 1.5)
                {
                    float3 derivativeColor = saturate(0.5 + derivative * _DerivativeScale);
                    return float4(derivativeColor, 1.0);
                }

                if (_Output < 2.5)
                {
                    float lengthValue = max(length(derivative), 0.0001);
                    float3 directionColor = 0.5 + 0.5 * (derivative / lengthValue);
                    return float4(saturate(directionColor), 1.0);
                }

                float slope = saturate(length(derivative) * _DerivativeScale);
                slope = saturate(pow(slope, _Contrast));
                return float4(slope, slope, slope, 1.0);
            }

            ENDHLSL
        }
    }
}
