﻿Shader "Hidden/Genesis/Circles"
{	
	Properties
	{				        
        circleCount("Circle/Sphere Count",Range(1,1000))=1
        minRadius("Minimum Radius",Range(1,100))=10
        maxRadius("Maximum Radius",Range(1,100))=10
        [Enum(Disabled,0,Enabled,1)] _RandomColors("Random Colors", int)=1
        [VisibleIf(_RandomColors,1)]
        [GenesisColor]_StartColor("Start Color", Color)=(0.5,0.5,0,1)
        [VisibleIf(_RandomColors,1)]
        [GenesisColor]_EndColor("End Color", Color)=(0,0,1,1)
        [VisibleIf(_RandomColors,0)]
        [GenesisColor]_CircleColor("Color",Color)=(0.9,0.9,0.9,1)
        [Enum(Disabled,0,Enabled,1)] _ScaleToRes("Scale to Resolution",int)=0
        _CameraPos("Sphere Camera Pos", Vector)=(0,-1,0)
        _LightDir("Sphere Light Dir", Vector)=(0,1,0)

    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        Cull Off ZWrite Off ZTest Always
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

            int _RandomColors;
            float4 _StartColor,_EndColor,_CircleColor;
            int circleCount;
            float minRadius;
            float maxRadius;
            float2 resolution;
            float time;
            int _ScaleToRes;
            float3 _CameraPos,_LightDir;

            float hash(float2 p)
            {
                return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
            }

            float2 hash2(float2 p)
            {
                return frac(sin(float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)))) * 43758.5453);
            }

            float hash(float3 p)
            {
                return frac(sin(dot(p, float3(127.1, 311.7, 74.7))) * 43758.5453);
            }

            float3 hash3(float3 p)
            {
                return frac(sin(float3(
                    dot(p, float3(127.1, 311.7, 74.7)),
                    dot(p, float3(269.5, 183.3, 246.1)),
                    dot(p, float3(113.5, 271.9, 124.6))
                )) * 43758.5453);
            }

            float sdSphere(float3 p, float3 center, float radius)
            {
                return length(p - center) - radius;
            }

            float3 estimateNormal(float3 p)
            {
                float eps = 0.001;
                float3 n;
                n.x = sdSphere(p + float3(eps, 0, 0), p, eps) - sdSphere(p - float3(eps, 0, 0), p, eps);
                n.y = sdSphere(p + float3(0, eps, 0), p, eps) - sdSphere(p - float3(0, eps, 0), p, eps);
                n.z = sdSphere(p + float3(0, 0, eps), p, eps) - sdSphere(p - float3(0, 0, eps), p, eps);
                return normalize(n);
            }

            float renderCircle(float2 uv, float2 center, float radius)
            {
                float dist = length(uv - center);
                return smoothstep(radius, radius - 0.01, dist); // Soft edge
            }

            float4 createCircles(float2 uv)
            {
                float2 resolution=_ScreenParams.xy;
                if(_ScaleToRes==1)
                    uv *= resolution; // Scale to pixel space                
                else
                    uv *=float2(1024,1024);

                float2 normUV = uv / resolution; // Normalize to [0,1]

                float3 color = float3(0, 0, 0);

                for (int i = 0; i < circleCount; ++i)
                {
                    float2 seed = float2(i, time);
                    float2 randPos = hash2(seed) * resolution;
                    float randRadius = lerp(minRadius, maxRadius, hash(seed + 0.5));

                    float alpha = renderCircle(uv, randPos, randRadius);
                    float3 circleColor;
                    if(_RandomColors==0)
                    {
                        circleColor=_CircleColor.xyz;
                    } else
                    {
                        float rand=hash(randPos+i);
                        circleColor=lerp(_StartColor,_EndColor,rand);
                    }
                    
                    color += alpha * circleColor;
                }

                return float4(saturate(color), 1.0);
            }

            float4 createSpheres(float2 uv)
            {
                float2 normUV = (uv * 2.0 - 1.0) * float2(resolution.x / resolution.y, 1.0);
                float3 forward = float3(0, 0, -1);
                float3 right = float3(1, 0, 0);
                float3 up = float3(0, 1, 0);
                float3 rayDir = normalize(forward + normUV.x * right + normUV.y * up);

                float t = 0.0;
                float maxDist = 20.0;
                int maxSteps = 128;
                float eps = 0.001;

                float3 color = float3(0, 0, 0);

                for (int i = 0; i < maxSteps; ++i)
                {
                    float3 p = _CameraPos + rayDir * t;
                    float minDist = 1e5;
                    float3 hitColor = float3(0, 0, 0);
                    float3 hitPos = p;
                    bool hit = false;

                    for (int j = 0; j < circleCount; ++j)
                    {
                        float3 seed = float3(j, time, j * 3.14);
                        float3 spherePos = hash3(seed) * 10.0 - 5.0;
                        float radius = lerp(minRadius, maxRadius, hash(seed + 1.0));

                        float dist = sdSphere(p, spherePos, radius);
                        if (dist < minDist)
                        {
                            minDist = dist;
                            hitColor = hash3(seed + 2.0);
                            hitPos = spherePos;
                            hit = true;
                        }
                    }

                    if (minDist < eps)
                    {
                        float3 normal = estimateNormal(p);
                        float diff = saturate(dot(normal, -_LightDir));
                        color = hitColor * diff;
                        break;
                    }

                    if (t > maxDist) break;
                    t += minDist;
                }

                return float4(color, 1.0);

            }
            float4 genesis(v2f_customrendertexture i)
			{
			    #if CRT_2D
                    return createCircles(i.localTexcoord.xy);
                #else
                    return createSpheres(i.localTexcoord.xy);
                #endif               
            }
            ENDHLSL
        }
    }
}