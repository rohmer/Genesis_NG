Shader "Hidden/Genesis/Bevel"
{
    Properties
    {
        // Height input
        [InlineTexture]_Height_2D("Height", 2D) = "black" {}
        [InlineTexture]_Height_3D("Height", 3D) = "black" {}
        [InlineTexture]_Height_Cube("Height", Cube) = "black" {}

        // Optional mask
        [InlineTexture]_Mask_2D("Mask", 2D) = "white" {}
        [InlineTexture]_Mask_3D("Mask", 3D) = "white" {}
        [InlineTexture]_Mask_Cube("Mask", Cube) = "white" {}

        _BevelWidth("Bevel Width", Range(0, 10)) = 2
        _Intensity("Intensity", Range(0, 4)) = 1
        _Profile("Profile", Range(0, 1)) = 0.5
        _Invert("Invert Height", Int) = 0
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
            TEXTURE_SAMPLER_X(_Mask);

            float _BevelWidth;
            float _Intensity;
            float _Profile;
            int   _Invert;

            // ------------------------------------------------------------
            float SampleHeight(float3 uv, float3 dir)
            {
                float h = SAMPLE_X(_Height, uv, dir).r;
                return _Invert ? (1.0 - h) : h;
            }

            // Sobel gradient
            float2 HeightGradient(float3 uv, float3 texel, float3 dir)
            {
                float hL = SampleHeight(uv - float3(texel.x, 0, 0), dir);
                float hR = SampleHeight(uv + float3(texel.x, 0, 0), dir);
                float hD = SampleHeight(uv - float3(0, texel.y, 0), dir);
                float hU = SampleHeight(uv + float3(0, texel.y, 0), dir);

                float dx = (hR - hL);
                float dy = (hU - hD);

                return float2(dx, dy);
            }

            // Profile shaping (Substance‑style)
            float ProfileCurve(float x)
            {
                // x in [0,1]
                // _Profile = 0 → rounded
                // _Profile = 1 → sharp
                float smooth = smoothstep(0, 1, x);
                float sharp  = pow(x, 0.35);
                return lerp(smooth, sharp, _Profile);
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float mask = SAMPLE_X(_Mask, uv, i.direction).r;

                // --- Height sampling with bevel width scaling
                float2 grad = HeightGradient(uv, texel * _BevelWidth, i.direction);

                // Convert gradient to normal
                float3 n = normalize(float3(-grad.x, -grad.y, 1.0 / _Intensity));

                // Convert normal Z to bevel shading
                float shade = saturate(n.z);

                // Apply profile shaping
                shade = ProfileCurve(shade);
                 
                // Apply mask
                shade *= mask;

                return float4(shade.xxx, 1);
            }

            ENDHLSL
        }
    }
}