Shader "Hidden/Genesis/RainEffect"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)]_Source_2D("InputTexture", 2D) = "white" {}
		[InlineTexture(HideInNodeInspector)]_Source_3D("InputTexture", 3D) = "white" {}
		[InlineTexture(HideInNodeInspector)]_Source_Cube("InputTexture", Cube) = "white" {}  
        [Tooltip(Defines the amount of rain on the screen)]
        _rainAmount("Rain Amount", Range(0,1))=0.3
        [Tooltip(Amount of blurring of the screen, makes the rain drops more pronounced)]
        _Distortion("Distortion Srength", Range(0,0.1)) = 0.02        
        [Tooltip(Seed value)]
        _Time("Seed", float)=52.0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Overlay" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET_API					
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            
            #pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV

            TEXTURE_SAMPLER_X(_Source);
            float _rainAmount,_Distortion, _Time;
            
            // Simple hash for randomness
            float hash21(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return frac(p.x * p.y);
            }

            // Procedural droplet distortion
            float2 DropletDistortion(float2 uv, float t)
            {
                float2 grid = uv * 20.0;
                float2 id = floor(grid);
                float2 f = frac(grid) - 0.5;

                float rnd = hash21(id);
                float dropTime = frac(t + rnd);
                float dropY = lerp(-1.0, 1.0, dropTime);

                float2 dropPos = float2(0.0, dropY);
                float dist = length(f - dropPos);

                float mask = smoothstep(0.15, 0.0, dist);
                float2 offset = normalize(f - dropPos) * mask * _Distortion;

                return offset;
            }

            float4 mixture (v2f_customrendertexture i) : SV_Target
			{
                float t=_Time;
                float2 uv=i.localTexcoord.xy;

                // Accumulate distortion from multiple droplets
                // TODO: Maybe consider a loop for this and make it user adjustable
                float2 distortion = 0;
                distortion += DropletDistortion(uv, t);
                distortion += DropletDistortion(uv * 1.5, t * 0.8 + 13.1);
                distortion += DropletDistortion(uv * 0.75, t * 1.2 + 7.7);
              
                float2 val=uv+distortion;
                float3 final=float3(val.x,val.y,0);
                float3 col=SAMPLE_X(_Source, float3(uv+distortion,0), i.direction).rgb;
                return float4(col.x,col.y,col.z,1.0);

            }
            ENDHLSL
        }
    }
}