Shader "Hidden/Genesis/HydraulicErosion"
{
  Properties {
    _HeightTex("Height", 2D) = "white" {}
    _WaterTex("Water+Sediment", 2D) = "black" {}
    _FluxTex("Flux/Velocity", 2D) = "black" {}
    _RainAmount("Rain per step", Range(0,0.1)) = 0.001
    _EvapRate("Evaporation", Range(0,0.1)) = 0.01
    _ErodeRate("Erode coeff", Range(0,1)) = 0.1
    _DepositRate("Deposit coeff", Range(0,1)) = 0.1
    _SedimentCapacityFactor("Capacity", Range(0,10)) = 4.0
    _MaxErodePerStep("Max Erode per step", Range(0,0.1)) = 0.01
    [GenesisHydraulicDebug]_DebugMode("Debug Mode", int) = 0
  }

  SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 100

    Pass {
      HLSLPROGRAM
      #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
      #pragma vertex CustomRenderTextureVertexShader
      #pragma fragment GenesisFragment

      sampler2D _HeightTex;
      sampler2D _WaterTex;
      sampler2D _FluxTex;
      float4 _HeightTex_TexelSize;

      float _RainAmount;
      float _EvapRate;
      float _ErodeRate;
      float _DepositRate;
      float _SedimentCapacityFactor;
      float _MaxErodePerStep;
      int _DebugMode;

      // single-channel helpers
      inline float sampleR(sampler2D s, float2 uv) { return tex2D(s, uv).r; }
      inline float2 sampleRG(sampler2D s, float2 uv) { return tex2D(s, uv).rg; }
      inline float4 sampleAll(sampler2D s, float2 uv) { return tex2D(s, uv); }

      float4 genesis(v2f_customrendertexture i) : SV_Target
      {
        float2 uv = i.localTexcoord.xy;
        float2 t = _HeightTex_TexelSize.xy;

        // --- read center and orthogonal neighbors once each ---
        float4 hC_all = sampleAll(_HeightTex, uv);
        float hC = hC_all.r;

        float4 wC_all = sampleAll(_WaterTex, uv);
        float wC = wC_all.r;
        float sC = wC_all.g; // sediment

        float2 vC = sampleRG(_FluxTex, uv); // velocity/flux packed in RG

        // neighbors: left, right, down, up
        float hL = sampleR(_HeightTex, uv - float2(t.x, 0));
        float hR = sampleR(_HeightTex, uv + float2(t.x, 0));
        float hD = sampleR(_HeightTex, uv - float2(0, t.y));
        float hU = sampleR(_HeightTex, uv + float2(0, t.y));

        float wL = sampleR(_WaterTex, uv - float2(t.x, 0));
        float wR = sampleR(_WaterTex, uv + float2(t.x, 0));
        float wD = sampleR(_WaterTex, uv - float2(0, t.y));
        float wU = sampleR(_WaterTex, uv + float2(0, t.y));

        float2 fluxL = sampleRG(_FluxTex, uv - float2(t.x, 0));
        float2 fluxR = sampleRG(_FluxTex, uv + float2(t.x, 0));
        float2 fluxD = sampleRG(_FluxTex, uv - float2(0, t.y));
        float2 fluxU = sampleRG(_FluxTex, uv + float2(0, t.y));

        // --- compute simple height+water differences to approximate outflow ---
        // total surface height = terrain + water
        float surfC = hC + wC;
        float surfL = hL + wL;
        float surfR = hR + wR;
        float surfD = hD + wD;
        float surfU = hU + wU;

        // positive drop from center to neighbor -> potential outflow
        float dropL = max(0.0, surfC - surfL);
        float dropR = max(0.0, surfC - surfR);
        float dropD = max(0.0, surfC - surfD);
        float dropU = max(0.0, surfC - surfU);

        // approximate flux magnitude to neighbors (simple explicit scheme)
        float outL = dropL;
        float outR = dropR;
        float outD = dropD;
        float outU = dropU;

        // normalize outflow so we don't remove more water than exists
        float totalOut = outL + outR + outD + outU + 1e-6;
        float scale = min(1.0, wC * 4.0 / totalOut); // factor 4 keeps timestep small
        outL *= scale; outR *= scale; outD *= scale; outU *= scale;

        // water update: incoming from neighbors (we approximate symmetric inflow)
        // here we use neighbor outflows as inflows; for a full solver you'd exchange buffers
        float inflow = (outL + outR + outD + outU) * 0.25;
        float outflow = (outL + outR + outD + outU) * 0.25;
        float wNew = wC + _RainAmount + inflow - outflow;
        wNew = max(0.0, wNew * (1.0 - _EvapRate));

        // velocity magnitude approximation (for capacity)
        float2 avgFlux = (fluxL + fluxR + fluxD + fluxU + vC) * 0.2;
        float speed = length(avgFlux) + 1e-6;

        // sediment capacity and erosion/deposition
        float capacity = max(0.0001, _SedimentCapacityFactor * speed * wNew);

        // compute desired sediment change
        float deltaSed = 0.0;
        float erosionAmount = 0.0;
        if (sC > capacity) {
          // deposit: remove sediment from water, add to terrain
          float deposit = _DepositRate * (sC - capacity);
          deposit = min(deposit, sC);
          deltaSed = -deposit;
          hC += deposit; // deposit onto terrain
        } else {
          // erode: remove from terrain into sediment
          float erode = _ErodeRate * (capacity - sC);
          erode = min(erode, _MaxErodePerStep);
          erode = min(erode, hC); // cannot erode below zero height
          deltaSed = erode;
          erosionAmount = erode;
          hC -= erode;
        }
        sC = max(0.0, sC + deltaSed);

        // pack simulation state into RGBA (R=height, G=water, B=sediment, A=debug)
        float4 simOut = float4(hC, wNew, sC, 1.0);

        // --- Debug visualization modes ---
        // 0 = simulation output (packed)
        // 1 = height (grayscale)
        // 2 = water depth (grayscale)
        // 3 = sediment (grayscale)
        // 4 = velocity magnitude (grayscale)
        // 5 = flux vector (visualize as normalized RG)
        // 6 = erosion amount (grayscale)
        // 7 = capacity (grayscale)
        float3 dbg = float3(0,0,0);
        float dbgA = 1.0;

        if (_DebugMode == 0) {
          dbg = simOut.rgb;
          dbgA = simOut.a;
        } else if (_DebugMode == 1) {
          dbg = float3(hC, hC, hC);
        } else if (_DebugMode == 2) {
          dbg = float3(wNew, wNew, wNew);
        } else if (_DebugMode == 3) {
          dbg = float3(sC, sC, sC);
        } else if (_DebugMode == 4) {
          // remap speed for visibility
          float visSpeed = saturate(speed * 2.0);
          dbg = float3(visSpeed, visSpeed, visSpeed);
        } else if (_DebugMode == 5) {
          // flux vector visualization: encode direction in RG, magnitude in B
          float2 dir = normalize(avgFlux);
          float mag = saturate(length(avgFlux) * 2.0);
          dbg = float3(dir * 0.5 + 0.5, mag); // R=dir.x, G=dir.y, B=mag
        } else if (_DebugMode == 6) {
          dbg = float3(erosionAmount * 100.0, erosionAmount * 100.0, erosionAmount * 100.0);
        } else if (_DebugMode == 7) {
          dbg = float3(capacity * 0.5, capacity * 0.5, capacity * 0.5);
        } else {
          dbg = simOut.rgb;
        }

        // final output: when debug mode is 0 we return simOut (so it can be written back),
        // otherwise return debug visualization in RGB and keep A as a marker (1.0)
        if (_DebugMode == 0) {
          return simOut;
        } else {
          return float4(saturate(dbg), dbgA);
        }
      }

      ENDHLSL
    }
  }
}
