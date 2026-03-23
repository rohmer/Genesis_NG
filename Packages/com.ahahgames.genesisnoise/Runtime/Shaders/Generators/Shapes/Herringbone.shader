Shader "Hidden/Genesis/Herringbone"
{
    Properties
    {
        _Tiling("Tiling", Vector, 2) = (5, 5, 0, 0)
        _Width("Width", Float) = 0.2
        _Cells("Cells", Float) = 4
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
        float _Width;
        float _Cells;
        CBUFFER_END
        
        
        // Object and Global properties
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Preview_float(float In, out float Out)
        {
            Out = In;
        }
        
        void Unity_Round_float(float In, out float Out)
        {
            Out = round(In);
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
        
        void Unity_Floor_float(float In, out float Out)
        {
            Out = floor(In);
        }
        
        void Unity_Modulo_float(float A, float B, out float Out)
        {
            Out = fmod(A, B);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        struct Bindings_Herringbone_2779352ef2443b545b86854fa838b877_float
        {
        half4 uv0;
        };
        
        void SG_Herringbone_2779352ef2443b545b86854fa838b877_float(float2 _tiling, float _width, float _cells, Bindings_Herringbone_2779352ef2443b545b86854fa838b877_float IN, out float4 Output1_1)
        {
        float _Property_ef639f51dd7d72898ee8550b23e38c79_Out_0_Float = _width;
        float _Multiply_650840660b6b18839262056801486587_Out_2_Float;
        Unity_Multiply_float_float(_Property_ef639f51dd7d72898ee8550b23e38c79_Out_0_Float, 0.5, _Multiply_650840660b6b18839262056801486587_Out_2_Float);
        float _Add_e91b26c2c401ff8e8b9c6796c6aec4c4_Out_2_Float;
        Unity_Add_float(float(0.05), _Multiply_650840660b6b18839262056801486587_Out_2_Float, _Add_e91b26c2c401ff8e8b9c6796c6aec4c4_Out_2_Float);
        float2 _Property_f00d2fb1332e778680845b1380efee33_Out_0_Vector2 = _tiling;
        float2 _TilingAndOffset_893c444071cbe382ad49b64903e49457_Out_3_Vector2;
        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_f00d2fb1332e778680845b1380efee33_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_893c444071cbe382ad49b64903e49457_Out_3_Vector2);
        float _Split_5386dc96b9a8748594ba7509fa341b61_R_1_Float = _TilingAndOffset_893c444071cbe382ad49b64903e49457_Out_3_Vector2[0];
        float _Split_5386dc96b9a8748594ba7509fa341b61_G_2_Float = _TilingAndOffset_893c444071cbe382ad49b64903e49457_Out_3_Vector2[1];
        float _Split_5386dc96b9a8748594ba7509fa341b61_B_3_Float = 0;
        float _Split_5386dc96b9a8748594ba7509fa341b61_A_4_Float = 0;
        float _Preview_e5e1ac551cae948ba140210e6cb402e4_Out_1_Float;
        Unity_Preview_float(_Split_5386dc96b9a8748594ba7509fa341b61_R_1_Float, _Preview_e5e1ac551cae948ba140210e6cb402e4_Out_1_Float);
        float _Round_0e835c5e0c130f8f8d9660da58bdc23e_Out_1_Float;
        Unity_Round_float(_Preview_e5e1ac551cae948ba140210e6cb402e4_Out_1_Float, _Round_0e835c5e0c130f8f8d9660da58bdc23e_Out_1_Float);
        float _Subtract_d1f0c38cbfa5758a989c966a15eafccc_Out_2_Float;
        Unity_Subtract_float(_Preview_e5e1ac551cae948ba140210e6cb402e4_Out_1_Float, _Round_0e835c5e0c130f8f8d9660da58bdc23e_Out_1_Float, _Subtract_d1f0c38cbfa5758a989c966a15eafccc_Out_2_Float);
        float _Absolute_ef7a254666a7e781b0f1c37218643484_Out_1_Float;
        Unity_Absolute_float(_Subtract_d1f0c38cbfa5758a989c966a15eafccc_Out_2_Float, _Absolute_ef7a254666a7e781b0f1c37218643484_Out_1_Float);
        float _Smoothstep_9510209154354f8f929a15885989441d_Out_3_Float;
        Unity_Smoothstep_float(_Add_e91b26c2c401ff8e8b9c6796c6aec4c4_Out_2_Float, _Multiply_650840660b6b18839262056801486587_Out_2_Float, _Absolute_ef7a254666a7e781b0f1c37218643484_Out_1_Float, _Smoothstep_9510209154354f8f929a15885989441d_Out_3_Float);
        float _Property_7f5a13bc8b7de783816c0c7d5f593cb9_Out_0_Float = _cells;
        float _Round_12ac6d7fcdca848b9949e7b4b53b3516_Out_1_Float;
        Unity_Round_float(_Property_7f5a13bc8b7de783816c0c7d5f593cb9_Out_0_Float, _Round_12ac6d7fcdca848b9949e7b4b53b3516_Out_1_Float);
        float _Add_bee29637169beb8fa315e2a9dff9925d_Out_2_Float;
        Unity_Add_float(_Round_12ac6d7fcdca848b9949e7b4b53b3516_Out_1_Float, float(0.5), _Add_bee29637169beb8fa315e2a9dff9925d_Out_2_Float);
        float _Preview_a6d7f5512c3bde8c8c0d096898eeb096_Out_1_Float;
        Unity_Preview_float(_Split_5386dc96b9a8748594ba7509fa341b61_G_2_Float, _Preview_a6d7f5512c3bde8c8c0d096898eeb096_Out_1_Float);
        float _Floor_0c8f3033dc899680bded6f2b9cb81955_Out_1_Float;
        Unity_Floor_float(_Preview_a6d7f5512c3bde8c8c0d096898eeb096_Out_1_Float, _Floor_0c8f3033dc899680bded6f2b9cb81955_Out_1_Float);
        float _Subtract_9ddb594a9ac36a8b83c6b7710628c1e9_Out_2_Float;
        Unity_Subtract_float(_Round_0e835c5e0c130f8f8d9660da58bdc23e_Out_1_Float, _Floor_0c8f3033dc899680bded6f2b9cb81955_Out_1_Float, _Subtract_9ddb594a9ac36a8b83c6b7710628c1e9_Out_2_Float);
        float _Add_950af3f49989e08286885924fb6b5eb1_Out_2_Float;
        Unity_Add_float(_Subtract_9ddb594a9ac36a8b83c6b7710628c1e9_Out_2_Float, float(-1), _Add_950af3f49989e08286885924fb6b5eb1_Out_2_Float);
        float _Property_c23b1e18c72bf1878de18cd56edc1775_Out_0_Float = _cells;
        float _Multiply_e3afbdc90e5f7e88ae5fa4984c1703c9_Out_2_Float;
        Unity_Multiply_float_float(_Property_c23b1e18c72bf1878de18cd56edc1775_Out_0_Float, 2, _Multiply_e3afbdc90e5f7e88ae5fa4984c1703c9_Out_2_Float);
        float _Preview_bdaf5e7217204a86a5bab88005948963_Out_1_Float;
        Unity_Preview_float(_Multiply_e3afbdc90e5f7e88ae5fa4984c1703c9_Out_2_Float, _Preview_bdaf5e7217204a86a5bab88005948963_Out_1_Float);
        float _Modulo_900151bbf9663a8c9780b3d19629af64_Out_2_Float;
        Unity_Modulo_float(_Add_950af3f49989e08286885924fb6b5eb1_Out_2_Float, _Preview_bdaf5e7217204a86a5bab88005948963_Out_1_Float, _Modulo_900151bbf9663a8c9780b3d19629af64_Out_2_Float);
        float _Add_6f53d77420662289967e9ad55e920c8c_Out_2_Float;
        Unity_Add_float(_Modulo_900151bbf9663a8c9780b3d19629af64_Out_2_Float, _Preview_bdaf5e7217204a86a5bab88005948963_Out_1_Float, _Add_6f53d77420662289967e9ad55e920c8c_Out_2_Float);
        float _Modulo_358512f53c16c5809812165670d1d426_Out_2_Float;
        Unity_Modulo_float(_Add_6f53d77420662289967e9ad55e920c8c_Out_2_Float, _Preview_bdaf5e7217204a86a5bab88005948963_Out_1_Float, _Modulo_358512f53c16c5809812165670d1d426_Out_2_Float);
        float _Step_67377d8b65c5c98ab34f6a6c032d7a45_Out_2_Float;
        Unity_Step_float(_Add_bee29637169beb8fa315e2a9dff9925d_Out_2_Float, _Modulo_358512f53c16c5809812165670d1d426_Out_2_Float, _Step_67377d8b65c5c98ab34f6a6c032d7a45_Out_2_Float);
        float _Subtract_96f7507ae4756189bb52de2dc69798d3_Out_2_Float;
        Unity_Subtract_float(_Smoothstep_9510209154354f8f929a15885989441d_Out_3_Float, _Step_67377d8b65c5c98ab34f6a6c032d7a45_Out_2_Float, _Subtract_96f7507ae4756189bb52de2dc69798d3_Out_2_Float);
        float _Add_3fb869e07d70bb81aaf9cca4f61c90ba_Out_2_Float;
        Unity_Add_float(float(0.05), _Multiply_650840660b6b18839262056801486587_Out_2_Float, _Add_3fb869e07d70bb81aaf9cca4f61c90ba_Out_2_Float);
        float _Round_301ff435117f648b8be12551b041e7d1_Out_1_Float;
        Unity_Round_float(_Preview_a6d7f5512c3bde8c8c0d096898eeb096_Out_1_Float, _Round_301ff435117f648b8be12551b041e7d1_Out_1_Float);
        float _Subtract_d6c3ee4c3a8e1884821672b52d49c881_Out_2_Float;
        Unity_Subtract_float(_Preview_a6d7f5512c3bde8c8c0d096898eeb096_Out_1_Float, _Round_301ff435117f648b8be12551b041e7d1_Out_1_Float, _Subtract_d6c3ee4c3a8e1884821672b52d49c881_Out_2_Float);
        float _Absolute_9472c348097f9289bde3b9728d15b199_Out_1_Float;
        Unity_Absolute_float(_Subtract_d6c3ee4c3a8e1884821672b52d49c881_Out_2_Float, _Absolute_9472c348097f9289bde3b9728d15b199_Out_1_Float);
        float _Smoothstep_477b3d2fc937bb84931f43c12e6790f6_Out_3_Float;
        Unity_Smoothstep_float(_Add_3fb869e07d70bb81aaf9cca4f61c90ba_Out_2_Float, _Multiply_650840660b6b18839262056801486587_Out_2_Float, _Absolute_9472c348097f9289bde3b9728d15b199_Out_1_Float, _Smoothstep_477b3d2fc937bb84931f43c12e6790f6_Out_3_Float);
        float _Floor_a785ce1c0604538abdf8f36d61862d26_Out_1_Float;
        Unity_Floor_float(_Split_5386dc96b9a8748594ba7509fa341b61_R_1_Float, _Floor_a785ce1c0604538abdf8f36d61862d26_Out_1_Float);
        float _Subtract_461329846b5d8a88a00dfaa59ea947c5_Out_2_Float;
        Unity_Subtract_float(_Round_301ff435117f648b8be12551b041e7d1_Out_1_Float, _Floor_a785ce1c0604538abdf8f36d61862d26_Out_1_Float, _Subtract_461329846b5d8a88a00dfaa59ea947c5_Out_2_Float);
        float _Preview_c2bdaef3de52868ba42ec030f4e85d4a_Out_1_Float;
        Unity_Preview_float(_Multiply_e3afbdc90e5f7e88ae5fa4984c1703c9_Out_2_Float, _Preview_c2bdaef3de52868ba42ec030f4e85d4a_Out_1_Float);
        float _Modulo_703fe779521cb6859f226a099b047964_Out_2_Float;
        Unity_Modulo_float(_Subtract_461329846b5d8a88a00dfaa59ea947c5_Out_2_Float, _Preview_c2bdaef3de52868ba42ec030f4e85d4a_Out_1_Float, _Modulo_703fe779521cb6859f226a099b047964_Out_2_Float);
        float _Add_6b931ccb14ce9b8fa3facf935f1e3250_Out_2_Float;
        Unity_Add_float(_Modulo_703fe779521cb6859f226a099b047964_Out_2_Float, _Preview_c2bdaef3de52868ba42ec030f4e85d4a_Out_1_Float, _Add_6b931ccb14ce9b8fa3facf935f1e3250_Out_2_Float);
        float _Modulo_4df07dd0325fc881b21413724d010d6b_Out_2_Float;
        Unity_Modulo_float(_Add_6b931ccb14ce9b8fa3facf935f1e3250_Out_2_Float, _Preview_c2bdaef3de52868ba42ec030f4e85d4a_Out_1_Float, _Modulo_4df07dd0325fc881b21413724d010d6b_Out_2_Float);
        float _Step_b0e99647e100438a874ef6c7d3b82086_Out_2_Float;
        Unity_Step_float(_Add_bee29637169beb8fa315e2a9dff9925d_Out_2_Float, _Modulo_4df07dd0325fc881b21413724d010d6b_Out_2_Float, _Step_b0e99647e100438a874ef6c7d3b82086_Out_2_Float);
        float _Subtract_e13b1543343e6881bb51247d2569d796_Out_2_Float;
        Unity_Subtract_float(_Smoothstep_477b3d2fc937bb84931f43c12e6790f6_Out_3_Float, _Step_b0e99647e100438a874ef6c7d3b82086_Out_2_Float, _Subtract_e13b1543343e6881bb51247d2569d796_Out_2_Float);
        float _Maximum_a5f38d85942e608db75a87391326eb94_Out_2_Float;
        Unity_Maximum_float(_Subtract_96f7507ae4756189bb52de2dc69798d3_Out_2_Float, _Subtract_e13b1543343e6881bb51247d2569d796_Out_2_Float, _Maximum_a5f38d85942e608db75a87391326eb94_Out_2_Float);
        Output1_1 = (_Maximum_a5f38d85942e608db75a87391326eb94_Out_2_Float.xxxx);
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
            float2 _Property_648ac1045e364a95bf616a040abcc31a_Out_0_Vector2 = _Tiling;
            float _Property_037eec28a2d246238d6b45d90698afc9_Out_0_Float = _Width;
            float _Property_3e5de5e81beb49489d477ef79e9ca802_Out_0_Float = _Cells;
            Bindings_Herringbone_2779352ef2443b545b86854fa838b877_float _Herringbone_e41c23fbd6a4481abd337f02d3107f65;
            _Herringbone_e41c23fbd6a4481abd337f02d3107f65.uv0 = IN.uv0;
            float4 _Herringbone_e41c23fbd6a4481abd337f02d3107f65_Output1_1_Vector4;
            SG_Herringbone_2779352ef2443b545b86854fa838b877_float(_Property_648ac1045e364a95bf616a040abcc31a_Out_0_Vector2, _Property_037eec28a2d246238d6b45d90698afc9_Out_0_Float, _Property_3e5de5e81beb49489d477ef79e9ca802_Out_0_Float, _Herringbone_e41c23fbd6a4481abd337f02d3107f65, _Herringbone_e41c23fbd6a4481abd337f02d3107f65_Output1_1_Vector4);
            Bindings_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float _AlphaSplit_e9d8bb825d5549d29a1efa11acd2a034;
            float3 _AlphaSplit_e9d8bb825d5549d29a1efa11acd2a034_RGB_1_Vector3;
            float _AlphaSplit_e9d8bb825d5549d29a1efa11acd2a034_Alpha_2_Float;
            SG_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float(_Herringbone_e41c23fbd6a4481abd337f02d3107f65_Output1_1_Vector4, _AlphaSplit_e9d8bb825d5549d29a1efa11acd2a034, _AlphaSplit_e9d8bb825d5549d29a1efa11acd2a034_RGB_1_Vector3, _AlphaSplit_e9d8bb825d5549d29a1efa11acd2a034_Alpha_2_Float);
            surface.BaseColor = _AlphaSplit_e9d8bb825d5549d29a1efa11acd2a034_RGB_1_Vector3;
            surface.Alpha = _AlphaSplit_e9d8bb825d5549d29a1efa11acd2a034_Alpha_2_Float;
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