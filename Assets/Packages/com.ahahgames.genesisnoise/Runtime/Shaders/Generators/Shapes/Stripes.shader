Shader "Hidden/Genesis/Stripes"
{
    Properties
    {
        _Frequency("Frequency", Float) = 6
        _Offset("Offset", Float) = 0
        _Thickness("Thickness", Float) = 0.5
        _Rotation("Rotation", Float) = 45
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
        float _Frequency;
        float _Offset;
        float _Thickness;
        float _Rotation;
        CBUFFER_END
        
        
        // Object and Global properties
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
        void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
        {
            Rotation = Rotation * (3.1415926f/180.0f);
            UV -= Center;
            float s, c;
            sincos(Rotation, s, c);
            float3 r3 = float3(-s, c, s);
            float2 r1;
            r1.y = dot(UV, r3.xy);
            r1.x = dot(UV, r3.yz);
            Out = r1 + Center;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Fraction_float2(float2 In, out float2 Out)
        {
            Out = frac(In);
        }
        
        void Unity_Rectangle_Fastest_float(float2 UV, float Width, float Height, out float Out)
        {
            float2 d = abs(UV * 2 - 1) - float2(Width, Height);
        #if defined(SHADER_STAGE_RAY_TRACING)
            d = saturate((1 - saturate(d * 1e7)));
        #else
            d = saturate(1 - d / fwidth(d));
        #endif
            Out = min(d.x, d.y);
        }
        
        struct Bindings_Stripes_1957c4e211f004e43b5a2040d7082630_float
        {
        half4 uv0;
        };
        
        void SG_Stripes_1957c4e211f004e43b5a2040d7082630_float(float _frequency, float _offset, float _width, float _rotation, Bindings_Stripes_1957c4e211f004e43b5a2040d7082630_float IN, out float Out_1)
        {
        float _Property_0d838097226700869079cc00d0852284_Out_0_Float = _rotation;
        float2 _Rotate_920daf2ba7bd6180a0e932ba67f5a262_Out_3_Vector2;
        Unity_Rotate_Degrees_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_0d838097226700869079cc00d0852284_Out_0_Float, _Rotate_920daf2ba7bd6180a0e932ba67f5a262_Out_3_Vector2);
        float _Property_5fe60eed304b8c83969752c293e4ba8f_Out_0_Float = _frequency;
        float2 _Vector2_08468c10273ef08d8ce3de1fb4f539c9_Out_0_Vector2 = float2(_Property_5fe60eed304b8c83969752c293e4ba8f_Out_0_Float, float(1));
        float _Property_b03df2adac750b87978af0b5cccfffce_Out_0_Float = _offset;
        float2 _Vector2_e54ebef4d572b582836426bc4e72c7d5_Out_0_Vector2 = float2(_Property_b03df2adac750b87978af0b5cccfffce_Out_0_Float, float(0));
        float2 _TilingAndOffset_c17d9a59d978ad80abc8c87c4becfaba_Out_3_Vector2;
        Unity_TilingAndOffset_float(_Rotate_920daf2ba7bd6180a0e932ba67f5a262_Out_3_Vector2, _Vector2_08468c10273ef08d8ce3de1fb4f539c9_Out_0_Vector2, _Vector2_e54ebef4d572b582836426bc4e72c7d5_Out_0_Vector2, _TilingAndOffset_c17d9a59d978ad80abc8c87c4becfaba_Out_3_Vector2);
        float2 _Fraction_9f379d335ff7bd88b257eeb9680ca387_Out_1_Vector2;
        Unity_Fraction_float2(_TilingAndOffset_c17d9a59d978ad80abc8c87c4becfaba_Out_3_Vector2, _Fraction_9f379d335ff7bd88b257eeb9680ca387_Out_1_Vector2);
        float _Property_f36035bc10ccf98cb4632b043de9f272_Out_0_Float = _width;
        float _Rectangle_af0961a9fd5f3a8b839e1378a1f45604_Out_3_Float;
        Unity_Rectangle_Fastest_float(_Fraction_9f379d335ff7bd88b257eeb9680ca387_Out_1_Vector2, _Property_f36035bc10ccf98cb4632b043de9f272_Out_0_Float, float(1), _Rectangle_af0961a9fd5f3a8b839e1378a1f45604_Out_3_Float);
        Out_1 = _Rectangle_af0961a9fd5f3a8b839e1378a1f45604_Out_3_Float;
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
            float _Property_08b08894e5dd42e5a93d3c4964258bf9_Out_0_Float = _Frequency;
            float _Property_b16a9ab757fa48a4a6324d08f790a82c_Out_0_Float = _Offset;
            float _Property_3155f7d4be2d46ca8b42441ef464cb96_Out_0_Float = _Thickness;
            float _Property_d35900615e0c485f8a74417b5ce00395_Out_0_Float = _Rotation;
            Bindings_Stripes_1957c4e211f004e43b5a2040d7082630_float _Stripes_6cb6eee7a12a4fbf9d069fd1bd41a467;
            _Stripes_6cb6eee7a12a4fbf9d069fd1bd41a467.uv0 = IN.uv0;
            float _Stripes_6cb6eee7a12a4fbf9d069fd1bd41a467_Out_1_Float;
            SG_Stripes_1957c4e211f004e43b5a2040d7082630_float(_Property_08b08894e5dd42e5a93d3c4964258bf9_Out_0_Float, _Property_b16a9ab757fa48a4a6324d08f790a82c_Out_0_Float, _Property_3155f7d4be2d46ca8b42441ef464cb96_Out_0_Float, _Property_d35900615e0c485f8a74417b5ce00395_Out_0_Float, _Stripes_6cb6eee7a12a4fbf9d069fd1bd41a467, _Stripes_6cb6eee7a12a4fbf9d069fd1bd41a467_Out_1_Float);
            Bindings_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68;
            float3 _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3;
            float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float;
            SG_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float((_Stripes_6cb6eee7a12a4fbf9d069fd1bd41a467_Out_1_Float.xxxx), _AlphaSplit_ef5448ee86a64148a89692eca4a45a68, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float);
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