Shader "Hidden/Genesis/Shader"
{
    Properties
    {
        _Tiling("Tiling", Vector, 2) = (1.5, 1.5, 0, 0)
        _Number("Number", Float) = 1
        _Width("Width", Float) = 0.6
        _Separation("Separation", Float) = 0.5
        _Position("Position", Vector, 2) = (0, 0, 0, 0)
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
        float _Number;
        float _Width;
        float _Separation;
        float2 _Position;
        CBUFFER_END
        
        
        // Object and Global properties
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Preview_float(float In, out float Out)
        {
            Out = In;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Round_float(float In, out float Out)
        {
            Out = round(In);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_Spiral_5a26cc160e0fc0a4b9c1a14cfd3d392f_float
        {
        half4 uv0;
        };
        
        void SG_Spiral_5a26cc160e0fc0a4b9c1a14cfd3d392f_float(float2 _tiling, float2 _position, float _number, float _width, float _separation, Bindings_Spiral_5a26cc160e0fc0a4b9c1a14cfd3d392f_float IN, out float Out_1)
        {
        float2 _Property_e153c7b880c3948db843c2d6bd8dfa6b_Out_0_Vector2 = _tiling;
        float2 _TilingAndOffset_fb8d7ff911a67789a67446af088ba42d_Out_3_Vector2;
        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_e153c7b880c3948db843c2d6bd8dfa6b_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_fb8d7ff911a67789a67446af088ba42d_Out_3_Vector2);
        float2 _Property_418e57ec89e01a808a8e910c7858ba93_Out_0_Vector2 = _position;
        float2 _PolarCoordinates_81c39618c2aa9484acc037ca0a85e8c0_Out_4_Vector2;
        Unity_PolarCoordinates_float(_TilingAndOffset_fb8d7ff911a67789a67446af088ba42d_Out_3_Vector2, _Property_418e57ec89e01a808a8e910c7858ba93_Out_0_Vector2, float(1), float(1), _PolarCoordinates_81c39618c2aa9484acc037ca0a85e8c0_Out_4_Vector2);
        float _Split_8bb3d72adfeef984a0e30f52792afa92_R_1_Float = _PolarCoordinates_81c39618c2aa9484acc037ca0a85e8c0_Out_4_Vector2[0];
        float _Split_8bb3d72adfeef984a0e30f52792afa92_G_2_Float = _PolarCoordinates_81c39618c2aa9484acc037ca0a85e8c0_Out_4_Vector2[1];
        float _Split_8bb3d72adfeef984a0e30f52792afa92_B_3_Float = 0;
        float _Split_8bb3d72adfeef984a0e30f52792afa92_A_4_Float = 0;
        float _Multiply_f95e1fd95bf2328fb2293556f91751fa_Out_2_Float;
        Unity_Multiply_float_float(_Split_8bb3d72adfeef984a0e30f52792afa92_R_1_Float, 3.141593, _Multiply_f95e1fd95bf2328fb2293556f91751fa_Out_2_Float);
        float _Property_d7d2693cab64328a949ffea10d71a529_Out_0_Float = _number;
        float _Property_dcaed979c2719285a2894d6bd9ff0ebd_Out_0_Float = _separation;
        float _Multiply_b84a89d2da34cb8c86b62707c0635ef5_Out_2_Float;
        Unity_Multiply_float_float(_Property_dcaed979c2719285a2894d6bd9ff0ebd_Out_0_Float, 6.283185, _Multiply_b84a89d2da34cb8c86b62707c0635ef5_Out_2_Float);
        float _Multiply_0ba36ec64f2be78796d57f9be3610a73_Out_2_Float;
        Unity_Multiply_float_float(_Property_d7d2693cab64328a949ffea10d71a529_Out_0_Float, _Multiply_b84a89d2da34cb8c86b62707c0635ef5_Out_2_Float, _Multiply_0ba36ec64f2be78796d57f9be3610a73_Out_2_Float);
        float _Multiply_62675af4d383d789867881173d1d1bf6_Out_2_Float;
        Unity_Multiply_float_float(_Split_8bb3d72adfeef984a0e30f52792afa92_G_2_Float, _Multiply_0ba36ec64f2be78796d57f9be3610a73_Out_2_Float, _Multiply_62675af4d383d789867881173d1d1bf6_Out_2_Float);
        float _Subtract_73b1f27dcee6018b8bfbd0e6273d3cb1_Out_2_Float;
        Unity_Subtract_float(_Multiply_f95e1fd95bf2328fb2293556f91751fa_Out_2_Float, _Multiply_62675af4d383d789867881173d1d1bf6_Out_2_Float, _Subtract_73b1f27dcee6018b8bfbd0e6273d3cb1_Out_2_Float);
        float _Preview_253fb7c4e86bce88ae63f57e87856b84_Out_1_Float;
        Unity_Preview_float(_Multiply_b84a89d2da34cb8c86b62707c0635ef5_Out_2_Float, _Preview_253fb7c4e86bce88ae63f57e87856b84_Out_1_Float);
        float _Divide_58c25313c91062808b2ac087b8b20f63_Out_2_Float;
        Unity_Divide_float(_Subtract_73b1f27dcee6018b8bfbd0e6273d3cb1_Out_2_Float, _Preview_253fb7c4e86bce88ae63f57e87856b84_Out_1_Float, _Divide_58c25313c91062808b2ac087b8b20f63_Out_2_Float);
        float _Round_11ce79525c2d0189903c2f7326cceac4_Out_1_Float;
        Unity_Round_float(_Divide_58c25313c91062808b2ac087b8b20f63_Out_2_Float, _Round_11ce79525c2d0189903c2f7326cceac4_Out_1_Float);
        float _Subtract_ba333a3a960e7a86b6be61cede6de288_Out_2_Float;
        Unity_Subtract_float(_Divide_58c25313c91062808b2ac087b8b20f63_Out_2_Float, _Round_11ce79525c2d0189903c2f7326cceac4_Out_1_Float, _Subtract_ba333a3a960e7a86b6be61cede6de288_Out_2_Float);
        float _Preview_2ac55deb2f099d8680234f4e77baf145_Out_1_Float;
        Unity_Preview_float(_Multiply_b84a89d2da34cb8c86b62707c0635ef5_Out_2_Float, _Preview_2ac55deb2f099d8680234f4e77baf145_Out_1_Float);
        float _Multiply_21daa93857f25e88a770ce610607f55a_Out_2_Float;
        Unity_Multiply_float_float(_Subtract_ba333a3a960e7a86b6be61cede6de288_Out_2_Float, _Preview_2ac55deb2f099d8680234f4e77baf145_Out_1_Float, _Multiply_21daa93857f25e88a770ce610607f55a_Out_2_Float);
        float _Absolute_47b018925bef9b8e80ac2f7d97fd47a7_Out_1_Float;
        Unity_Absolute_float(_Multiply_21daa93857f25e88a770ce610607f55a_Out_2_Float, _Absolute_47b018925bef9b8e80ac2f7d97fd47a7_Out_1_Float);
        float _Property_8b04eb5a6b3dad898b68ed9c91a50bc7_Out_0_Float = _width;
        float _Multiply_644513c011c3648e803298eb42dae23b_Out_2_Float;
        Unity_Multiply_float_float(_Absolute_47b018925bef9b8e80ac2f7d97fd47a7_Out_1_Float, _Property_8b04eb5a6b3dad898b68ed9c91a50bc7_Out_0_Float, _Multiply_644513c011c3648e803298eb42dae23b_Out_2_Float);
        float _Smoothstep_614f49cb59eec08cb13627fa2deffbe9_Out_3_Float;
        Unity_Smoothstep_float(float(0.4), float(0.6), _Multiply_644513c011c3648e803298eb42dae23b_Out_2_Float, _Smoothstep_614f49cb59eec08cb13627fa2deffbe9_Out_3_Float);
        Out_1 = _Smoothstep_614f49cb59eec08cb13627fa2deffbe9_Out_3_Float;
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
            float2 _Property_a86abc967cd044f8b0b858de40b94f89_Out_0_Vector2 = _Position;
            float _Property_d181bc43e6ec4e21a731af15b6fb175b_Out_0_Float = _Number;
            float _Property_b4f171e6d17d4284a63ad1cf85d2d33d_Out_0_Float = _Width;
            float _Property_1718430e46b949a1a3513c44215ec86a_Out_0_Float = _Separation;
            Bindings_Spiral_5a26cc160e0fc0a4b9c1a14cfd3d392f_float _Spiral_c3d6663b12924b339b553a58e73f70bd;
            _Spiral_c3d6663b12924b339b553a58e73f70bd.uv0 = IN.uv0;
            float _Spiral_c3d6663b12924b339b553a58e73f70bd_Out_1_Float;
            SG_Spiral_5a26cc160e0fc0a4b9c1a14cfd3d392f_float(_Property_373cf82f73754e218bf7948e96a2d8c5_Out_0_Vector2, _Property_a86abc967cd044f8b0b858de40b94f89_Out_0_Vector2, _Property_d181bc43e6ec4e21a731af15b6fb175b_Out_0_Float, _Property_b4f171e6d17d4284a63ad1cf85d2d33d_Out_0_Float, _Property_1718430e46b949a1a3513c44215ec86a_Out_0_Float, _Spiral_c3d6663b12924b339b553a58e73f70bd, _Spiral_c3d6663b12924b339b553a58e73f70bd_Out_1_Float);
            Bindings_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68;
            float3 _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3;
            float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float;
            SG_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float((_Spiral_c3d6663b12924b339b553a58e73f70bd_Out_1_Float.xxxx), _AlphaSplit_ef5448ee86a64148a89692eca4a45a68, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float);
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