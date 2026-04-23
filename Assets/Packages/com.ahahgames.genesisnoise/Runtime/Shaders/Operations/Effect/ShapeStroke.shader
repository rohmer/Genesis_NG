Shader "Hidden/Genesis/ShapeStroke"
{
    Properties
    {
        // Binary shape mask (0–1)
        [InlineTexture]_Shape_2D("Shape", 2D) = "black" {}
        [InlineTexture]_Shape_3D("Shape", 3D) = "black" {}
        [InlineTexture]_Shape_Cube("Shape", Cube) = "black" {}

        _Thickness("Stroke Thickness", Range(1, 64)) = 8
        _Softness("Softness", Range(0, 1)) = 0.35

        // 0 = Outer, 1 = Inner, 2 = Both
        _Mode("Stroke Mode", Int) = 0

        _StrokeColor("Stroke Color", Color) = (1,1,1,1)
        _Opacity("Opacity", Range(0, 1)) = 1.0
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

            TEXTURE_SAMPLER_X(_Shape);

            float _Thickness;
            float _Softness;
            int   _Mode;
            float4 _StrokeColor;
            float _Opacity;

            float SampleShape(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Shape, uv, dir).r;
            }

            // Soft falloff curve (Substance-like)
            float Falloff(float x)
            {
                float smooth = smoothstep(0, 1, x);
                float sharp  = pow(x, 0.35);
                return lerp(smooth, sharp, _Softness);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv    = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                float shape = SampleShape(uv, i.direction);

                int R = (int)_Thickness;

                float stroke = 0.0;

                // Scan a radius around the pixel
                for (int y = -R; y <= R; y++)
                for (int x = -R; x <= R; x++)
                {
                    float2 offset = float2(x, y);
                    float dist = length(offset);

                    if (dist > R)
                        continue;

                    float2 suv = uv + offset * texel;
                    float s = SampleShape(float3(suv,0), i.direction);

                    // Outer stroke: pixel is outside, neighbor is inside
                    if (_Mode == 0 || _Mode == 2)
                    {
                        if (shape < 0.5 && s > 0.5)
                        {
                            float t = dist / R;
                            stroke = max(stroke, Falloff(1.0 - t));
                        }
                    }

                    // Inner stroke: pixel is inside, neighbor is outside
                    if (_Mode == 1 || _Mode == 2)
                    {
                        if (shape > 0.5 && s < 0.5)
                        {
                            float t = dist / R;
                            stroke = max(stroke, Falloff(1.0 - t));
                        }
                    }
                }

                stroke *= _Opacity;

                float3 col = _StrokeColor.rgb * stroke;

                return float4(col, stroke);
            }
             
            ENDHLSL
        }
    }
}