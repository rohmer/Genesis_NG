Shader "Hidden/Genesis/Transform2D"
{
    Properties
    {
        [Tooltip(Input texture)]
        _Source("Source", 2D) = "white" {}

        [Tooltip(Translation in UV space)]
        _Offset("Offset", Vector) = (0,0,0,0)

        [Tooltip(Scale (X,Y))] 
        _Scale("Scale", Vector) = (1,1,0,0)

        [Tooltip(Rotation in degrees)]
        _Rotation("Rotation", Float) = 0

        [Tooltip(Pivot point (0 to 1))]
        _Pivot("Pivot", Vector) = (0.5,0.5,0,0)

        [Tooltip(0 Wrap, 1 Clamp)]
        [Enum(Wrap,0, Clamp,1)]_Mode("Mode", Float) = 0
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

            sampler2D _Source;

            float2 _Offset;
            float2 _Scale;
            float _Rotation;
            float2 _Pivot;
            float _Mode;

            float2 Transform2D(float2 uv)
            {
                // Move pivot to origin
                uv -= _Pivot;

                // Scale
                uv /= max(_Scale, float2(1e-5, 1e-5));

                // Rotation
                float r = radians(_Rotation);
                float cs = cos(r);
                float sn = sin(r);

                float2x2 rot = float2x2(cs, -sn, sn, cs);
                uv = mul(rot, uv);

                // Translate
                uv += _Pivot + _Offset;

                return uv;
            }

            float4 genesis(v2f_customrendertexture i)
            {
                float3 uv = i.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float2 tuv = Transform2D(uv.xy);

                // Wrap or clamp
                if (_Mode < 0.5)
                    tuv = frac(tuv);          // Wrap
                else
                    tuv = saturate(tuv);      // Clamp

                return tex2D(_Source, tuv);
            }

            ENDHLSL 
        }
    }
}
