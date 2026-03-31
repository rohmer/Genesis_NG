Shader "Hidden/Genesis/GrayscaleToHeight"
{
    Properties
    {
        [InlineTexture]_MainTex("Input Texture", 2D) = "white" {}
        _LumaWeights("Luminance Weights (R,G,B)", Vector) = (0.2126,0.7152,0.0722,0)
        _Blur("Blur Radius (0=off,1=3x3)", Range(0,1)) = 0.0
        _Contrast("Contrast", Range(0.1,4.0)) = 1.0
        _Exposure("Exposure", Range(-2,2)) = 0.0
        _Invert("Invert", Range(0,1)) = 0
        _MicroDetail("Micro Detail Strength", Range(0,1)) = 0.0
        _MicroFreq("Micro Frequency", Range(1,32)) = 8.0
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
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_MainTex);

            float4 _LumaWeights;
            float _Blur, _Contrast, _Exposure, _Invert;
            float _MicroDetail, _MicroFreq;

            float rand(float2 uv) { return frac(sin(dot(uv, float2(12.9898,78.233))) * 43758.5453); }
            float microNoise(float2 uv) { return (rand(uv * _MicroFreq) - 0.5) * _MicroDetail; }

            float luminance(float3 c)
            {
                return dot(c, _LumaWeights.rgb);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv3 = i.localTexcoord.xyz;
                float2 uv = i.localTexcoord.xy;

                // Base sample
                float3 col = SAMPLE_X(_MainTex, uv3, i.direction).rgb;
                float h = luminance(col);

                // Optional 3x3 box blur (cheap) controlled by _Blur
                if (_Blur > 0.001)
                {
                    float2 texel = float2(1.0/_ScreenParams.x, 1.0/_ScreenParams.y);
                    float sum = 0.0;
                    sum += SAMPLE_X(_MainTex, float3(uv + texel * float2(-1,-1), uv3.z), i.direction).r;
                    sum += SAMPLE_X(_MainTex, float3(uv + texel * float2( 0,-1), uv3.z), i.direction).r;
                    sum += SAMPLE_X(_MainTex, float3(uv + texel * float2( 1,-1), uv3.z), i.direction).r;
                    sum += SAMPLE_X(_MainTex, float3(uv + texel * float2(-1, 0), uv3.z), i.direction).r;
                    sum += h;
                    sum += SAMPLE_X(_MainTex, float3(uv + texel * float2( 1, 0), uv3.z), i.direction).r;
                    sum += SAMPLE_X(_MainTex, float3(uv + texel * float2(-1, 1), uv3.z), i.direction).r;
                    sum += SAMPLE_X(_MainTex, float3(uv + texel * float2( 0, 1), uv3.z), i.direction).r;
                    sum += SAMPLE_X(_MainTex, float3(uv + texel * float2( 1, 1), uv3.z), i.direction).r;
                    float blurred = sum / 9.0;
                    h = lerp(h, blurred, saturate(_Blur));
                }

                // Micro detail (adds small-scale variation)
                float micro = microNoise(uv);
                h = h + micro;

                // Exposure and contrast
                h = pow(saturate(h * exp2(_Exposure)), _Contrast);

                // Invert option
                h = lerp(h, 1.0 - h, step(0.5, _Invert));

                
                return float4(h, h, h, 1.0);
            }
            ENDHLSL
        }
    }
}
