Shader "Hidden/Genesis/Warp"
{
    Properties
    {
        [Tooltip(Input texture)]
        _Source("Source", 2D) = "white" {}

        [Tooltip(Noise scale)]
        _NoiseScale("Noise Scale", Float) = 4.0

        [Tooltip(Warp intensity)]
        _Intensity("Intensity", Float) = 0.05

        [Tooltip(Random seed)]
        _Seed("Seed", Float) = 1.0

        [Tooltip(Optional mask)]
        _Mask("Mask", 2D) = "white" {}

        [Tooltip(Mask strength)]
        _MaskStrength("Mask Strength", Float) = 1.0
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
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            sampler2D _Source;
            sampler2D _Mask;

            float _NoiseScale;
            float _Intensity;
            float _Seed;
            float _MaskStrength;

            // ---------------------------------------
            // Hash → uniform random
            // ---------------------------------------
            float hash(float2 p)
            {
                p = frac(p * 0.3183099 + _Seed * 0.1234);
                p *= 17.0;
                return frac(p.x * p.y * (p.x + p.y));
            }

            // ---------------------------------------
            // Simple value noise (deterministic)
            // ---------------------------------------
            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                float a = hash(i);
                float b = hash(i + float2(1,0));
                float c = hash(i + float2(0,1));
                float d = hash(i + float2(1,1));

                float2 u = f * f * (3.0 - 2.0 * f);

                return lerp(lerp(a,b,u.x), lerp(c,d,u.x), u.y);
            }

            // ---------------------------------------
            // Warp UVs using scalar noise
            // ---------------------------------------
            float2 warpUV(float2 uv)
            {
                float2 p = uv * _NoiseScale;

                float n1 = noise(p);
                float n2 = noise(p + 37.2);

                float2 warp = float2(n1, n2) * _Intensity;

                return uv + warp;
            }

            // ---------------------------------------
            // Final CRT fragment
            // ---------------------------------------
            float4 genesis(v2f_customrendertexture i)
            {
                float3 uv = i.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float2 baseUV = uv.xy;

                // Mask
                float mask = tex2D(_Mask, baseUV).r;
                float maskFactor = lerp(1.0, mask, _MaskStrength);

                // Warp
                float2 warpedUV = lerp(baseUV, warpUV(baseUV), maskFactor);

                return tex2D(_Source, warpedUV);
            }

            ENDHLSL 
        }
    }
}
