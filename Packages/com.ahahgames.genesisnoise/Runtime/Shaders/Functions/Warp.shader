Shader "Hidden/Genesis/Warp"
{
    Properties
    {
        [NoScaleOffset]Texture2D_2a477a8e2c4e4d239a82974de4948550("Input", 2D) = "white" {}
        [NoScaleOffset]Texture2D_49e0c5c6961a4b3c8da31529eaa3172a("Gradient", 2D) = "black" {}
        Vector1_d27f7af35354444ebf1e0efe1f69cd1f("Intensity", Range(-5, 5)) = 1
    }
    SubShader
    {
        Tags
        {
            // RenderPipeline: <None>
            // RenderType: <None>
            // Queue: <None>
            // DisableBatching: <None>
            "ShaderGraphShader"="true"
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                // LightMode: <None>
            }
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
        	Lighting Off
        	Blend One Zero
        
        	HLSLPROGRAM
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        	#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/CustomRenderTexture/CustomTexture.hlsl"
        	#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/CustomRenderTexture/CustomTextureGraph.hlsl"
        	#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
        
        	#pragma vertex CustomRenderTextureVertexShader
        	#pragma fragment frag
        	#pragma target 3.0
        
            // Pragmas
            // PassPragmas: <None>
        
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
        
        	struct SurfaceDescriptionInputs
        	{
        		// update input values
        		float4	uv0;
        		float4	uv1;
        		uint	primitiveID;
        		float3	direction;
        
        		// ShaderGraph accessors:
        		float3 WorldSpaceViewDirection;
        		float3 ObjectSpaceViewDirection;
        		float3 ObjectSpacePosition;
        		float3 TimeParameters;
        		float3 WorldSpaceNormal;
        		float3 ObjectSpaceNormal;
        		float2 NDCPosition;
        		float4 ScreenPosition;
        	};
        
        	SurfaceDescriptionInputs ConvertV2FToSurfaceInputs( v2f_customrendertexture IN )
        	{
        		SurfaceDescriptionInputs o;
        		
        		o.uv0 = float4(IN.localTexcoord, 0);
        		o.uv1 = float4(IN.globalTexcoord, 0);
        		o.primitiveID = IN.primitiveID;
        		o.direction = normalize(IN.direction);
        
        		// other space of view direction are not supported
        
        // 		$SurfaceDescriptionInputs.ObjectSpaceNormal							o.ObjectSpaceNormal = o.direction;
        //    ^ ERROR: unrecognized command: SurfaceDescriptionInputs
        
        
        		// Unsupported properties:
        
        		// We can't fake the positions because we can't differentiate Cube and 2D custom render textures
        
        		return o;
        	}
        
        	// --------------------------------------------------
        	// Graph
        
        	// Graph Properties
        	CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_2a477a8e2c4e4d239a82974de4948550_TexelSize;
        float4 Texture2D_49e0c5c6961a4b3c8da31529eaa3172a_TexelSize;
        float Vector1_d27f7af35354444ebf1e0efe1f69cd1f;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Clamp);
        SAMPLER(SamplerState_Trilinear_Repeat);
        TEXTURE2D(Texture2D_2a477a8e2c4e4d239a82974de4948550);
        SAMPLER(samplerTexture2D_2a477a8e2c4e4d239a82974de4948550);
        TEXTURE2D(Texture2D_49e0c5c6961a4b3c8da31529eaa3172a);
        SAMPLER(samplerTexture2D_49e0c5c6961a4b3c8da31529eaa3172a);
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        // unity-custom-func-begin
        void smoothDeriv_float(TEXTURE2D(hmap), SAMPLER(samp), float2 texST, float isUpscaleHQ, out float2 deriv){
        #pragma target 4.5
        
        #ifdef SHADERGRAPH_PREVIEW
        
        	float lod = 0;
        #else
        
        	float lod = hmap.CalculateLevelOfDetail(samp, texST);
        
        #endif
        
        
        
        	uint2 dimension;
        
        	hmap.GetDimensions(dimension.x, dimension.y);
        
        	float2 onePixOffs = float2(1.0/dimension.x, 1.0/dimension.y);
        
        
        
        	float eoffs = exp2(lod);
        
        	float2 actualOffs = onePixOffs*eoffs;
        
        
        
        	float2 st_c = texST;
        
        	float2 st_r = st_c+float2(actualOffs.x, 0.0);
        
        	float2 st_u = st_c+float2(0.0, actualOffs.y);
        
        
        
        	float Hr = hmap.Sample(samp, st_r).x;
        
        	float Hu = hmap.Sample(samp, st_u).x;
        
        	float Hc = hmap.Sample(samp, st_c).x;
        
        
        
        	float2 dHduv = float2(Hr-Hc, Hu-Hc)/eoffs;
        
        
        
        
        
        #ifdef SHADERGRAPH_PREVIEW
        #else
        
        	float start = 0.5;		// smooth upscale fades in
        
        	float end = 0.05;		// 100% smooth method
        
        	
        
        	float mix = saturate( (lod-start) / (end - start) );
        
        	
        
        	if(isUpscaleHQ && mix>0.0)
        
        	{
        
        		float2 f2TexCoord = dimension*texST-float2(0.5,0.5);
        
        		float2 f2FlTexCoord = floor(f2TexCoord);
        
        		float2 t = saturate(f2TexCoord - f2FlTexCoord);
        
        
        
        		const float4 vSamplesUL = hmap.Gather( samp, (f2FlTexCoord+float2(-1.0,-1.0) + float2(0.5,0.5))/dimension );
        
        		const float4 vSamplesUR = hmap.Gather( samp, (f2FlTexCoord+float2(1.0,-1.0) + float2(0.5,0.5))/dimension );
        
        		const float4 vSamplesLL = hmap.Gather( samp, (f2FlTexCoord+float2(-1.0,1.0) + float2(0.5,0.5))/dimension );
        
        		const float4 vSamplesLR = hmap.Gather( samp, (f2FlTexCoord+float2(1.0,1.0) + float2(0.5,0.5))/dimension );
        
        		
        
        		// scanlines are given in the horizontal direction. For instance float4(UL.wz, UR.wz) represents a scanline
        
        		float4x4 H = {  vSamplesUL.w, vSamplesUL.z, vSamplesUR.w, vSamplesUR.z,
        
        						vSamplesUL.x, vSamplesUL.y, vSamplesUR.x, vSamplesUR.y,
        
        						vSamplesLL.w, vSamplesLL.z, vSamplesLR.w, vSamplesLR.z,
        
        						vSamplesLL.x, vSamplesLL.y, vSamplesLR.x, vSamplesLR.y };
        
        
        
        		float2 A = float2((1.0-t.x), t.x);
        
        		float2 B = float2((1.0-t.y), t.y);
        
        
        
        		//float4x2 diffMat = 0.5 * float4x2( float2(-1.0, 0.0), float2(0.0, -1.0), float2(1.0, 0.0), float2(0.0, 1.0) );
        
        		//float2x4 blurMat = 0.25 * float2x4( float4(1.0, 2.0, 1.0, 0.0), float4(0.0, 1.0, 2.0, 1.0) );
        
        		//float2x2 matdHdu = mul(blurMat, mul( H, diffMat));
        
        		//float2x2 matdHdv = mul(blurMat, mul( transpose(H), diffMat));
        
        		//float2 dHduv = float2( dot(B, mul( matdHdu, A)), dot(A, mul( matdHdv, B)) );
        
        
        
        		float4 X = 0.25*float4(A.x, 2*A.x+A.y, A.x+2*A.y, A.y);				//	mul(A, blurMat);
        
        		float4 Y = 0.25*float4(B.x, 2*B.x+B.y, B.x+2*B.y, B.y);				//	mul(B, blurMat);
        
        		float4 dX = 0.5*float4(-A.x, -A.y, A.x, A.y);						//  mul(diffMat, A);
        
        		float4 dY = 0.5*float4(-B.x, -B.y, B.x, B.y);						//  mul(diffMat, B);
        
        
        
        		float2 dHduv_smooth = float2( dot(Y, mul(H, dX)), dot(dY, mul(H, X)) );
        
        		dHduv = lerp(dHduv, dHduv_smooth, mix);
        
        	}
        #endif	
        
        	deriv = dHduv;
        }
        // unity-custom-func-end
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        void Unity_Negate_float2(float2 In, out float2 Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        struct Bindings_HeightMapToDeriv_f5ecd5b529c562a49b96d8a76d0c7182_float
        {
        };
        
        void SG_HeightMapToDeriv_f5ecd5b529c562a49b96d8a76d0c7182_float(UnityTexture2D Texture2D_63FC87EE, UnitySamplerState SamplerState_41637c985b3c4d6fa0ef99c9cb9aeb17, float2 Vector2_63281F45, float Vector1_69A73678, float Boolean_C3CE8264, Bindings_HeightMapToDeriv_f5ecd5b529c562a49b96d8a76d0c7182_float IN, out float2 derivdHduv_1, out float3 NormalTS_2)
        {
        float _Property_34c3a055ce4c49d09c8413a4c0b5d54c_Out_0_Float = Vector1_69A73678;
        UnityTexture2D _Property_5309c78e20324c08b1dd7924afdf35f1_Out_0_Texture2D = Texture2D_63FC87EE;
        UnitySamplerState _Property_c06ea6d5395a4a2485276641b6f42b96_Out_0_SamplerState = SamplerState_41637c985b3c4d6fa0ef99c9cb9aeb17;
        float2 _Property_1d4d6500b262410ea2731b322a488582_Out_0_Vector2 = Vector2_63281F45;
        float _Property_aec074fccff647ec87e300fe2f5ddcf0_Out_0_Boolean = Boolean_C3CE8264;
        float2 _smoothDerivCustomFunction_408b0add76024d72874e296897025bab_deriv_3_Vector2;
        smoothDeriv_float(_Property_5309c78e20324c08b1dd7924afdf35f1_Out_0_Texture2D.tex, _Property_c06ea6d5395a4a2485276641b6f42b96_Out_0_SamplerState.samplerstate, _Property_1d4d6500b262410ea2731b322a488582_Out_0_Vector2, _Property_aec074fccff647ec87e300fe2f5ddcf0_Out_0_Boolean, _smoothDerivCustomFunction_408b0add76024d72874e296897025bab_deriv_3_Vector2);
        float2 _Multiply_8f89313568b74dfda0203db0d4343ae8_Out_2_Vector2;
        Unity_Multiply_float2_float2((_Property_34c3a055ce4c49d09c8413a4c0b5d54c_Out_0_Float.xx), _smoothDerivCustomFunction_408b0add76024d72874e296897025bab_deriv_3_Vector2, _Multiply_8f89313568b74dfda0203db0d4343ae8_Out_2_Vector2);
        float2 _Negate_d62f1bbce9fb49068c591adfb0de890f_Out_1_Vector2;
        Unity_Negate_float2(_Multiply_8f89313568b74dfda0203db0d4343ae8_Out_2_Vector2, _Negate_d62f1bbce9fb49068c591adfb0de890f_Out_1_Vector2);
        float _Split_616acae22e724cc38d80886aa550b156_R_1_Float = _Negate_d62f1bbce9fb49068c591adfb0de890f_Out_1_Vector2[0];
        float _Split_616acae22e724cc38d80886aa550b156_G_2_Float = _Negate_d62f1bbce9fb49068c591adfb0de890f_Out_1_Vector2[1];
        float _Split_616acae22e724cc38d80886aa550b156_B_3_Float = 0;
        float _Split_616acae22e724cc38d80886aa550b156_A_4_Float = 0;
        float3 _Vector3_25760bbb8d154f0da467076001900113_Out_0_Vector3 = float3(_Split_616acae22e724cc38d80886aa550b156_R_1_Float, _Split_616acae22e724cc38d80886aa550b156_G_2_Float, float(1));
        float3 _Normalize_beca1558b1844c5db6572de37b85cde9_Out_1_Vector3;
        Unity_Normalize_float3(_Vector3_25760bbb8d154f0da467076001900113_Out_0_Vector3, _Normalize_beca1558b1844c5db6572de37b85cde9_Out_1_Vector3);
        derivdHduv_1 = _Multiply_8f89313568b74dfda0203db0d4343ae8_Out_2_Vector2;
        NormalTS_2 = _Normalize_beca1558b1844c5db6572de37b85cde9_Out_1_Vector3;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        	// Graph Pixel
        	struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_caf3779b71ca45ce9cc6c3b805d8bc53_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_2a477a8e2c4e4d239a82974de4948550);
            float4 _UV_db89e323a27e48049e273389517c176c_Out_0_Vector4 = IN.uv0;
            UnityTexture2D _Property_8f83ba4f7b8f4fdb91f94f50468f387f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_49e0c5c6961a4b3c8da31529eaa3172a);
            float4 _UV_a7edb2c3c7ed47cea0020c21f5d30f38_Out_0_Vector4 = IN.uv0;
            float _Property_af5f5c8429964ed191b5db7687e7b0c9_Out_0_Float = Vector1_d27f7af35354444ebf1e0efe1f69cd1f;
            float _Multiply_87febb22ff434e24ba934ccf83a1ee9b_Out_2_Float;
            Unity_Multiply_float_float(_Property_af5f5c8429964ed191b5db7687e7b0c9_Out_0_Float, 10, _Multiply_87febb22ff434e24ba934ccf83a1ee9b_Out_2_Float);
            Bindings_HeightMapToDeriv_f5ecd5b529c562a49b96d8a76d0c7182_float _HeightMapToDeriv_27c5a48c74d84588aacc0aa8749d7791;
            float2 _HeightMapToDeriv_27c5a48c74d84588aacc0aa8749d7791_derivdHduv_1_Vector2;
            float3 _HeightMapToDeriv_27c5a48c74d84588aacc0aa8749d7791_NormalTS_2_Vector3;
            SG_HeightMapToDeriv_f5ecd5b529c562a49b96d8a76d0c7182_float(_Property_8f83ba4f7b8f4fdb91f94f50468f387f_Out_0_Texture2D, UnityBuildSamplerStateStruct(SamplerState_Trilinear_Repeat), (_UV_a7edb2c3c7ed47cea0020c21f5d30f38_Out_0_Vector4.xy), _Multiply_87febb22ff434e24ba934ccf83a1ee9b_Out_2_Float, 1, _HeightMapToDeriv_27c5a48c74d84588aacc0aa8749d7791, _HeightMapToDeriv_27c5a48c74d84588aacc0aa8749d7791_derivdHduv_1_Vector2, _HeightMapToDeriv_27c5a48c74d84588aacc0aa8749d7791_NormalTS_2_Vector3);
            float3 _Add_5292916aaa444ab398adc78c5d8a67a1_Out_2_Vector3;
            Unity_Add_float3((_UV_db89e323a27e48049e273389517c176c_Out_0_Vector4.xyz), _HeightMapToDeriv_27c5a48c74d84588aacc0aa8749d7791_NormalTS_2_Vector3, _Add_5292916aaa444ab398adc78c5d8a67a1_Out_2_Vector3);
            float4 _SampleTexture2D_4c606194ccfc4000891fcb61d8c51387_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_caf3779b71ca45ce9cc6c3b805d8bc53_Out_0_Texture2D.tex, UnityBuildSamplerStateStruct(SamplerState_Linear_Clamp).samplerstate, _Property_caf3779b71ca45ce9cc6c3b805d8bc53_Out_0_Texture2D.GetTransformedUV((_Add_5292916aaa444ab398adc78c5d8a67a1_Out_2_Vector3.xy)) );
            float _SampleTexture2D_4c606194ccfc4000891fcb61d8c51387_R_4_Float = _SampleTexture2D_4c606194ccfc4000891fcb61d8c51387_RGBA_0_Vector4.r;
            float _SampleTexture2D_4c606194ccfc4000891fcb61d8c51387_G_5_Float = _SampleTexture2D_4c606194ccfc4000891fcb61d8c51387_RGBA_0_Vector4.g;
            float _SampleTexture2D_4c606194ccfc4000891fcb61d8c51387_B_6_Float = _SampleTexture2D_4c606194ccfc4000891fcb61d8c51387_RGBA_0_Vector4.b;
            float _SampleTexture2D_4c606194ccfc4000891fcb61d8c51387_A_7_Float = _SampleTexture2D_4c606194ccfc4000891fcb61d8c51387_RGBA_0_Vector4.a;
            float _Split_b24e8dbae9834bf3a59a7383c8f47fe1_R_1_Float = _SampleTexture2D_4c606194ccfc4000891fcb61d8c51387_RGBA_0_Vector4[0];
            float _Split_b24e8dbae9834bf3a59a7383c8f47fe1_G_2_Float = _SampleTexture2D_4c606194ccfc4000891fcb61d8c51387_RGBA_0_Vector4[1];
            float _Split_b24e8dbae9834bf3a59a7383c8f47fe1_B_3_Float = _SampleTexture2D_4c606194ccfc4000891fcb61d8c51387_RGBA_0_Vector4[2];
            float _Split_b24e8dbae9834bf3a59a7383c8f47fe1_A_4_Float = _SampleTexture2D_4c606194ccfc4000891fcb61d8c51387_RGBA_0_Vector4[3];
            surface.BaseColor = (_SampleTexture2D_4c606194ccfc4000891fcb61d8c51387_RGBA_0_Vector4.xyz);
            surface.Alpha = _Split_b24e8dbae9834bf3a59a7383c8f47fe1_A_4_Float;
            return surface;
        }
        
        	float4 frag(v2f_customrendertexture IN) : SV_Target
        	{
        		SurfaceDescriptionInputs surfaceInput = ConvertV2FToSurfaceInputs(IN);
        		SurfaceDescription surface = SurfaceDescriptionFunction(surfaceInput);
        
        		return float4(surface.BaseColor, surface.Alpha);
        	}
        	ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}