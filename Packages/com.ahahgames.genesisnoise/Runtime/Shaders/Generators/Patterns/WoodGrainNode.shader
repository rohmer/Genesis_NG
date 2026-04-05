Shader "Hidden/Genesis/WoodGrainNode"
{
  Properties {
    _MainTex("Source (optional)", 2D) = "white" {}
    _Scale("Grain Scale", Range(0.1,50)) = 8.0
    _Stretch("Stretch (fiber axis)", Range(0.1,10)) = 4.0
    _RingFreq("Ring Frequency", Range(0.1,50)) = 6.0
    _Turbulence("Turbulence", Range(0,4)) = 0.6
    _KnotAmount("Knot Amount", Range(0,1)) = 0.25
    _Contrast("Contrast", Range(0.1,4)) = 1.2
    [Enum(Packed,0,Grain,1,Ring,2,Knots,3,Combined,4)]_DebugMode("Debug Mode", int) = 4
  }
  SubShader {
    Pass {
      HLSLPROGRAM
      #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
      #pragma vertex CustomRenderTextureVertexShader
      #pragma fragment GenesisFragment

      sampler2D _MainTex;
      float4 _MainTex_TexelSize;
      float _Scale, _Stretch, _RingFreq, _Turbulence, _KnotAmount, _Contrast;
      int _DebugMode;

      // Simple hash / noise (value noise + fbm)
      float hash(float2 p){ p = frac(p*0.3183099+0.1); p *= 17.0; return frac(p.x*p.y*(p.x+p.y)); }
      float noise(float2 p){
        float2 i = floor(p);
        float2 f = frac(p);
        float a = hash(i);
        float b = hash(i+float2(1,0));
        float c = hash(i+float2(0,1));
        float d = hash(i+float2(1,1));
        float2 u = f*f*(3.0-2.0*f);
        return lerp(lerp(a,b,u.x), lerp(c,d,u.x), u.y);
      }
      float fbm(float2 p){
        float v=0.0, amp=0.5;
        for(int i=0;i<5;i++){ v += amp*noise(p); p *= 2.0; amp *= 0.5; }
        return v;
      }

      float4 genesis(v2f_customrendertexture IN) : SV_Target {
        float2 uv = IN.localTexcoord.xy;

        // orient/stetch grain along X axis by default; rotate externally if needed
        float2 p = uv * _Scale;
        p.x *= _Stretch;

        // base rings: distance from a center line (simulate tree rings)
        float ringBase = abs(frac(p.x * _RingFreq) - 0.5) * 2.0; // banded pattern

        // turbulence modulates rings and grain
        float turb = fbm(p * 0.5) * _Turbulence;
        float rings = smoothstep(0.0, 1.0, 1.0 - ringBase + turb*0.5);

        // fine grain: high-frequency noise stretched along fiber axis
        float grain = fbm(p * 4.0 + turb*2.0);
        grain = pow(saturate(grain), _Contrast);

        // knots: localized circular distortions using additional noise
        float2 knotSeed = p * 0.5;
        float k = fbm(knotSeed * 1.5);
        float2 knotPos = frac(knotSeed) - 0.5;
        float knotMask = smoothstep(0.4, 0.0, length(knotPos) * (1.0 + k*2.0));
        knotMask *= _KnotAmount * k;

        // combine: rings modulate grain; knots add local swirl (here we brighten grain)
        float combined = lerp(grain * 0.6 + rings * 0.4, 1.0, knotMask);

        // outputs: R=grain, G=rings, B=knotMask, A=combined (or debug)
        float4 sim = float4(saturate(grain), saturate(rings), saturate(knotMask), saturate(combined));

        // debug modes: 0=packed,1=grain,2=rings,3=knots,4=combined
        if (_DebugMode == 0) return sim;
        if (_DebugMode == 1) return float4(sim.r,sim.r,sim.r,1);
        if (_DebugMode == 2) return float4(sim.g,sim.g,sim.g,1);
        if (_DebugMode == 3) return float4(sim.b,sim.b,sim.b,1);
        return float4(sim.a,sim.a,sim.a,1);
      }
      ENDHLSL
    }
  }
}
