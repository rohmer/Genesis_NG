Shader "Hidden/Genesis/DirectionalWarp"
{
    Properties
    {
        [Tooltip(Input texture to warp)]
        _Source("Source", 2D) = "white" {}

        [Tooltip(Warp intensity)]
        _Intensity("Intensity", Float) = 0.1

        [Tooltip(Warp direction angle in degrees)]
        _Angle("Angle", Float) = 0.0

        [Tooltip(Warp map (grayscale))]
        _WarpMap("Warp Map", 2D) = "gray" {}

        [Tooltip(Warp map scale)]
        _WarpScale("Warp Scale", Float) = 4.0

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
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            sampler2D _Source;
            sampler2D _WarpMap;
            sampler2D _Mask;

            float _Intensity;
            float _Angle;
            float _WarpScale;
            float _MaskStrength;

            // ---------------------------------------------------------
            // Rotate a vector by angle
            // ---------------------------------------------------------
            float2 dirFromAngle(float a)
            {
                float r = radians(a);
                return float2(cos(r), sin(r));
            }

            // ---------------------------------------------------------
            // Sample warp map (grayscale)
            // ---------------------------------------------------------
            float warpValue(float2 uv)
            {
                return tex2D(_WarpMap, uv).r;
            }

            // ---------------------------------------------------------
            // Directional warp UV computation
            // ---------------------------------------------------------
            float2 directionalWarpUV(float2 uv)
            {
                float2 dir = dirFromAngle(_Angle);

                // Sample warp map at scaled UV
                float w = warpValue(uv * _WarpScale);

                // Warp amount
                float2 offset = dir * (w * _Intensity);

                return uv + offset;
            }

            // ---------------------------------------------------------
            // Final CRT fragment
            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i)
            {
                float3 uv = i.localTexcoord.xyz;

                #ifdef CRT_CUBE
                    uv.z = 0.5;
                #endif

                float2 baseUV = uv.xy;

                // Mask sampling
                float m = tex2D(_Mask, baseUV).r;
                float maskFactor = lerp(1.0, m, _MaskStrength);

                // Compute warped UV
                float2 warpedUV = lerp(baseUV, directionalWarpUV(baseUV), maskFactor);

                // Sample source texture
                return tex2D(_Source, warpedUV);
            }

            ENDHLSL
        }
    }
}
