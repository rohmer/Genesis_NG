Shader "Hidden/Genesis/TileRandom"
{
    Properties
    {
        // Layout
        _Scale("Global Scale", Float) = 1.0
        _TilesX("Tiles X", Float) = 8.0
        _TilesY("Tiles Y", Float) = 8.0

        // Mode: 0 = Single (one texture per tile), 1 = Stack (each texture may appear)
        [Enum(Single,0, Stack,1)] _Mode("Mode", Float) = 0

        // Textures (1..4)
        _TexCount("Texture Count", Range(1,4)) = 4
        _UseTex1("Use Tex1", Range(0,1)) = 1
        _UseTex2("Use Tex2", Range(0,1)) = 1
        _UseTex3("Use Tex3", Range(0,1)) = 1
        _UseTex4("Use Tex4", Range(0,1)) = 1
        _Tex1("Texture 1", 2D) = "white" {}
        _Tex2("Texture 2", 2D) = "white" {}
        _Tex3("Texture 3", 2D) = "white" {}
        _Tex4("Texture 4", 2D) = "white" {}

        // Per-texture presence probability when in Stack mode
        _Prob1("Prob Tex1", Range(0,1)) = 1.0
        _Prob2("Prob Tex2", Range(0,1)) = 0.5
        _Prob3("Prob Tex3", Range(0,1)) = 0.25
        _Prob4("Prob Tex4", Range(0,1)) = 0.1

        // Per-tile variation
        _Seed("Seed (integer)", Float) = 0.0
        _RotationJitter("Rotation Jitter", Range(0,1)) = 1.0
        _ScaleJitter("Scale Jitter", Range(0,1)) = 0.25
        _FlipChance("Flip Chance", Range(0,1)) = 0.15

        // Randomized position strength (0 = center, 1 = anywhere in tile)
        _RandomPosStrength("Random Position Strength", Range(0,1)) = 1.0

        // Random size controls
        _RandomSizeStrength("Random Size Strength", Range(0,1)) = 1.0
        _MinSize("Min Size (fraction of half-tile)", Range(0.05,1.0)) = 0.25
        _MaxSize("Max Size (fraction of half-tile)", Range(0.05,1.0)) = 0.75

        // Tile appearance
        _EdgeSoftness("Edge Softness", Range(0,1)) = 0.06
        _Coverage("Coverage (tile fill)", Range(0,1)) = 1.0
        _BlendMode("Blend Mode 0=Add 1=Multiply 2=Max", Range(0,2)) = 0

        // Debug
        [Enum(None,0, TileId,1, SelectedIndex,2, AnchorPos,3, Size,4, Final,5, Inverted,6)] _Debug("Debug", Float) = 5
    }
    SubShader { Pass {
        HLSLPROGRAM
        #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
        #pragma vertex CustomRenderTextureVertexShader
        #pragma fragment GenesisFragment
        #pragma target 3.0

        // Layout
        float _Scale;
        float _TilesX;
        float _TilesY;

        float _Mode;

        // Textures
        float _TexCount;
        float _UseTex1;
        float _UseTex2;
        float _UseTex3;
        float _UseTex4;
        sampler2D _Tex1;
        sampler2D _Tex2;
        sampler2D _Tex3;
        sampler2D _Tex4;

        float _Prob1;
        float _Prob2;
        float _Prob3;
        float _Prob4;

        // Variation
        float _Seed;
        float _RotationJitter;
        float _ScaleJitter;
        float _FlipChance;

        float _RandomPosStrength;

        // Random size
        float _RandomSizeStrength;
        float _MinSize;
        float _MaxSize;

        // Appearance
        float _EdgeSoftness;
        float _Coverage;
        float _BlendMode;

        float _Debug;

        // deterministic hash helpers
        float hash11(float n){ return frac(sin(n*127.1 + _Seed)*43758.5453); }
        float2 hash21(float2 p){ float n = dot(p, float2(127.1,311.7)); return frac(sin(float2(n,n+1.0)*127.1 + _Seed)*43758.5453); }

        // small fbm for micro breakup
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
        float fbm(float2 p){
            float v=0.0; float a=0.5; float2 shift = float2(100,100);
            for(int i=0;i<4;i++){ v += a*noise2(p); p = p*2.0 + shift; a *= 0.5; }
            return v;
        }

        // blend helper
        float blendMode(float a, float b, float mode){
            if (mode < 0.5) return saturate(a + b);
            else if (mode < 1.5) return a * b;
            else return max(a,b);
        }

        // sample selected texture (texIndex 1..4). If texture not used, returns 0.
        float sampleTextureByIndex(int idx, float2 uv)
        {
            if (idx == 1 && _UseTex1 > 0.5) { return tex2D(_Tex1, uv).r; }
            if (idx == 2 && _UseTex2 > 0.5) { return tex2D(_Tex2, uv).r; }
            if (idx == 3 && _UseTex3 > 0.5) { return tex2D(_Tex3, uv).r; }
            if (idx == 4 && _UseTex4 > 0.5) { return tex2D(_Tex4, uv).r; }
            return 0.0;
        }

        // sample tile from texture with rotation/scale/flip about tile center
        float sampleTileTex(int texIndex, float2 uvTileLocal, float rotation, float flip, float scale)
        {
            // uvTileLocal is position relative to tile center (-0.5..0.5)
            float2 p = uvTileLocal * scale;
            // rotate by -rotation to align texture
            float c = cos(-rotation), s = sin(-rotation);
            float2 r = float2(p.x * c - p.y * s, p.x * s + p.y * c);
            r.x *= flip;
            float2 texUV = saturate(r * 0.5 + 0.5);
            return sampleTextureByIndex(texIndex, texUV);
        }

        float4 genesis(v2f_customrendertexture i) : SV_Target {
            float2 uv = i.localTexcoord.xy;

            // non-square compensation if pipeline provides aspect in z
            if (i.localTexcoord.z > 0.0) {
                float aspect = i.localTexcoord.z;
                uv.x *= aspect;
            }

            // global scale
            uv *= _Scale;

            // cell coordinates
            float2 cellUV = uv * float2(max(1.0,_TilesX), max(1.0,_TilesY));
            float2 cellIndexF = floor(cellUV);
            float2 uvInCell = frac(cellUV) - 0.5; // centered -0.5..0.5

            // per-tile deterministic id (use integer coords)
            float tileHash = hash11(cellIndexF.x + cellIndexF.y * 57.0);

            // per-tile randoms for rotation/scale/flip
            float rVal = hash11(tileHash * 12.9898 + 1.0);
            float rRot = hash11(tileHash * 78.233 + 2.0);
            float rScale = hash11(tileHash * 99.13 + 3.0);
            float rFlip = hash11(tileHash * 45.32 + 4.0);

            float rot = (rRot - 0.5) * 6.2831853 * _RotationJitter;
            float scaleNoise = 1.0 + (rScale - 0.5) * _ScaleJitter;
            float flip = (rFlip < _FlipChance) ? -1.0 : 1.0;

            // Mode: Single -> pick one texture index per tile
            //       Stack  -> evaluate each texture with its probability and overlay
            float result = 0.0;
            int texCount = (int)round(_TexCount);
            texCount = clamp(texCount, 1, 4);

            if (_Mode < 0.5) {
                // Single mode: pick index from rVal
                int sel = 1 + (int)floor(rVal * texCount);
                sel = clamp(sel, 1, texCount);
                result = sampleTileTex(sel, uvInCell, rot, flip, scaleNoise);
            } else {
                // Stack mode: for each texture, decide presence by probability and overlay in index order
                float probs[4];
                probs[0] = _Prob1;
                probs[1] = _Prob2;
                probs[2] = _Prob3;
                probs[3] = _Prob4;

                for (int t = 1; t <= texCount; t++) {
                    float r = hash11(tileHash * (12.34 * t) + t * 7.77);
                    float pres = probs[t-1];
                    if (r < pres) {
                        float layerRot = rot + (hash11(tileHash + t) - 0.5) * 0.2;
                        float layerFlip = flip * ((hash11(tileHash + t*3.0) < 0.5) ? -1.0 : 1.0);
                        float s = sampleTileTex(t, uvInCell, layerRot + (t*0.13), layerFlip, scaleNoise);
                        result = blendMode(result, s, _BlendMode);
                    }
                }
            }

            float accum = result;

            // debug outputs
            if (_Debug == 1) { // TileId visualization
                return float4(frac(tileHash), frac(tileHash), frac(tileHash), 1);
            }
            if (_Debug == 2) { // Selected index (Single mode) or stack presence summary
                if (_Mode < 0.5) {
                    int sel = 1 + (int)floor(rVal * texCount);
                    float v = sel / max(1.0, (float)texCount);
                    return float4(v,v,v,1);
                } else {
                    float sum = 0.0;
                    for (int t=1; t<=texCount; t++) {
                        float r = hash11(tileHash * (12.34 * t) + t * 7.77);
                        if (r < ( (t==1)?_Prob1: (t==2)?_Prob2: (t==3)?_Prob3:_Prob4 )) sum += 1.0;
                    }
                    return float4(saturate(sum/4.0),saturate(sum/4.0),saturate(sum/4.0),1);
                }
            }
            if (_Debug == 3) { // Anchor position visualization (disabled in "texture-only" mode)
                return float4(0.5, 0.5, 0.0, 1);
            }
            if (_Debug == 4) { // Size visualization (disabled in "texture-only" mode)
                return float4(1.0, 1.0, 1.0, 1);
            }
            if (_Debug == 6) { // Inverted final
                return float4(1.0 - accum, 1.0 - accum, 1.0 - accum, 1);
            }

            // default: final shaded
            return float4(accum, accum, accum, 1);
        }
        ENDHLSL
    }} 
    FallBack Off
}
