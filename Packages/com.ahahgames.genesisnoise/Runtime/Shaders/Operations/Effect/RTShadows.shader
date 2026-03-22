Shader "Hidden/Genesis/RTShadows"
{
    Properties
    {
        // Height map input (0–1)
        [InlineTexture]_Height_2D("Height", 2D) = "black" {}
        [InlineTexture]_Height_3D("Height", 3D) = "black" {}
        [InlineTexture]_Height_Cube("Height", Cube) = "black" {}

        _HeightScale("Height Scale", Range(0, 10)) = 1.0

        // Light position on sphere:
        // X: horizontal in turns (0–1)
        // Y: vertical, 0/1 = horizon, 0.5 = zenith
        _LightPos("Light Position", Vector) = (0.0, 0.5, 0, 0)

        _LightIntensity("Light Intensity", Range(0, 4)) = 1.0
        _ShadowOpacity("Shadow Opacity", Range(0, 1)) = 1.0
        _ShadowAttenuation("Shadow Attenuation", Range(0, 2)) = 1.0

        _MaxShadowLength("Max Shadow Length", Range(0, 64)) = 32.0
        _Samples("Samples", Range(4, 64)) = 24
        _Bias("Height Bias", Range(0, 0.1)) = 0.01
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_Height);

            float _HeightScale;
            float4 _LightPos;
            float _LightIntensity;
            float _ShadowOpacity;
            float _ShadowAttenuation;
            float _MaxShadowLength;
            float _Samples;
            float _Bias;

            float SampleHeight(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Height, uv, dir).r * _HeightScale;
            }

            // Convert Substance-style light position to a 3D direction
            float3 GetLightDir()
            {
                float horiz = _LightPos.x; // turns
                float vert  = _LightPos.y; // 0/1 horizon, 0.5 zenith

                float az = horiz * 6.2831853;
                float el = (vert - 0.5) * 3.14159265; // -pi/2..pi/2

                float3 d;
                d.x = cos(el) * cos(az);
                d.z = cos(el) * sin(az);
                d.y = sin(el);

                return normalize(d);
            }

            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float h0 = SampleHeight(uv, i.direction);

                float3 L = GetLightDir();

                // Project light direction onto texture plane (x,z → uv)
                float2 dirUV = normalize(float2(L.x, L.z));
                // If light is almost vertical, shadows vanish
                float vertical = abs(L.y);
                float verticalFactor = saturate(1.0 - vertical);

                int   N      = max(1, (int)_Samples);
                float maxLen = _MaxShadowLength;
                if (maxLen <= 0.0)
                    return float4(1, 1, 1, 1);

                float stepLen = maxLen / N;

                float shadow = 0.0;

                for (int s = 1; s <= N; s++)
                {
                    float dist = stepLen * s;

                    float2 suv = uv + dirUV * (dist * texel);
                    float h = SampleHeight(float3(suv,0.0), i.direction);

                    // Height difference along light direction
                    float expected = h0 + L.y * dist + _Bias;

                    if (h > expected)
                    {
                        float atten = exp(-_ShadowAttenuation * (dist / maxLen));
                        shadow += atten;
                    }
                }

                shadow = saturate(shadow / N);
                shadow *= _LightIntensity * verticalFactor;
                shadow *= _ShadowOpacity;

                float lit = 1.0 - shadow;

                return float4(lit.xxx, 1);
            }

            ENDHLSL
        }
    }
}