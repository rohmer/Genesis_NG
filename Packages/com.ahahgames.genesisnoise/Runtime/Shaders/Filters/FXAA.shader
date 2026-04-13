Shader "Hidden/Genesis/FXAA"
{
    Properties
    {
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        _ContrastThreshold("Contrast Threshold", Range(0.01, 0.333)) = 0.063
        _RelativeThreshold("Relative Threshold", Range(0.01, 1.0)) = 0.125
        _SubpixelBlending("Subpixel Blending", Range(0.0, 1.0)) = 0.75
        _EdgeSpan("Edge Span", Range(1.0, 16.0)) = 8.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET_API
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma target 3.0
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_Source);

            float _ContrastThreshold;
            float _RelativeThreshold;
            float _SubpixelBlending;
            float _EdgeSpan;

            float Luma(float3 color)
            {
                return dot(color, float3(0.299, 0.587, 0.114));
            }

            float2 GetTexelSizeXY()
            {
                return rcp(float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight));
            }

            float4 SampleSource(v2f_customrendertexture i, float2 offset)
            {
#if defined(CRT_CUBE)
                float2 faceUV = i.globalTexcoord.xy + offset;
                float3 dir = ComputeCubemapDirectionFromUV(faceUV, int(_CustomRenderTextureCubeFace));
                return SAMPLE_X(_Source, float3(faceUV, 0.0), dir);
#else
                float3 uvw = i.localTexcoord.xyz + float3(offset, 0.0);
                return SAMPLE_X(_Source, uvw, i.direction);
#endif
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 texel = GetTexelSizeXY();

                float4 m  = SampleSource(i, float2( 0.0,  0.0));
                float4 n  = SampleSource(i, float2( 0.0, -1.0) * texel);
                float4 e  = SampleSource(i, float2( 1.0,  0.0) * texel);
                float4 s  = SampleSource(i, float2( 0.0,  1.0) * texel);
                float4 w  = SampleSource(i, float2(-1.0,  0.0) * texel);
                float4 nw = SampleSource(i, float2(-1.0, -1.0) * texel);
                float4 ne = SampleSource(i, float2( 1.0, -1.0) * texel);
                float4 sw = SampleSource(i, float2(-1.0,  1.0) * texel);
                float4 se = SampleSource(i, float2( 1.0,  1.0) * texel);

                float lumaM  = Luma(m.rgb);
                float lumaN  = Luma(n.rgb);
                float lumaE  = Luma(e.rgb);
                float lumaS  = Luma(s.rgb);
                float lumaW  = Luma(w.rgb);
                float lumaNW = Luma(nw.rgb);
                float lumaNE = Luma(ne.rgb);
                float lumaSW = Luma(sw.rgb);
                float lumaSE = Luma(se.rgb);

                float lumaMin = min(lumaM, min(min(min(lumaN, lumaE), min(lumaS, lumaW)), min(min(lumaNW, lumaNE), min(lumaSW, lumaSE))));
                float lumaMax = max(lumaM, max(max(max(lumaN, lumaE), max(lumaS, lumaW)), max(max(lumaNW, lumaNE), max(lumaSW, lumaSE))));
                float lumaRange = lumaMax - lumaMin;
                float threshold = max(_ContrastThreshold, lumaMax * _RelativeThreshold);

                if (lumaRange < threshold)
                    return m;

                float2 dir;
                dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
                dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));

                float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) * 0.03125, 1.0 / 128.0);
                float rcpDirMin = rcp(min(abs(dir.x), abs(dir.y)) + dirReduce);
                dir = clamp(dir * rcpDirMin, -_EdgeSpan, _EdgeSpan) * texel;

                float4 resultA = 0.5 * (
                    SampleSource(i, dir * (1.0 / 3.0 - 0.5)) +
                    SampleSource(i, dir * (2.0 / 3.0 - 0.5))
                );

                float4 resultB = resultA * 0.5 + 0.25 * (
                    SampleSource(i, dir * -0.5) +
                    SampleSource(i, dir *  0.5)
                );

                float lumaB = Luma(resultB.rgb);

                if (lumaB < lumaMin || lumaB > lumaMax)
                    return resultA;

                return lerp(resultA, resultB, _SubpixelBlending);
            }

            ENDHLSL
        }
    }
}
