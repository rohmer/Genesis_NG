Shader "Hidden/Genesis/Emboss"
{
    Properties
    {
        // Height input
        [InlineTexture]_Height_2D("Height", 2D) = "black" {}
        [InlineTexture]_Height_3D("Height", 3D) = "black" {}
        [InlineTexture]_Height_Cube("Height", Cube) = "black" {}

        // Direction map (optional)
        [InlineTexture]_Direction_2D("Direction Map", 2D) = "black" {}
        [InlineTexture]_Direction_3D("Direction Map", 3D) = "black" {}
        [InlineTexture]_Direction_Cube("Direction Map", Cube) = "black" {}

        _EmbossWidth("Emboss Width", Range(0, 10)) = 2
        _Depth("Depth", Range(0, 4)) = 1

        _DirectionAngle("Direction Angle", Range(0, 1)) = 0.0
        _DirectionStrength("Direction Strength", Range(0, 1)) = 1
        _DirectionIsVector("Direction Is Vector", Int) = 0

        _Invert("Invert Height", Int) = 0
        _Profile("Profile", Range(0, 1)) = 0.5
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
            TEXTURE_SAMPLER_X(_Direction);

            float _EmbossWidth;
            float _Depth;
            float _DirectionAngle;
            float _DirectionStrength;
            int   _DirectionIsVector;
            int   _Invert;
            float _Profile;

            // ------------------------------------------------------------
            float SampleHeight(float3 uv, float3 dir)
            {
                float h = SAMPLE_X(_Height, uv, dir).r;
                return _Invert ? (1.0 - h) : h;
            }

            float3 SampleDirection(float3 uv, float3 dir)
            {
                float4 d = SAMPLE_X(_Direction, uv, dir);

                if (_DirectionIsVector == 1)
                {
                    float2 v = normalize(d.xy * 2 - 1);
                    return float3(v.x,v.y,0);
                }
                else
                {
                    float angle = d.r * 6.2831853;
                    return float3(cos(angle), sin(angle),0);
                }
            }

            float3 BaseDirection()
            {
                float angle = _DirectionAngle * 6.2831853;
                return float3(cos(angle), sin(angle),0);
            }

            // Soft profile shaping (Substance‑like)
            float ProfileCurve(float x)
            {
                float smooth = smoothstep(0, 1, x);
                float sharp  = pow(x, 0.35);
                return lerp(smooth, sharp, _Profile);
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                // --- Direction
                float3 dirBase = BaseDirection();
                float3 dirMap  = SampleDirection(uv, i.direction);

                float3 dir = normalize(lerp(dirBase, dirMap, _DirectionStrength));

                // --- Height samples along direction
                float h0 = SampleHeight(uv - dir * texel * _EmbossWidth, i.direction);
                float h1 = SampleHeight(uv + dir * texel * _EmbossWidth, i.direction);

                // Emboss difference
                float diff = (h1 - h0) * _Depth;

                // Convert to shading
                float shade = saturate(0.5 + diff * 0.5);

                // Apply profile shaping
                shade = ProfileCurve(shade);

                return float4(shade.xxx, 1);
            } 

            ENDHLSL
        }
    }
}