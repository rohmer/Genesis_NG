Shader "Hidden/Genesis/Distance"
{
    Properties
    {
        [Tooltip(Input mask (white is features))]
        _Source("Source", 2D) = "white" {}

        [Tooltip(Max distance in UV units)]
        _MaxDistance("Max Distance", Float) = 0.25

        [Tooltip(Threshold for binary mask)]
        _Threshold("Threshold", Float) = 0.5

        [Tooltip(Number of radial samples)]
        _Samples("Samples", Int) = 16

        [Tooltip(Invert output)][Enum(Off,0, On,1)]
        _Invert("Invert", Float) = 0

        [Tooltip(Optional mask texture)]
        _Mask("Mask", 2D) = "white" {}

        [Tooltip(How strongly the mask affects the distance)]
        _MaskStrength("Mask Strength", Float) = 1.0
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
            sampler2D _Mask;

            float _MaxDistance;
            float _Threshold;
            int _Samples;
            float _Invert;
            float _MaskStrength;

            // ---------------------------------------------------------
            float maskAt(float2 uv)
            {
                return tex2D(_Source, uv).r;
            }

            float distanceField(float2 uv)
            {
                float center = maskAt(uv);
                bool isFeature = center > _Threshold;

                float minDist = _MaxDistance;

                for (int i = 0; i < _Samples; i++)
                {
                    float t = (float)i / (float)_Samples;
                    float angle = t * 6.2831853;

                    float2 dir = float2(cos(angle), sin(angle));

                    const int STEPS = 32;
                    for (int s = 1; s <= STEPS; s++)
                    {
                        float d = (s / (float)STEPS) * _MaxDistance;
                        float2 p = uv + dir * d;

                        float m = maskAt(p);

                        if (!isFeature && m > _Threshold)
                        {
                            minDist = min(minDist, d);
                            break;
                        }

                        if (isFeature && m <= _Threshold)
                        {
                            minDist = min(minDist, d);
                            break;
                        }
                    }
                }

                float result = saturate(minDist / _MaxDistance);

                if (isFeature)
                    result = 0.0;

                if (_Invert > 0.5)
                    result = 1.0 - result;

                return result;
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i)
            {
                float3 uv = i.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float d = distanceField(uv.xy);

                // Mask sampling
                float m = tex2D(_Mask, uv.xy).r;

                // Apply mask (Substance-style)
                d *= lerp(1.0, m, _MaskStrength);

                return float4(d, d, d, 1.0);
            }

            ENDHLSL
        }
    }
}
