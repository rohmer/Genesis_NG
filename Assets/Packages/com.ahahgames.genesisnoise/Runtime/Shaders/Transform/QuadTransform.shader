Shader "Hidden/Genesis/QuadTransform"
{
    Properties
    {
        // Source texture
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Quad corners in UV space
        _P0("Corner 0 (Bottom Left)",  Vector) = (0.0, 0.0, 0, 0)
        _P1("Corner 1 (Bottom Right)", Vector) = (1.0, 0.0, 0, 0)
        _P2("Corner 2 (Top Right)",    Vector) = (1.0, 1.0, 0, 0)
        _P3("Corner 3 (Top Left)",     Vector) = (0.0, 1.0, 0, 0)

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
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_Source);

            float4 _P0;
            float4 _P1;
            float4 _P2;
            float4 _P3;
            int _Mode;

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float3 WrapOrClamp(float3 uv)
            {
                return (_Mode == 0) ? frac(uv) : saturate(uv);
            }

            // Bilinear quad mapping
            float3 QuadMap(float2 uv)
            {
                float u = uv.x;
                float v = uv.y;

                float2 p0 = _P0.xy;
                float2 p1 = _P1.xy;
                float2 p2 = _P2.xy;
                float2 p3 = _P3.xy;

                // Bilinear interpolation:
                // P(u,v) = (1-u)(1-v)P0 + u(1-v)P1 + u v P2 + (1-u)v P3
                float2 a = lerp(p0, p1, u);
                float2 b = lerp(p3, p2, u);
                return float3(lerp(a, b, v),0);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                // Map UV into the quad
                float3 warpedUV = QuadMap(uv);

                // Wrap or clamp
                warpedUV = WrapOrClamp(warpedUV);

                float3 col = SampleSource(warpedUV, i.direction);

                return float4(col, 1);
            }

            ENDHLSL 
        }
    }
}