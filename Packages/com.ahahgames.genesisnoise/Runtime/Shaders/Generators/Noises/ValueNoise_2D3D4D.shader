Shader "Hidden/Genesis/ValueNoise_2D3D4D"
{
    Properties
    {
        [Enum(2D,0,3D,1,4D,2)]
        _Dim("Noise Dimension", int) = 0

        [Tooltip(Frequency and tiling)]
        _Scale("Scale", Vector) = (4,4,4,4)

        [Tooltip(Offset in noise space)]
        _Offset("Offset", Vector) = (0,0,0,0)

        [Tooltip(Amplitude)]
        _Amplitude("Amplitude", Range(0,2)) = 1.0

        [Tooltip(Contrast shaping)]
        _Contrast("Contrast", Range(0.5,4)) = 1.0

        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D)   = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D)   = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs",Cube)= "uv" {}
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
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            TEXTURE_SAMPLER_X(_UV);

            int    _Dim;
            float4 _Scale;
            float4 _Offset;
            float  _Amplitude;
            float  _Contrast;
            int    _Seed;

            // ---------------------------------------------------------
            // Hash functions (deterministic, sampler-free)
            float hash1(float n)
            {
                return frac(sin(n * 127.1) * 43758.5453123);
            }

            float hash2(float2 p)
            {
                return hash1(dot(p, float2(127.1, 311.7)));
            }

            float hash3(float3 p)
            {
                return hash1(dot(p, float3(127.1, 311.7, 74.7)));
            }

            float hash4(float4 p)
            {
                return hash1(dot(p, float4(127.1, 311.7, 74.7, 19.3)));
            }

            // ---------------------------------------------------------
            // Smooth interpolation
            float smooth(float t)
            {
                return t * t * (3.0 - 2.0 * t);
            }

            // ---------------------------------------------------------
            // 2D Value Noise
            float value2D(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                float2 u = smooth(f);

                float a = hash2(i + float2(0,0));
                float b = hash2(i + float2(1,0));
                float c = hash2(i + float2(0,1));
                float d = hash2(i + float2(1,1));

                float x1 = lerp(a, b, u.x);
                float x2 = lerp(c, d, u.x);

                return lerp(x1, x2, u.y);
            }

            // ---------------------------------------------------------
            // 3D Value Noise
            float value3D(float3 p)
            {
                float3 i = floor(p);
                float3 f = frac(p);

                float3 u = smooth(f);

                float c000 = hash3(i + float3(0,0,0));
                float c100 = hash3(i + float3(1,0,0));
                float c010 = hash3(i + float3(0,1,0));
                float c110 = hash3(i + float3(1,1,0));

                float c001 = hash3(i + float3(0,0,1));
                float c101 = hash3(i + float3(1,0,1));
                float c011 = hash3(i + float3(0,1,1));
                float c111 = hash3(i + float3(1,1,1));

                float x00 = lerp(c000, c100, u.x);
                float x10 = lerp(c010, c110, u.x);
                float x01 = lerp(c001, c101, u.x);
                float x11 = lerp(c011, c111, u.x);

                float y0 = lerp(x00, x10, u.y);
                float y1 = lerp(x01, x11, u.y);

                return lerp(y0, y1, u.z);
            }

            // ---------------------------------------------------------
            // 4D Value Noise
            float value4D(float4 p)
            {
                float4 i = floor(p);
                float4 f = frac(p);

                float4 u = smooth(f);

                float4 v0000 = float4(0,0,0,0);
                float4 v1000 = float4(1,0,0,0);
                float4 v0100 = float4(0,1,0,0);
                float4 v1100 = float4(1,1,0,0);

                float4 v0010 = float4(0,0,1,0);
                float4 v1010 = float4(1,0,1,0);
                float4 v0110 = float4(0,1,1,0);
                float4 v1110 = float4(1,1,1,0);

                float4 v0001 = float4(0,0,0,1);
                float4 v1001 = float4(1,0,0,1);
                float4 v0101 = float4(0,1,0,1);
                float4 v1101 = float4(1,1,0,1);

                float4 v0011 = float4(0,0,1,1);
                float4 v1011 = float4(1,0,1,1);
                float4 v0111 = float4(0,1,1,1);
                float4 v1111 = float4(1,1,1,1);

                float n0000 = hash4(i + v0000);
                float n1000 = hash4(i + v1000);
                float n0100 = hash4(i + v0100);
                float n1100 = hash4(i + v1100);

                float n0010 = hash4(i + v0010);
                float n1010 = hash4(i + v1010);
                float n0110 = hash4(i + v0110);
                float n1110 = hash4(i + v1110);

                float n0001 = hash4(i + v0001);
                float n1001 = hash4(i + v1001);
                float n0101 = hash4(i + v0101);
                float n1101 = hash4(i + v1101);

                float n0011 = hash4(i + v0011);
                float n1011 = hash4(i + v1011);
                float n0111 = hash4(i + v0111);
                float n1111 = hash4(i + v1111);

                float x000 = lerp(n0000, n1000, u.x);
                float x100 = lerp(n0100, n1100, u.x);
                float x010 = lerp(n0010, n1010, u.x);
                float x110 = lerp(n0110, n1110, u.x);

                float x001 = lerp(n0001, n1001, u.x);
                float x101 = lerp(n0101, n1101, u.x);
                float x011 = lerp(n0011, n1011, u.x);
                float x111 = lerp(n0111, n1111, u.x);

                float y00 = lerp(x000, x100, u.y);
                float y10 = lerp(x010, x110, u.y);
                float y01 = lerp(x001, x101, u.y);
                float y11 = lerp(x011, x111, u.y);

                float z0 = lerp(y00, y10, u.z);
                float z1 = lerp(y01, y11, u.z);

                return lerp(z0, z1, u.w);
            }

            // ---------------------------------------------------------
            float evaluateNoise(float3 uv)
            {
                // uv comes in [0,1] from CRT; we just apply scale/offset
                if (_Dim == 0) // 2D
                {
                    float2 p = uv.xy * _Scale.xy + _Offset.xy;
                    return value2D(p);
                }
                else if (_Dim == 1) // 3D
                {
                    float3 p = uv * _Scale.xyz + _Offset.xyz;
                    return value3D(p);
                }
                else // 4D
                {
                    float4 p = float4(uv, 0) * _Scale + _Offset;
                    return value4D(p);
                }
            }

            // ---------------------------------------------------------
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv;

                #ifdef CRT_3D
                    #ifdef USE_CUSTOM_UV
                        uv = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);
                    #else
                        uv = float3(GetDefaultUVs(i), 0);
                    #endif
                #else
                    #ifdef USE_CUSTOM_UV
                        uv = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);
                    #else
                        uv = float3(i.localTexcoord.xyz);
                    #endif
                #endif

                float v = evaluateNoise(uv);

                v *= _Amplitude;
                v = saturate(pow(v, _Contrast));

                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}