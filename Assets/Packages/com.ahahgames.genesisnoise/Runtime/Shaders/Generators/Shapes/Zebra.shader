Shader "Hidden/Genesis/Zebra"
{
    Properties
    {
        [Tooltip(Global tiling)] _Scale("Scale", Vector) = (4,4,0,0)
        [Tooltip(Rotation in radians)] _Angle("Angle", Range(0,6.283)) = 0.0

        [Tooltip(Number of stripe cycles)] _Frequency("Frequency", Range(1,24)) = 9
        [Tooltip(Width of dark stripes)] _StripeWidth("Stripe Width", Range(0.05,0.95)) = 0.45
        [Tooltip(Amount of stripe waviness)] _Waviness("Waviness", Range(0,1)) = 0.55
        [Tooltip(Amount of branching and pinching)] _Branching("Branching", Range(0,1)) = 0.35

        [Tooltip(Soft edge)] _Softness("Softness", Range(0,0.25)) = 0.035
        [Tooltip(Fur-like tonal grain)] _FurDetail("Fur Detail", Range(0,1)) = 0.35
        [Tooltip(Contrast shaping)] _Contrast("Contrast", Range(0.5,4)) = 1.15

        [Tooltip(Random variation amount)] _Randomness("Randomness", Range(0,1)) = 0.35
        [Tooltip(Random seed)] _Seed("Seed", int) = 331
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

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment

            float2 _Scale;
            float  _Angle;

            float  _Frequency;
            float  _StripeWidth;
            float  _Waviness;
            float  _Branching;

            float  _Softness;
            float  _FurDetail;
            float  _Contrast;

            float  _Randomness;
            float  _Seed;

            float hash11(float n)
            {
                n += _Seed * 17.0;
                return frac(sin(n * 127.1) * 43758.5453);
            }

            float2 rotate2D(float2 p, float a)
            {
                float s = sin(a);
                float c = cos(a);
                return float2(c * p.x - s * p.y, s * p.x + c * p.y);
            }

            float stripePulse(float x, float width, float softness)
            {
                float d = abs(frac(x) - 0.5);
                float edge = width * 0.5;
                return smoothstep(edge + softness, edge - softness, d);
            }

            float zebra(float2 uv)
            {
                float2 p = (uv - 0.5) * _Scale;
                p = rotate2D(p, _Angle);

                float2 cell = floor(p);
                float randomValue = hash11(cell.x + cell.y * 31.0);
                float variation = (randomValue - 0.5) * _Randomness;

                float frequency = max(1.0, _Frequency + variation * 2.0);
                float softness = max(_Softness, 0.0001);

                float waveA = sin((p.y * 1.35 + _Seed * 0.011) * 6.28318);
                float waveB = sin((p.y * 2.70 + p.x * 0.35 + _Seed * 0.017) * 6.28318);
                float waveC = sin((p.y * 5.10 - p.x * 0.70 + _Seed * 0.023) * 6.28318);
                float warp = (waveA * 0.18 + waveB * 0.09 + waveC * 0.045) * _Waviness;

                float branchField = sin((p.y * 2.0 + _Seed * 0.031) * 6.28318);
                float pinch = _Branching * branchField * sin((p.x * 1.35 + p.y * 0.55) * 6.28318) * 0.22;
                float taperedWidth = saturate(_StripeWidth + pinch + variation * 0.10);

                float stripeCoord = p.x * frequency + warp * frequency;
                float baseStripe = stripePulse(stripeCoord, taperedWidth, softness * frequency);

                float splitCoord = stripeCoord + sin(p.y * 6.28318 * 1.8 + _Seed) * 0.32;
                float splitStripe = stripePulse(splitCoord, taperedWidth * 0.46, softness * frequency);
                float splitGate = smoothstep(0.15, 0.95, abs(branchField)) * _Branching;

                float stripe = max(baseStripe, splitStripe * splitGate);

                float ragged = 0.5 + 0.5 * sin((p.y * 11.0 + p.x * 2.3 + _Seed) * 6.28318);
                stripe *= lerp(1.0, 0.82 + 0.18 * ragged, _Randomness);

                float fur = 0.82 + 0.18 * (0.5 + 0.5 * sin((p.x * 12.0 + p.y * 3.0 + _Seed) * 6.28318));
                float value = stripe * lerp(1.0, fur, _FurDetail);
                return pow(saturate(value), _Contrast);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float v = zebra(i.localTexcoord.xy);
                return float4(v, v, v, 1.0);
            }

            ENDHLSL
        }
    }
}
