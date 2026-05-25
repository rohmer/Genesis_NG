Shader "Hidden/Genesis/PincushionLensDistortion"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _Source_2D("Input Texture", 2D) = "white" {}
        [InlineTexture(HideInNodeInspector)] _Source_3D("Input Texture", 3D) = "white" {}
        [InlineTexture(HideInNodeInspector)] _Source_Cube("Input Texture", Cube) = "white" {}

        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
        [InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}

        [Tooltip(Center of the lens)] _Center("Center", Vector) = (0.5,0.5,0,0)
        [Tooltip(Pincushion distortion amount)] _Distortion("Distortion", Range(0,1)) = 0.35
        [Tooltip(Higher order inward edge pull)] _CubicDistortion("Cubic Distortion", Range(0,1)) = 0.12
        [Tooltip(Zoom compensation after distortion)] _Zoom("Zoom", Range(0.25,2.0)) = 1.0

        [Tooltip(Chromatic channel separation)] _Chromatic("Chromatic", Range(0,1)) = 0.14
        [Tooltip(Edge fade for stretched borders)] _EdgeFade("Edge Fade", Range(0,1)) = 0.2
        [Tooltip(Blend between original and distorted image)] _Mix("Mix", Range(0,1)) = 1.0
        [Tooltip(Input UV scale)] _Scale("Scale", Float) = 1.0

        [Tooltip(Random seed)] _Seed("Seed", Int) = 42
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET_API
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            TEXTURE_SAMPLER_X(_Source);
            TEXTURE_SAMPLER_X(_UV);

            float2 _Center;
            float _Distortion;
            float _CubicDistortion;
            float _Zoom;
            float _Chromatic;
            float _EdgeFade;
            float _Mix;
            float _Scale;
            int _Seed;

            float2 DistortUV(float2 uv)
            {
                float2 p = (uv - _Center) / max(_Zoom, 0.0001);
                float r2 = dot(p, p);
                float factor = 1.0 - _Distortion * r2 - _CubicDistortion * r2 * r2;
                return _Center + p * factor;
            }

            float4 SampleSource(float2 uv, float3 direction)
            {
                return SAMPLE_X(_Source, float3(frac(uv), 0.0), direction);
            }

            float EdgeMask(float2 uv)
            {
                float2 edgeDistance = min(uv, 1.0 - uv);
                float edge = min(edgeDistance.x, edgeDistance.y);
                return smoothstep(0.0, max(_EdgeFade, 0.0001), edge);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uvs = GetNoiseUVs(
                    i,
                    SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction),
                    _Seed
                );

                float2 uv = (uvs.xy - 0.5) * _Scale + 0.5;
                float2 distortedUV = DistortUV(uv);

                float2 radial = distortedUV - _Center;
                float chroma = _Chromatic * length(radial) * 0.025;
                float2 chromaOffset = normalize(radial + 0.0001) * chroma;

                float4 original = SampleSource(uv, i.direction);
                float r = SampleSource(distortedUV + chromaOffset, i.direction).r;
                float g = SampleSource(distortedUV, i.direction).g;
                float b = SampleSource(distortedUV - chromaOffset, i.direction).b;
                float a = SampleSource(distortedUV, i.direction).a;

                float mask = lerp(1.0, EdgeMask(distortedUV), _EdgeFade);
                float4 distorted = float4(float3(r, g, b) * mask, a);
                return lerp(original, distorted, _Mix);
            }

            ENDHLSL
        }
    }
}
