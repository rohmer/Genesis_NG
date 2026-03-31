Shader "Hidden/Genesis/DoGEdge"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        _Source("Source Texture", 2D) = "white" {}

        _Radius1("Radius 1 (texels)", Range(1,8)) = 1
        _Radius2("Radius 2 (texels)", Range(1,16)) = 3
        _Sigma1("Sigma 1", Range(0.1,8)) = 1.0
        _Sigma2("Sigma 2", Range(0.1,16)) = 2.5

        _EdgeThreshold("Edge Threshold", Range(0,1)) = 0.05
        _EdgeStrength("Edge Strength", Range(0,8)) = 4.0
        _Softness("Edge Softness", Range(0,1)) = 0.2

        _EdgeColor("Edge Color", Color) = (0,0,0,1)
        [Enum(Mask,0,Overlay,1,Edges,2)]_OutputMode("Output Mode", Float) = 1   // 0 = Mask, 1 = Overlay, 2 = Edges Only        
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment genesis
            
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV
            #pragma shader_feature _TILINGMODE_NONE _TILINGMODE_TILED
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"

            TEXTURE_SAMPLER_X(_UV);
            TEXTURE2D(_Source);
            SAMPLER(sampler_Source);

            float4 _TexelSize;
            float _Radius1;
            float _Radius2;
            float _Sigma1;
            float _Sigma2;
            float _EdgeThreshold;
            float _EdgeStrength;
            float _Softness;
            float4 _EdgeColor;
            float _OutputMode;
            int _Seed;

            // luminance
            float Luma(float3 c) { return dot(c, float3(0.2126, 0.7152, 0.0722)); }

            // Gaussian weight
            float gaussian(float x, float sigma)
            {
                float s = max(1e-4, sigma);
                return exp(-0.5 * (x * x) / (s * s));
            }

            // Separable blur approximation: sample along X and Y using symmetric offsets
            float3 SeparableBlur(v2f_customrendertexture i, float2 uv, int radius, float sigma)
            {
                // horizontal pass
                float3 sumH = float3(0,0,0);
                float wsumH = 0.0;
                for (int x = -radius; x <= radius; x++)
                {
                    float w = gaussian((float)x, sigma);
                    float2 off = float2(x, 0) * _TexelSize.xy;
                    sumH += SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + off).rgb * w;
                    wsumH += w;
                }
                float3 tmp = sumH / max(1e-6, wsumH);

                // vertical pass using the horizontally blurred sample by re-sampling source (approx)
                // for simplicity and to avoid extra texture reads we reapply separable weights directly
                float3 sumV = float3(0,0,0);
                float wsumV = 0.0;
                for (int y = -radius; y <= radius; y++)
                {
                    float w = gaussian((float)y, sigma);
                    float2 off = float2(0, y) * _TexelSize.xy;
                    sumV += SAMPLE_TEXTURE2D(_Source, sampler_Source, uv + off).rgb * w;
                    wsumV += w;
                }
                float3 result = sumV / max(1e-6, wsumV);

                // This two-pass approach approximates a separable Gaussian with 2*radius+1 samples per axis
                return result;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                _TexelSize = float4(0.01,0.01,0.01,0);
                // Resolve UVs using Genesis helper
                float3 raw = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);
                float2 uv = raw.xy;

                // read source
                float3 src = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv).rgb;

                // compute two blurred versions
                int r1 = max(1, (int)(_Radius1 + 0.5));
                int r2 = max(1, (int)(_Radius2 + 0.5));

                float3 blur1 = SeparableBlur(i, uv, r1, _Sigma1);
                float3 blur2 = SeparableBlur(i, uv, r2, _Sigma2);

                // Difference of Gaussians on luminance
                float l1 = Luma(blur1);
                float l2 = Luma(blur2);
                float dog = l1 - l2;

                // edge response: amplify, threshold, and soften
                float edgeRaw = abs(dog) * _EdgeStrength;
                float edge = saturate((edgeRaw - _EdgeThreshold) / max(1e-6, (1.0 - _EdgeThreshold)));
                // apply softness to smooth threshold transition
                edge = smoothstep(0.0, 1.0, lerp(edge, edge * (1.0 - _Softness) + _Softness * edgeRaw, 1.0));

                // final mask
                float mask = saturate(edge);

                int mode = max(0, min(2, (int)(_OutputMode + 0.5)));

                if (mode == 0)
                {
                    // Mask output as grayscale
                    return float4(mask, mask, mask, 1.0);
                }
                else if (mode == 1)
                {
                    // Overlay edges on source: dark or colored edges multiplied over source
                    float3 edgeCol = _EdgeColor.rgb;
                    float3 outColor = lerp(src, src * (1.0 - edge) + edgeCol * edge, 1.0);
                    return float4(saturate(outColor), 1.0);
                }
                else // mode == 2
                {
                    // Edges only: colored edges on transparent background
                    float3 edgeCol = _EdgeColor.rgb;
                    return float4(edgeCol * mask, 1.0);
                }
            }

            ENDHLSL
        }
    }
}
