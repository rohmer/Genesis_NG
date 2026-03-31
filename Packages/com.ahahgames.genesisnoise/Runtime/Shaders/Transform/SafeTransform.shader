Shader "Hidden/Genesis/SafeTransform"
{
    Properties
    {
        // Input texture
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Transform controls
        _Offset("Offset (X,Y)", Vector) = (0.0, 0.0, 0, 0)
        _Scale("Uniform Scale", Range(0.1, 4)) = 1.0
        _Rotation("Rotation (turns)", Range(0, 1)) = 0.0

        // Pivot for rotation/scale
        _Pivot("Pivot", Vector) = (0.5, 0.5, 0.5, 0)

        // Safe region clamp
        _SafeMin("Safe Min", Vector) = (0.0, 0.0, 0.0, 0)
        _SafeMax("Safe Max", Vector) = (1.0, 1.0, 1.0, 0)

        // Wrap mode: 0 = Wrap, 1 = Clamp
        [Enum(Wrap,0,Clamp,1)]_Mode("Wrap Mode", Int) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_Source);

            float4 _Offset;
            float _Scale;
            float _Rotation;
            float4 _Pivot;
            float4 _SafeMin;
            float4 _SafeMax;
            int _Mode;

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float3 WrapOrClamp(float3 uv)
            {
                return (_Mode == 0) ? frac(uv) : saturate(uv);
            }
             
            float3 Rotate(float2 p, float ang)
            {
                float s = sin(ang);
                float c = cos(ang);
                return float3(
                    p.x * c - p.y * s,
                    p.x * s + p.y * c,
                    0
                );
            }

            float3 SafeTransformUV(float3 uv)
            {
                float3 pivot = _Pivot.xyz;

                // Move to pivot
                uv -= pivot;

                // Apply uniform scale
                uv *= _Scale;

                // Apply rotation (turns → radians)
                float ang = _Rotation * 6.2831853;
                uv = Rotate(uv, ang);

                // Move back
                uv += pivot;

                // Apply offset
                uv += _Offset.xyz;

                // Clamp to safe region
                uv = clamp(uv, _SafeMin.xyz, _SafeMax.xyz);

                return uv;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                // Apply safe transform
                uv = SafeTransformUV(uv);

                // Wrap or clamp
                uv = WrapOrClamp(uv);

                float3 col = SampleSource(uv, i.direction);

                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}