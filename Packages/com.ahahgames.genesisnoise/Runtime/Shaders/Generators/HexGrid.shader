Shader "Hidden/Genesis/HexGrid"
{
    Properties
    {
        _Scale("Scale", Vector, 2) = (10, 10, 0, 0)
        _Line_Width("Line Width", Range(0, 1)) = 0.1
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
        float2 _Scale;
        float _Line_Width;
        CBUFFER_END
        
        
        // Object and Global properties
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Fraction_float2(float2 In, out float2 Out)
        {
            Out = frac(In);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Floor_float2(float2 In, out float2 Out)
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
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_OneMinus_float2(float2 In, out float2 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Step_float2(float2 Edge, float2 In, out float2 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_InverseLerp_float(float A, float B, float T, out float Out)
        {
            Out = (T - A)/(B - A);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_DDXY_74abdb71de0c4e67b1a5909087ae3f79_float(float In, out float Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                    #error 'DDXY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = abs(ddx(In)) + abs(ddy(In));
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        // unity-custom-func-begin
        void Hash21Tchou_float(float2 p, out float Out){
        uint r;
        
        uint2 v = (uint2) (int2) round(p);
        
        v.y ^= 1103515245U;
        
        v.x += v.y;
        
        v.x *= v.y;                        
        v.x ^= v.x >> 5u;             
        v.x *= 0x27d4eb2du;     
        r = v.x;
        
        Out = r * (1.0 / float(0xffffffff));
        }
        // unity-custom-func-end
        
        struct Bindings_Hash21_f9cb7e2359090704d8ce920bb2c8f0e0_float
        {
        };
        
        void SG_Hash21_f9cb7e2359090704d8ce920bb2c8f0e0_float(float2 _In, Bindings_Hash21_f9cb7e2359090704d8ce920bb2c8f0e0_float IN, out float Out_1)
        {
        float2 _Property_dfe0e1c50fb44c23a9cf47c3cb978b13_Out_0_Vector2 = _In;
        float _Hash21TchouCustomFunction_f329ddd3ccbd40c895e296e64420e5eb_Out_1_Float;
        Hash21Tchou_float(_Property_dfe0e1c50fb44c23a9cf47c3cb978b13_Out_0_Vector2, _Hash21TchouCustomFunction_f329ddd3ccbd40c895e296e64420e5eb_Out_1_Float);
        Out_1 = _Hash21TchouCustomFunction_f329ddd3ccbd40c895e296e64420e5eb_Out_1_Float;
        }
        
        struct Bindings_HexGrid_9d5ab070c54c57049b7958a425bd33ef_float
        {
        half4 uv0;
        };
        
        void SG_HexGrid_9d5ab070c54c57049b7958a425bd33ef_float(float2 _UV, bool _UV_3252b5a4c5ff46c6884b893efd0e1d12_IsConnected, float2 _Scale, float _LineWidth, Bindings_HexGrid_9d5ab070c54c57049b7958a425bd33ef_float IN, out float Grid_1, out float EdgeDistance_2, out float TileID_3)
        {
        float _Property_cb7d3dd9120d4a85a3e730777f15ba25_Out_0_Float = _LineWidth;
        float _Float_71261deb126a4b5aaa451fb60b59f039_Out_0_Float = float(0.5773503);
        float2 _Property_9f14c33a69ff42078c5dd9e045038320_Out_0_Vector2 = _UV;
        bool _Property_9f14c33a69ff42078c5dd9e045038320_Out_0_Vector2_IsConnected = _UV_3252b5a4c5ff46c6884b893efd0e1d12_IsConnected;
        float4 _UV_adcfd6d214434b779c25ab6c8b91fdc5_Out_0_Vector4 = IN.uv0;
        float2 _BranchOnInputConnection_580d7213a5104a5f871e7bde70b7501e_Out_3_Vector2 = _Property_9f14c33a69ff42078c5dd9e045038320_Out_0_Vector2_IsConnected ? _Property_9f14c33a69ff42078c5dd9e045038320_Out_0_Vector2 : (_UV_adcfd6d214434b779c25ab6c8b91fdc5_Out_0_Vector4.xy);
        float2 _Property_ee1ce111d23c4370abc6007c265748d0_Out_0_Vector2 = _Scale;
        float2 _Multiply_d8babd3007184af5a100979c58bb2382_Out_2_Vector2;
        Unity_Multiply_float2_float2(_BranchOnInputConnection_580d7213a5104a5f871e7bde70b7501e_Out_3_Vector2, _Property_ee1ce111d23c4370abc6007c265748d0_Out_0_Vector2, _Multiply_d8babd3007184af5a100979c58bb2382_Out_2_Vector2);
        float _Split_cf50d257c31f46118b112941ece1503f_R_1_Float = _Multiply_d8babd3007184af5a100979c58bb2382_Out_2_Vector2[0];
        float _Split_cf50d257c31f46118b112941ece1503f_G_2_Float = _Multiply_d8babd3007184af5a100979c58bb2382_Out_2_Vector2[1];
        float _Split_cf50d257c31f46118b112941ece1503f_B_3_Float = 0;
        float _Split_cf50d257c31f46118b112941ece1503f_A_4_Float = 0;
        float _Multiply_5ba3576cf4af4d179354c0485fd033cd_Out_2_Float;
        Unity_Multiply_float_float(_Float_71261deb126a4b5aaa451fb60b59f039_Out_0_Float, _Split_cf50d257c31f46118b112941ece1503f_R_1_Float, _Multiply_5ba3576cf4af4d179354c0485fd033cd_Out_2_Float);
        float _Multiply_689d6af4166b482298bec6f73e03542e_Out_2_Float;
        Unity_Multiply_float_float(_Multiply_5ba3576cf4af4d179354c0485fd033cd_Out_2_Float, 2, _Multiply_689d6af4166b482298bec6f73e03542e_Out_2_Float);
        float _Add_4f91719b10e64f29b1e1951320dd25a7_Out_2_Float;
        Unity_Add_float(_Multiply_5ba3576cf4af4d179354c0485fd033cd_Out_2_Float, _Split_cf50d257c31f46118b112941ece1503f_G_2_Float, _Add_4f91719b10e64f29b1e1951320dd25a7_Out_2_Float);
        float2 _Vector2_655c42418c5c423588114047a36b61a3_Out_0_Vector2 = float2(_Multiply_689d6af4166b482298bec6f73e03542e_Out_2_Float, _Add_4f91719b10e64f29b1e1951320dd25a7_Out_2_Float);
        float2 _Fraction_dff0bd5bd2cd447f9f53b571e3634697_Out_1_Vector2;
        Unity_Fraction_float2(_Vector2_655c42418c5c423588114047a36b61a3_Out_0_Vector2, _Fraction_dff0bd5bd2cd447f9f53b571e3634697_Out_1_Vector2);
        float _Split_ea914bd0257e465e83fc2e2d351589e1_R_1_Float = _Fraction_dff0bd5bd2cd447f9f53b571e3634697_Out_1_Vector2[0];
        float _Split_ea914bd0257e465e83fc2e2d351589e1_G_2_Float = _Fraction_dff0bd5bd2cd447f9f53b571e3634697_Out_1_Vector2[1];
        float _Split_ea914bd0257e465e83fc2e2d351589e1_B_3_Float = 0;
        float _Split_ea914bd0257e465e83fc2e2d351589e1_A_4_Float = 0;
        float _Add_d9b464c1db274f44a7f7a0f0c8da96cf_Out_2_Float;
        Unity_Add_float(_Split_ea914bd0257e465e83fc2e2d351589e1_R_1_Float, _Split_ea914bd0257e465e83fc2e2d351589e1_G_2_Float, _Add_d9b464c1db274f44a7f7a0f0c8da96cf_Out_2_Float);
        float _Subtract_dbd1c31b45ca4818849935ff0b73fadd_Out_2_Float;
        Unity_Subtract_float(_Add_d9b464c1db274f44a7f7a0f0c8da96cf_Out_2_Float, float(1), _Subtract_dbd1c31b45ca4818849935ff0b73fadd_Out_2_Float);
        float2 _Floor_234fbdb6cc9e4c2ebae7162dc391a8b5_Out_1_Vector2;
        Unity_Floor_float2(_Vector2_655c42418c5c423588114047a36b61a3_Out_0_Vector2, _Floor_234fbdb6cc9e4c2ebae7162dc391a8b5_Out_1_Vector2);
        float _Split_7ca15f55e00d4b6787ca25093d625048_R_1_Float = _Floor_234fbdb6cc9e4c2ebae7162dc391a8b5_Out_1_Vector2[0];
        float _Split_7ca15f55e00d4b6787ca25093d625048_G_2_Float = _Floor_234fbdb6cc9e4c2ebae7162dc391a8b5_Out_1_Vector2[1];
        float _Split_7ca15f55e00d4b6787ca25093d625048_B_3_Float = 0;
        float _Split_7ca15f55e00d4b6787ca25093d625048_A_4_Float = 0;
        float _Add_4696e51e50e84fab8ec4bbd65e373aa7_Out_2_Float;
        Unity_Add_float(_Split_7ca15f55e00d4b6787ca25093d625048_R_1_Float, _Split_7ca15f55e00d4b6787ca25093d625048_G_2_Float, _Add_4696e51e50e84fab8ec4bbd65e373aa7_Out_2_Float);
        float _Modulo_902d9b9ca2fe4595a64855dc03dd43a7_Out_2_Float;
        Unity_Modulo_float(_Add_4696e51e50e84fab8ec4bbd65e373aa7_Out_2_Float, float(3), _Modulo_902d9b9ca2fe4595a64855dc03dd43a7_Out_2_Float);
        float _Step_4d10c28ec45b48d98fd97e50066137b9_Out_2_Float;
        Unity_Step_float(float(1), _Modulo_902d9b9ca2fe4595a64855dc03dd43a7_Out_2_Float, _Step_4d10c28ec45b48d98fd97e50066137b9_Out_2_Float);
        float _Multiply_8d45173cf9e4432781534c99f3d847d7_Out_2_Float;
        Unity_Multiply_float_float(_Subtract_dbd1c31b45ca4818849935ff0b73fadd_Out_2_Float, _Step_4d10c28ec45b48d98fd97e50066137b9_Out_2_Float, _Multiply_8d45173cf9e4432781534c99f3d847d7_Out_2_Float);
        float2 _Swizzle_a905421ae26d4c75bb6336275723d656_Out_1_Vector2 = _Fraction_dff0bd5bd2cd447f9f53b571e3634697_Out_1_Vector2.yx;
        float2 _Multiply_a471faa986b94b5d92c71b2a4d26115b_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Fraction_dff0bd5bd2cd447f9f53b571e3634697_Out_1_Vector2, float2(2, 2), _Multiply_a471faa986b94b5d92c71b2a4d26115b_Out_2_Vector2);
        float2 _Subtract_19e62fb94c324854aa5d0d02af8892df_Out_2_Vector2;
        Unity_Subtract_float2(_Swizzle_a905421ae26d4c75bb6336275723d656_Out_1_Vector2, _Multiply_a471faa986b94b5d92c71b2a4d26115b_Out_2_Vector2, _Subtract_19e62fb94c324854aa5d0d02af8892df_Out_2_Vector2);
        float _Step_0265bb43d8454293b84537af6ef7e4c1_Out_2_Float;
        Unity_Step_float(float(2), _Modulo_902d9b9ca2fe4595a64855dc03dd43a7_Out_2_Float, _Step_0265bb43d8454293b84537af6ef7e4c1_Out_2_Float);
        float2 _Multiply_4a6fa5bf4ff54b83aa2bd5c4faad60b9_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Subtract_19e62fb94c324854aa5d0d02af8892df_Out_2_Vector2, (_Step_0265bb43d8454293b84537af6ef7e4c1_Out_2_Float.xx), _Multiply_4a6fa5bf4ff54b83aa2bd5c4faad60b9_Out_2_Vector2);
        float2 _Add_496340faf53e40cf970e58e02f0241bb_Out_2_Vector2;
        Unity_Add_float2((_Multiply_8d45173cf9e4432781534c99f3d847d7_Out_2_Float.xx), _Multiply_4a6fa5bf4ff54b83aa2bd5c4faad60b9_Out_2_Vector2, _Add_496340faf53e40cf970e58e02f0241bb_Out_2_Vector2);
        float2 _OneMinus_5f09b3a1562d49b88c48e5353762d463_Out_1_Vector2;
        Unity_OneMinus_float2(_Swizzle_a905421ae26d4c75bb6336275723d656_Out_1_Vector2, _OneMinus_5f09b3a1562d49b88c48e5353762d463_Out_1_Vector2);
        float2 _Add_e54db37408514639ba07cdd91a26bca8_Out_2_Vector2;
        Unity_Add_float2(_Add_496340faf53e40cf970e58e02f0241bb_Out_2_Vector2, _OneMinus_5f09b3a1562d49b88c48e5353762d463_Out_1_Vector2, _Add_e54db37408514639ba07cdd91a26bca8_Out_2_Vector2);
        float2 _Step_6820617cc39944f1b8acef27c49fb7ee_Out_2_Vector2;
        Unity_Step_float2(_Fraction_dff0bd5bd2cd447f9f53b571e3634697_Out_1_Vector2, _Swizzle_a905421ae26d4c75bb6336275723d656_Out_1_Vector2, _Step_6820617cc39944f1b8acef27c49fb7ee_Out_2_Vector2);
        float _DotProduct_346886296e1a4c0cade97e6d79c17045_Out_2_Float;
        Unity_DotProduct_float2(_Add_e54db37408514639ba07cdd91a26bca8_Out_2_Vector2, _Step_6820617cc39944f1b8acef27c49fb7ee_Out_2_Vector2, _DotProduct_346886296e1a4c0cade97e6d79c17045_Out_2_Float);
        float _InverseLerp_c8520ff182a24155acd860724f13f871_Out_3_Float;
        Unity_InverseLerp_float(_Property_cb7d3dd9120d4a85a3e730777f15ba25_Out_0_Float, float(1), _DotProduct_346886296e1a4c0cade97e6d79c17045_Out_2_Float, _InverseLerp_c8520ff182a24155acd860724f13f871_Out_3_Float);
        float _OneMinus_f1a1044608cd41ef80b7199c2795cfd5_Out_1_Float;
        Unity_OneMinus_float(_InverseLerp_c8520ff182a24155acd860724f13f871_Out_3_Float, _OneMinus_f1a1044608cd41ef80b7199c2795cfd5_Out_1_Float);
        float _DDXY_74abdb71de0c4e67b1a5909087ae3f79_Out_1_Float;
        Unity_DDXY_74abdb71de0c4e67b1a5909087ae3f79_float(_OneMinus_f1a1044608cd41ef80b7199c2795cfd5_Out_1_Float, _DDXY_74abdb71de0c4e67b1a5909087ae3f79_Out_1_Float);
        float _Divide_cc692cf2307d4e1d8596c5258a5f5c38_Out_2_Float;
        Unity_Divide_float(_InverseLerp_c8520ff182a24155acd860724f13f871_Out_3_Float, _DDXY_74abdb71de0c4e67b1a5909087ae3f79_Out_1_Float, _Divide_cc692cf2307d4e1d8596c5258a5f5c38_Out_2_Float);
        float _Saturate_bab2a9fef9574fc2ba72ff1199d71dfe_Out_1_Float;
        Unity_Saturate_float(_Divide_cc692cf2307d4e1d8596c5258a5f5c38_Out_2_Float, _Saturate_bab2a9fef9574fc2ba72ff1199d71dfe_Out_1_Float);
        float2 _Add_d0862c8022894bf7b1d492049b8e7c38_Out_2_Vector2;
        Unity_Add_float2((_Step_4d10c28ec45b48d98fd97e50066137b9_Out_2_Float.xx), _Floor_234fbdb6cc9e4c2ebae7162dc391a8b5_Out_1_Vector2, _Add_d0862c8022894bf7b1d492049b8e7c38_Out_2_Vector2);
        float2 _Multiply_03f402d3caa4430d94a19dced1f24a84_Out_2_Vector2;
        Unity_Multiply_float2_float2((_Step_0265bb43d8454293b84537af6ef7e4c1_Out_2_Float.xx), _Step_6820617cc39944f1b8acef27c49fb7ee_Out_2_Vector2, _Multiply_03f402d3caa4430d94a19dced1f24a84_Out_2_Vector2);
        float2 _Subtract_8e7a4ddbd3934c068a564b276a5b2a06_Out_2_Vector2;
        Unity_Subtract_float2(_Add_d0862c8022894bf7b1d492049b8e7c38_Out_2_Vector2, _Multiply_03f402d3caa4430d94a19dced1f24a84_Out_2_Vector2, _Subtract_8e7a4ddbd3934c068a564b276a5b2a06_Out_2_Vector2);
        float2 _Floor_c503ac91885d404ebefe6c4e9c2b7e33_Out_1_Vector2;
        Unity_Floor_float2(_Subtract_8e7a4ddbd3934c068a564b276a5b2a06_Out_2_Vector2, _Floor_c503ac91885d404ebefe6c4e9c2b7e33_Out_1_Vector2);
        Bindings_Hash21_f9cb7e2359090704d8ce920bb2c8f0e0_float _Hash21_5acac2f18cce41e2aded526497ee35cd;
        half _Hash21_5acac2f18cce41e2aded526497ee35cd_Out_1_Float;
        SG_Hash21_f9cb7e2359090704d8ce920bb2c8f0e0_float(_Floor_c503ac91885d404ebefe6c4e9c2b7e33_Out_1_Vector2, _Hash21_5acac2f18cce41e2aded526497ee35cd, _Hash21_5acac2f18cce41e2aded526497ee35cd_Out_1_Float);
        Grid_1 = _Saturate_bab2a9fef9574fc2ba72ff1199d71dfe_Out_1_Float;
        EdgeDistance_2 = _DotProduct_346886296e1a4c0cade97e6d79c17045_Out_2_Float;
        TileID_3 = _Hash21_5acac2f18cce41e2aded526497ee35cd_Out_1_Float;
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
            float2 _Property_3808521a33694fbc9bee6f5fe55f56f0_Out_0_Vector2 = _Scale;
            float _Property_662789954ec14031840584af237020da_Out_0_Float = _Line_Width;
            Bindings_HexGrid_9d5ab070c54c57049b7958a425bd33ef_float _HexGrid_188f1b09671b4a8b8e94e67483c9a967;
            _HexGrid_188f1b09671b4a8b8e94e67483c9a967.uv0 = IN.uv0;
            float _HexGrid_188f1b09671b4a8b8e94e67483c9a967_Grid_1_Float;
            float _HexGrid_188f1b09671b4a8b8e94e67483c9a967_EdgeDistance_2_Float;
            float _HexGrid_188f1b09671b4a8b8e94e67483c9a967_TileID_3_Float;
            SG_HexGrid_9d5ab070c54c57049b7958a425bd33ef_float(float2 (0, 0), false, _Property_3808521a33694fbc9bee6f5fe55f56f0_Out_0_Vector2, _Property_662789954ec14031840584af237020da_Out_0_Float, _HexGrid_188f1b09671b4a8b8e94e67483c9a967, _HexGrid_188f1b09671b4a8b8e94e67483c9a967_Grid_1_Float, _HexGrid_188f1b09671b4a8b8e94e67483c9a967_EdgeDistance_2_Float, _HexGrid_188f1b09671b4a8b8e94e67483c9a967_TileID_3_Float);
            Bindings_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float _AlphaSplit_2b44683e0a1c49c792e46925c48ea2cf;
            float3 _AlphaSplit_2b44683e0a1c49c792e46925c48ea2cf_RGB_1_Vector3;
            float _AlphaSplit_2b44683e0a1c49c792e46925c48ea2cf_Alpha_2_Float;
            SG_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float((_HexGrid_188f1b09671b4a8b8e94e67483c9a967_Grid_1_Float.xxxx), _AlphaSplit_2b44683e0a1c49c792e46925c48ea2cf, _AlphaSplit_2b44683e0a1c49c792e46925c48ea2cf_RGB_1_Vector3, _AlphaSplit_2b44683e0a1c49c792e46925c48ea2cf_Alpha_2_Float);
            surface.BaseColor = _AlphaSplit_2b44683e0a1c49c792e46925c48ea2cf_RGB_1_Vector3;
            surface.Alpha = _AlphaSplit_2b44683e0a1c49c792e46925c48ea2cf_Alpha_2_Float;
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