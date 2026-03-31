Shader "Hidden/Genesis/TrapezoidTransform"
{
    Properties
    {
        // Source texture
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Width multipliers for top and bottom edges
        _TopWidth("Top Width", Range(0.1, 4)) = 1.0
        _BottomWidth("Bottom Width", Range(0.1, 4)) = 1.0

        // Horizontal offset of the top edge relative to bottom
        _TopOffset("Top Offset", Range(-1, 1)) = 0.0

        // Pivot for the transform
        _Pivot("Pivot", Vector) = (0.5, 0.5, 0.5, 0)

        // Wrap mode
        [Enum(Wrap,0,Clamp,1)]_Mode("Wrap Mode", Int) = 0 // 0 = wrap, 1 = clamp
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

            float _TopWidth;
            float _BottomWidth;
            float _TopOffset;
            float4 _Pivot;
            int _Mode;

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float3 WrapOrClamp(float3 uv)
            {
                return (_Mode == 0) ? frac(uv) : saturate(uv);
            }

            float3 ApplyTrapezoid(float3 uv)
            {
                float3 p = uv - _Pivot.xyz;

                // Vertical interpolation factor (0 = bottom, 1 = top)
                float t = saturate(p.y + 0.5);

                // Width at this vertical position
                float width = lerp(_BottomWidth, _TopWidth, t);

                // Horizontal offset at this vertical position
                float offset = _TopOffset * (t - 0.5);

                // Apply trapezoid scaling
                p.x = (p.x - offset) / width;

                return p + _Pivot.xyz;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                 
                // Apply trapezoid transform
                uv = ApplyTrapezoid(uv);

                // Wrap or clamp
                uv = WrapOrClamp(uv);

                float3 col = SampleSource(uv, i.direction);
                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}