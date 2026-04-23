Shader "Hidden/Genesis/NormalRotate"
{
    Properties
    {
        [Normal][NoScaleOffset]Texture2D_95AB7B17("Normal Map", 2D) = "bump" {}
        [NoScaleOffset]Texture2D_92e0578231b74b3bad71d945d017278d("Rotation Map", 2D) = "black" {}
        Vector1_D0B32F70("Rotation In Degree", Float) = 0
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
        float4 Texture2D_95AB7B17_TexelSize;
        float4 Texture2D_92e0578231b74b3bad71d945d017278d_TexelSize;
        float Vector1_D0B32F70;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_95AB7B17);
        SAMPLER(samplerTexture2D_95AB7B17);
        TEXTURE2D(Texture2D_92e0578231b74b3bad71d945d017278d);
        SAMPLER(samplerTexture2D_92e0578231b74b3bad71d945d017278d);
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
        void Unity_Fraction_float(float In, out float Out)
        {
            Out = frac(In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
        
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
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
            UnityTexture2D _Property_eb3eb65aa1c64e4fa12fcf2d1fbda77e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_95AB7B17);
            float4 _SampleTexture2D_6c01639045bf42e38a1a83abed63a231_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_eb3eb65aa1c64e4fa12fcf2d1fbda77e_Out_0_Texture2D.tex, _Property_eb3eb65aa1c64e4fa12fcf2d1fbda77e_Out_0_Texture2D.samplerstate, _Property_eb3eb65aa1c64e4fa12fcf2d1fbda77e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            _SampleTexture2D_6c01639045bf42e38a1a83abed63a231_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_6c01639045bf42e38a1a83abed63a231_RGBA_0_Vector4);
            float _SampleTexture2D_6c01639045bf42e38a1a83abed63a231_R_4_Float = _SampleTexture2D_6c01639045bf42e38a1a83abed63a231_RGBA_0_Vector4.r;
            float _SampleTexture2D_6c01639045bf42e38a1a83abed63a231_G_5_Float = _SampleTexture2D_6c01639045bf42e38a1a83abed63a231_RGBA_0_Vector4.g;
            float _SampleTexture2D_6c01639045bf42e38a1a83abed63a231_B_6_Float = _SampleTexture2D_6c01639045bf42e38a1a83abed63a231_RGBA_0_Vector4.b;
            float _SampleTexture2D_6c01639045bf42e38a1a83abed63a231_A_7_Float = _SampleTexture2D_6c01639045bf42e38a1a83abed63a231_RGBA_0_Vector4.a;
            float _Property_08ce33a55b2e47b58316ce0f7d2af4ff_Out_0_Float = Vector1_D0B32F70;
            UnityTexture2D _Property_88eec48421ac4b6eb2ba1601609fa836_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_92e0578231b74b3bad71d945d017278d);
            float4 _SampleTexture2D_beff69a9d5f44fe48c75816e66ff8e88_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_88eec48421ac4b6eb2ba1601609fa836_Out_0_Texture2D.tex, _Property_88eec48421ac4b6eb2ba1601609fa836_Out_0_Texture2D.samplerstate, _Property_88eec48421ac4b6eb2ba1601609fa836_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_beff69a9d5f44fe48c75816e66ff8e88_R_4_Float = _SampleTexture2D_beff69a9d5f44fe48c75816e66ff8e88_RGBA_0_Vector4.r;
            float _SampleTexture2D_beff69a9d5f44fe48c75816e66ff8e88_G_5_Float = _SampleTexture2D_beff69a9d5f44fe48c75816e66ff8e88_RGBA_0_Vector4.g;
            float _SampleTexture2D_beff69a9d5f44fe48c75816e66ff8e88_B_6_Float = _SampleTexture2D_beff69a9d5f44fe48c75816e66ff8e88_RGBA_0_Vector4.b;
            float _SampleTexture2D_beff69a9d5f44fe48c75816e66ff8e88_A_7_Float = _SampleTexture2D_beff69a9d5f44fe48c75816e66ff8e88_RGBA_0_Vector4.a;
            float _Fraction_f9224aa190884c64918a691126a195b8_Out_1_Float;
            Unity_Fraction_float(_SampleTexture2D_beff69a9d5f44fe48c75816e66ff8e88_R_4_Float, _Fraction_f9224aa190884c64918a691126a195b8_Out_1_Float);
            float _Multiply_d1160740ef554290ae97af6f41a68326_Out_2_Float;
            Unity_Multiply_float_float(_Fraction_f9224aa190884c64918a691126a195b8_Out_1_Float, 360, _Multiply_d1160740ef554290ae97af6f41a68326_Out_2_Float);
            float _Add_e3262cfb33e240afae82440ea2e06592_Out_2_Float;
            Unity_Add_float(_Property_08ce33a55b2e47b58316ce0f7d2af4ff_Out_0_Float, _Multiply_d1160740ef554290ae97af6f41a68326_Out_2_Float, _Add_e3262cfb33e240afae82440ea2e06592_Out_2_Float);
            float3 _RotateAboutAxis_0c428e8c28754b9d84db80c329129845_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float((_SampleTexture2D_6c01639045bf42e38a1a83abed63a231_RGBA_0_Vector4.xyz), float3 (0, 0, 1), _Add_e3262cfb33e240afae82440ea2e06592_Out_2_Float, _RotateAboutAxis_0c428e8c28754b9d84db80c329129845_Out_3_Vector3);
            float3 _Remap_aad0f1f124d44efb9c8370901abe1c99_Out_3_Vector3;
            Unity_Remap_float3(_RotateAboutAxis_0c428e8c28754b9d84db80c329129845_Out_3_Vector3, float2 (-1, 1), float2 (0, 1), _Remap_aad0f1f124d44efb9c8370901abe1c99_Out_3_Vector3);
            surface.BaseColor = _Remap_aad0f1f124d44efb9c8370901abe1c99_Out_3_Vector3;
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