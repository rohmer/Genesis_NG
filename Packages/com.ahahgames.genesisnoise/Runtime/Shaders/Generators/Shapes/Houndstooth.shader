Shader "Hidden/Genesis/Houndstooth"
{
    Properties
    {
        _Tiling("Tiling", Vector, 2) = (10, 10, 0, 0)
        _Teeth("Teeth", Float) = 1
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
        float _Teeth;
        CBUFFER_END
        
        
        // Object and Global properties
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_Houndstooth_67a22abd94d077a4282e47a4cc312992_float
        {
        half4 uv0;
        };
        
        void SG_Houndstooth_67a22abd94d077a4282e47a4cc312992_float(float2 _tiling, float _teeth, Bindings_Houndstooth_67a22abd94d077a4282e47a4cc312992_float IN, out float Out_1)
        {
        float2 _Property_9b30654317e7b78686c13e6cd60230d8_Out_0_Vector2 = _tiling;
        float2 _TilingAndOffset_1255fdbd4b31b786b6c10cf1c2325ded_Out_3_Vector2;
        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_9b30654317e7b78686c13e6cd60230d8_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_1255fdbd4b31b786b6c10cf1c2325ded_Out_3_Vector2);
        float _Split_ef2362a0d00bdb89aa58c27f97a25ec7_R_1_Float = _TilingAndOffset_1255fdbd4b31b786b6c10cf1c2325ded_Out_3_Vector2[0];
        float _Split_ef2362a0d00bdb89aa58c27f97a25ec7_G_2_Float = _TilingAndOffset_1255fdbd4b31b786b6c10cf1c2325ded_Out_3_Vector2[1];
        float _Split_ef2362a0d00bdb89aa58c27f97a25ec7_B_3_Float = 0;
        float _Split_ef2362a0d00bdb89aa58c27f97a25ec7_A_4_Float = 0;
        float _Fraction_17b84f7f41747c89803659f0ae20cf1c_Out_1_Float;
        Unity_Fraction_float(_Split_ef2362a0d00bdb89aa58c27f97a25ec7_R_1_Float, _Fraction_17b84f7f41747c89803659f0ae20cf1c_Out_1_Float);
        float _Smoothstep_6f82725a80608281a7e2739d7fece039_Out_3_Float;
        Unity_Smoothstep_float(float(0.5), float(0.55), _Fraction_17b84f7f41747c89803659f0ae20cf1c_Out_1_Float, _Smoothstep_6f82725a80608281a7e2739d7fece039_Out_3_Float);
        float _Smoothstep_76c578d86ec0ee84bca026135f051f83_Out_3_Float;
        Unity_Smoothstep_float(float(0.95), float(1), _Fraction_17b84f7f41747c89803659f0ae20cf1c_Out_1_Float, _Smoothstep_76c578d86ec0ee84bca026135f051f83_Out_3_Float);
        float _Subtract_c5631ce201cd85829cb6f3171395dcf4_Out_2_Float;
        Unity_Subtract_float(_Smoothstep_6f82725a80608281a7e2739d7fece039_Out_3_Float, _Smoothstep_76c578d86ec0ee84bca026135f051f83_Out_3_Float, _Subtract_c5631ce201cd85829cb6f3171395dcf4_Out_2_Float);
        float _Fraction_c8231402137af480aae10c19422eb144_Out_1_Float;
        Unity_Fraction_float(_Split_ef2362a0d00bdb89aa58c27f97a25ec7_G_2_Float, _Fraction_c8231402137af480aae10c19422eb144_Out_1_Float);
        float _Smoothstep_3a3c016bef19b887a3e84b078aa57313_Out_3_Float;
        Unity_Smoothstep_float(float(0.5), float(0.55), _Fraction_c8231402137af480aae10c19422eb144_Out_1_Float, _Smoothstep_3a3c016bef19b887a3e84b078aa57313_Out_3_Float);
        float _Smoothstep_dc483984ce32b58ca39cb29456968097_Out_3_Float;
        Unity_Smoothstep_float(float(0.95), float(1), _Fraction_c8231402137af480aae10c19422eb144_Out_1_Float, _Smoothstep_dc483984ce32b58ca39cb29456968097_Out_3_Float);
        float _Subtract_b830888697d3bd89bc4ad8a8b3275434_Out_2_Float;
        Unity_Subtract_float(_Smoothstep_3a3c016bef19b887a3e84b078aa57313_Out_3_Float, _Smoothstep_dc483984ce32b58ca39cb29456968097_Out_3_Float, _Subtract_b830888697d3bd89bc4ad8a8b3275434_Out_2_Float);
        float _Split_04411adb6464f08281ab3ca1593188c5_R_1_Float = _TilingAndOffset_1255fdbd4b31b786b6c10cf1c2325ded_Out_3_Vector2[0];
        float _Split_04411adb6464f08281ab3ca1593188c5_G_2_Float = _TilingAndOffset_1255fdbd4b31b786b6c10cf1c2325ded_Out_3_Vector2[1];
        float _Split_04411adb6464f08281ab3ca1593188c5_B_3_Float = 0;
        float _Split_04411adb6464f08281ab3ca1593188c5_A_4_Float = 0;
        float _Add_af3082a1a6d51380bcac8004683501b5_Out_2_Float;
        Unity_Add_float(_Split_04411adb6464f08281ab3ca1593188c5_R_1_Float, _Split_04411adb6464f08281ab3ca1593188c5_G_2_Float, _Add_af3082a1a6d51380bcac8004683501b5_Out_2_Float);
        float _Property_94797c852dbf2580a4309ef4588ae8dc_Out_0_Float = _teeth;
        float _Multiply_5d742d077d18a288bdf1d7b6a70c6afa_Out_2_Float;
        Unity_Multiply_float_float(_Add_af3082a1a6d51380bcac8004683501b5_Out_2_Float, _Property_94797c852dbf2580a4309ef4588ae8dc_Out_0_Float, _Multiply_5d742d077d18a288bdf1d7b6a70c6afa_Out_2_Float);
        float _Fraction_7ccf343cf495c48b924283d094805a73_Out_1_Float;
        Unity_Fraction_float(_Multiply_5d742d077d18a288bdf1d7b6a70c6afa_Out_2_Float, _Fraction_7ccf343cf495c48b924283d094805a73_Out_1_Float);
        float _Smoothstep_7451dbbc23d239878e40a41f40199b10_Out_3_Float;
        Unity_Smoothstep_float(float(0.5), float(0.55), _Fraction_7ccf343cf495c48b924283d094805a73_Out_1_Float, _Smoothstep_7451dbbc23d239878e40a41f40199b10_Out_3_Float);
        float _Smoothstep_11c08cdfbc2c58809b0163f0cf6a3ba3_Out_3_Float;
        Unity_Smoothstep_float(float(0.95), float(1), _Fraction_7ccf343cf495c48b924283d094805a73_Out_1_Float, _Smoothstep_11c08cdfbc2c58809b0163f0cf6a3ba3_Out_3_Float);
        float _Subtract_e2cb076e2aeba1829e489e409cba808c_Out_2_Float;
        Unity_Subtract_float(_Smoothstep_7451dbbc23d239878e40a41f40199b10_Out_3_Float, _Smoothstep_11c08cdfbc2c58809b0163f0cf6a3ba3_Out_3_Float, _Subtract_e2cb076e2aeba1829e489e409cba808c_Out_2_Float);
        float _Lerp_b0c1608acb6ca28fa85729906081ee79_Out_3_Float;
        Unity_Lerp_float(_Subtract_c5631ce201cd85829cb6f3171395dcf4_Out_2_Float, _Subtract_b830888697d3bd89bc4ad8a8b3275434_Out_2_Float, _Subtract_e2cb076e2aeba1829e489e409cba808c_Out_2_Float, _Lerp_b0c1608acb6ca28fa85729906081ee79_Out_3_Float);
        Out_1 = _Lerp_b0c1608acb6ca28fa85729906081ee79_Out_3_Float;
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
            float _Property_8c54f0194017487ebeb430acf81b5c0c_Out_0_Float = _Teeth;
            Bindings_Houndstooth_67a22abd94d077a4282e47a4cc312992_float _Houndstooth_0e82f7174c604d63a394a36c4bea726f;
            _Houndstooth_0e82f7174c604d63a394a36c4bea726f.uv0 = IN.uv0;
            float _Houndstooth_0e82f7174c604d63a394a36c4bea726f_Out_1_Float;
            SG_Houndstooth_67a22abd94d077a4282e47a4cc312992_float(_Property_373cf82f73754e218bf7948e96a2d8c5_Out_0_Vector2, _Property_8c54f0194017487ebeb430acf81b5c0c_Out_0_Float, _Houndstooth_0e82f7174c604d63a394a36c4bea726f, _Houndstooth_0e82f7174c604d63a394a36c4bea726f_Out_1_Float);
            Bindings_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68;
            float3 _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3;
            float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float;
            SG_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float((_Houndstooth_0e82f7174c604d63a394a36c4bea726f_Out_1_Float.xxxx), _AlphaSplit_ef5448ee86a64148a89692eca4a45a68, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float);
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