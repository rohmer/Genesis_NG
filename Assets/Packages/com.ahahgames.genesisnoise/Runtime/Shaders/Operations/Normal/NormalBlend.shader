Shader "Hidden/Genesis/NormalBlend"
{
    Properties
    {
        [Normal][NoScaleOffset]Texture2D_D25175D9("Normal A", 2D) = "bump" {}
        [Normal][NoScaleOffset]Texture2D_49D81452("Normal B", 2D) = "bump" {}
        Vector1_6EE3E138("Opacity", Range(0, 1)) = 0
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
        float4 Texture2D_D25175D9_TexelSize;
        float4 Texture2D_49D81452_TexelSize;
        float Vector1_6EE3E138;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Trilinear_Repeat);
        TEXTURE2D(Texture2D_D25175D9);
        SAMPLER(samplerTexture2D_D25175D9);
        TEXTURE2D(Texture2D_49D81452);
        SAMPLER(samplerTexture2D_49D81452);
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
        void Unity_Negate_float2(float2 In, out float2 Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        struct Bindings_vec3tsnormaltoderiv_54b5778cf1b9e9845bc663ae97aa0520_float
        {
        };
        
        void SG_vec3tsnormaltoderiv_54b5778cf1b9e9845bc663ae97aa0520_float(float3 Vector3_42E4211B, Bindings_vec3tsnormaltoderiv_54b5778cf1b9e9845bc663ae97aa0520_float IN, out float2 Derivative_1)
        {
        float3 _Property_a199ba34e6eda08dadcb1391ba5fe0c2_Out_0_Vector3 = Vector3_42E4211B;
        float _Split_8c14d5bd08af7282b1cda62e83f209cf_R_1_Float = _Property_a199ba34e6eda08dadcb1391ba5fe0c2_Out_0_Vector3[0];
        float _Split_8c14d5bd08af7282b1cda62e83f209cf_G_2_Float = _Property_a199ba34e6eda08dadcb1391ba5fe0c2_Out_0_Vector3[1];
        float _Split_8c14d5bd08af7282b1cda62e83f209cf_B_3_Float = _Property_a199ba34e6eda08dadcb1391ba5fe0c2_Out_0_Vector3[2];
        float _Split_8c14d5bd08af7282b1cda62e83f209cf_A_4_Float = 0;
        float2 _Vector2_439b97bf2fe3ef87a532d661e14ad79d_Out_0_Vector2 = float2(_Split_8c14d5bd08af7282b1cda62e83f209cf_R_1_Float, _Split_8c14d5bd08af7282b1cda62e83f209cf_G_2_Float);
        float2 _Negate_169e079234c8ec819717a01618e390a8_Out_1_Vector2;
        Unity_Negate_float2(_Vector2_439b97bf2fe3ef87a532d661e14ad79d_Out_0_Vector2, _Negate_169e079234c8ec819717a01618e390a8_Out_1_Vector2);
        float _Float_76d2811bec90a382ba95c3036edfcb58_Out_0_Float = float(0.0078125);
        float3 _Absolute_61184c366e09c280a43355914cb504cf_Out_1_Vector3;
        Unity_Absolute_float3(_Property_a199ba34e6eda08dadcb1391ba5fe0c2_Out_0_Vector3, _Absolute_61184c366e09c280a43355914cb504cf_Out_1_Vector3);
        float _Split_f00d545d74523586a5aa4c7116ea3231_R_1_Float = _Absolute_61184c366e09c280a43355914cb504cf_Out_1_Vector3[0];
        float _Split_f00d545d74523586a5aa4c7116ea3231_G_2_Float = _Absolute_61184c366e09c280a43355914cb504cf_Out_1_Vector3[1];
        float _Split_f00d545d74523586a5aa4c7116ea3231_B_3_Float = _Absolute_61184c366e09c280a43355914cb504cf_Out_1_Vector3[2];
        float _Split_f00d545d74523586a5aa4c7116ea3231_A_4_Float = 0;
        float _Maximum_24fe740d06ea068995aca2966f5ef3ef_Out_2_Float;
        Unity_Maximum_float(_Split_f00d545d74523586a5aa4c7116ea3231_R_1_Float, _Split_f00d545d74523586a5aa4c7116ea3231_G_2_Float, _Maximum_24fe740d06ea068995aca2966f5ef3ef_Out_2_Float);
        float _Multiply_37341a6929e2388186365cb4e52c8f7b_Out_2_Float;
        Unity_Multiply_float_float(_Float_76d2811bec90a382ba95c3036edfcb58_Out_0_Float, _Maximum_24fe740d06ea068995aca2966f5ef3ef_Out_2_Float, _Multiply_37341a6929e2388186365cb4e52c8f7b_Out_2_Float);
        float _Maximum_4c7f6b1edb609988bf3b414f43048c00_Out_2_Float;
        Unity_Maximum_float(_Multiply_37341a6929e2388186365cb4e52c8f7b_Out_2_Float, _Split_f00d545d74523586a5aa4c7116ea3231_B_3_Float, _Maximum_4c7f6b1edb609988bf3b414f43048c00_Out_2_Float);
        float2 _Divide_e6474c118fa2f982a67df558b5ac8ef9_Out_2_Vector2;
        Unity_Divide_float2(_Negate_169e079234c8ec819717a01618e390a8_Out_1_Vector2, (_Maximum_4c7f6b1edb609988bf3b414f43048c00_Out_2_Float.xx), _Divide_e6474c118fa2f982a67df558b5ac8ef9_Out_2_Vector2);
        Derivative_1 = _Divide_e6474c118fa2f982a67df558b5ac8ef9_Out_2_Vector2;
        }
        
        struct Bindings_textsnormtoderiv_d4a9c754eaad78e48928b11a75e7efbc_float
        {
        };
        
        void SG_textsnormtoderiv_d4a9c754eaad78e48928b11a75e7efbc_float(UnityTexture2D Texture2D_42B1E69E, UnitySamplerState SamplerState_448e4294d15c45a28abf0ce02a556994, float2 Vector2_777D300E, Bindings_textsnormtoderiv_d4a9c754eaad78e48928b11a75e7efbc_float IN, out float2 Derivative_1)
        {
        UnityTexture2D _Property_19f30303953d4d19890e44119c12e8c6_Out_0_Texture2D = Texture2D_42B1E69E;
        float2 _Property_8e20b72a9d514d2fac3da6c21111098f_Out_0_Vector2 = Vector2_777D300E;
        UnitySamplerState _Property_468bc56c040f46668d3271ebb893b9b6_Out_0_SamplerState = SamplerState_448e4294d15c45a28abf0ce02a556994;
        float4 _SampleTexture2D_13b4fb5fe963487abcf71521c77c0579_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_19f30303953d4d19890e44119c12e8c6_Out_0_Texture2D.tex, _Property_468bc56c040f46668d3271ebb893b9b6_Out_0_SamplerState.samplerstate, _Property_19f30303953d4d19890e44119c12e8c6_Out_0_Texture2D.GetTransformedUV(_Property_8e20b72a9d514d2fac3da6c21111098f_Out_0_Vector2) );
        _SampleTexture2D_13b4fb5fe963487abcf71521c77c0579_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_13b4fb5fe963487abcf71521c77c0579_RGBA_0_Vector4);
        float _SampleTexture2D_13b4fb5fe963487abcf71521c77c0579_R_4_Float = _SampleTexture2D_13b4fb5fe963487abcf71521c77c0579_RGBA_0_Vector4.r;
        float _SampleTexture2D_13b4fb5fe963487abcf71521c77c0579_G_5_Float = _SampleTexture2D_13b4fb5fe963487abcf71521c77c0579_RGBA_0_Vector4.g;
        float _SampleTexture2D_13b4fb5fe963487abcf71521c77c0579_B_6_Float = _SampleTexture2D_13b4fb5fe963487abcf71521c77c0579_RGBA_0_Vector4.b;
        float _SampleTexture2D_13b4fb5fe963487abcf71521c77c0579_A_7_Float = _SampleTexture2D_13b4fb5fe963487abcf71521c77c0579_RGBA_0_Vector4.a;
        float3 _Vector3_2b0bf8600b914ebba2e510fc340630a5_Out_0_Vector3 = float3(_SampleTexture2D_13b4fb5fe963487abcf71521c77c0579_R_4_Float, _SampleTexture2D_13b4fb5fe963487abcf71521c77c0579_G_5_Float, _SampleTexture2D_13b4fb5fe963487abcf71521c77c0579_B_6_Float);
        Bindings_vec3tsnormaltoderiv_54b5778cf1b9e9845bc663ae97aa0520_float _vec3tsnormaltoderiv_cb483b8959bc4cc2b305326a0e725da7;
        float2 _vec3tsnormaltoderiv_cb483b8959bc4cc2b305326a0e725da7_Derivative_1_Vector2;
        SG_vec3tsnormaltoderiv_54b5778cf1b9e9845bc663ae97aa0520_float(_Vector3_2b0bf8600b914ebba2e510fc340630a5_Out_0_Vector3, _vec3tsnormaltoderiv_cb483b8959bc4cc2b305326a0e725da7, _vec3tsnormaltoderiv_cb483b8959bc4cc2b305326a0e725da7_Derivative_1_Vector2);
        Derivative_1 = _vec3tsnormaltoderiv_cb483b8959bc4cc2b305326a0e725da7_Derivative_1_Vector2;
        }
        
        void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        struct Bindings_ResolveSurfgrad_d5377ff6754dc80499223a55226e07f8_float
        {
        };
        
        void SG_ResolveSurfgrad_d5377ff6754dc80499223a55226e07f8_float(float3 Vector3_80BE829, float3 Vector3_9A56BC6D, Bindings_ResolveSurfgrad_d5377ff6754dc80499223a55226e07f8_float IN, out float3 PerturbedNormal_1)
        {
        float3 _Property_9aec3d0cd34042759977d46a97731b51_Out_0_Vector3 = Vector3_9A56BC6D;
        float3 _Property_7e553af81aab40afa680fa8c4b92e2d0_Out_0_Vector3 = Vector3_80BE829;
        float3 _Subtract_dbc0595f06134dd890d948edb979437b_Out_2_Vector3;
        Unity_Subtract_float3(_Property_9aec3d0cd34042759977d46a97731b51_Out_0_Vector3, _Property_7e553af81aab40afa680fa8c4b92e2d0_Out_0_Vector3, _Subtract_dbc0595f06134dd890d948edb979437b_Out_2_Vector3);
        float3 _Normalize_4bf11b7312a045ae8e7594e6f8b1aa20_Out_1_Vector3;
        Unity_Normalize_float3(_Subtract_dbc0595f06134dd890d948edb979437b_Out_2_Vector3, _Normalize_4bf11b7312a045ae8e7594e6f8b1aa20_Out_1_Vector3);
        PerturbedNormal_1 = _Normalize_4bf11b7312a045ae8e7594e6f8b1aa20_Out_1_Vector3;
        }
        
        void Unity_Remap_float3(float3 In, float2 InMinMax, float2 OutMinMax, out float3 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
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
            UnityTexture2D _Property_91e1cd78559346f59fc8aefd4b43c965_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_D25175D9);
            float4 _UV_7150b2de307c4726b7238c0112bf8de5_Out_0_Vector4 = IN.uv0;
            Bindings_textsnormtoderiv_d4a9c754eaad78e48928b11a75e7efbc_float _textsnormtoderiv_1c43c97a88404de98c60485601458c2f;
            float2 _textsnormtoderiv_1c43c97a88404de98c60485601458c2f_Derivative_1_Vector2;
            SG_textsnormtoderiv_d4a9c754eaad78e48928b11a75e7efbc_float(_Property_91e1cd78559346f59fc8aefd4b43c965_Out_0_Texture2D, UnityBuildSamplerStateStruct(SamplerState_Trilinear_Repeat), (_UV_7150b2de307c4726b7238c0112bf8de5_Out_0_Vector4.xy), _textsnormtoderiv_1c43c97a88404de98c60485601458c2f, _textsnormtoderiv_1c43c97a88404de98c60485601458c2f_Derivative_1_Vector2);
            UnityTexture2D _Property_042e5e728f0a47dfba931bf2161a8d13_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_49D81452);
            Bindings_textsnormtoderiv_d4a9c754eaad78e48928b11a75e7efbc_float _textsnormtoderiv_e14e7d02620744809c52e34d857a19cf;
            float2 _textsnormtoderiv_e14e7d02620744809c52e34d857a19cf_Derivative_1_Vector2;
            SG_textsnormtoderiv_d4a9c754eaad78e48928b11a75e7efbc_float(_Property_042e5e728f0a47dfba931bf2161a8d13_Out_0_Texture2D, UnityBuildSamplerStateStruct(SamplerState_Trilinear_Repeat), (_UV_7150b2de307c4726b7238c0112bf8de5_Out_0_Vector4.xy), _textsnormtoderiv_e14e7d02620744809c52e34d857a19cf, _textsnormtoderiv_e14e7d02620744809c52e34d857a19cf_Derivative_1_Vector2);
            float _Property_fa644de2577a4f54bc3afa37683c427a_Out_0_Float = Vector1_6EE3E138;
            float2 _Lerp_73c30cb90eb84ab48e8066c1299074a1_Out_3_Vector2;
            Unity_Lerp_float2(_textsnormtoderiv_1c43c97a88404de98c60485601458c2f_Derivative_1_Vector2, _textsnormtoderiv_e14e7d02620744809c52e34d857a19cf_Derivative_1_Vector2, (_Property_fa644de2577a4f54bc3afa37683c427a_Out_0_Float.xx), _Lerp_73c30cb90eb84ab48e8066c1299074a1_Out_3_Vector2);
            Bindings_ResolveSurfgrad_d5377ff6754dc80499223a55226e07f8_float _ResolveSurfgrad_c73febf7a9204387b2fc3fbbb0c8a877;
            float3 _ResolveSurfgrad_c73febf7a9204387b2fc3fbbb0c8a877_PerturbedNormal_1_Vector3;
            SG_ResolveSurfgrad_d5377ff6754dc80499223a55226e07f8_float((float3(_Lerp_73c30cb90eb84ab48e8066c1299074a1_Out_3_Vector2, 0.0)), float3 (0, 0, 1), _ResolveSurfgrad_c73febf7a9204387b2fc3fbbb0c8a877, _ResolveSurfgrad_c73febf7a9204387b2fc3fbbb0c8a877_PerturbedNormal_1_Vector3);
            float3 _Remap_993f69de73d5471280af07605e476fa5_Out_3_Vector3;
            Unity_Remap_float3(_ResolveSurfgrad_c73febf7a9204387b2fc3fbbb0c8a877_PerturbedNormal_1_Vector3, float2 (-1, 1), float2 (0, 1), _Remap_993f69de73d5471280af07605e476fa5_Out_3_Vector3);
            surface.BaseColor = _Remap_993f69de73d5471280af07605e476fa5_Out_3_Vector3;
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