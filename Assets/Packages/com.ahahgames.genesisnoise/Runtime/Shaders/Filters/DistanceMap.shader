Shader "Hidden/Genesis/DistanceMap"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
        _Source("Source Texture", 2D) = "white" {}

        _Threshold("Feature Threshold (luma)", Range(0,1)) = 0.5
        _MaxRadius("Max Radius (texels)", Range(1,64)) = 32
        _Normalize("Normalize by MaxRadius (0/1)", Float) = 1
        _Signed("Signed Distance (0=unsigned,1=signed)", Float) = 0
        _InvertMask("Invert Mask (0/1)", Float) = 0
        _OutputMode("Output Mode (0=Gray,1=ColorRamp)", Float) = 0
       
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
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/NoiseUtils.hlsl"

            TEXTURE_SAMPLER_X(_UV);
            TEXTURE2D(_Source);
            SAMPLER(sampler_Source);

            float4 _TexelSize;
            float _Threshold;
            int _MaxRadius;
            float _Normalize;
            float _Signed;
            float _InvertMask;
            float _OutputMode;
            int _Seed;

            float Luma(float3 c) { return dot(c, float3(0.2126, 0.7152, 0.0722)); }

            // color ramp helper (simple HSV-like)
            float3 ColorRamp(float t)
            {
                // t in [0,1]
                float3 a = float3(0.0, 0.0, 0.0);
                float3 b = float3(0.0, 0.5, 1.0);
                float3 c = float3(1.0, 1.0, 0.0);
                if (t < 0.5) return lerp(a, b, t * 2.0);
                return lerp(b, c, (t - 0.5) * 2.0);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                _TexelSize= float4(0.01,0.01,0.01,0);
                // Resolve UVs using Genesis helper
                float3 raw = GetNoiseUVs(i, SAMPLE_X(_UV, i.localTexcoord.xyz, i.direction), _Seed);
                float2 uv = raw.xy;

                // center sample and mask
                float3 centerCol = SAMPLE_TEXTURE2D(_Source, sampler_Source, uv).rgb;
                float centerL = Luma(centerCol);
                float centerMask = step(_Threshold, centerL);
                if (_InvertMask > 0.5) centerMask = 1.0 - centerMask;

                // If signed distance requested, we will compute distance to nearest feature and nearest background
                float minFeatureDist = 1e6;
                float minBackgroundDist = 1e6;

                // Precompute texel offsets scale
                float2 texel = _TexelSize.xy;

                // clamp radius to reasonable integer
                int R = max(1, min(64, _MaxRadius));

                // iterate over circular neighborhood
                // Note: this is an O(R^2) brute-force search; keep R modest for real-time use
                for (int y = -R; y <= R; y++)
                {
                    // compute max x for circle to reduce samples
                    int maxX = (int)floor(sqrt((float)(R*R - y*y)));
                    for (int x = -maxX; x <= maxX; x++)
                    {
                        float2 offTex = float2(x, y);
                        float2 sampleUV = uv + offTex * texel;
                        // sample mask at neighbor
                        float3 sCol = SAMPLE_TEXTURE2D(_Source, sampler_Source, sampleUV).rgb;
                        float sL = Luma(sCol);
                        float sMask = step(_Threshold, sL);
                        if (_InvertMask > 0.5) sMask = 1.0 - sMask;

                        if (sMask > 0.5)
                        {
                            // neighbor is feature
                            float d = length(offTex);
                            if (d < minFeatureDist) minFeatureDist = d;
                        }
                        else
                        {
                            // neighbor is background
                            float d = length(offTex);
                            if (d < minBackgroundDist) minBackgroundDist = d;
                        }

                        // early exit: if both zero distances found
                        if (minFeatureDist <= 0.0 && minBackgroundDist <= 0.0) break;
                    }
                }

                // compute unsigned distance: distance to nearest feature
                float dist = minFeatureDist;

                // if signed requested: inside feature -> negative distance to background; outside -> positive distance to feature
                if (_Signed > 0.5)
                {
                    if (centerMask > 0.5)
                    {
                        // inside feature: distance to nearest background (negative)
                        dist = -minBackgroundDist;
                    }
                    else
                    {
                        // outside feature: distance to nearest feature (positive)
                        dist = minFeatureDist;
                    }
                }

                // clamp large values
                float maxD = (float)R;
                float nd = dist;
                if (_Normalize > 0.5)
                {
                    // normalize to [0,1] by radius; signed distances map to [-1,1]
                    if (_Signed > 0.5)
                        nd = saturate((dist / maxD) * 0.5 + 0.5); // map [-R,R] -> [0,1]
                    else
                        nd = saturate(dist / maxD);
                }
                else
                {
                    // output in pixels (clamped)
                    nd = clamp(dist, -maxD, maxD);
                }

                // output modes
                int mode = max(0, min(1, (int)(_OutputMode + 0.5)));
                if (mode == 0)
                {
                    // grayscale distance
                    if (_Normalize > 0.5)
                        return float4(nd, nd, nd, 1.0);
                    else
                    {
                        // encode signed pixel distance into R channel (bias to 0.5 if signed)
                        if (_Signed > 0.5)
                        {
                            float enc = nd / (2.0 * maxD) + 0.5;
                            return float4(enc, enc, enc, 1.0);
                        }
                        else
                        {
                            float enc = nd / maxD;
                            return float4(enc, enc, enc, 1.0);
                        }
                    }
                }
                else
                {
                    // color ramp visualization
                    float t = nd;
                    if (_Normalize < 0.5)
                    {
                        // map pixel distance to [0,1] for ramp
                        t = saturate((nd + maxD) / (2.0 * maxD));
                    }
                    float3 col = ColorRamp(t);
                    return float4(col, 1.0);
                }
            }

            ENDHLSL
        }
    }
}
