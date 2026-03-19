Shader "Hidden/Genesis/Grid"
{
    Properties
    {
        _Tiling("Tiling", Vector, 2) = (8, 8, 0, 0)
        _Size("Size", Float) = 0.9
        _Offset("Offset", Vector, 2) = (0, 0, 0, 0)
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
        float _Size;
        float2 _Offset;
        CBUFFER_END
        
        
        // Object and Global properties
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
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
        
        struct Bindings_Grid_f2ff61a18444547458ea8849584f6bec_float
        {
        half4 uv0;
        };
        
        void SG_Grid_f2ff61a18444547458ea8849584f6bec_float(float _width, float2 _tiling, float2 _offset, Bindings_Grid_f2ff61a18444547458ea8849584f6bec_float IN, out float Out_1)
        {
        float2 _Property_372660d10ff02e85a219c963d16063f1_Out_0_Vector2 = _tiling;
        float2 _Property_cf215d09b9c0dd8cbc94e9ff5fc8cd32_Out_0_Vector2 = _offset;
        float2 _TilingAndOffset_7ef98bf5d80d3e80920e877b157d97a2_Out_3_Vector2;
        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_372660d10ff02e85a219c963d16063f1_Out_0_Vector2, _Property_cf215d09b9c0dd8cbc94e9ff5fc8cd32_Out_0_Vector2, _TilingAndOffset_7ef98bf5d80d3e80920e877b157d97a2_Out_3_Vector2);
        float2 _Fraction_00dd85cd0e38fc8ba6e24864e56ff16d_Out_1_Vector2;
        Unity_Fraction_float2(_TilingAndOffset_7ef98bf5d80d3e80920e877b157d97a2_Out_3_Vector2, _Fraction_00dd85cd0e38fc8ba6e24864e56ff16d_Out_1_Vector2);
        float _Property_213c9e6e95ba64828704c5ad7e10ffe4_Out_0_Float = _width;
        float _Rectangle_60dc71b9aa2e6084b4873c8f50fb6a1b_Out_3_Float;
        Unity_Rectangle_Fastest_float(_Fraction_00dd85cd0e38fc8ba6e24864e56ff16d_Out_1_Vector2, _Property_213c9e6e95ba64828704c5ad7e10ffe4_Out_0_Float, _Property_213c9e6e95ba64828704c5ad7e10ffe4_Out_0_Float, _Rectangle_60dc71b9aa2e6084b4873c8f50fb6a1b_Out_3_Float);
        Out_1 = _Rectangle_60dc71b9aa2e6084b4873c8f50fb6a1b_Out_3_Float;
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
            float _Property_08b08894e5dd42e5a93d3c4964258bf9_Out_0_Float = _Size;
            float2 _Property_23c0ef2244e145be840e3b30e3acbc6d_Out_0_Vector2 = _Tiling;
            float2 _Property_169210aae0194fb89e2d13ca857407b7_Out_0_Vector2 = _Offset;
            Bindings_Grid_f2ff61a18444547458ea8849584f6bec_float _Grid_5552a8a4b36d46a2a2a4cceeee468b47;
            _Grid_5552a8a4b36d46a2a2a4cceeee468b47.uv0 = IN.uv0;
            float _Grid_5552a8a4b36d46a2a2a4cceeee468b47_Out_1_Float;
            SG_Grid_f2ff61a18444547458ea8849584f6bec_float(_Property_08b08894e5dd42e5a93d3c4964258bf9_Out_0_Float, _Property_23c0ef2244e145be840e3b30e3acbc6d_Out_0_Vector2, _Property_169210aae0194fb89e2d13ca857407b7_Out_0_Vector2, _Grid_5552a8a4b36d46a2a2a4cceeee468b47, _Grid_5552a8a4b36d46a2a2a4cceeee468b47_Out_1_Float);
            Bindings_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68;
            float3 _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3;
            float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float;
            SG_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float((_Grid_5552a8a4b36d46a2a2a4cceeee468b47_Out_1_Float.xxxx), _AlphaSplit_ef5448ee86a64148a89692eca4a45a68, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float);
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