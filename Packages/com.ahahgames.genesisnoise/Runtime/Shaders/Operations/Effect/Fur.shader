Shader "Hidden/Genesis/Fur"
{	
	Properties
	{
		// By default a shader node is supposed to handle all the input texture dimension, we use a prefix to determine which one is used
		[Tooltip(Source Texture)][InlineTexture]_Source_2D("Source", 2D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_3D("Source", 3D) = "white" {}
		[Tooltip(Source Texture)][InlineTexture]_Source_Cube("Source", Cube) = "white" {}
		[Tooltip(Color Texture)][InlineTexture]_Color_2D("Color", 2D) = "white" {}
		[Tooltip(Color Texture)][InlineTexture]_Color_3D("Color", 3D) = "white" {}
		[Tooltip(Color Texture)][InlineTexture]_Color_Cube("Color", Cube) = "white" {}
				
		[Tooltip(Fur layers)]_FurLayers("Fur Layers", Range(1,100))=30
		[Tooltip(The depth of the fur)]_furDepth("Fur Depth",Range(0.01,1.0))=0.5
		[Tooltip(View position defines where the result is viewed from)][GenesisVector3]_viewPos("View Position", Vector)=(0,0,1,0)
		[Tooltip(Direction light is aiming)][GenesisVector3]_lightDir("Light direction", Vector)=(0,1,1,0)
		[Tooltip(Use specular highlights)][Enum(No,0,Yes,1)]_useSpec("Specular Highlights", int)=1
		[Tooltip(Specular power increases the total power of the highlight)][VisibleIf(_useSpec,1)]_specPower("Specular Power",Range(0.01,96))=32
		[Tooltip(Specular intensity increases the harshness of the highlight)][VisibleIf(_useSpec,1)]_specularIntensity("Specular intensity",Range(0.01,8))=1
		[Tooltip(Enable Rim Lighting)][Enum(No,0,Yes,1)]_useRimlight("Rim lighting", int)=1
		[Tooltip(Rim light intensity)][VisibleIf(_useRimlight,1)]_rimIntense("Rim light intensity",Range(0.01,1))=0.25
		[Tooltip(Use procedural strand direction)][Enum(No,0,Yes,1)]_useStrandDir("Procedural Strand Dir", int)=100
		[Tooltip(Procedural strand flow scale)]_strandFlowScale("Strand Flow Scale",Range(0.01,4))=1.0

		[Tooltip(Seed value)]_Seed("Seed",int)=52
	}

	SubShader 
	{
		Pass
		{
			HLSLPROGRAM			
			#define BUILTIN_TARGET_API					
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"			
			#pragma vertex CustomRenderTextureVertexShader
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment

			TEXTURE_X(_Source);
			SAMPLER_X(sampler_Source); 
			TEXTURE_X(_Color);
			SAMPLER_X(sampler_Color); 
			int _Seed, _useSpec,_useRimlight,_useStrandDir;
			int _shellCount,_FurLayers,_furDepth;
			float _specPower, _specularIntensity,_rimIntense,_strandFlowScale;
			float3 _viewPos, _lightDir;

			float hash(float2 p)
			{
				return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
			}

			float3 strandDirection(float2 uv)
			{
				// Procedural pseudo-random strand direction based on UV
				float angle = hash(uv * _strandFlowScale) * 6.2831853; // [0, 2π]
				return float3(cos(angle), sin(angle), 0.0); // Tangent-like direction
			}

			float3 ComputeNormal(float2 UV, float texelSize, float3 dir)
			{
				float hL = SAMPLE_X_SAMPLER(_Source, sampler_Source, UV+float2(-texelSize,0), dir).r;
				float hR = SAMPLE_X_SAMPLER(_Source, sampler_Source, UV+float2(texelSize,0), dir).r;
				float hD = SAMPLE_X_SAMPLER(_Source, sampler_Source, UV+float2(0,-texelSize), dir).r;
				float hU = SAMPLE_X_SAMPLER(_Source, sampler_Source, UV+float2(0,texelSize), dir).r;
				// Compute gradient
				float3 dx = float3(2 * texelSize, 0, hR - hL);
				float3 dy = float3(0, 2 * texelSize, hU - hD);

				// Cross product gives normal
				float3 normal = normalize(cross(dx, dy));
				return normal;				
			}

			float4 mixture (v2f_customrendertexture i) : SV_Target
            {
				float texelSize=1.0/_ScreenParams.x*_ScreenParams.y;				
				float furAlpha=SAMPLE_X_SAMPLER(_Source, sampler_Source,i.localTexcoord,i.direction).r;

				// Generate normal
				float3 normal=ComputeNormal(i.localTexcoord,texelSize,i.direction);
				// Normalize vectors
				float3 N = normalize(normal);
				float3 L = normalize(_lightDir);
				float3 V = normalize(_viewPos - i.globalTexcoord);

				float3 strandDir=i.direction;
				if(_useStrandDir)
				{
					// Procedural strand direction (adds anisotropy)
					float3 strandDir = normalize(strandDirection(i.localTexcoord));					
				}
				float strandDot=abs(dot(strandDir,L));
				
				// Diffuse lighting with strand influence
				float diff = max(0.0, dot(N, L) * 0.5 + 0.5) * strandDot;
				float spec=0;
				if(_useSpec)
				{
					// Specular (Blinn-Phong)
					float3 H = normalize(L + V);
					spec = pow(max(dot(N, H), 0.0), _specPower) * _specularIntensity;
				} 

				float rim=0;
				if(_useRimlight)
				{
					 rim = pow(1.0 - saturate(dot(N, V)), 2.0) * _rimIntense;
				}
				float facing = dot(N, V);
				float fade = saturate(1.0 - facing * _furDepth);

				float4 baseColor=SAMPLE_X_SAMPLER(_Color,sampler_Color, i.localTexcoord,i.direction);
				float3 color=baseColor.rgb*diff+spec+rim;
				float alpha=furAlpha*fade;
				
				return float4(color,alpha);
								
			}
			ENDHLSL
		}
	}
}