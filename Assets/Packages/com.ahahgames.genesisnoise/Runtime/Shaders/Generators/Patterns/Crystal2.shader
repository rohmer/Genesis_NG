Shader "Hidden/Genesis/Crystal2"
{
    Properties
    {
        _Scale("Global Scale", Float) = 4.0

        // Layer A (primary streaks)
        _A_Scale("A Scale", Float) = 1.0
        _A_Stretch("A Stretch", Range(0.1,10.0)) = 6.0
        _A_Angle("A Angle (radians)", Float) = 0.6
        _A_Contrast("A Contrast", Float) = 1.6
        _A_Weight("A Weight", Range(0,1)) = 0.9
        _A_Blur("A Blur Taps", Range(1,8)) = 3.0
        _A_Turb("A Turbulence", Range(0,1)) = 0.18

        // Layer B (secondary, crossing streaks)
        _B_Scale("B Scale", Float) = 1.6
        _B_Stretch("B Stretch", Range(0.1,10.0)) = 4.0
        _B_Angle("B Angle (radians)", Float) = -0.9
        _B_Contrast("B Contrast", Float) = 1.2
        _B_Weight("B Weight", Range(0,1)) = 0.6
        _B_Blur("B Blur Taps", Range(1,8)) = 2.0
        _B_Turb("B Turbulence", Range(0,1)) = 0.25

        // Micro detail (fine grain / smear)
        _MicroScale("Micro Scale", Float) = 18.0
        _MicroStrength("Micro Strength", Range(0,1)) = 0.35

        // Flow and tiling seed
        _Flow("Flow Strength", Range(0,1)) = 0.28
        _FlowScale("Flow Scale", Float) = 3.5
        _TileSize("Tile Size", Float) = 8.0
        _Seed("Seed", Float) = 0.0

        _NonSquare("Non Square Expansion", Float) = 0.0
        [Enum(None,0, RawFBM,1, LayerA,2, LayerB,3, Micro,4, Shaded,5, Inverted,6)] _Debug("Debug", Float) = 4
    }
    SubShader { Pass {
        HLSLPROGRAM
        #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
        #pragma vertex CustomRenderTextureVertexShader
        #pragma fragment GenesisFragment
        #pragma target 3.0

        float _Scale;

        float _A_Scale;
        float _A_Stretch;
        float _A_Angle;
        float _A_Contrast;
        float _A_Weight;
        float _A_Blur;
        float _A_Turb;

        float _B_Scale;
        float _B_Stretch;
        float _B_Angle;
        float _B_Contrast;
        float _B_Weight;
        float _B_Blur;
        float _B_Turb;

        float _MicroScale;
        float _MicroStrength;

        float _Flow;
        float _FlowScale;
        float _TileSize;
        float _Seed;

        float _NonSquare;
        float _Debug;

        // Tiling-safe integer wrap helper
        float2 wrapInt2(float2 v, float tile) {
            // operate on integer cell coords so tiling repeats every tile cells
            // use fmod on floor to avoid fractional wrap issues
            float2 ip = floor(v);
            float2 wrapped = fmod(ip, max(1e-5, tile));
            // keep fractional part unchanged
            float2 fp = frac(v);
            return wrapped + fp;
        }

        // hash functions that use wrapped integer cell coords and seed offset
        float hash11_tiled(float n, float seedOffset, float tile) {
            // wrap n by tile to keep tiling
            float wn = fmod(floor(n) + seedOffset, max(1e-5, tile));
            return frac(sin((wn + 0.1234) * 127.1) * 43758.5453);
        }

        float2 hash21_tiled(float2 p, float seedOffset, float tile) {
            // wrap integer cell coords to tile
            float2 ip = floor(p);
            ip = fmod(ip + seedOffset, max(1e-5, tile));
            float2 n = float2(dot(ip, float2(127.1,311.7)), dot(ip, float2(269.5,183.3)));
            float2 r = frac(sin(n * 127.1) * 43758.5453);
            return r;
        }

        // value noise using tiled integer wrap
        float noise2_tiled(float2 p, float seedOffset, float tile){
            // wrap integer coordinates so noise tiles
            float2 i = floor(p);
            float2 f = frac(p);
            float2 iw = fmod(i + seedOffset, max(1e-5, tile));
            float a = hash11_tiled(iw.x + iw.y * 57.0, seedOffset, tile);
            float b = hash11_tiled(iw.x+1.0 + iw.y*57.0, seedOffset, tile);
            float c = hash11_tiled(iw.x + (iw.y+1.0)*57.0, seedOffset, tile);
            float d = hash11_tiled(iw.x+1.0 + (iw.y+1.0)*57.0, seedOffset, tile);
            float2 u = f*f*(3.0-2.0*f);
            return lerp(lerp(a,b,u.x), lerp(c,d,u.x), u.y);
        }

        // tiled fbm
        float fbm_tiled(float2 p, int octaves, float seedOffset, float tile){
            float v=0.0; float a=0.5; float2 shift = float2(100,100);
            for(int i=0;i<octaves;i++){
                v += a * noise2_tiled(p, seedOffset, tile);
                p = p*2.0 + shift;
                a *= 0.5;
            }
            return v;
        }

        // low-cost domain warp (flow) using tiled fbm
        float2 domainWarp_tiled(float2 p, float strength, float scale, float seedOffset, float tile){
            float2 q = float2(fbm_tiled(p * scale, 3, seedOffset, tile), fbm_tiled((p + 5.2) * scale, 3, seedOffset, tile));
            return p + (q - 0.5) * strength;
        }

        // rotate UV by angle
        float2 rotate(float2 uv, float ang){
            float c = cos(ang), s = sin(ang);
            return float2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
        }

        // anisotropic FBM using tiled fbm
        float anisotropicFBM_tiled(float2 uv, float stretch, float scale, int octaves, float seedOffset, float tile){
            float2 p = uv * scale;
            p.x *= stretch;
            return fbm_tiled(p, octaves, seedOffset, tile);
        }

        // directional blur along angle using tiled anisotropic FBM
        float directionalStreak_tiled(float2 uv, float angle, float stretch, float scale, float blurTaps, float turb, float seedOffset, float tile)
        {
            float2 ruv = rotate(uv, angle);
            if (turb > 0.001) ruv = domainWarp_tiled(ruv, turb, max(1.0, scale * 0.5), seedOffset, tile);
            int taps = max(1, (int)blurTaps);
            float sum = 0.0;
            float wsum = 0.0;
            for (int t = -taps; t <= taps; t++){
                float off = t / (float)max(1,taps);
                float2 sampleUV = ruv + float2(off * 0.5, 0.0);
                float s = anisotropicFBM_tiled(sampleUV, stretch, scale, 5, seedOffset, tile);
                float w = exp(-abs(off)*1.5);
                sum += s * w;
                wsum += w;
            }
            return sum / max(1e-5, wsum);
        }

        float4 genesis(v2f_customrendertexture i) : SV_Target {
            float2 uv = i.localTexcoord.xy;

            // non-square compensation
            if (_NonSquare > 0.0 && i.localTexcoord.z > 0.0) {
                float aspect = i.localTexcoord.z;
                uv.x = lerp(uv.x, uv.x * aspect, _NonSquare);
            }

            // global scale and seed offset
            float2 gUV = uv * _Scale;

            // derive integer seed offset from _Seed so tiling remains integer-based
            float seedOffset = floor(_Seed);

            // apply global flow warp using tiled domain warp
            if (_Flow > 0.001) gUV = domainWarp_tiled(gUV, _Flow, _FlowScale, seedOffset, max(1.0, _TileSize));

            // Layer A: primary diagonal streaks (tiled)
            float a = directionalStreak_tiled(gUV, _A_Angle, _A_Stretch, _A_Scale, _A_Blur, _A_Turb, seedOffset + 1.0, max(1.0, _TileSize));
            a = pow(saturate(a), _A_Contrast);
            a *= _A_Weight;

            // Layer B: crossing streaks (tiled)
            float b = directionalStreak_tiled(gUV, _B_Angle, _B_Stretch, _B_Scale, _B_Blur, _B_Turb, seedOffset + 7.0, max(1.0, _TileSize));
            b = pow(saturate(b), _B_Contrast);
            b *= _B_Weight;

            // Micro detail: tiled anisotropic FBM blended from both orientations
            float microA = anisotropicFBM_tiled(rotate(gUV, _A_Angle), _A_Stretch * 0.5, _MicroScale * 0.8, 4, seedOffset + 3.0, max(1.0, _TileSize));
            float microB = anisotropicFBM_tiled(rotate(gUV, _B_Angle), _B_Stretch * 0.5, _MicroScale * 1.2, 4, seedOffset + 5.0, max(1.0, _TileSize));
            float micro = lerp(microA, microB, 0.5);
            micro = pow(saturate(micro), _MicroStrength * 2.0);
            micro *= _MicroStrength;

            // combine layers
            float combined = saturate(a + b * 0.6);
            combined = saturate(combined * (1.0 - 0.25 * micro) + 0.15 * micro);
            combined = pow(saturate(combined), 0.95);

            // debug outputs
            if (_Debug == 1) return float4(a,a,a,1); // Layer A
            if (_Debug == 2) return float4(b,b,b,1); // Layer B
            if (_Debug == 3) return float4(micro,micro,micro,1); // Micro
            if (_Debug == 4) return float4(1.0 - combined, 1.0 - combined, 1.0 - combined, 1); // Inverted
            return float4(combined, combined, combined, 1);
        }
        ENDHLSL
    }} 
    FallBack Off
}
