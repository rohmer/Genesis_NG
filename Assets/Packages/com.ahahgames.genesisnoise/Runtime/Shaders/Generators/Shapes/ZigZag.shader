Shader "Hidden/Genesis/ZigZag"
{
    Properties
    {
        _Tiling("Tiling", Vector, 2) = (3, 3, 0, 0)
        _Wavelength("Wavelength", Float) = 0.5
        _Amplitude("Amplitude", Float) = 0.2
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
        float _Wavelength;
        float _Amplitude;
        CBUFFER_END
        
        
        // Object and Global properties
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void TriangleWave_float(float In, out float Out)
        {
            Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Round_float(float In, out float Out)
        {
            Out = round(In);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_ZigZag_1de2640525189284b8e549fd02f813f1_float
        {
        half4 uv0;
        };
        
        void SG_ZigZag_1de2640525189284b8e549fd02f813f1_float(float2 _tiling, float _wavelength, float _amplitude, Bindings_ZigZag_1de2640525189284b8e549fd02f813f1_float IN, out float Out_1)
        {
        float2 _Property_c3d717ab3a32a4858ffdc3a1e0fbae8a_Out_0_Vector2 = _tiling;
        float2 _TilingAndOffset_2dd99dd81959e4899577487e0e7cb5ab_Out_3_Vector2;
        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_c3d717ab3a32a4858ffdc3a1e0fbae8a_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_2dd99dd81959e4899577487e0e7cb5ab_Out_3_Vector2);
        float _Split_2b46ddf8f06d018194a5b4a08517cb82_R_1_Float = _TilingAndOffset_2dd99dd81959e4899577487e0e7cb5ab_Out_3_Vector2[0];
        float _Split_2b46ddf8f06d018194a5b4a08517cb82_G_2_Float = _TilingAndOffset_2dd99dd81959e4899577487e0e7cb5ab_Out_3_Vector2[1];
        float _Split_2b46ddf8f06d018194a5b4a08517cb82_B_3_Float = 0;
        float _Split_2b46ddf8f06d018194a5b4a08517cb82_A_4_Float = 0;
        float _Property_6b473e3c48706482bf8dec2e8c4612ae_Out_0_Float = _amplitude;
        float _Divide_860e53b6f6ad5981a155adbed68fc5a5_Out_2_Float;
        Unity_Divide_float(_Split_2b46ddf8f06d018194a5b4a08517cb82_G_2_Float, _Property_6b473e3c48706482bf8dec2e8c4612ae_Out_0_Float, _Divide_860e53b6f6ad5981a155adbed68fc5a5_Out_2_Float);
        float _Property_f76c2fdd03acc18385a577ec31e4ab7a_Out_0_Float = _wavelength;
        float _Divide_01d358a1f0dc448bbd610151ae677910_Out_2_Float;
        Unity_Divide_float(_Split_2b46ddf8f06d018194a5b4a08517cb82_R_1_Float, _Property_f76c2fdd03acc18385a577ec31e4ab7a_Out_0_Float, _Divide_01d358a1f0dc448bbd610151ae677910_Out_2_Float);
        float _TriangleWave_63a30e2468e33784bd94f3eb9166d072_Out_1_Float;
        TriangleWave_float(_Divide_01d358a1f0dc448bbd610151ae677910_Out_2_Float, _TriangleWave_63a30e2468e33784bd94f3eb9166d072_Out_1_Float);
        float _Subtract_5dabb4b50a2b6e8499f243ced95a5970_Out_2_Float;
        Unity_Subtract_float(_Divide_860e53b6f6ad5981a155adbed68fc5a5_Out_2_Float, _TriangleWave_63a30e2468e33784bd94f3eb9166d072_Out_1_Float, _Subtract_5dabb4b50a2b6e8499f243ced95a5970_Out_2_Float);
        float _Round_889f188df9e9be84a4c182bab15b0231_Out_1_Float;
        Unity_Round_float(_Subtract_5dabb4b50a2b6e8499f243ced95a5970_Out_2_Float, _Round_889f188df9e9be84a4c182bab15b0231_Out_1_Float);
        float _Subtract_98d5fbbff44f6083b1478e4383138f49_Out_2_Float;
        Unity_Subtract_float(_Subtract_5dabb4b50a2b6e8499f243ced95a5970_Out_2_Float, _Round_889f188df9e9be84a4c182bab15b0231_Out_1_Float, _Subtract_98d5fbbff44f6083b1478e4383138f49_Out_2_Float);
        float _Absolute_45195baffbc25680897d9194868089ac_Out_1_Float;
        Unity_Absolute_float(_Subtract_98d5fbbff44f6083b1478e4383138f49_Out_2_Float, _Absolute_45195baffbc25680897d9194868089ac_Out_1_Float);
        float _Multiply_ebe2548ade0765818756922d48313e08_Out_2_Float;
        Unity_Multiply_float_float(2, _Absolute_45195baffbc25680897d9194868089ac_Out_1_Float, _Multiply_ebe2548ade0765818756922d48313e08_Out_2_Float);
        float _Smoothstep_81359d54b189898abd293b9ddbd675b7_Out_3_Float;
        Unity_Smoothstep_float(float(0.5), float(0.55), _Multiply_ebe2548ade0765818756922d48313e08_Out_2_Float, _Smoothstep_81359d54b189898abd293b9ddbd675b7_Out_3_Float);
        Out_1 = _Smoothstep_81359d54b189898abd293b9ddbd675b7_Out_3_Float;
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
            float _Property_efafd5e298b24394a8532a47fd77d2a7_Out_0_Float = _Wavelength;
            float _Property_79872766530b4b81831f53438b3c3c02_Out_0_Float = _Amplitude;
            Bindings_ZigZag_1de2640525189284b8e549fd02f813f1_float _ZigZag_aca02a6a34c344a8a2fdd869c5e43351;
            _ZigZag_aca02a6a34c344a8a2fdd869c5e43351.uv0 = IN.uv0;
            float _ZigZag_aca02a6a34c344a8a2fdd869c5e43351_Out_1_Float;
            SG_ZigZag_1de2640525189284b8e549fd02f813f1_float(_Property_373cf82f73754e218bf7948e96a2d8c5_Out_0_Vector2, _Property_efafd5e298b24394a8532a47fd77d2a7_Out_0_Float, _Property_79872766530b4b81831f53438b3c3c02_Out_0_Float, _ZigZag_aca02a6a34c344a8a2fdd869c5e43351, _ZigZag_aca02a6a34c344a8a2fdd869c5e43351_Out_1_Float);
            Bindings_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68;
            float3 _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3;
            float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float;
            SG_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float((_ZigZag_aca02a6a34c344a8a2fdd869c5e43351_Out_1_Float.xxxx), _AlphaSplit_ef5448ee86a64148a89692eca4a45a68, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float);
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