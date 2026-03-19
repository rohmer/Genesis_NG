Shader "Hidden/Genesis/HexLattice"
{
    Properties
    {
        _Tiling("Tiling", Vector, 2) = (10, 10, 0, 0)
        _Hex_Scale("Hex Scale", Range(0, 1)) = 1
        _Edge_Width("Edge Width", Range(0, 1)) = 0.2
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
        float _Hex_Scale;
        float _Edge_Width;
        CBUFFER_END
        
        
        // Object and Global properties
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Floor_float(float In, out float Out)
        {
            Out = floor(In);
        }
        
        void Unity_Modulo_float(float A, float B, out float Out)
        {
            Out = fmod(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Modulo_float2(float2 A, float2 B, out float2 Out)
        {
            Out = fmod(A, B);
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float2(float2 In, out float2 Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_HexLattice_ae6f2edd46e88d5459d149f7a35446e1_float
        {
        half4 uv0;
        };
        
        void SG_HexLattice_ae6f2edd46e88d5459d149f7a35446e1_float(float2 _tiling, float _scale, float _edge, Bindings_HexLattice_ae6f2edd46e88d5459d149f7a35446e1_float IN, out float Out_1)
        {
        float _Property_ad523d03d9c557848bd05c6d29e4f76f_Out_0_Float = _edge;
        float2 _Property_3c37fdea2f2393849f42e2ab1c17d623_Out_0_Vector2 = _tiling;
        float2 _TilingAndOffset_9f3f116662dbdf8d9ff54290ac261dca_Out_3_Vector2;
        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_3c37fdea2f2393849f42e2ab1c17d623_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_9f3f116662dbdf8d9ff54290ac261dca_Out_3_Vector2);
        float _Split_ec4d176bb7c0888aaa50d9d2141f8ab2_R_1_Float = _TilingAndOffset_9f3f116662dbdf8d9ff54290ac261dca_Out_3_Vector2[0];
        float _Split_ec4d176bb7c0888aaa50d9d2141f8ab2_G_2_Float = _TilingAndOffset_9f3f116662dbdf8d9ff54290ac261dca_Out_3_Vector2[1];
        float _Split_ec4d176bb7c0888aaa50d9d2141f8ab2_B_3_Float = 0;
        float _Split_ec4d176bb7c0888aaa50d9d2141f8ab2_A_4_Float = 0;
        float _Multiply_e1c38402c4e27a829eb8a879a85946f6_Out_2_Float;
        Unity_Multiply_float_float(1.5, _Split_ec4d176bb7c0888aaa50d9d2141f8ab2_R_1_Float, _Multiply_e1c38402c4e27a829eb8a879a85946f6_Out_2_Float);
        float _Floor_fda6e33420cb098bbc4e4348442b564d_Out_1_Float;
        Unity_Floor_float(_Multiply_e1c38402c4e27a829eb8a879a85946f6_Out_2_Float, _Floor_fda6e33420cb098bbc4e4348442b564d_Out_1_Float);
        float _Modulo_5dedbffee9d5af839b1ae7631799e4b3_Out_2_Float;
        Unity_Modulo_float(_Floor_fda6e33420cb098bbc4e4348442b564d_Out_1_Float, float(2), _Modulo_5dedbffee9d5af839b1ae7631799e4b3_Out_2_Float);
        float _Multiply_81429557179b168ebee15641f7a6f012_Out_2_Float;
        Unity_Multiply_float_float(0.5, _Modulo_5dedbffee9d5af839b1ae7631799e4b3_Out_2_Float, _Multiply_81429557179b168ebee15641f7a6f012_Out_2_Float);
        float _Add_011d279ae54bd5898c3ffb1a7d4c108b_Out_2_Float;
        Unity_Add_float(_Split_ec4d176bb7c0888aaa50d9d2141f8ab2_G_2_Float, _Multiply_81429557179b168ebee15641f7a6f012_Out_2_Float, _Add_011d279ae54bd5898c3ffb1a7d4c108b_Out_2_Float);
        float2 _Vector2_c37863a01c2a6e83b8b8f0564aced3b9_Out_0_Vector2 = float2(_Multiply_e1c38402c4e27a829eb8a879a85946f6_Out_2_Float, _Add_011d279ae54bd5898c3ffb1a7d4c108b_Out_2_Float);
        float2 _Modulo_4a298f0a5349bb81aa2648907b930be4_Out_2_Vector2;
        Unity_Modulo_float2(_Vector2_c37863a01c2a6e83b8b8f0564aced3b9_Out_0_Vector2, float2(1, 1), _Modulo_4a298f0a5349bb81aa2648907b930be4_Out_2_Vector2);
        float2 _Subtract_620c7f298c4db9859ff68f1b681d3d33_Out_2_Vector2;
        Unity_Subtract_float2(_Modulo_4a298f0a5349bb81aa2648907b930be4_Out_2_Vector2, float2(0.5, 0.5), _Subtract_620c7f298c4db9859ff68f1b681d3d33_Out_2_Vector2);
        float2 _Absolute_82fa645a6d76768e81b16c1264b2ebab_Out_1_Vector2;
        Unity_Absolute_float2(_Subtract_620c7f298c4db9859ff68f1b681d3d33_Out_2_Vector2, _Absolute_82fa645a6d76768e81b16c1264b2ebab_Out_1_Vector2);
        float _Split_a67e597f5f79af8da6821647925258c4_R_1_Float = _Absolute_82fa645a6d76768e81b16c1264b2ebab_Out_1_Vector2[0];
        float _Split_a67e597f5f79af8da6821647925258c4_G_2_Float = _Absolute_82fa645a6d76768e81b16c1264b2ebab_Out_1_Vector2[1];
        float _Split_a67e597f5f79af8da6821647925258c4_B_3_Float = 0;
        float _Split_a67e597f5f79af8da6821647925258c4_A_4_Float = 0;
        float _Multiply_d6b75e862a379b868c8a7574e3ead437_Out_2_Float;
        Unity_Multiply_float_float(1.5, _Split_a67e597f5f79af8da6821647925258c4_R_1_Float, _Multiply_d6b75e862a379b868c8a7574e3ead437_Out_2_Float);
        float _Add_8eb27aba22a3128da5476346686c30e0_Out_2_Float;
        Unity_Add_float(_Multiply_d6b75e862a379b868c8a7574e3ead437_Out_2_Float, _Split_a67e597f5f79af8da6821647925258c4_G_2_Float, _Add_8eb27aba22a3128da5476346686c30e0_Out_2_Float);
        float _Multiply_2e68df5428e25e8498465a3dbb50a936_Out_2_Float;
        Unity_Multiply_float_float(_Split_a67e597f5f79af8da6821647925258c4_G_2_Float, 2, _Multiply_2e68df5428e25e8498465a3dbb50a936_Out_2_Float);
        float _Maximum_f88e9595003eea8fa653d97f727e2a91_Out_2_Float;
        Unity_Maximum_float(_Add_8eb27aba22a3128da5476346686c30e0_Out_2_Float, _Multiply_2e68df5428e25e8498465a3dbb50a936_Out_2_Float, _Maximum_f88e9595003eea8fa653d97f727e2a91_Out_2_Float);
        float _Property_7ccb379b6695758eaded473f165e48cf_Out_0_Float = _scale;
        float _Subtract_428b6ff76803e18d825a2d88fb2a686f_Out_2_Float;
        Unity_Subtract_float(_Maximum_f88e9595003eea8fa653d97f727e2a91_Out_2_Float, _Property_7ccb379b6695758eaded473f165e48cf_Out_0_Float, _Subtract_428b6ff76803e18d825a2d88fb2a686f_Out_2_Float);
        float _Absolute_321aa5642a4a1a8fb3b1a54ceca808f6_Out_1_Float;
        Unity_Absolute_float(_Subtract_428b6ff76803e18d825a2d88fb2a686f_Out_2_Float, _Absolute_321aa5642a4a1a8fb3b1a54ceca808f6_Out_1_Float);
        float _Multiply_835acd47380f758b982a50a8064ea46d_Out_2_Float;
        Unity_Multiply_float_float(_Absolute_321aa5642a4a1a8fb3b1a54ceca808f6_Out_1_Float, 2, _Multiply_835acd47380f758b982a50a8064ea46d_Out_2_Float);
        float _Smoothstep_0cd10edc36bef589a04ab9b5be10c276_Out_3_Float;
        Unity_Smoothstep_float(float(0), _Property_ad523d03d9c557848bd05c6d29e4f76f_Out_0_Float, _Multiply_835acd47380f758b982a50a8064ea46d_Out_2_Float, _Smoothstep_0cd10edc36bef589a04ab9b5be10c276_Out_3_Float);
        Out_1 = _Smoothstep_0cd10edc36bef589a04ab9b5be10c276_Out_3_Float;
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
            float _Property_8c54f0194017487ebeb430acf81b5c0c_Out_0_Float = _Hex_Scale;
            float _Property_147d5888fc9c45ce9f6acb828adc5d2e_Out_0_Float = _Edge_Width;
            Bindings_HexLattice_ae6f2edd46e88d5459d149f7a35446e1_float _HexLattice_9f2b066769604502b8683077298934e5;
            _HexLattice_9f2b066769604502b8683077298934e5.uv0 = IN.uv0;
            float _HexLattice_9f2b066769604502b8683077298934e5_Out_1_Float;
            SG_HexLattice_ae6f2edd46e88d5459d149f7a35446e1_float(_Property_373cf82f73754e218bf7948e96a2d8c5_Out_0_Vector2, _Property_8c54f0194017487ebeb430acf81b5c0c_Out_0_Float, _Property_147d5888fc9c45ce9f6acb828adc5d2e_Out_0_Float, _HexLattice_9f2b066769604502b8683077298934e5, _HexLattice_9f2b066769604502b8683077298934e5_Out_1_Float);
            Bindings_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68;
            float3 _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3;
            float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float;
            SG_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float((_HexLattice_9f2b066769604502b8683077298934e5_Out_1_Float.xxxx), _AlphaSplit_ef5448ee86a64148a89692eca4a45a68, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float);
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