Shader "Hidden/Genesis/FloodFillToColor"
{
    Properties
    {
        // Region ID map from Flood Fill
        [InlineTexture]_RegionID_2D("Region ID", 2D) = "black" {}
        [InlineTexture]_RegionID_3D("Region ID", 3D) = "black" {}
        [InlineTexture]_RegionID_Cube("Region ID", Cube) = "black" {}

        _Seed("Seed", Range(0, 1000)) = 0
        _Saturation("Saturation", Range(0, 1)) = 1
        _Value("Value", Range(0, 1)) = 1
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

            TEXTURE_SAMPLER_X(_RegionID);

            float _Seed;
            float _Saturation;
            float _Value;

            // ------------------------------------------------------------
            // Hash functions for stable region colors
            float Hash11(float x)
            {
                x = frac(x * 0.1031 + _Seed * 0.0137);
                x *= x + 33.33;
                x *= x + x;
                return frac(x);
            }

            float3 HashColor(float id)
            {
                // Three decorrelated hashes
                float h = Hash11(id);
                float s = lerp(0.2, _Saturation, Hash11(id + 17.123));
                float v = lerp(0.5, _Value,      Hash11(id + 91.77));

                // Convert HSV → RGB
                float3 rgb;

                float f = frac(h * 6.0);
                float i = floor(h * 6.0);

                float p = v * (1.0 - s);
                float q = v * (1.0 - s * f);
                float t = v * (1.0 - s * (1.0 - f));

                if (i == 0) rgb = float3(v, t, p);
                else if (i == 1) rgb = float3(q, v, p);
                else if (i == 2) rgb = float3(p, v, t);
                else if (i == 3) rgb = float3(p, q, v);
                else if (i == 4) rgb = float3(t, p, v);
                else             rgb = float3(v, p, q);

                return rgb;
            }

            float SampleRegionID(float3 uv, float3 dir)
            {
                return SAMPLE_X(_RegionID, uv, dir).r;
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float id = SampleRegionID(uv, i.direction);

                // Background (no region)
                if (id <= 0.00001)
                    return float4(0, 0, 0, 1);

                // Convert region ID → stable random color
                float3 col = HashColor(id);

                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}