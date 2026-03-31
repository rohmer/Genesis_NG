Shader "Hidden/Genesis/DirtGradient"
{
    Properties
    {
        // Global
        _Seed("Seed", Float) = 0.0
        _Scale("Base Scale", Float) = 3.0
        _Vignette("Vignette Strength", Range(0,1)) = 0.12
        [Enum(None,0, RawNoise,1, Mask,2, Inverted,3)] _Debug("Debug", Float) = 0

        // Vertical falloff
        _VerticalBias("Vertical Bias", Range(-1,1)) = -0.35
        _VerticalCurve("Vertical Curve Exponent", Range(0.1,5.0)) = 1.6
        _VerticalOffset("Vertical Offset", Range(-1,1)) = 0.0

        // Far layer (background, soft)
        _FarScale("Far Scale", Float) = 2.0
        _FarTurbulence("Far Turbulence", Range(0,1)) = 0.25
        _FarTurbulenceScale("Far Turb Scale", Float) = 3.0
        _FarWeight("Far Weight", Range(0,1)) = 0.6

        // Near layer (foreground, detailed)
        _NearScale("Near Scale", Float) = 8.0
        _NearTurbulence("Near Turbulence", Range(0,1)) = 0.45
        _NearTurbulenceScale("Near Turb Scale", Float) = 6.0
        _NearWeight("Near Weight", Range(0,1)) = 0.6

        // Layer blend control
        [Enum(Add,0,Multiply,1,Max,2)]_LayerBlend("Layer Blend Mode", int) = 0 // 0 = Add, 1 = Multiply, 2 = Max
    }
    SubShader { Pass {
        HLSLPROGRAM
        #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
        #pragma vertex CustomRenderTextureVertexShader
        #pragma fragment GenesisFragment
        #pragma target 3.0

        float _Seed;
        float _Scale;
        float _Vignette;
        float _Debug;

        float _VerticalBias;
        float _VerticalCurve;
        float _VerticalOffset;

        float _FarScale;
        float _FarTurbulence;
        float _FarTurbulenceScale;
        float _FarWeight;

        float _NearScale;
        float _NearTurbulence;
        float _NearTurbulenceScale;
        float _NearWeight;

        float _LayerBlend;

        // cheap hash / value noise
        float hash11(float n){ return frac(sin(n*127.1 + _Seed)*43758.5453); }
        float noise2(float2 p){
            float2 i = floor(p);
            float2 f = frac(p);
            float a = hash11(i.x + i.y*57.0);
            float b = hash11(i.x+1.0 + i.y*57.0);
            float c = hash11(i.x + (i.y+1.0)*57.0);
            float d = hash11(i.x+1.0 + (i.y+1.0)*57.0);
            float2 u = f*f*(3.0-2.0*f);
            return lerp(lerp(a,b,u.x), lerp(c,d,u.x), u.y);
        }

        // fbm
        float fbm(float2 p, int octaves)
        {
            float v=0.0; float a=0.5; float2 shift = float2(100,100);
            for(int i=0;i<octaves;i++){
                v += a*noise2(p);
                p = p*2.0 + shift;
                a *= 0.5;
            }
            return v;
        }

        // low-cost domain warp using fbm
        float2 domainWarp(float2 p, float strength, float scale)
        {
            float qx = fbm(p * scale, 3);
            float qy = fbm((p + 5.2) * scale, 3);
            return p + (float2(qx,qy) - 0.5) * strength;
        }

        // non-linear vertical falloff function
        float verticalFalloff(float v)
        {
            // remap v so 0 = top, 1 = bottom; apply bias and offset
            float t = saturate(v + _VerticalOffset + _VerticalBias);
            // apply exponent curve while preserving endpoints
            // use smoothstep-like shaping by mixing pow and linear to avoid extreme flattening
            float curved = pow(t, _VerticalCurve);
            // blend between linear and curved to keep artist control subtle
            float mixAmount = saturate((_VerticalCurve - 1.0) / 4.0); // small heuristic
            return lerp(t, curved, mixAmount);
        }

        // blend helper
        float blendLayers(float a, float b, float mode)
        {
            if (mode < 0.5) { // Add
                return saturate(a + b);
            } else if (mode < 1.5) { // Multiply
                return a * b;
            } else { // Max
                return max(a,b);
            }
        }

        float4 genesis(v2f_customrendertexture i) : SV_Target {
            float2 uv = i.localTexcoord.xy;

            // non-square compensation if aspect provided
            if (i.localTexcoord.z > 0.0) {
                float aspect = i.localTexcoord.z;
                uv.x = lerp(uv.x, uv.x * aspect, 1.0);
            }

            // vertical coordinate (0 top -> 1 bottom)
            float v = uv.y;

            // compute vertical falloff once
            float fall = verticalFalloff(v);

            // base coordinate with global scale and seed jitter
            float2 baseP = uv * _Scale + _Seed;

            // Far layer (soft background clouds)
            float2 farP = baseP * (_FarScale / max(1e-5,_Scale));
            if (_FarTurbulence > 0.001) farP = domainWarp(farP, _FarTurbulence, _FarTurbulenceScale);
            float farCloud = fbm(farP, 5);
            // soften far layer and bias by falloff so it primarily affects large-scale tonal shift
            farCloud = saturate(lerp(farCloud * 0.9 + 0.05, farCloud, 0.6) * (0.6 + 0.4 * fall));
            farCloud *= _FarWeight;

            // Near layer (detailed foreground clouds)
            float2 nearP = baseP * (_NearScale / max(1e-5,_Scale));
            if (_NearTurbulence > 0.001) nearP = domainWarp(nearP, _NearTurbulence, _NearTurbulenceScale);
            float nearCloud = fbm(nearP, 6);
            // accentuate details and let near layer be stronger where falloff is high (bottom)
            nearCloud = saturate(pow(nearCloud, 1.0) * (0.4 + 0.6 * fall));
            nearCloud *= _NearWeight;

            // combine layers with selected blend mode
            float combined = blendLayers(farCloud, nearCloud, _LayerBlend);

            // final tonal mapping: invert fall so top is darker, bottom lighter, modulated by combined clouds
            // base gradient (1 top -> 0 bottom) then modulate by combined cloud density
            float baseGradient = saturate(1.0 - v);
            float shaded = lerp(baseGradient, baseGradient * (1.0 - combined), combined);

            // apply a final gentle contrast curve using smoothstep
            shaded = smoothstep(0.02, 0.98, pow(saturate(shaded), 1.0));

            // subtle vignette
            float2 center = uv - 0.5;
            float dist = length(center);
            shaded *= lerp(1.0, 1.0 - _Vignette, smoothstep(0.4, 0.9, dist));

            // debug outputs
            if (_Debug == 1) return float4(farCloud, farCloud, farCloud, 1); // far layer
            if (_Debug == 2) return float4(nearCloud, nearCloud, nearCloud, 1); // near layer
            if (_Debug == 3) return float4(1.0 - shaded, 1.0 - shaded, 1.0 - shaded, 1); // inverted preview

            return float4(shaded, shaded, shaded, 1);
        }
        ENDHLSL
    }} 
    FallBack Off
}
