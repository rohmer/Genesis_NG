Shader "Hidden/Genesis/ShapeDropShadow"
{
    Properties
    {
        // Shape mask (0–1)
        [InlineTexture]_Shape_2D("Shape", 2D) = "black" {}
        [InlineTexture]_Shape_3D("Shape", 3D) = "black" {}
        [InlineTexture]_Shape_Cube("Shape", Cube) = "black" {}

        _Distance("Shadow Distance", Range(0, 64)) = 16
        _Softness("Softness", Range(0, 1)) = 0.35
        _Opacity("Opacity", Range(0, 1)) = 1.0

        // Direction in turns (0–1)
        _Angle("Direction", Range(0, 1)) = 0.125

        // Shadow color
        _ShadowColor("Shadow Color", Color) = (0,0,0,1)
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

            TEXTURE_SAMPLER_X(_Shape);

            float _Distance;
            float _Softness;
            float _Opacity;
            float _Angle;
            float4 _ShadowColor;

            float SampleShape(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Shape, uv, dir).r;
            }

            float2 DirFromAngle(float a)
            {
                float ang = a * 6.2831853;
                return float2(cos(ang), sin(ang));
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float shape = SampleShape(uv, i.direction);

                // If inside shape, no shadow is cast *onto* itself
                if (shape > 0.5)
                    return float4(0,0,0,0);

                float2 dir = DirFromAngle(_Angle);

                int steps = max(1, (int)_Distance);
                float shadow = 0.0;

                // Ray‑march along shadow direction
                for (int s = 1; s <= steps; s++)
                {
                    float2 suv = uv - dir * (s * texel);

                    float m = SampleShape(float3(suv,0), i.direction);

                    if (m > 0.5)
                    {
                        float t = (float)s / steps;

                        // Softness curve
                        float soft = smoothstep(1.0, 1.0 - _Softness, t);

                        shadow = soft;
                        break;
                    }
                }

                shadow *= _Opacity;

                float3 col = _ShadowColor.rgb * shadow;
                return float4(col, shadow);
            }

            ENDHLSL
        }
    }
}   