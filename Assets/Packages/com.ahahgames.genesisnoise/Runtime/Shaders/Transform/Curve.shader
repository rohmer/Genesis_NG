Shader "Hidden/Genesis/Curve"
{
    Properties
    {
        [Tooltip(Input texture)]
        _Source("Source", 2D) = "white" {}

        [Tooltip(Number of curve keys)]
        _KeyCount("Key Count", Int) = 2

        [Tooltip(Key positions 0 to 1)]
        _KeyPositions("Positions", Vector) = (0, 0.5, 1, 1)

        [Tooltip(Key values 0 to 1)]
        _KeyValues("Values", Vector) = (0, 0.5, 1, 1)

        [Tooltip(Enable smooth interpolation)][Enum(Off,0, On,1)]
        _Smooth("Smooth", Float) = 0
    }
     
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            sampler2D _Source;

            int _KeyCount;
            float4 _KeyPositions;
            float4 _KeyValues;
            float _Smooth;

            float EvalCurve(float x)
            {
                x = saturate(x);

                int idxA = 0;
                int idxB = 0;

                // Find segment
                for (int i = 0; i < _KeyCount - 1; i++)
                {
                    float pa = _KeyPositions[i];
                    float pb = _KeyPositions[i + 1];

                    if (x >= pa && x <= pb)
                    {
                        idxA = i;
                        idxB = i + 1;
                        break;
                    }
                }

                float pa = _KeyPositions[idxA];
                float pb = _KeyPositions[idxB];
                float va = _KeyValues[idxA];
                float vb = _KeyValues[idxB];

                float t = (x - pa) / max(1e-5, (pb - pa));
                t = saturate(t);

                if (_Smooth > 0.5)
                    t = t * t * (3.0 - 2.0 * t); // smoothstep

                return lerp(va, vb, t);
            }

            float4 genesis(v2f_customrendertexture i)
            {
                float3 uv = i.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif
                 
                float4 src = tex2D(_Source, uv.xy);

                // Apply curve per channel
                float3 outColor = float3(
                    EvalCurve(src.r),
                    EvalCurve(src.g),
                    EvalCurve(src.b)
                );

                return float4(outColor, 1.0);
            }

            ENDHLSL
        }
    }
}
