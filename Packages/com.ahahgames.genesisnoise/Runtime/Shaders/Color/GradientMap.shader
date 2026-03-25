Shader "Hidden/Genesis/GradientMap"
{
    Properties
    {
        [Tooltip(Grayscale source input)]
        _Source("Source", 2D) = "white" {}

        [Tooltip(Number of active gradient keys)]
        _KeyCount("Key Count", Int) = 2

        [Tooltip(Gradient positions 0 to 1)]
        _KeyPositions("Positions", Vector) = (0, 0.33, 0.66, 1)

        [Tooltip(Gradient colors for each key)][HDR]
        _KeyColors0("Color 0", Color) = (0,0,0,1)
        [HDR]_KeyColors1("Color 1", Color) = (1,1,1,1)
        [HDR]_KeyColors2("Color 2", Color) = (1,0,0,1)
        [HDR]_KeyColors3("Color 3", Color) = (0,1,0,1)
        [HDR]_KeyColors4("Color 4", Color) = (0,0,1,1)
        [HDR]_KeyColors5("Color 5", Color) = (1,1,0,1)
        [HDR]_KeyColors6("Color 6", Color) = (1,0,1,1)
        [HDR]_KeyColors7("Color 7", Color) = (0,1,1,1)
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

            int _KeyCount;
            float4 _KeyPositions;

            float4 _KeyColors0;
            float4 _KeyColors1;
            float4 _KeyColors2;
            float4 _KeyColors3;
            float4 _KeyColors4;
            float4 _KeyColors5;
            float4 _KeyColors6;
            float4 _KeyColors7;

            float4 GetKeyColor(int i)
            {
                switch(i)
                {
                    case 0: return _KeyColors0;
                    case 1: return _KeyColors1;
                    case 2: return _KeyColors2;
                    case 3: return _KeyColors3;
                    case 4: return _KeyColors4;
                    case 5: return _KeyColors5;
                    case 6: return _KeyColors6;
                    case 7: return _KeyColors7;
                }
                return 0;
            }

            float4 mixture(v2f_customrendertexture IN) : SV_Target
            {
                float3 uv = IN.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float gray = tex2D(_Source, uv.xy).r;
                gray = saturate(gray);

                // Find the two keys surrounding the grayscale value
                int idxA = 0;
                int idxB = 0;

                for (int i = 0; i < _KeyCount - 1; i++)
                {
                    float pa = _KeyPositions[i];
                    float pb = _KeyPositions[i + 1];

                    if (gray >= pa && gray <= pb)
                    {
                        idxA = i;
                        idxB = i + 1;
                        break;
                    }
                }

                float posA = _KeyPositions[idxA];
                float posB = _KeyPositions[idxB];

                float t = (gray - posA) / max(1e-5, (posB - posA));
                t = saturate(t);

                float4 colA = GetKeyColor(idxA);
                float4 colB = GetKeyColor(idxB);

                return lerp(colA, colB, t);
            }

            ENDHLSL
        }
    } 
}
