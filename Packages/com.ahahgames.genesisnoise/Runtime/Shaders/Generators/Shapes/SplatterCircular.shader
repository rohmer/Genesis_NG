Shader "Hidden/Genesis/SplatterCircular"
{
    Properties
    {
        [InlineTexture]_MainTex("Input Texture", 2D) = "white" {}
        _Center("Circle Center (UV)", Vector) = (0.5,0.5,0,0)
        _Radius("Circle Radius", Range(0,1)) = 0.45
        _Feather("Circle Edge Feather", Range(0,0.5)) = 0.02

        _SplatterCount("Splatter Count", Range(1,32)) = 12
        _SplatterSize("Splatter Size (relative)", Range(0.01,0.5)) = 0.06
        _SplatterScale("Splatter Texture Scale", Range(0.1,4.0)) = 1.0
        _RadialJitter("Radial Jitter", Range(0,1)) = 0.25
        _AngularJitter("Angular Jitter", Range(0,1)) = 0.15
        _Seed("Random Seed", Float) = 0.0

        _EdgeFeather("Splat Edge Feather", Range(0.0,0.5)) = 0.02
        _Blend("Blend Original/Result", Range(0,1)) = 1.0
        _InvertMask("Invert Mask", Range(0,1)) = 0
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

            float4 _Center;
            float _Radius;
            float _Feather;

            float _SplatterCount;
            float _SplatterSize;
            float _SplatterScale;
            float _RadialJitter;
            float _AngularJitter;
            float _Seed;

            float _EdgeFeather;
            float _Blend;
            float _InvertMask;

            // Constants
            #define MAX_SPLATS 32

            // Simple hash / random generator (returns 0..1)
            float rand1(float2 p)
            {
                return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453123);
            }
            float rand1(float seed, int i)
            {
                return rand1(float2(seed + i * 12.9898, seed * 78.233 + i * 0.1234));
            }

            // 2D gaussian falloff for a splat (0..1)
            float splatFalloff(float2 d, float radius, float edge)
            {
                // distance normalized to radius
                float nd = length(d) / max(1e-6, radius);
                // soft edge using smoothstep
                float inner = 1.0 - saturate(edge / max(1e-6, radius));
                float mask = smoothstep(1.0, inner, nd);
                return mask;
            }

            // Main fragment (entrypoint must match pragma)
            float4 mixture(v2f_customrendertexture i) : SV_Target
            {
                float3 uv3 = i.localTexcoord.xyz;
                float2 uv = uv3.xy;

                // Base original color
                float4 colOrig = SAMPLE_X(_MainTex, uv3, i.direction);

                // Circle center and vector from center
                float2 center = _Center.xy;
                float2 p = uv - center;
                float r = length(p);

                // Circle mask (feathered)
                float inner = _Radius - _Feather;
                float circleMask = smoothstep(_Radius, inner, r); // 1 inside, 0 outside

                // Accumulate splat mask and color
                float accumMask = 0.0;
                float3 accumColor = float3(0,0,0);

                // Loop over splats (fixed upper bound for HLSL)
                int count = (int)clamp(_SplatterCount, 1.0, (float)MAX_SPLATS);
                for (int si = 0; si < MAX_SPLATS; ++si)
                {
                    if (si >= count) break;

                    // Generate deterministic random parameters per splat
                    float rndA = rand1(_Seed, si); // 0..1
                    float rndB = rand1(_Seed + 1.0, si);
                    float rndC = rand1(_Seed + 2.0, si);

                    // Base angle around circle
                    float angle = ( (float)si / max(1.0, (float)count) ) * 2.0 * PI;
                    // apply angular jitter
                    angle += (rndA - 0.5) * 2.0 * PI * _AngularJitter;

                    // base radial position (on circle) with jitter inward/outward
                    float radialOffset = _Radius * (1.0 + (rndB - 0.5) * 2.0 * _RadialJitter);
                    float2 splatCenter = center + float2(cos(angle), sin(angle)) * radialOffset;

                    // splat size with slight per-splat variation
                    float splatR = _SplatterSize * (0.75 + rndC * 0.5);

                    // compute local distance from current uv to splat center
                    float2 d = uv - splatCenter;

                    // splat mask (gaussian-like with feather)
                    float sMask = splatFalloff(d, splatR, _EdgeFeather);

                    if (sMask > 0.001)
                    {
                        // Sample input texture mapped into splat local space:
                        // Map local coordinates into [0,1] by centering and scaling, so each splat stamps a portion of the source.
                        float2 localUV = (d / max(1e-6, splatR)) * 0.5 + 0.5; // -1..1 -> 0..1
                        // Optionally scale the sampled texture inside splat
                        localUV = (localUV - 0.5) / _SplatterScale + 0.5;

                        // Preserve z for 3D/CUBE compatibility
                        float3 sampleCoord = float3(saturate(localUV), uv3.z);
                        float4 splatCol = SAMPLE_X(_MainTex, sampleCoord, i.direction);

                        // Accumulate weighted color and mask
                        accumColor += splatCol.rgb * sMask;
                        accumMask += sMask;
                    }
                }

                // Normalize accumulated color if any splats contributed
                float3 splatterColor = (accumMask > 0.0001) ? (accumColor / accumMask) : float3(0,0,0);

                // Combine circle mask with splatter mask so splats only appear inside circle
                float finalMask = circleMask * saturate(accumMask);

                // Optionally invert mask
                if (_InvertMask > 0.5)
                    finalMask = 1.0 - finalMask;

                // Blend between original and splatter result
                float3 outRGB = lerp(colOrig.rgb, splatterColor, finalMask * saturate(_Blend));

                return float4(outRGB, 1.0);
            }

            ENDHLSL
        }
    }
}
