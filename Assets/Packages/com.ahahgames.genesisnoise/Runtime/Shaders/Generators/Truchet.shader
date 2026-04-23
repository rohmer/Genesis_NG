Shader "Hidden/Genesis/Truchet"
{
    Properties
    {
        _Tiling("Tiling", Vector, 2) = (5, 5, 0, 0)
        _Seed("Seed", Int) = 52
        _Repetition("Repetition", Int) = 3
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
        float2 _Tiling;
        float _Seed;
        float _Repetition;
        CBUFFER_END
        
        
        // Object and Global properties
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Ceiling_float2(float2 In, out float2 Out)
        {
            Out = ceil(In);
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sign_float(float In, out float Out)
        {
            Out = sign(In);
        }
        
        void Unity_Fraction_float2(float2 In, out float2 Out)
        {
            Out = frac(In);
        }
        
        void Unity_OneMinus_float2(float2 In, out float2 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Minimum_float(float A, float B, out float Out)
        {
            Out = min(A, B);
        };
        
        void Unity_Fraction_float(float In, out float Out)
        {
            Out = frac(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        struct Bindings_Truchet_443a06ee36571b848aa0cc4eb4f681b4_float
        {
        half4 uv0;
        };
        
        void SG_Truchet_443a06ee36571b848aa0cc4eb4f681b4_float(float2 _tiling, float _seed, float _repetition, Bindings_Truchet_443a06ee36571b848aa0cc4eb4f681b4_float IN, out float Out_1)
        {
        float _Property_d870e879a0d1db8a841c61b19745d769_Out_0_Float = _repetition;
        float2 _Property_d83fb46e71e99d83a94d63a6600d54bc_Out_0_Vector2 = _tiling;
        float2 _TilingAndOffset_33ebf501a454a486871fd6d7d91b5888_Out_3_Vector2;
        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_d83fb46e71e99d83a94d63a6600d54bc_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_33ebf501a454a486871fd6d7d91b5888_Out_3_Vector2);
        float2 _Ceiling_74477c623383c78caf562638c8643af9_Out_1_Vector2;
        Unity_Ceiling_float2(_TilingAndOffset_33ebf501a454a486871fd6d7d91b5888_Out_3_Vector2, _Ceiling_74477c623383c78caf562638c8643af9_Out_1_Vector2);
        float _Length_956ccab6f0af248e97ec5c9860138951_Out_1_Float;
        Unity_Length_float2(_Ceiling_74477c623383c78caf562638c8643af9_Out_1_Vector2, _Length_956ccab6f0af248e97ec5c9860138951_Out_1_Float);
        float _Property_432583befd4fbf8c89982283c76d43d5_Out_0_Float = _seed;
        float _Multiply_1794450e91046d8b8b8a4fbc17e0bf58_Out_2_Float;
        Unity_Multiply_float_float(_Length_956ccab6f0af248e97ec5c9860138951_Out_1_Float, _Property_432583befd4fbf8c89982283c76d43d5_Out_0_Float, _Multiply_1794450e91046d8b8b8a4fbc17e0bf58_Out_2_Float);
        float _Cosine_818804a0b30d9080a6c3eb1a4ad5f67f_Out_1_Float;
        Unity_Cosine_float(_Multiply_1794450e91046d8b8b8a4fbc17e0bf58_Out_2_Float, _Cosine_818804a0b30d9080a6c3eb1a4ad5f67f_Out_1_Float);
        float _Sign_731f02f9348a1084b28e61d319a8ddc6_Out_1_Float;
        Unity_Sign_float(_Cosine_818804a0b30d9080a6c3eb1a4ad5f67f_Out_1_Float, _Sign_731f02f9348a1084b28e61d319a8ddc6_Out_1_Float);
        float _Split_accd05460635048d923d30f91d7775ec_R_1_Float = _TilingAndOffset_33ebf501a454a486871fd6d7d91b5888_Out_3_Vector2[0];
        float _Split_accd05460635048d923d30f91d7775ec_G_2_Float = _TilingAndOffset_33ebf501a454a486871fd6d7d91b5888_Out_3_Vector2[1];
        float _Split_accd05460635048d923d30f91d7775ec_B_3_Float = 0;
        float _Split_accd05460635048d923d30f91d7775ec_A_4_Float = 0;
        float _Multiply_86f3fb89ccf8698295790be1e1fe8b81_Out_2_Float;
        Unity_Multiply_float_float(_Sign_731f02f9348a1084b28e61d319a8ddc6_Out_1_Float, _Split_accd05460635048d923d30f91d7775ec_R_1_Float, _Multiply_86f3fb89ccf8698295790be1e1fe8b81_Out_2_Float);
        float2 _Vector2_0bb7b8b50fa35a89ad0868729a478d15_Out_0_Vector2 = float2(_Multiply_86f3fb89ccf8698295790be1e1fe8b81_Out_2_Float, _Split_accd05460635048d923d30f91d7775ec_G_2_Float);
        float2 _Fraction_bb86df7d67ecdf8dbbec1e5f6d2d1f0a_Out_1_Vector2;
        Unity_Fraction_float2(_Vector2_0bb7b8b50fa35a89ad0868729a478d15_Out_0_Vector2, _Fraction_bb86df7d67ecdf8dbbec1e5f6d2d1f0a_Out_1_Vector2);
        float _Length_46c2da05de63c38daa63859a93c5faec_Out_1_Float;
        Unity_Length_float2(_Fraction_bb86df7d67ecdf8dbbec1e5f6d2d1f0a_Out_1_Vector2, _Length_46c2da05de63c38daa63859a93c5faec_Out_1_Float);
        float2 _OneMinus_f479dfa52aa48280a0b9e9a66d87deef_Out_1_Vector2;
        Unity_OneMinus_float2(_Fraction_bb86df7d67ecdf8dbbec1e5f6d2d1f0a_Out_1_Vector2, _OneMinus_f479dfa52aa48280a0b9e9a66d87deef_Out_1_Vector2);
        float _Length_99b197592589a98d99d00d1f540669d8_Out_1_Float;
        Unity_Length_float2(_OneMinus_f479dfa52aa48280a0b9e9a66d87deef_Out_1_Vector2, _Length_99b197592589a98d99d00d1f540669d8_Out_1_Float);
        float _Minimum_593fbcfcd11cc08dad37d8d9151101f3_Out_2_Float;
        Unity_Minimum_float(_Length_46c2da05de63c38daa63859a93c5faec_Out_1_Float, _Length_99b197592589a98d99d00d1f540669d8_Out_1_Float, _Minimum_593fbcfcd11cc08dad37d8d9151101f3_Out_2_Float);
        float _Multiply_b40b1ee72c7eb28eb0eaee91164c032b_Out_2_Float;
        Unity_Multiply_float_float(_Property_d870e879a0d1db8a841c61b19745d769_Out_0_Float, _Minimum_593fbcfcd11cc08dad37d8d9151101f3_Out_2_Float, _Multiply_b40b1ee72c7eb28eb0eaee91164c032b_Out_2_Float);
        float _Fraction_ccc5db17d0a5ad80947f669867e247ac_Out_1_Float;
        Unity_Fraction_float(_Multiply_b40b1ee72c7eb28eb0eaee91164c032b_Out_2_Float, _Fraction_ccc5db17d0a5ad80947f669867e247ac_Out_1_Float);
        float _Smoothstep_85806da33565bd85b179df783dabec24_Out_3_Float;
        Unity_Smoothstep_float(float(0.8), float(0.6), _Fraction_ccc5db17d0a5ad80947f669867e247ac_Out_1_Float, _Smoothstep_85806da33565bd85b179df783dabec24_Out_3_Float);
        float _Smoothstep_85c9e4ba7f27ff83b26532c3ca1cea09_Out_3_Float;
        Unity_Smoothstep_float(float(0.4), float(0.2), _Fraction_ccc5db17d0a5ad80947f669867e247ac_Out_1_Float, _Smoothstep_85c9e4ba7f27ff83b26532c3ca1cea09_Out_3_Float);
        float _Subtract_b29f4fe31f6bfd8d9cceb61faf5dab52_Out_2_Float;
        Unity_Subtract_float(_Smoothstep_85806da33565bd85b179df783dabec24_Out_3_Float, _Smoothstep_85c9e4ba7f27ff83b26532c3ca1cea09_Out_3_Float, _Subtract_b29f4fe31f6bfd8d9cceb61faf5dab52_Out_2_Float);
        Out_1 = _Subtract_b29f4fe31f6bfd8d9cceb61faf5dab52_Out_2_Float;
        }
        
        struct Bindings_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float
        {
        };
        
        void SG_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float(float4 _RGBA, Bindings_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float IN, out float3 RGB_1, out float Alpha_2)
        {
        float4 _Property_5d89e3d762924af3b7e53b3dd9236195_Out_0_Vector4 = _RGBA;
        float3 _Swizzle_45aaffda5d9c408b92f0fc57acc0f913_Out_1_Vector3 = _Property_5d89e3d762924af3b7e53b3dd9236195_Out_0_Vector4.xyz;
        float _Swizzle_112911596b4343ee9fbf5dd7ccb2542a_Out_1_Float = _Property_5d89e3d762924af3b7e53b3dd9236195_Out_0_Vector4.w;
        RGB_1 = _Swizzle_45aaffda5d9c408b92f0fc57acc0f913_Out_1_Vector3;
        Alpha_2 = _Swizzle_112911596b4343ee9fbf5dd7ccb2542a_Out_1_Float;
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
            float2 _Property_373cf82f73754e218bf7948e96a2d8c5_Out_0_Vector2 = _Tiling;
            float _Property_d181bc43e6ec4e21a731af15b6fb175b_Out_0_Float = _Seed;
            float _Property_b4f171e6d17d4284a63ad1cf85d2d33d_Out_0_Float = _Repetition;
            Bindings_Truchet_443a06ee36571b848aa0cc4eb4f681b4_float _Truchet_44fc6e52471e42628d1be3e6e849eb7e;
            _Truchet_44fc6e52471e42628d1be3e6e849eb7e.uv0 = IN.uv0;
            float _Truchet_44fc6e52471e42628d1be3e6e849eb7e_Out_1_Float;
            SG_Truchet_443a06ee36571b848aa0cc4eb4f681b4_float(_Property_373cf82f73754e218bf7948e96a2d8c5_Out_0_Vector2, _Property_d181bc43e6ec4e21a731af15b6fb175b_Out_0_Float, _Property_b4f171e6d17d4284a63ad1cf85d2d33d_Out_0_Float, _Truchet_44fc6e52471e42628d1be3e6e849eb7e, _Truchet_44fc6e52471e42628d1be3e6e849eb7e_Out_1_Float);
            Bindings_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68;
            float3 _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3;
            float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float;
            SG_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float((_Truchet_44fc6e52471e42628d1be3e6e849eb7e_Out_1_Float.xxxx), _AlphaSplit_ef5448ee86a64148a89692eca4a45a68, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float);
            surface.BaseColor = _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3;
            surface.Alpha = _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float;
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