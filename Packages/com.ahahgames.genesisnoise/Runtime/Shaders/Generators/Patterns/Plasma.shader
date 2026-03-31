Shader "Hidden/Genesis/Plasma"
{
    Properties
    {
        [Tooltip(Global scale of the plasma pattern)]
        _Scale("Scale", Float) = 4.0

        [Tooltip(Turbulence strength)]
        _Turbulence("Turbulence", Float) = 1.0

        [Tooltip(Interference strength)]
        _Interference("Interference", Float) = 1.0

        [Tooltip(Brightness)]
        _Brightness("Brightness", Float) = 1.0

        [Tooltip(Contrast)]
        _Contrast("Contrast", Float) = 1.0

        [Tooltip(Random seed)]
        _Seed("Seed", Float) = 1.0
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

            float _Scale;
            float _Turbulence;
            float _Interference;
            float _Brightness;
            float _Contrast;
            float _Seed;

            // ---------------------------------------------------------
            // Hash
            // ---------------------------------------------------------
            float hash(float2 p)
            {
                p = frac(p * 0.3183099 + _Seed * 0.1234);
                p *= 17.0;
                return frac(p.x * p.y * (p.x + p.y));
            }

            // ---------------------------------------------------------
            // Value Noise
            // ---------------------------------------------------------
            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                float a = hash(i);
                float b = hash(i + float2(1,0));
                float c = hash(i + float2(0,1));
                float d = hash(i + float2(1,1));

                float2 u = f*f*(3.0 - 2.0*f);

                return lerp(lerp(a,b,u.x), lerp(c,d,u.x), u.y);
            }

            // ---------------------------------------------------------
            // FBM
            // ---------------------------------------------------------
            float fbm(float2 p)
            {
                float v = 0.0;
                float a = 0.5;

                for (int i = 0; i < 5; i++)
                {
                    v += noise(p) * a;
                    p *= 2.0;
                    a *= 0.5;
                }

                return v;
            }

            // ---------------------------------------------------------
            // Plasma Core
            // ---------------------------------------------------------
            float plasma(float2 uv)
            {
                float2 p = uv * _Scale;

                // Base FBM
                float f1 = fbm(p);

                // Phase-shifted FBM
                float f2 = fbm(p + float2(13.37, 7.91));

                // Interference pattern
                float inter = sin((f1 - f2) * 6.2831853 * _Interference);

                // Turbulence
                float turb = fbm(p * 2.0 + inter * _Turbulence);

                // Combine
                float v = f1 * 0.5 + f2 * 0.5 + inter * 0.35 + turb * 0.25;

                // Normalize
                v = saturate(v);

                // Brightness & contrast
                v = pow(v * _Brightness, _Contrast);

                return v;
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

                float v = plasma(uv.xy);

                return float4(v, v, v, 1.0);
            } 

            ENDHLSL
        }
    }
}
