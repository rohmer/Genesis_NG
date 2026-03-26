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

        // sample brush from texture with rotation/scale/flip around an anchor (anchor in tile-local coords)
        float sampleBrushTexAtAnchor(int texIndex, float2 anchorLocal, float2 uvTileLocal, float brushSize, float rotation, float flip)
        {
            // uvTileLocal is pixel position relative to tile center (-0.5..0.5)
            // compute local relative to anchor
            float2 local = uvTileLocal - anchorLocal;
            float2 p = local / brushSize;
            // rotate by -rotation to align texture
            float c = cos(-rotation), s = sin(-rotation);
            float2 r = float2(p.x * c - p.y * s, p.x * s + p.y * c);
            r.x *= flip;
            float2 texUV = saturate(r * 0.5 + 0.5);
            return sampleTextureByIndex(texIndex, texUV);
        }

        float4 mixture(v2f_customrendertexture i) : SV_Target {
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

            // compute a randomized anchor position inside the tile (range -0.5..0.5)
            float2 rnd = hash21(cellIndexF + float2(3.0,7.0));
            float2 anchorOffset = (rnd - 0.5) * _RandomPosStrength; // -0.5..0.5 scaled by strength
            float2 anchorLocal = anchorOffset;

            // per-tile randoms for rotation/scale/flip
            float rVal = hash11(tileHash * 12.9898 + 1.0);
            float rRot = hash11(tileHash * 78.233 + 2.0);
            float rScale = hash11(tileHash * 99.13 + 3.0);
            float rFlip = hash11(tileHash * 45.32 + 4.0);

            float rot = (rRot - 0.5) * 6.2831853 * _RotationJitter;
            float scaleNoise = 1.0 + (rScale - 0.5) * _ScaleJitter;
            float flip = (rFlip < _FlipChance) ? -1.0 : 1.0;

            // compute randomized brush size per tile using RandomSizeStrength and Min/Max
            // base half-tile size is 0.5; we compute a multiplier in [MinSize, MaxSize]
            float sizeNoise = hash11(tileHash * 42.42 + 9.0); // deterministic per-tile
            float sizeMapped = lerp(_MinSize, _MaxSize, sizeNoise); // in fraction of half-tile
            // blend between default coverage-based size and randomized size by strength
            float baseSize = 0.5 * _Coverage; // default half-tile coverage
            float randSize = baseSize * sizeMapped;
            float brushSize = lerp(baseSize, randSize, _RandomSizeStrength);
            // apply scaleNoise (scale jitter) so final brushSize accounts for scale jitter
            brushSize /= scaleNoise;

            // compute mask for this tile's anchor (soft circular/elliptical falloff)
            float2 localToAnchor = uvInCell - anchorLocal;
            float dist = length(localToAnchor);
            float nd = saturate(dist / max(1e-5, brushSize));
            float maskAnchor = 1.0 - smoothstep(1.0 - _EdgeSoftness, 1.0, nd);

            // micro breakup
            float micro = fbm(cellUV * 2.0 + tileHash * 13.0) * 0.06;

            // Mode: Single -> pick one texture index per tile
            //       Stack  -> evaluate each texture with its probability and overlay
            float result = 0.0;
            int texCount = (int)round(_TexCount);
            texCount = clamp(texCount, 1, 4);

            if (_Mode < 0.5) {
                // Single mode: pick index from rVal
                int sel = 1 + (int)floor(rVal * texCount);
                sel = clamp(sel, 1, texCount);
                float sample = sampleBrushTexAtAnchor(sel, anchorLocal, uvInCell, brushSize, rot, flip);
                if (sample <= 0.0001) sample = rVal; // fallback grayscale
                result = sample * maskAnchor;
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
                        float s = sampleBrushTexAtAnchor(t, anchorLocal, uvInCell, brushSize, layerRot + (t*0.13), layerFlip);
                        if (s <= 0.0001) s = r;
                        result = blendMode(result, s * maskAnchor, _BlendMode);
                    }
                }
            }

            // neighbor contributions: sample 3x3 neighbor tiles because anchors are randomized and can overlap
            float accum = result;
            for (int oy=-1; oy<=1; oy++){
                for (int ox=-1; ox<=1; ox++){
                    if (ox==0 && oy==0) continue; // skip center (already computed)
                    float2 nIdx = cellIndexF + float2(ox, oy);
                    float nHash = hash11(nIdx.x + nIdx.y * 57.0);
                    // neighbor anchor
                    float2 nrnd = hash21(nIdx + float2(3.0,7.0));
                    float2 nAnchor = (nrnd - 0.5) * _RandomPosStrength;
                    // neighbor randoms
                    float nrVal = hash11(nHash * 12.9898 + 1.0);
                    float nrRot = hash11(nHash * 78.233 + 2.0);
                    float nrScale = hash11(nHash * 99.13 + 3.0);
                    float nrFlip = hash11(nHash * 45.32 + 4.0);
                    float nrot = (nrRot - 0.5) * 6.2831853 * _RotationJitter;
                    float nscaleNoise = 1.0 + (nrScale - 0.5) * _ScaleJitter;
                    float nflip = (nrFlip < _FlipChance) ? -1.0 : 1.0;

                    // neighbor randomized size
                    float nSizeNoise = hash11(nHash * 42.42 + 9.0);
                    float nSizeMapped = lerp(_MinSize, _MaxSize, nSizeNoise);
                    float nBaseSize = 0.5 * _Coverage;
                    float nRandSize = nBaseSize * nSizeMapped;
                    float nBrushSize = lerp(nBaseSize, nRandSize, _RandomSizeStrength) / nscaleNoise;

                    // compute uvInCell relative to neighbor tile: shift uvInCell by tile offset
                    float2 uvRel = frac(cellUV - float2(ox,oy)) - 0.5;
                    float2 localToNAnchor = uvRel - nAnchor;
                    float ndist = length(localToNAnchor);
                    float nnd = saturate(ndist / max(1e-5, nBrushSize));
                    float nmask = 1.0 - smoothstep(1.0 - _EdgeSoftness, 1.0, nnd);

                    if (_Mode < 0.5) {
                        int sel = 1 + (int)floor(nrVal * texCount);
                        sel = clamp(sel, 1, texCount);
                        float s = sampleBrushTexAtAnchor(sel, nAnchor, uvRel, nBrushSize, nrot, nflip);
                        if (s <= 0.0001) s = nrVal;
                        float w = smoothstep(0.9, 0.0, length(uvRel - nAnchor)); // proximity weight
                        accum = blendMode(accum, s * nmask * w, _BlendMode);
                    } else {
                        for (int t=1; t<=texCount; t++){
                            float r = hash11(nHash * (12.34 * t) + t * 7.77);
                            float pres = (t==1)?_Prob1: (t==2)?_Prob2: (t==3)?_Prob3:_Prob4;
                            if (r < pres) {
                                float layerRot = nrot + (hash11(nHash + t) - 0.5) * 0.2;
                                float layerFlip = nflip * ((hash11(nHash + t*3.0) < 0.5) ? -1.0 : 1.0);
                                float s = sampleBrushTexAtAnchor(t, nAnchor, uvRel, nBrushSize, layerRot + (t*0.13), layerFlip);
                                if (s <= 0.0001) s = r;
                                float w = smoothstep(0.9, 0.0, length(uvRel - nAnchor));
                                accum = blendMode(accum, s * nmask * w, _BlendMode);
                            }
                        }
                    }
                }
            }

            // add subtle micro breakup
            accum = saturate(accum + micro * 0.05);

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
            if (_Debug == 3) { // Anchor position visualization (normalized)
                float2 anchorVis = anchorLocal + 0.5;
                return float4(anchorVis.x, anchorVis.y, 0.0, 1);
            }
            if (_Debug == 4) { // Size visualization (normalized 0..1)
                // show per-tile randomized size (mapped)
                float sizeNoiseVis = hash11(tileHash * 42.42 + 9.0);
                float sizeMappedVis = lerp(_MinSize, _MaxSize, sizeNoiseVis);
                return float4(sizeMappedVis, sizeMappedVis, sizeMappedVis, 1);
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
