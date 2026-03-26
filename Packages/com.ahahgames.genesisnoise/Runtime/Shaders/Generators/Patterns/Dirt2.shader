Shader "Hidden/Genesis/GrungeDirt2"
{
    Properties
    {
        _Preset("Preset", Range(0,14)) = 0
        _Scale("Scale", Float) = 8.0
        _Disorder("Disorder", Range(0,1)) = 0.35
        _DisorderSpeed("Disorder Speed", Float) = 1.0
        _DisorderAniso("Disorder Anisotropy", Range(0,1)) = 0.0
        _DisorderAngle("Disorder Angle", Range(0,1)) = 0.0
        _TileOffset("Tile Offset", Vector) = (0,0,0,0)
        _NonSquare("Non Square Expansion", Float) = 0.0
        _Seed("Seed", Float) = 0.0
        _Debug("Debug", Float) = 0
    }
    SubShader { Pass {
        HLSLPROGRAM
        #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
        #pragma vertex CustomRenderTextureVertexShader
        #pragma fragment GenesisFragment
        #pragma target 3.0

        float _Preset;
        float _Scale;
        float _Disorder;
        float _DisorderSpeed;
        float _DisorderAniso;
        float _DisorderAngle;
        float4 _TileOffset;
        float _NonSquare;
        float _Seed;
        float _Debug;

        // Preset table: map preset index -> parameter set
        // Call: applyPreset((int)round(_Preset));
void applyPreset(int p)
{
    // Preset list (index -> values)
    // Format: Scale, Disorder, DisorderSpeed, DisorderAniso, DisorderAngle, TileOffset.xy, NonSquare, Seed
    if (p == 0)  { _Scale=8.0;  _Disorder=0.35; _DisorderSpeed=1.0; _DisorderAniso=0.00; _DisorderAngle=0.00; _TileOffset=float4(0,0,0,0); _NonSquare=0.0; _Seed=0.0; } // Default
    else if (p == 1)  { _Scale=12.0; _Disorder=0.45; _DisorderSpeed=1.2; _DisorderAniso=0.20; _DisorderAngle=0.25; _TileOffset=float4(0.10,0.05,0,0); _NonSquare=0.0; _Seed=42.0; } // Dense streaks
    else if (p == 2)  { _Scale=4.0;  _Disorder=0.15; _DisorderSpeed=0.8; _DisorderAniso=0.60; _DisorderAngle=0.60; _TileOffset=float4(0,0,0,0); _NonSquare=1.0; _Seed=7.0; } // Coarse anisotropic
    else if (p == 3)  { _Scale=6.0;  _Disorder=0.25; _DisorderSpeed=0.9; _DisorderAniso=0.10; _DisorderAngle=0.10; _TileOffset=float4(0.02,0.02,0,0); _NonSquare=0.0; _Seed=13.0; } // Soft grain
    else if (p == 4)  { _Scale=16.0; _Disorder=0.55; _DisorderSpeed=1.5; _DisorderAniso=0.35; _DisorderAngle=0.40; _TileOffset=float4(0.2,0.1,0,0); _NonSquare=0.0; _Seed=99.0; } // Fine noisy dirt
    else if (p == 5)  { _Scale=3.0;  _Disorder=0.10; _DisorderSpeed=0.6; _DisorderAniso=0.80; _DisorderAngle=0.75; _TileOffset=float4(0,0,0,0); _NonSquare=1.0; _Seed=5.0; } // Large streaks
    else if (p == 6)  { _Scale=10.0; _Disorder=0.40; _DisorderSpeed=1.0; _DisorderAniso=0.30; _DisorderAngle=0.15; _TileOffset=float4(0.05,0.0,0,0); _NonSquare=0.0; _Seed=21.0; } // Mid grain
    else if (p == 7)  { _Scale=20.0; _Disorder=0.65; _DisorderSpeed=1.8; _DisorderAniso=0.10; _DisorderAngle=0.05; _TileOffset=float4(0.3,0.15,0,0); _NonSquare=0.0; _Seed=128.0; } // Very fine speckle
    else if (p == 8)  { _Scale=5.0;  _Disorder=0.30; _DisorderSpeed=1.0; _DisorderAniso=0.50; _DisorderAngle=0.5;  _TileOffset=float4(0.0,0.1,0,0); _NonSquare=0.0; _Seed=77.0; } // Directional mid
    else if (p == 9)  { _Scale=9.0;  _Disorder=0.20; _DisorderSpeed=0.9; _DisorderAniso=0.05; _DisorderAngle=0.9;  _TileOffset=float4(0.0,0.0,0,0); _NonSquare=1.0; _Seed=3.0; } // Subtle square-preserve
    else if (p == 10) { _Scale=14.0; _Disorder=0.50; _DisorderSpeed=1.3; _DisorderAniso=0.25; _DisorderAngle=0.33; _TileOffset=float4(0.12,0.06,0,0); _NonSquare=0.0; _Seed=200.0; } // Painterly grit
    else if (p == 11) { _Scale=7.0;  _Disorder=0.28; _DisorderSpeed=0.95; _DisorderAniso=0.15; _DisorderAngle=0.2;  _TileOffset=float4(0.04,0.02,0,0); _NonSquare=0.0; _Seed=11.0; } // Balanced
    else if (p == 12) { _Scale=2.5;  _Disorder=0.08; _DisorderSpeed=0.5; _DisorderAniso=0.9; _DisorderAngle=0.7;  _TileOffset=float4(0,0,0,0); _NonSquare=1.0; _Seed=9.0; } // Long streaks
    else if (p == 13) { _Scale=18.0; _Disorder=0.70; _DisorderSpeed=2.0; _DisorderAniso=0.05; _DisorderAngle=0.1;  _TileOffset=float4(0.25,0.12,0,0); _NonSquare=0.0; _Seed=255.0; } // Extreme fine noise
    else if (p == 14) { _Scale=11.0; _Disorder=0.38; _DisorderSpeed=1.05; _DisorderAniso=0.22; _DisorderAngle=0.28; _TileOffset=float4(0.06,0.03,0,0); _NonSquare=0.0; _Seed=64.0; } // Natural mid
    else             { _Scale=8.0;  _Disorder=0.35; _DisorderSpeed=1.0; _DisorderAniso=0.00; _DisorderAngle=0.00; _TileOffset=float4(0,0,0,0); _NonSquare=0.0; _Seed=0.0; } // fallback
}


        float hash11(float n){ return frac(sin(n*127.1+_Seed)*43758.5453); }
        float2 hash21(float n){ return float2(hash11(n), hash11(n+19.19)); }
        float noise2(float2 p){ float2 i=floor(p); float2 f=frac(p); float a=hash11(i.x+i.y*57.0); float b=hash11(i.x+1.0+i.y*57.0); float c=hash11(i.x+(i.y+1.0)*57.0); float d=hash11(i.x+1.0+(i.y+1.0)*57.0); float2 u=f*f*(3.0-2.0*f); return lerp(lerp(a,b,u.x), lerp(c,d,u.x), u.y); }
        float fbm_dir(float2 p, float disorder, float aniso, float angle){ float v=0; float amp=0.5; float2 dir=float2(cos(angle),sin(angle)); for(int i=0;i<5;i++){ float2 off = dir * disorder * aniso * pow(0.5,i); v += amp * noise2(p + off); float a = angle + 0.3*i; dir = float2(cos(a), sin(a)); p = p*2.0 + float2(12.34,45.67); amp *= 0.5; } return v; }

        float4 mixture(v2f_customrendertexture i) : SV_Target {
            int presetIndex = (int)round(_Preset);
            applyPreset(presetIndex);

            float2 uv = i.localTexcoord.xy;
            if (_NonSquare > 0.0) { float aspect = i.localTexcoord.z; uv.x = lerp(uv.x, uv.x * aspect, _NonSquare); }
            uv += _TileOffset.xy;
            float2 p = uv * max(1.0, _Scale);
            float angle = _DisorderAngle * 6.2831853;
            float aniso = lerp(0.0, _DisorderAniso * 4.0, _Disorder);
            float d = fbm_dir(p * (1.0 + _Disorder*2.0), _Disorder * _DisorderSpeed, aniso, angle);
            float detail = fbm_dir(p*2.0, _Disorder*0.6, aniso*0.6, angle + 1.0) * 0.5;
            float grunge = saturate(d * 0.8 + detail * 0.2);
            grunge = pow(grunge, 1.0 + _Disorder*0.8);
            grunge = saturate((grunge - 0.25) / 0.75);
            if (_Debug == 1) return float4(grunge,grunge,grunge,1);
            return float4(grunge,grunge,grunge,1);
        }
        ENDHLSL
    } }
}
