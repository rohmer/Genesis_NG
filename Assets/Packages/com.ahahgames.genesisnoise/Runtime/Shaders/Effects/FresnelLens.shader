Shader "Hidden/Genesis/FresnelLens"
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
        [Tooltip(Radius of the lens aperture)] _Radius("Radius", Range(0.05,1.5)) = 0.5
        [Tooltip(Number of concentric Fresnel grooves)] _Grooves("Grooves", Range(2,128)) = 48
        [Tooltip(Refraction strength)] _Strength("Strength", Range(-1,1)) = 0.18

        [Tooltip(Focus power across the lens)] _Focus("Focus", Range(0,4)) = 1.0
        [Tooltip(Chromatic channel separation)] _Chromatic("Chromatic", Range(0,1)) = 0.18
        [Tooltip(Ring highlight strength)] _RingHighlight("Ring Highlight", Range(0,2)) = 0.55
        [Tooltip(Blend between original and refracted image)] _Mix("Mix", Range(0,1)) = 1.0

        [Tooltip(Feather at the lens edge)] _EdgeFeather("Edge Feather", Range(0,0.5)) = 0.12
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
            float _Radius;
            float _Grooves;
            float _Strength;
            float _Focus;
            float _Chromatic;
            float _RingHighlight;
            float _Mix;
            float _EdgeFeather;
            float _Scale;
            int _Seed;

            float ridgeWave(float x)
            {
                float f = frac(x);
                return 1.0 - abs(f * 2.0 - 1.0);
            }

            float grooveSlope(float x)
            {
                float f = frac(x);
                return f < 0.5 ? 1.0 : -1.0;
            }

            float4 SampleSource(float2 uv, float3 direction)
            {
                return SAMPLE_X(_Source, float3(frac(uv), 0.0), direction);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uvs = GetNoiseUVs(
                    i,
                    SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction),
                    _Seed
                );

                float2 uv = (uvs.xy - 0.5) * _Scale + 0.5;
                float2 toCenter = uv - _Center;
                float dist = length(toCenter);
                float2 dir = dist > 0.0001 ? toCenter / dist : float2(0.0, 1.0);

                float normalizedRadius = dist / max(_Radius, 0.0001);
                float aperture = 1.0 - smoothstep(1.0 - _EdgeFeather, 1.0, normalizedRadius);

                float grooveCoord = normalizedRadius * _Grooves;
                float groove = ridgeWave(grooveCoord);
                float slope = grooveSlope(grooveCoord);
                float focusFalloff = pow(saturate(1.0 - normalizedRadius), _Focus);
                float refractAmount = _Strength * aperture * (0.35 + 0.65 * focusFalloff) * (0.35 + 0.65 * groove) * slope;

                float2 refractedUV = uv - dir * refractAmount;
                float chroma = _Chromatic * abs(refractAmount) * 0.75;

                float4 original = SampleSource(uv, i.direction);
                float r = SampleSource(refractedUV - dir * chroma, i.direction).r;
                float g = SampleSource(refractedUV, i.direction).g;
                float b = SampleSource(refractedUV + dir * chroma, i.direction).b;
                float a = SampleSource(refractedUV, i.direction).a;

                float highlight = pow(saturate(groove), 6.0) * _RingHighlight * aperture;
                float4 refracted = float4(saturate(float3(r, g, b) + highlight), a);
                float4 mixed = lerp(original, refracted, _Mix * aperture);

                return mixed;
            }

            ENDHLSL
        }
    }
}
