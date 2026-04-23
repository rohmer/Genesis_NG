﻿Shader "Hidden/Genesis/Lines"
{	
	Properties
	{	
         [Enum(Disable,0,Enable,1)]_RandomColors("Random Colors",int)=1
         [VisibleIf(_RandomColors,0)]
         _LineColor("Line Color",Color)=(1,1,1,1)
        _Background  ("Background", Color) = (0,0,0,1)

        _LineWidth   ("Line Width", Range(0.0005, 0.02)) = 0.003
        _Feather     ("Edge Feather", Range(0, 0.02))     = 0.0015

        _LineCount   ("Line Count", Range(1, 512)) = 128
        _Seed        ("Seed", Float)               = 1.0

        _LengthMin   ("Length Min", Range(0.01, 1.5)) = 0.10
        _LengthMax   ("Length Max", Range(0.01, 1.5)) = 0.60

        _AngleMin    ("Angle Min (deg)", Range(0,180)) = 0
        _AngleMax    ("Angle Max (deg)", Range(0,180)) = 180

        _Animate     ("Animate (0/1)", Range(0,1)) = 1
        _TimeScale   ("Time Scale", Range(0,5))    = 0.25
        _Jitter      ("Jitter (wrap-around)", Range(0,0.5)) = 0.0


    }

	SubShader
    {
    	Tags { "RenderType"="Opaque" }
		LOD 100
		Cull Off
        ZWrite Off
        ZTest Always
        Blend One Zero
 
		Pass
		{
			HLSLPROGRAM
			#define BUILTIN_TARGET_API					
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
		    float4 _Color;
            float4 _Background;

            float  _LineWidth;
            float  _Feather;

            float  _LineCount;
            float  _Seed;

            float  _LengthMin;
            float  _LengthMax;

            float  _AngleMin;
            float  _AngleMax;

            float  _Animate;
            float  _TimeScale;
            float  _Jitter;
            int _RandomColors;
            float2 _Time;

            float hash(float n) { return frac(sin(n) * 43758.5453); }
            float2 hash2(float n)
            {
                float2 s = sin(float2(n, n + 1.2345)) * 43758.5453;
                return frac(s);
            }
            float3 hash3(float n)
            {
                float3 s = sin(float3(n, n+1.2345, n+2.3456)) * 43758.5453;
                return frac(s);
            }

            float sdSegment(float2 p, float2 a, float2 b)
            {
                float2 pa = p - a;
                float2 ba = b - a;
                float  h  = saturate(dot(pa, ba) / dot(ba, ba));
                return length(pa - ba * h);
            }



			float4 genesis(v2f_customrendertexture i)
			{	
                float aspect = _ScreenParams.x / _ScreenParams.y;
                float2 p = float2(i.localTexcoord.x * aspect, i.localTexcoord.y);
                float t = (_Animate >= 0.5) ? (_Time.y * _TimeScale) : 0.0;

                int count = max(1, (int)_LineCount);
                float lenMin = min(_LengthMin, _LengthMax);
                float lenMax = max(_LengthMin, _LengthMax);

                float3 accumColor = _Background.rgb;
                float accumAlpha  = _Background.a;

                [loop]
                for (int idx = 0; idx < count; idx++)
                {
                    float base = _Seed + idx;

                    float2 c = hash2(base + 17.0);
                    if (_Jitter > 0.0 || _Animate >= 0.5)
                    {
                        float stepPhase = floor(t * 10.0);
                        float2 j = (hash2(base + 97.0 + stepPhase) - 0.5) * _Jitter;
                        c = frac(c + j);
                    }

                    float aDeg = lerp(_AngleMin, _AngleMax, hash(base + 23.0));
                    float aRad = radians(aDeg);
                    aRad += (_Animate >= 0.5) ? ((hash(base + 41.0) - 0.5) * 0.5 * t) : 0.0;

                    float2 dir = float2(cos(aRad), sin(aRad));
                    float len = lerp(lenMin, lenMax, hash(base + 29.0));

                    float2 dirA = normalize(float2(dir.x * aspect, dir.y));
                    float2 a = float2(c.x * aspect, c.y) - 0.5 * len * dirA;
                    float2 b = float2(c.x * aspect, c.y) + 0.5 * len * dirA;

                    float d = sdSegment(p, a, b);
                    float alpha = 1.0 - smoothstep(_LineWidth, _LineWidth + _Feather, d);

                    // Per-line random color
                    float3 lineCol = hash3(base * 13.17) * alpha;

                    // Alpha blending over background
                    accumColor = lerp(accumColor, lineCol, alpha);
                    accumAlpha = lerp(accumAlpha, 1.0, alpha);
                }
                if(_RandomColors==1)
                    return float4(accumColor, accumAlpha);
                else
                {
                    if(accumColor.x>0.0 && accumColor.y>0.0 && accumColor.z>0.0 && accumAlpha==1)
                        return float4(1,1,1,1);
                    else
                        return float4(0,0,0,1);
                }


			}
			ENDHLSL
		}
	}
}
