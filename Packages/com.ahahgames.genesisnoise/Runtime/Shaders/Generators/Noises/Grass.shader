Shader "Hidden/Genesis/Grass"
{
    Properties
    {
        // Domain
        [Enum(Disabled,0, Enabled,1)]_UseWorldSpace ("Use World Space XZ (toggle)", Float) = 0
        [GenesisVector2]_DomainMin ("Domain Min (UV or XZ)", Vector) = (0,0,0,0)
        [GenesisVector2]_DomainMax ("Domain Max (UV or XZ)", Vector) = (1,1,0,0)

        // Density & shape
        _BladeSpacing ("Blade Spacing", Range(0.001, 0.02)) = 0.004
        _BladeWidth   ("Blade Base Half-Width", Range(0.0002, 0.003)) = 0.0008
        [GenesisVector2]_LengthMinMax ("Blade Length Min/Max", Vector) = (0.012, 0.022, 0, 0)
        _JitterMax    ("Cell Jitter", Range(0, 0.02)) = 0.004
        _LookupDist   ("Neighbor Radius (1-8)", Range(1, 8)) = 4

        // Wind
        _WindStrength ("Wind Strength", Range(0, 0.2)) = 0.05
        _WindFreq     ("Wind Frequency", Range(0.2, 6.0)) = 2.1
        [GenesisVector2]_WindDir      ("Wind Direction XY", Vector) = (0.6, 1.0, 0, 0)

        // Lighting & AO
        _MinLight     ("Min Light", Range(0, 1)) = 0.3
        _AOIntensity  ("AO Intensity", Range(0, 1)) = 0.5
        [Enum(Disabled,0, Enabled,1)]_UseAO        ("Use AO (toggle)", Float) = 1
        [Enum(Disabled,0, Enabled,1)]_UseDirLight  ("Use Directional Light (toggle)", Float) = 1

        // Palette
        _AutumnChance ("Autumn Chance (0..1)", Range(0,1)) = 0.1
        _GreenA       ("Green A", Color) = (0.618, 0.831, 0.361, 1)
        _GreenB       ("Green B", Color) = (0.451, 0.659, 0.231, 1)
        _GreenC       ("Green C", Color) = (0.580, 0.698, 0.459, 1)
        _GreenD       ("Green D", Color) = (0.227, 0.412, 0.09, 1)
        _AutA         ("Autumn A", Color) = (0.208, 0.165, 0.024, 1)
        _AutB         ("Autumn B", Color) = (0.861,0.821,0.604, 1)
        _AutC         ("Autumn C", Color) = (0.671, 0.667, 0.557, 1)
        _AutD         ("Autumn D", Color) = (0.427, 0.435, 0.247, 1)

    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET				
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            // Feature keywords
            #pragma shader_feature_local _AUTUMN_COLORS
            #pragma shader_feature_local _WIND
            #pragma shader_feature_local _WIDTHRAND
            #pragma shader_feature_local _AO
            #pragma shader_feature_local _DIRLIGHT
            #pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV

            

            // We keep a maximum unroll bound for nested loops for performance and compatibility.
            // Runtime _LookupDist clamps inside these bounds.
            static const int MAX_LOOKUP = 8;
            
            // Properties
            float  _UseWorldSpace;
            float4 _DomainMin;
            float4 _DomainMax;

            float  _BladeSpacing;
            float  _BladeWidth;
            float4 _LengthMinMax; // x=min, y=max
            float  _JitterMax;
            float  _LookupDist;

            float  _WindStrength;
            float  _WindFreq;
            float4 _WindDir;

            float  _MinLight;
            float  _AOIntensity;
            float  _UseAO;
            float  _UseDirLight;

            float  _AutumnChance;
            float4 _GreenA, _GreenB, _GreenC, _GreenD;
            float4 _AutA,   _AutB,   _AutC,   _AutD;
            float2 _Time;

            static const float  HASHSCALE1 = 0.1031;
            static const float3 HASHSCALE3 = float3(0.1031, 0.1030, 0.0973);

            float hash21(float2 p)
            {
                float3 p3 = frac(float3(p.x, p.y, p.x) * HASHSCALE1);
                p3 += dot(p3, p3.yzx + 19.19);
                return frac((p3.x + p3.y) * p3.z);
            }

            float3 hash23(float2 p)
            {
                float3 p3 = frac(float3(p.x, p.y, p.x) * HASHSCALE3);
                p3 += dot(p3, p3.yxz + 19.19);
                return frac((p3.xxy + p3.yzz) * p3.zyx);
            }

            float2 hash22(float2 p)
            {
                float3 p3 = frac(float3(p.x, p.y, p.x) * HASHSCALE3);
                p3 += dot(p3, p3.yzx + 19.19);
                return frac((p3.xx + p3.yz) * p3.zy);
            }

            float3 paletteCos(float x, float3 A, float3 B, float3 C, float3 D)
            {
                return A + B * cos(2.0 * PI * (C * x + D));
            }

            float3 getGrassColor(float x)
            {
                float r = hash21(float2(x, x * 37.17));
                if (r < _AutumnChance)
                {
                    return paletteCos(x, _AutA.rgb, _AutB.rgb, _AutC.rgb, _AutD.rgb);
                }
                return paletteCos(x, _GreenA.rgb, _GreenB.rgb, _GreenC.rgb, _GreenD.rgb);
            }

            // Returns height proxy z (>=0 if hit, -1 miss). Outputs blade color.
            float getBlade(float2 p, float2 bladePos, out float4 col)
            {
                float3 g3 = hash23(bladePos * 123512.41) * 2.0 - 1.0.xxx;

                // Wind bend — lateral offsets modulate the blade frame.
                float t = _Time.y;
                float2 wdir = normalize(_WindDir.xy + 1e-4);
                g3.xy += _WindStrength * float2(
                    sin((dot(p, wdir) * 2.0 + t) * _WindFreq),
                    cos((dot(p, wdir.yx) * 1.3 + t) * _WindFreq)
                );

                // z in [0, ~0.4], used as simple "height" + lighting normal proxy
                g3.z = g3.z * 0.2 + 0.2;

                float2 dir = normalize(g3.xy);
                float lenRnd = hash21(bladePos * 102348.7);
                float grassLen = lerp(_LengthMinMax.x, _LengthMinMax.y, lenRnd);

                // Switch to blade frame
                float2 gv = p - bladePos;
                float gx = dot(dir, gv);
                float gy = dot(float2(-dir.y, dir.x), gv);
                float gxn = gx / max(grassLen, 1e-6);

                // Width profile (parabolic taper) with subtle wind stretch
                float baseW = _BladeWidth * (1.0 + 0.15 * sin(t * 0.1 + gx * 50.0));
                float halfW = baseW * (1.0 - gxn * gxn);

                if (gxn >= 0.0 && gxn <= 1.0 && abs(gy) <= halfW)
                {
                    float3 c = getGrassColor(hash21(bladePos * 2631.6));

                    // Simple directional light using g3 as a pseudo normal
                    float3 lightDir = normalize(float3(sin(t * 0.7), cos(t * 0.5), 1.0));
                    float lit = 1.0;
                    if (_UseDirLight > 0.5)
                        lit = max(dot(normalize(g3), lightDir), _MinLight);

                    // Darker towards tip/root for depth
                    float shade = 0.2 + 0.8 * gxn;
                    col = float4(c * shade * lit, 1.0);
                    return g3.z * gxn;
                }

                col = float4(0,0,0,1);
                return -1.0;
            }

            float sampleGrass(float2 p, out float4 color)
            {
                // Grid quantization
                float invSpacing = 1.0 / max(_BladeSpacing, 1e-6);
                int xcount = (int)floor(invSpacing);
                int ycount = (int)floor(invSpacing);
                int ox = (int)floor(p.x * (float)xcount);
                int oy = (int)floor(p.y * (float)ycount);

                float maxz = -1.0;

                float aoAccum = 0.0;
                int   aoCount = 0;

                int L = min((int)round(_LookupDist), MAX_LOOKUP);

                [loop]
                for (int i = -MAX_LOOKUP; i <= MAX_LOOKUP; ++i)
                {
                    if (i < -L || i > L) continue;

                    [loop]
                    for (int j = -MAX_LOOKUP; j <= MAX_LOOKUP; ++j)
                    {
                        if (j < -L || j > L) continue;

                        float2 upos = float2(ox + i, oy + j);
                        float2 bladePos = upos * _BladeSpacing + hash22(upos) * _JitterMax;

                        float4 tmp;
                        float z = getBlade(p, bladePos, tmp);

                        if (z > maxz)
                        {
                            maxz = z;
                            color = tmp;
                        }

                        if (_UseAO > 0.5 && z >= 0.0)
                        {
                            aoAccum += 1.0;
                            aoCount++;
                        }
                    }
                }

                if (_UseAO > 0.5 && aoCount > 0 && maxz >= 0.0)
                {
                    float ao = saturate(1.0 - (aoAccum / (float)aoCount) * _AOIntensity);
                    color.rgb *= ao;
                }

                if (maxz < 0.0) color = 0;
                return maxz;
            }

            float2 computeDomain(float2 uv, float3 worldPos)
            {
                // Lerp either UV or XZ into normalized [0..1] domain defined by _DomainMin/Max
                float2 raw = (_UseWorldSpace > 0.5) ? worldPos.xz : uv;
                float2 mn = _DomainMin.xy;
                float2 mx = _DomainMax.xy;
                float2 t = (raw - mn) / max(mx - mn, float2(1e-6, 1e-6));
                return saturate(t);
            }

            float4 genesis (v2f_customrendertexture i)
            {                
                _Time=hash22(i.localTexcoord.xy);
                float2 uv = i.localTexcoord.xy; // already 0..1 (remapped by properties if you wish)
                float3 worldPos=i.globalTexcoord.xyz;
                float4 col;
                float2 p=computeDomain(uv,worldPos);
                sampleGrass(p,col);
                
                return col;
            }

            ENDHLSL
        }
    }
    FallBack Off
}
