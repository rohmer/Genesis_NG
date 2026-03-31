Shader "Hidden/Genesis/ExtendShape"
{
    Properties
    {
        // Input mask (white = shape, black = background)
        [InlineTexture]_Source_2D("Source", 2D) = "black" {}
        [InlineTexture]_Source_3D("Source", 3D) = "black" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "black" {}

        _Radius("Radius", Range(1, 32)) = 8
        _Iterations("Iterations", Range(1, 8)) = 3
        _Softness("Softness", Range(0, 1)) = 0.25

        // Optional directional bias
        _DirectionAngle("Direction Angle", Range(0, 1)) = 0
        _DirectionStrength("Direction Strength", Range(0, 1)) = 0
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

            TEXTURE_SAMPLER_X(_Source);

            float _Radius;
            float _Iterations;
            float _Softness;

            float _DirectionAngle;
            float _DirectionStrength;

            // ------------------------------------------------------------
            float SampleMask(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).r;
            }

            float3 BaseDirection()
            {
                float a = _DirectionAngle * 6.2831853;
                return float3(cos(a), sin(a),0);
            }

            // Directional weight (bias growth toward a direction)
            float DirectionWeight(float3 dir, float3 offset)
            {
                float2 o = normalize(offset);
                float d = max(0.0, dot(dir, o));
                return lerp(1.0, d, _DirectionStrength);
            }

            // Soft falloff curve (Substance-like)
            float SoftCurve(float x)
            {
                return pow(x, lerp(4.0, 1.0, _Softness));
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv     = i.localTexcoord.xyz;
                float3 texel  = float3(0.01,0.01,0.01);

                float3 dir = BaseDirection();

                float value = SampleMask(uv, i.direction);

                // Iterative dilation
                for (int it = 0; it < _Iterations; it++)
                {
                    float best = value;

                    for (int y = -_Radius; y <= _Radius; y++)
                    for (int x = -_Radius; x <= _Radius; x++)
                    {
                        float3 offset = float3(x, y,0);
                        float dist = length(offset);

                        if (dist > _Radius)
                            continue;

                        float3 suv = uv + offset * texel;
                        float s = SampleMask(suv, i.direction);

                        // Directional bias
                        float wDir = DirectionWeight(dir, offset);

                        // Softness falloff
                        float wSoft = SoftCurve(1.0 - dist / _Radius);

                        float w = wDir * wSoft;

                        best = max(best, s * w);
                    }

                    value = best;
                } 

                return float4(value.xxx, 1);
            }

            ENDHLSL
        }
    }
}