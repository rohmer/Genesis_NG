Shader "Hidden/Genesis/GrungeDirt"
{
    Properties
    {
        _Scale("Scale", Float) = 6.0
        _Balance("Balance", Range(0,1)) = 0.5
        _Contrast("Contrast", Float) = 1.0
        [Enum(Normal,0,Inverted,1)]_Invert("Invert", Float) = 0.0
        _Coverage("Coverage", Range(0,1)) = 0.5
        _NonSquare("Non Square Expansion", Float) = 0.0
        _Seed("Seed", Float) = 0.0
        [Enum(None,0, RawNoise,1, Mask,2, Inverted,3)] _Debug("Debug", Float) = 0
    }
    SubShader { Pass {
        HLSLPROGRAM
        #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
        #pragma vertex CustomRenderTextureVertexShader
        #pragma fragment GenesisFragment
        #pragma target 3.0

        float _Scale;
        float _Balance;
        float _Contrast;
        float _Invert;
        float _Coverage;
        float _NonSquare;
        float _Seed;
        float _Debug;

        // cheap hash / value noise
        float hash11(float n){ return frac(sin(n*127.1+_Seed)*43758.5453); }
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
        float fbm(float2 p){
            float v=0.0; float a=0.5; float2 shift = float2(100,100);
            for(int i=0;i<5;i++){
                v += a*noise2(p);
                p = p*2.0 + shift;
                a *= 0.5;
            }
            return v;
        }

        float4 mixture(v2f_customrendertexture i) : SV_Target {
            float2 uv = i.localTexcoord.xy;

            // non-square compensation
            if (_NonSquare > 0.0) {
                float aspect = i.localTexcoord.z; // use z as aspect if provided by pipeline
                uv.x = lerp(uv.x, uv.x * aspect, _NonSquare);
            }

            // scale and seed jitter
            float2 p = uv * _Scale + _Seed;

            // base grunge: fbm + spot shaping
            float g = fbm(p * 1.0);
            // accentuate spots by raising to power and adding small high-frequency
            float spots = pow(saturate((g - (1.0 - _Coverage)) / max(1e-5,_Coverage)), 1.5);
            spots += 0.15 * fbm(p * 8.0);

            // balance shifts midpoint (like Substance Balance)
            float balanced = lerp(spots, 1.0 - spots, _Balance);

            // contrast
            balanced = pow(saturate(balanced), _Contrast);

            // invert
            if (_Invert > 0.5) balanced = 1.0 - balanced;

            // threshold to produce mask if desired
            float mask = step(0.5, balanced);

            // debug outputs
            if (_Debug == 1) return float4(g,g,g,1); // raw noise
            if (_Debug == 2) return float4(mask,mask,mask,1); // mask
            if (_Debug == 3) return float4(1.0-balanced,1.0-balanced,1.0-balanced,1); // inverted preview

            return float4(balanced, balanced, balanced, 1);
        }
        ENDHLSL
    } }
}
