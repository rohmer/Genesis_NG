Shader "Hidden/Genesis/RoundedPolygon"
{
    Properties
    {
        _Width("Width", Range(0, 1)) = 0.5
        _Height("Height", Range(0, 1)) = 0.5
        _Sides("Sides", Int) = 6
        _Rounding("Rounding", Range(0, 1)) = 0.35
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
        float _Width;
        float _Height;
        float _Sides;
        float _Rounding;
        CBUFFER_END
        
        
        // Object and Global properties
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
        void RoundedPolygon_Func_float(float2 UV, float Width, float Height, float Sides, float Roundness, out float Out)
        {
            UV = UV * 2. + float2(-1.,-1.);
            float epsilon = 1e-6;
            UV.x = UV.x / ( Width + (Width==0)*epsilon);
            UV.y = UV.y / ( Height + (Height==0)*epsilon);
            Roundness = clamp(Roundness, 1e-6, 1.);
            float i_sides = floor( abs( Sides ) );
            float fullAngle = 2. * PI / i_sides;
            float halfAngle = fullAngle / 2.;
            float opositeAngle = HALF_PI - halfAngle;
            float diagonal = 1. / cos( halfAngle );
            // Chamfer values
            float chamferAngle = Roundness * halfAngle; // Angle taken by the chamfer
            float remainingAngle = halfAngle - chamferAngle; // Angle that remains
            float ratio = tan(remainingAngle) / tan(halfAngle); // This is the ratio between the length of the polygon's triangle and the distance of the chamfer center to the polygon center
            // Center of the chamfer arc
            float2 chamferCenter = float2(
                cos(halfAngle) ,
                sin(halfAngle)
            )* ratio * diagonal;
            // starting of the chamfer arc
            float2 chamferOrigin = float2(
                1.,
                tan(remainingAngle)
            );
            // Using Al Kashi algebra, we determine:
            // The distance distance of the center of the chamfer to the center of the polygon (side A)
            float distA = length(chamferCenter);
            // The radius of the chamfer (side B)
            float distB = 1. - chamferCenter.x;
            // The refence length of side C, which is the distance to the chamfer start
            float distCref = length(chamferOrigin);
            // This will rescale the chamfered polygon to fit the uv space
            // diagonal = length(chamferCenter) + distB;
            float uvScale = diagonal;
            UV *= uvScale;
            float2 polaruv = float2 (
                atan2( UV.y, UV.x ),
                length(UV)
            );
            polaruv.x += HALF_PI + 2*PI;
            polaruv.x = fmod( polaruv.x + halfAngle, fullAngle );
            polaruv.x = abs(polaruv.x - halfAngle);
            UV = float2( cos(polaruv.x), sin(polaruv.x) ) * polaruv.y;
            // Calculate the angle needed for the Al Kashi algebra
            float angleRatio = 1. - (polaruv.x-remainingAngle) / chamferAngle;
            // Calculate the distance of the polygon center to the chamfer extremity
            float distC = sqrt( distA*distA + distB*distB - 2.*distA*distB*cos( PI - halfAngle * angleRatio ) );
            Out = UV.x;
            float chamferZone = ( halfAngle - polaruv.x ) < chamferAngle;
            Out = lerp( UV.x, polaruv.y / distC, chamferZone );
            // Output this to have the shape mask instead of the distance field
        #if defined(SHADER_STAGE_RAY_TRACING)
            Out = saturate((1 - Out) * 1e7);
        #else
            Out = saturate((1 - Out) / fwidth(Out));
        #endif
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
            float _Property_8d1a448f04714a52932b382fc36c96d3_Out_0_Float = _Width;
            float _Property_0c9734adf65b459b928f7d5ab8ff676c_Out_0_Float = _Height;
            float _Property_d907ce187259410f8eccc74656ce7120_Out_0_Float = _Sides;
            float _Property_ba424a270cb74ce49dd79453e8b16a38_Out_0_Float = _Rounding;
            float _RoundedPolygon_429607d596a74a778d43429839bfed1a_Out_5_Float;
            RoundedPolygon_Func_float(IN.uv0.xy, _Property_8d1a448f04714a52932b382fc36c96d3_Out_0_Float, _Property_0c9734adf65b459b928f7d5ab8ff676c_Out_0_Float, _Property_d907ce187259410f8eccc74656ce7120_Out_0_Float, _Property_ba424a270cb74ce49dd79453e8b16a38_Out_0_Float, _RoundedPolygon_429607d596a74a778d43429839bfed1a_Out_5_Float);
            Bindings_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68;
            float3 _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3;
            float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float;
            SG_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float((_RoundedPolygon_429607d596a74a778d43429839bfed1a_Out_5_Float.xxxx), _AlphaSplit_ef5448ee86a64148a89692eca4a45a68, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float);
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