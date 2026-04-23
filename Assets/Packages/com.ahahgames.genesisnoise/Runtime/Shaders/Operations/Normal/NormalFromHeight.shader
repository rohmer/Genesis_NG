Shader "Hidden/Genesis/NormalFromHeight"
{
    Properties
    {
        [NoScaleOffset]Texture2D_B5DB8B20("Height Map", 2D) = "grey" {}
        Vector1_C30F1996("Strength", Float) = 10
        [ToggleUI]UnsignedNormalized("UnsignedNormalized", Float) = 1
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
        float4 Texture2D_B5DB8B20_TexelSize;
        float Vector1_C30F1996;
        float UnsignedNormalized;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Trilinear_Repeat);
        TEXTURE2D(Texture2D_B5DB8B20);
        SAMPLER(samplerTexture2D_B5DB8B20);
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
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
        
        void Unity_Remap_float3(float3 In, float2 InMinMax, float2 OutMinMax, out float3 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
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
            float _Property_8b51c85288e1450b942c9e0dc22aaa09_Out_0_Boolean = UnsignedNormalized;
            UnityTexture2D _Property_21759bbc082b45df9fc89e518b36a04d_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_B5DB8B20);
            float4 _UV_a2e359560bef44fdb6156d677619ad52_Out_0_Vector4 = IN.uv0;
            float _Property_8266cb9e536f436cbcf06e7aa4733e15_Out_0_Float = Vector1_C30F1996;
            Bindings_HeightMapToDeriv_f5ecd5b529c562a49b96d8a76d0c7182_float _HeightMapToDeriv_31bd2fed2aaa4111bc92971ca470f763;
            float2 _HeightMapToDeriv_31bd2fed2aaa4111bc92971ca470f763_derivdHduv_1_Vector2;
            float3 _HeightMapToDeriv_31bd2fed2aaa4111bc92971ca470f763_NormalTS_2_Vector3;
            SG_HeightMapToDeriv_f5ecd5b529c562a49b96d8a76d0c7182_float(_Property_21759bbc082b45df9fc89e518b36a04d_Out_0_Texture2D, UnityBuildSamplerStateStruct(SamplerState_Trilinear_Repeat), (_UV_a2e359560bef44fdb6156d677619ad52_Out_0_Vector4.xy), _Property_8266cb9e536f436cbcf06e7aa4733e15_Out_0_Float, 1, _HeightMapToDeriv_31bd2fed2aaa4111bc92971ca470f763, _HeightMapToDeriv_31bd2fed2aaa4111bc92971ca470f763_derivdHduv_1_Vector2, _HeightMapToDeriv_31bd2fed2aaa4111bc92971ca470f763_NormalTS_2_Vector3);
            float3 _Remap_60093b1e8bfb4d80bfedeb49df5da4be_Out_3_Vector3;
            Unity_Remap_float3(_HeightMapToDeriv_31bd2fed2aaa4111bc92971ca470f763_NormalTS_2_Vector3, float2 (-1, 1), float2 (0, 1), _Remap_60093b1e8bfb4d80bfedeb49df5da4be_Out_3_Vector3);
            float3 _Branch_a23553dc266d4117a942d51275a46203_Out_3_Vector3;
            Unity_Branch_float3(_Property_8b51c85288e1450b942c9e0dc22aaa09_Out_0_Boolean, _Remap_60093b1e8bfb4d80bfedeb49df5da4be_Out_3_Vector3, _HeightMapToDeriv_31bd2fed2aaa4111bc92971ca470f763_NormalTS_2_Vector3, _Branch_a23553dc266d4117a942d51275a46203_Out_3_Vector3);
            surface.BaseColor = _Branch_a23553dc266d4117a942d51275a46203_Out_3_Vector3;
            surface.Alpha = float(1);
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