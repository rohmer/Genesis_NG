Shader "Hidden/Genesis/Crystal1"
{
    Properties
    {
        // Global
        _Seed("Seed", Float) = 0.0
        _Scale("Base Scale", Float) = 6.0
        _NonSquare("Non Square Expansion", Float) = 0.0
        _Specular("Specular Intensity", Range(0,2)) = 1.0
        _Roughness("Roughness", Range(0.01,1.0)) = 0.25
        _Fresnel("Fresnel Strength", Range(0,2)) = 0.8
        [Enum(None,0, Macro,1, Mid,2, Micro,3, Normal,4, Shaded,5, Inverted,6)] _Debug("Debug", Float) = 0

        // Macro layer (large facets)
        _MacroScale("Macro Scale", Float) = 2.0
        _MacroDensity("Macro Density", Range(0.1,10.0)) = 1.8
        _MacroSharp("Macro Sharpness", Range(0.1,8.0)) = 2.8
        _MacroWeight("Macro Weight", Range(0,1)) = 0.7
        _MacroTurb("Macro Turbulence", Range(0,1)) = 0.12
        _MacroOrient("Macro Orientation", Range(-1,1)) = 0.0

        // Mid layer (medium facets)
        _MidScale("Mid Scale", Float) = 6.0
        _MidDensity("Mid Density", Range(0.1,20.0)) = 3.6
        _MidSharp("Mid Sharpness", Range(0.1,8.0)) = 2.2
        _MidWeight("Mid Weight", Range(0,1)) = 0.6
        _MidTurb("Mid Turbulence", Range(0,1)) = 0.28
        _MidOrient("Mid Orientation", Range(-1,1)) = 0.2

        // Micro layer (frost / grain)
        _MicroScale("Micro Scale", Float) = 24.0
        _MicroStrength("Micro Strength", Range(0,1)) = 0.45
        _MicroContrast("Micro Contrast", Float) = 1.2
        _MicroTurb("Micro Turbulence", Range(0,1)) = 0.35
        _MicroOrient("Micro Orientation", Range(-1,1)) = 0.0

        // Layer blending
        _LayerBlendMode("Layer Blend Mode", Range(0,2)) = 0 // 0 Add, 1 Multiply, 2 Max
    }
    SubShader { Pass {
        HLSLPROGRAM
        #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
        #pragma vertex CustomRenderTextureVertexShader
        #pragma fragment GenesisFragment
        #pragma target 3.0

        // globals
        float _Seed;
        float _Scale;
        float _NonSquare;
        float _Specular;
        float _Roughness;
        float _Fresnel;
        float _Debug;
        float _LayerBlendMode;

        // Macro
        float _MacroScale;
        float _MacroDensity;
        float _MacroSharp;
        float _MacroWeight;
        float _MacroTurb;
        float _MacroOrient;

        // Mid
        float _MidScale;
        float _MidDensity;
        float _MidSharp;
        float _MidWeight;
        float _MidTurb;
        float _MidOrient;

        // Micro
        float _MicroScale;
        float _MicroStrength;
        float _MicroContrast;
        float _MicroTurb;
        float _MicroOrient;

        // hash / noise
        float hash11(float n){ return frac(sin(n*127.1 + _Seed)*43758.5453); }
        float2 hash21(float2 p){
            float n = dot(p, float2(127.1,311.7));
            return frac(sin(float2(n, n+1.0)*127.1 + _Seed) * 43758.5453);
        }

        // value noise
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
        float fbm(float2 p, int octaves){
            float v=0.0; float a=0.5; float2 shift = float2(100,100);
            for(int i=0;i<octaves;i++){
                v += a*noise2(p);
                p = p*2.0 + shift;
                a *= 0.5;
            }
            return v;
        }

        // cheap cellular F1 (distance to nearest random point) + id
        float2 cellularF1(float2 p){
            float2 ip = floor(p);
            float2 fp = frac(p);
            float best = 10.0;
            float bestId = 0.0;
            for(int y=-1;y<=1;y++){
                for(int x=-1;x<=1;x++){
                    float2 b = float2(x,y);
                    float2 rp = hash21(ip + b);
                    float2 diff = b + rp - fp;
                    float d = dot(diff,diff);
                    if (d < best){
                        best = d;
                        bestId = hash11((ip.x + b.x) + (ip.y + b.y)*57.0);
                    }
                }
            }
            return float2(sqrt(best), bestId);
        }

        // domain warp helper
        float2 domainWarp(float2 p, float strength, float scale){
            float2 q = float2(fbm(p * scale, 3), fbm((p + 5.2) * scale, 3));
            return p + (q - 0.5) * strength;
        }

        // compute normal from height using derivatives
        float3 computeNormalFromHeight(float h){
            float hx = ddx(h);
            float hy = ddy(h);
            float3 n = normalize(float3(-hx, -hy, 1.0));
            return n;
        }

        // simple specular + fresnel
        float specularBRDF(float3 n, float3 v, float3 l, float roughness, float intensity, float fresnel){
            float3 h = normalize(v + l);
            float ndoth = saturate(dot(n,h));
            float spec = pow(ndoth, max(1.0, (1.0 - roughness) * 128.0));
            float fn = fresnel * pow(1.0 - saturate(dot(n,v)), 5.0);
            return intensity * (spec + fn * 0.5);
        }

        // layer blend helper
        float blendMode(float a, float b, float mode){
            if (mode < 0.5) { // Add
                return saturate(a + b);
            } else if (mode < 1.5) { // Multiply
                return a * b;
            } else { // Max
                return max(a,b);
            }
        }

        // generate a faceted layer using cellular + shaping
        float facetLayer(float2 uv, float layerScale, float density, float sharpness, float turb, float orient, out float rawDist)
        {
            // orientation bias: rotate uv slightly based on orient
            float ang = orient * 1.2;
            float ca = cos(ang), sa = sin(ang);
            float2 uvr = float2(uv.x * ca - uv.y * sa, uv.x * sa + uv.y * ca);

            float2 p = uvr * layerScale * density;
            if (turb > 0.001) p = domainWarp(p, turb, max(1.0, layerScale * 0.5));

            float2 c = cellularF1(p);
            float dist = c.x;
            rawDist = dist;

            // facet shaping: invert distance and sharpen
            float facet = pow(saturate(1.0 - dist * 1.6), sharpness);

            // small ridge accent by sampling neighbor jitter
            float2 jitter = hash21(floor(p) + c.y) - 0.5;
            float2 sampleP = p + jitter * 0.5;
            float2 c2 = cellularF1(sampleP);
            float ridge = saturate((c2.x - dist) * 3.5);
            facet = saturate(facet + ridge * 0.45);

            // per-cell tone variation
            float tone = lerp(0.9, 1.12, hash11(c.y * 12.9898));
            return saturate(facet * tone);
        }

        // micro frost layer using fbm + high-frequency noise
        float microLayer(float2 uv, float microScale, float strength, float contrast, float turb, float orient)
        {
            // orientation bias via rotation
            float ang = orient * 2.0;
            float ca = cos(ang), sa = sin(ang);
            float2 uvr = float2(uv.x * ca - uv.y * sa, uv.x * sa + uv.y * ca);

            float2 p = uvr * microScale;
            if (turb > 0.001) p = domainWarp(p, turb, microScale * 0.25);

            float m = fbm(p, 6) * 0.6 + 0.4 * noise2(p * 3.0);
            m = pow(saturate(m), contrast);
            return saturate(m * strength);
        }

        float4 mixture(v2f_customrendertexture i) : SV_Target {
            float2 uv = i.localTexcoord.xy;

            // non-square compensation
            if (_NonSquare > 0.0 && i.localTexcoord.z > 0.0) {
                float aspect = i.localTexcoord.z;
                uv.x = lerp(uv.x, uv.x * aspect, _NonSquare);
            }

            // base uv scaled by global scale
            float2 baseUV = uv * _Scale;

            // Macro layer
            float rawMacroDist;
            float macro = facetLayer(baseUV, _MacroScale, _MacroDensity, _MacroSharp, _MacroTurb, _MacroOrient, rawMacroDist);
            macro *= _MacroWeight;

            // Mid layer
            float rawMidDist;
            float mid = facetLayer(baseUV, _MidScale, _MidDensity, _MidSharp, _MidTurb, _MidOrient, rawMidDist);
            mid *= _MidWeight;

            // Micro layer
            float micro = microLayer(baseUV, _MicroScale, _MicroStrength, _MicroContrast, _MicroTurb, _MicroOrient);

            // combine layers progressively: macro -> mid -> micro
            float combined = blendMode(macro, mid, _LayerBlendMode);
            combined = blendMode(combined, micro, _LayerBlendMode);

            // height for normal computation: bias layers so macro dominates silhouette
            float height = saturate(macro * 0.6 + mid * 0.3 + micro * 0.1);

            // compute normal from height
            float3 n = computeNormalFromHeight(height);

            // lighting (CRT preview)
            float3 vdir = normalize(float3(0.0, 0.0, 1.0));
            float3 ldir = normalize(float3(-0.45, 0.6, 1.0));

            float ndotl = saturate(dot(n, ldir));
            float diffuse = ndotl * 0.35;
            float spec = specularBRDF(n, vdir, ldir, _Roughness, _Specular, _Fresnel);

            // final shaded output
            float baseAlbedo = height;
            float shaded = saturate(baseAlbedo * (0.6 + diffuse) + spec);

            // subtle edge darkening using macro distance to emphasize facets
            float edge = smoothstep(0.02, 0.12, rawMacroDist);
            shaded = lerp(shaded * 0.88, shaded, edge);

            // debug outputs
            if (_Debug == 0) return float4(macro, macro, macro, 1); // Macro
            if (_Debug == 1) return float4(mid, mid, mid, 1); // Mid
            if (_Debug == 2) return float4(micro, micro, micro, 1); // Micro
            if (_Debug == 3) return float4(n * 0.5 + 0.5, 1); // Normal
            if (_Debug == 4) return float4(shaded, shaded, shaded, 1); // Shaded final
            if (_Debug == 5) return float4(1.0 - shaded, 1.0 - shaded, 1.0 - shaded, 1); // Inverted

            return float4(shaded, shaded, shaded, 1);
        }
        ENDHLSL
    }} 
    FallBack Off
}
