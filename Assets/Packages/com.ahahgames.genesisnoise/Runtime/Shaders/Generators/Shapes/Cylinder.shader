Shader "Hidden/Genesis/Cylinder"
{
    Properties
    {
        [NoScaleOffset]_UV_2D("UV_2D", 2D) = "white" {}
        [NoScaleOffset]_UV_3D("UV_3D", 3D) = "white" {}
        [NoScaleOffset]_UV_Cube("UV_Cube", CUBE) = "" {}
        Color_0b800f21b7834f34b2f8fccb70497644("InnerColor", Color) = (1, 1, 1, 1)
        Color_4e4ca9b8331044a7a521f153309b8fa0("OuterColor", Color) = (0, 0, 0, 0)
        _Radius("Radius", Range(0, 1)) = 0.05
        Vector1_557fe2158c17440fa91cf546c074fa13("Length", Range(0, 1)) = 0.4
        _Scale("[Inspector] Scale", Vector) = (1, 1, 1, 0)
        _Offset("[Inspector] Offset", Vector) = (0, 0, 0, 0)
        _Smooth("Smooth", Range(0, 1)) = 0
        _Rotation("Rotation (Deg)", Range(0, 360)) = 0
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
            #pragma shader_feature_local _ USE_CUSTOM_UV
        
        #if defined(USE_CUSTOM_UV)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
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
        		o.WorldSpaceViewDirection = o.direction;
        
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
        float4 _UV_2D_TexelSize;
        float4 Color_0b800f21b7834f34b2f8fccb70497644;
        float4 Color_4e4ca9b8331044a7a521f153309b8fa0;
        float _Radius;
        float Vector1_557fe2158c17440fa91cf546c074fa13;
        float3 _Scale;
        float3 _Offset;
        float _Smooth;
        float _Rotation;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_UV_2D);
        SAMPLER(sampler_UV_2D);
        TEXTURE3D(_UV_3D);
        SAMPLER(sampler_UV_3D);
        TEXTURECUBE(_UV_Cube);
        SAMPLER(sampler_UV_Cube);
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
        // unity-custom-func-begin
        void IsCubemap_float(out float CubeMap){
        #if defined(UNITY_CUSTOM_TEXTURE_INCLUDED)
        CubeMap = CustomRenderTextureDimension == CRT_DIMENSION_CUBE;
        #else
        CubeMap = false;
        #endif
        }
        // unity-custom-func-end
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_UvOrDirection_af5ac8792ac0de645a18e7392189ee62_float
        {
        float3 WorldSpaceViewDirection;
        half4 uv0;
        };
        
        void SG_UvOrDirection_af5ac8792ac0de645a18e7392189ee62_float(Bindings_UvOrDirection_af5ac8792ac0de645a18e7392189ee62_float IN, out float4 OutVector4_1)
        {
        float _IsCubemapCustomFunction_44f52bbf76d24c7f9499651fac1f3e23_CubeMap_0_Boolean;
        IsCubemap_float(_IsCubemapCustomFunction_44f52bbf76d24c7f9499651fac1f3e23_CubeMap_0_Boolean);
        float4 _UV_05dbd5f6c3f74ac6a2982a8fd9b8c855_Out_0_Vector4 = IN.uv0;
        float3 _Branch_fe4e4f06620248ee89aa95864f0c5733_Out_3_Vector3;
        Unity_Branch_float3(_IsCubemapCustomFunction_44f52bbf76d24c7f9499651fac1f3e23_CubeMap_0_Boolean, IN.WorldSpaceViewDirection, (_UV_05dbd5f6c3f74ac6a2982a8fd9b8c855_Out_0_Vector4.xyz), _Branch_fe4e4f06620248ee89aa95864f0c5733_Out_3_Vector3);
        OutVector4_1 = (float4(_Branch_fe4e4f06620248ee89aa95864f0c5733_Out_3_Vector3, 1.0));
        }
        
        // unity-custom-func-begin
        void IsCubemap2_float(out float Cubemap, out float T2D, out float T3D){
        #if defined(UNITY_CUSTOM_TEXTURE_INCLUDED)
        Cubemap = CustomRenderTextureDimension == CRT_DIMENSION_CUBE;
        T2D = CustomRenderTextureDimension == CRT_DIMENSION_2D;
        T3D = CustomRenderTextureDimension == CRT_DIMENSION_3D;
        #else
        Cubemap = false;
        T2D = true;
        T3D = false;
        #endif
        }
        // unity-custom-func-end
        
        struct Bindings_CustomTextureDimension_6963768b4883e2f41a9369ffa0873580_float
        {
        };
        
        void SG_CustomTextureDimension_6963768b4883e2f41a9369ffa0873580_float(Bindings_CustomTextureDimension_6963768b4883e2f41a9369ffa0873580_float IN, out float _2D_1, out float _3D_2, out float Cubemap_3)
        {
        float _IsCubemap2CustomFunction_44f52bbf76d24c7f9499651fac1f3e23_Cubemap_0_Boolean;
        float _IsCubemap2CustomFunction_44f52bbf76d24c7f9499651fac1f3e23_T2D_1_Boolean;
        float _IsCubemap2CustomFunction_44f52bbf76d24c7f9499651fac1f3e23_T3D_2_Boolean;
        IsCubemap2_float(_IsCubemap2CustomFunction_44f52bbf76d24c7f9499651fac1f3e23_Cubemap_0_Boolean, _IsCubemap2CustomFunction_44f52bbf76d24c7f9499651fac1f3e23_T2D_1_Boolean, _IsCubemap2CustomFunction_44f52bbf76d24c7f9499651fac1f3e23_T3D_2_Boolean);
        _2D_1 = _IsCubemap2CustomFunction_44f52bbf76d24c7f9499651fac1f3e23_T2D_1_Boolean;
        _3D_2 = _IsCubemap2CustomFunction_44f52bbf76d24c7f9499651fac1f3e23_T3D_2_Boolean;
        Cubemap_3 = _IsCubemap2CustomFunction_44f52bbf76d24c7f9499651fac1f3e23_Cubemap_0_Boolean;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_SampleCustomUV_1410a13e31985de4ba8d88632b5fb1df_float
        {
        };
        
        void SG_SampleCustomUV_1410a13e31985de4ba8d88632b5fb1df_float(UnityTexture3D Texture3D_55bc0f4b7968470cbbe24f93b9dd80f0, UnityTexture2D Texture2D_0c990abc2fae4145917d7a2d060186b9, UnityTextureCube Cubemap_a0e2de8579584a009c8cb1b06ea30340, float3 Vector3_9a12621ab29e4c57ab8729b4364fc37a, Bindings_SampleCustomUV_1410a13e31985de4ba8d88632b5fb1df_float IN, out float3 UV_0)
        {
        Bindings_CustomTextureDimension_6963768b4883e2f41a9369ffa0873580_float _CustomTextureDimension_4746b829a13a4421b33a9c2f8dbbc369;
        float _CustomTextureDimension_4746b829a13a4421b33a9c2f8dbbc369_var2D_1_Boolean;
        float _CustomTextureDimension_4746b829a13a4421b33a9c2f8dbbc369_var3D_2_Boolean;
        float _CustomTextureDimension_4746b829a13a4421b33a9c2f8dbbc369_Cubemap_3_Boolean;
        SG_CustomTextureDimension_6963768b4883e2f41a9369ffa0873580_float(_CustomTextureDimension_4746b829a13a4421b33a9c2f8dbbc369, _CustomTextureDimension_4746b829a13a4421b33a9c2f8dbbc369_var2D_1_Boolean, _CustomTextureDimension_4746b829a13a4421b33a9c2f8dbbc369_var3D_2_Boolean, _CustomTextureDimension_4746b829a13a4421b33a9c2f8dbbc369_Cubemap_3_Boolean);
        UnityTexture2D _Property_cdd8701393d442739b4dc8ffe1cf1fc5_Out_0_Texture2D = Texture2D_0c990abc2fae4145917d7a2d060186b9;
        float3 _Property_e0fb0083291d440fab47c15fbf3c2e0c_Out_0_Vector3 = Vector3_9a12621ab29e4c57ab8729b4364fc37a;
        float4 _SampleTexture2D_4af6d365fc8145ada48c74f3316030fe_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_cdd8701393d442739b4dc8ffe1cf1fc5_Out_0_Texture2D.tex, _Property_cdd8701393d442739b4dc8ffe1cf1fc5_Out_0_Texture2D.samplerstate, _Property_cdd8701393d442739b4dc8ffe1cf1fc5_Out_0_Texture2D.GetTransformedUV((_Property_e0fb0083291d440fab47c15fbf3c2e0c_Out_0_Vector3.xy)) );
        float _SampleTexture2D_4af6d365fc8145ada48c74f3316030fe_R_4_Float = _SampleTexture2D_4af6d365fc8145ada48c74f3316030fe_RGBA_0_Vector4.r;
        float _SampleTexture2D_4af6d365fc8145ada48c74f3316030fe_G_5_Float = _SampleTexture2D_4af6d365fc8145ada48c74f3316030fe_RGBA_0_Vector4.g;
        float _SampleTexture2D_4af6d365fc8145ada48c74f3316030fe_B_6_Float = _SampleTexture2D_4af6d365fc8145ada48c74f3316030fe_RGBA_0_Vector4.b;
        float _SampleTexture2D_4af6d365fc8145ada48c74f3316030fe_A_7_Float = _SampleTexture2D_4af6d365fc8145ada48c74f3316030fe_RGBA_0_Vector4.a;
        float4 _Branch_8522ad2f16994f3aae639748f168c474_Out_3_Vector4;
        Unity_Branch_float4(_CustomTextureDimension_4746b829a13a4421b33a9c2f8dbbc369_var2D_1_Boolean, _SampleTexture2D_4af6d365fc8145ada48c74f3316030fe_RGBA_0_Vector4, float4(0, 0, 0, 0), _Branch_8522ad2f16994f3aae639748f168c474_Out_3_Vector4);
        UnityTexture3D _Property_1981c7608f7748a0bb100859ca932214_Out_0_Texture3D = Texture3D_55bc0f4b7968470cbbe24f93b9dd80f0;
        float4 _SampleTexture3D_01b254d12a9940578fe210a6cfd6837d_RGBA_0_Vector4 = SAMPLE_TEXTURE3D(_Property_1981c7608f7748a0bb100859ca932214_Out_0_Texture3D.tex, _Property_1981c7608f7748a0bb100859ca932214_Out_0_Texture3D.samplerstate, _Property_e0fb0083291d440fab47c15fbf3c2e0c_Out_0_Vector3 );
        float _SampleTexture3D_01b254d12a9940578fe210a6cfd6837d_R_5_Float = _SampleTexture3D_01b254d12a9940578fe210a6cfd6837d_RGBA_0_Vector4.r;
        float _SampleTexture3D_01b254d12a9940578fe210a6cfd6837d_G_6_Float = _SampleTexture3D_01b254d12a9940578fe210a6cfd6837d_RGBA_0_Vector4.g;
        float _SampleTexture3D_01b254d12a9940578fe210a6cfd6837d_B_7_Float = _SampleTexture3D_01b254d12a9940578fe210a6cfd6837d_RGBA_0_Vector4.b;
        float _SampleTexture3D_01b254d12a9940578fe210a6cfd6837d_A_8_Float = _SampleTexture3D_01b254d12a9940578fe210a6cfd6837d_RGBA_0_Vector4.a;
        float4 _Branch_6a10f79acd094416a8cebfe41b864eeb_Out_3_Vector4;
        Unity_Branch_float4(_CustomTextureDimension_4746b829a13a4421b33a9c2f8dbbc369_var3D_2_Boolean, _SampleTexture3D_01b254d12a9940578fe210a6cfd6837d_RGBA_0_Vector4, float4(0, 0, 0, 0), _Branch_6a10f79acd094416a8cebfe41b864eeb_Out_3_Vector4);
        float4 _Add_479e7913b32f429e82446d8f144aa7d6_Out_2_Vector4;
        Unity_Add_float4(_Branch_8522ad2f16994f3aae639748f168c474_Out_3_Vector4, _Branch_6a10f79acd094416a8cebfe41b864eeb_Out_3_Vector4, _Add_479e7913b32f429e82446d8f144aa7d6_Out_2_Vector4);
        UnityTextureCube _Property_b1a8a041ae634d3c9bd40c03e7327653_Out_0_Cubemap = Cubemap_a0e2de8579584a009c8cb1b06ea30340;
        float4 _SampleCubemap_f13574ac19c04aa588f4813cad04d09a_Out_0_Vector4 = SAMPLE_TEXTURECUBE_LOD(_Property_b1a8a041ae634d3c9bd40c03e7327653_Out_0_Cubemap.tex, _Property_b1a8a041ae634d3c9bd40c03e7327653_Out_0_Cubemap.samplerstate, _Property_e0fb0083291d440fab47c15fbf3c2e0c_Out_0_Vector3, float(0));
        float4 _Branch_67755ba2b2474fd6b07a8971bac8b24e_Out_3_Vector4;
        Unity_Branch_float4(_CustomTextureDimension_4746b829a13a4421b33a9c2f8dbbc369_Cubemap_3_Boolean, _SampleCubemap_f13574ac19c04aa588f4813cad04d09a_Out_0_Vector4, float4(0, 0, 0, 0), _Branch_67755ba2b2474fd6b07a8971bac8b24e_Out_3_Vector4);
        float4 _Add_860199bca0464f808ae3132d590e872f_Out_2_Vector4;
        Unity_Add_float4(_Add_479e7913b32f429e82446d8f144aa7d6_Out_2_Vector4, _Branch_67755ba2b2474fd6b07a8971bac8b24e_Out_3_Vector4, _Add_860199bca0464f808ae3132d590e872f_Out_2_Vector4);
        float3 _Property_74d4cc0384994ad29a37bf7d2b84dda0_Out_0_Vector3 = Vector3_9a12621ab29e4c57ab8729b4364fc37a;
        #if defined(USE_CUSTOM_UV)
        float3 _USECUSTOMUV_acfbf696a2694893906e1548995dde08_Out_0_Vector3 = (_Add_860199bca0464f808ae3132d590e872f_Out_2_Vector4.xyz);
        #else
        float3 _USECUSTOMUV_acfbf696a2694893906e1548995dde08_Out_0_Vector3 = _Property_74d4cc0384994ad29a37bf7d2b84dda0_Out_0_Vector3;
        #endif
        UV_0 = _USECUSTOMUV_acfbf696a2694893906e1548995dde08_Out_0_Vector3;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
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
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Fraction_float3(float3 In, out float3 Out)
        {
            Out = frac(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        // unity-custom-func-begin
        void sdCylinder_float(float3 UV, float Size, float Length, out float Distance){
        float2 d = abs(float2(length(UV.xz),UV.y)) - float2(Length, Size);
        
        Distance = min(max(d.x,d.y),0.0) + length(max(d,0.0));
        
        }
        // unity-custom-func-end
        
        struct Bindings_Cylinder_fb4101c8d0faca04691b5ca40b9451a4_float
        {
        };
        
        void SG_Cylinder_fb4101c8d0faca04691b5ca40b9451a4_float(float3 Vector3_3346b92eb0ab4ab4b7d8c14aee8a267b, float Vector1_5ed138a11217423c9d9e4aa7b3e7b52d, float Vector1_8c6ad11a34104511bf92d5b357824d99, Bindings_Cylinder_fb4101c8d0faca04691b5ca40b9451a4_float IN, out float Distance_1)
        {
        float3 _Property_091c6b186d1144728bd9b29ef7db0099_Out_0_Vector3 = Vector3_3346b92eb0ab4ab4b7d8c14aee8a267b;
        float _Property_12439409a6a4467bb5f2d2c6c092a199_Out_0_Float = Vector1_5ed138a11217423c9d9e4aa7b3e7b52d;
        float _Property_133079657a234ccebd2e72cbf2e8a988_Out_0_Float = Vector1_8c6ad11a34104511bf92d5b357824d99;
        float _sdCylinderCustomFunction_b386cc3fff824f3083e95bba30929387_Distance_1_Float;
        sdCylinder_float(_Property_091c6b186d1144728bd9b29ef7db0099_Out_0_Vector3, _Property_12439409a6a4467bb5f2d2c6c092a199_Out_0_Float, _Property_133079657a234ccebd2e72cbf2e8a988_Out_0_Float, _sdCylinderCustomFunction_b386cc3fff824f3083e95bba30929387_Distance_1_Float);
        Distance_1 = _sdCylinderCustomFunction_b386cc3fff824f3083e95bba30929387_Distance_1_Float;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_SmoothLerpSDF_eb9da8909793e87438a92e17a6251e1f_float
        {
        };
        
        void SG_SmoothLerpSDF_eb9da8909793e87438a92e17a6251e1f_float(float4 Vector4_48826b261ec94b8cb42b95b8787d36ec, float4 Vector4_4b1d800475e5454fa8b8e7e053e69c58, float Vector1_41c567a03434496ca7d2ac8eb9ef3c1e, float Vector1_768a0efedfcc4b63a9b4dafde91ba44f, Bindings_SmoothLerpSDF_eb9da8909793e87438a92e17a6251e1f_float IN, out float4 OutVector4_1)
        {
        float4 _Property_5528c69097024726872b20b5fb6c9ff0_Out_0_Vector4 = Vector4_48826b261ec94b8cb42b95b8787d36ec;
        float4 _Property_603df54393364d5f8ecc78f553adcb15_Out_0_Vector4 = Vector4_4b1d800475e5454fa8b8e7e053e69c58;
        float _Property_8e09435c65ab4cab9fac6fe0a7f205da_Out_0_Float = Vector1_41c567a03434496ca7d2ac8eb9ef3c1e;
        float _Property_838201df4b334ac9b9524b14090ffe5c_Out_0_Float = Vector1_768a0efedfcc4b63a9b4dafde91ba44f;
        float _Subtract_39f2b462c3734713b5629f4733c2b806_Out_2_Float;
        Unity_Subtract_float(_Property_8e09435c65ab4cab9fac6fe0a7f205da_Out_0_Float, _Property_838201df4b334ac9b9524b14090ffe5c_Out_0_Float, _Subtract_39f2b462c3734713b5629f4733c2b806_Out_2_Float);
        float _Smoothstep_18b19b5a7b994edea62124f52aef66ab_Out_3_Float;
        Unity_Smoothstep_float(_Subtract_39f2b462c3734713b5629f4733c2b806_Out_2_Float, _Property_8e09435c65ab4cab9fac6fe0a7f205da_Out_0_Float, float(0.002), _Smoothstep_18b19b5a7b994edea62124f52aef66ab_Out_3_Float);
        float4 _Lerp_cf7e27c704df4d3f865e7f01f4526da9_Out_3_Vector4;
        Unity_Lerp_float4(_Property_5528c69097024726872b20b5fb6c9ff0_Out_0_Vector4, _Property_603df54393364d5f8ecc78f553adcb15_Out_0_Vector4, (_Smoothstep_18b19b5a7b994edea62124f52aef66ab_Out_3_Float.xxxx), _Lerp_cf7e27c704df4d3f865e7f01f4526da9_Out_3_Vector4);
        OutVector4_1 = _Lerp_cf7e27c704df4d3f865e7f01f4526da9_Out_3_Vector4;
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
            float4 _Property_ea523fd14892481aaa13f177314e567b_Out_0_Vector4 = Color_4e4ca9b8331044a7a521f153309b8fa0;
            float4 _Property_00c27b6fb4f248d4b169144b26e9e712_Out_0_Vector4 = Color_0b800f21b7834f34b2f8fccb70497644;
            UnityTexture3D _Property_08afcbe0b24c49afbab02c1c8bfa7d85_Out_0_Texture3D = UnityBuildTexture3DStruct(_UV_3D);
            UnityTexture2D _Property_cbe85f4a30ff46fe8f606ffc2088b6cf_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_UV_2D);
            UnityTextureCube _Property_4dd6be9736a343688e1a02579395ca4b_Out_0_Cubemap = UnityBuildTextureCubeStruct(_UV_Cube);
            Bindings_UvOrDirection_af5ac8792ac0de645a18e7392189ee62_float _UvOrDirection_7a62d7120f6344de81f4b34641072c26;
            _UvOrDirection_7a62d7120f6344de81f4b34641072c26.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _UvOrDirection_7a62d7120f6344de81f4b34641072c26.uv0 = IN.uv0;
            float4 _UvOrDirection_7a62d7120f6344de81f4b34641072c26_OutVector4_1_Vector4;
            SG_UvOrDirection_af5ac8792ac0de645a18e7392189ee62_float(_UvOrDirection_7a62d7120f6344de81f4b34641072c26, _UvOrDirection_7a62d7120f6344de81f4b34641072c26_OutVector4_1_Vector4);
            Bindings_SampleCustomUV_1410a13e31985de4ba8d88632b5fb1df_float _SampleCustomUV_4e4017107e0841acad570c384317485e;
            float3 _SampleCustomUV_4e4017107e0841acad570c384317485e_UV_0_Vector3;
            SG_SampleCustomUV_1410a13e31985de4ba8d88632b5fb1df_float(_Property_08afcbe0b24c49afbab02c1c8bfa7d85_Out_0_Texture3D, _Property_cbe85f4a30ff46fe8f606ffc2088b6cf_Out_0_Texture2D, _Property_4dd6be9736a343688e1a02579395ca4b_Out_0_Cubemap, (_UvOrDirection_7a62d7120f6344de81f4b34641072c26_OutVector4_1_Vector4.xyz), _SampleCustomUV_4e4017107e0841acad570c384317485e, _SampleCustomUV_4e4017107e0841acad570c384317485e_UV_0_Vector3);
            float3 _Subtract_5f6fe928d44d4959b8387687323d14fb_Out_2_Vector3;
            Unity_Subtract_float3(_SampleCustomUV_4e4017107e0841acad570c384317485e_UV_0_Vector3, float3(0.5, 0.5, 0.5), _Subtract_5f6fe928d44d4959b8387687323d14fb_Out_2_Vector3);
            float _Property_e3b1ab4ac8fa4ba9af342e0949aa4f8e_Out_0_Float = _Rotation;
            float3 _RotateAboutAxis_a6c1e97527e44f409d7ebedae3417bfd_Out_3_Vector3;
            Unity_Rotate_About_Axis_Degrees_float(_Subtract_5f6fe928d44d4959b8387687323d14fb_Out_2_Vector3, float3 (0, 0, 1), _Property_e3b1ab4ac8fa4ba9af342e0949aa4f8e_Out_0_Float, _RotateAboutAxis_a6c1e97527e44f409d7ebedae3417bfd_Out_3_Vector3);
            float3 _Add_038532a4b9dd4b86b9271eac2391fdbd_Out_2_Vector3;
            Unity_Add_float3(_RotateAboutAxis_a6c1e97527e44f409d7ebedae3417bfd_Out_3_Vector3, float3(0.5, 0.5, 0.5), _Add_038532a4b9dd4b86b9271eac2391fdbd_Out_2_Vector3);
            float3 _Property_0431201c3f984ec38f743a1090e80004_Out_0_Vector3 = _Scale;
            float3 _Multiply_1e3facd469cb460db0728e3653aade57_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Add_038532a4b9dd4b86b9271eac2391fdbd_Out_2_Vector3, _Property_0431201c3f984ec38f743a1090e80004_Out_0_Vector3, _Multiply_1e3facd469cb460db0728e3653aade57_Out_2_Vector3);
            float3 _Property_63fe1f038ae44a159d00f6854d3d0757_Out_0_Vector3 = _Offset;
            float3 _Add_957010d89e78480f8612cceac3006466_Out_2_Vector3;
            Unity_Add_float3(_Multiply_1e3facd469cb460db0728e3653aade57_Out_2_Vector3, _Property_63fe1f038ae44a159d00f6854d3d0757_Out_0_Vector3, _Add_957010d89e78480f8612cceac3006466_Out_2_Vector3);
            float3 _Fraction_2fe1b25d36314f2e9bb8ad259942c2e4_Out_1_Vector3;
            Unity_Fraction_float3(_Add_957010d89e78480f8612cceac3006466_Out_2_Vector3, _Fraction_2fe1b25d36314f2e9bb8ad259942c2e4_Out_1_Vector3);
            float3 _Subtract_b458d845cf76483cb160b870e2f242ed_Out_2_Vector3;
            Unity_Subtract_float3(_Fraction_2fe1b25d36314f2e9bb8ad259942c2e4_Out_1_Vector3, float3(0.5, 0.5, 0.5), _Subtract_b458d845cf76483cb160b870e2f242ed_Out_2_Vector3);
            float _Property_cfa6796c492c43f1a2d3f4c6bfb72ac7_Out_0_Float = _Radius;
            float _Divide_58cc991b5328479f97f62dee394c5a57_Out_2_Float;
            Unity_Divide_float(_Property_cfa6796c492c43f1a2d3f4c6bfb72ac7_Out_0_Float, float(2), _Divide_58cc991b5328479f97f62dee394c5a57_Out_2_Float);
            float _Property_672a821046704dc084667de50d807b46_Out_0_Float = Vector1_557fe2158c17440fa91cf546c074fa13;
            Bindings_Cylinder_fb4101c8d0faca04691b5ca40b9451a4_float _Cylinder_4acfc0f95f9c43e4a1eeb319e073ec2b;
            float _Cylinder_4acfc0f95f9c43e4a1eeb319e073ec2b_Distance_1_Float;
            SG_Cylinder_fb4101c8d0faca04691b5ca40b9451a4_float(_Subtract_b458d845cf76483cb160b870e2f242ed_Out_2_Vector3, _Divide_58cc991b5328479f97f62dee394c5a57_Out_2_Float, _Property_672a821046704dc084667de50d807b46_Out_0_Float, _Cylinder_4acfc0f95f9c43e4a1eeb319e073ec2b, _Cylinder_4acfc0f95f9c43e4a1eeb319e073ec2b_Distance_1_Float);
            float _Property_5736e850513b46209a9bf46685b1e882_Out_0_Float = _Smooth;
            Bindings_SmoothLerpSDF_eb9da8909793e87438a92e17a6251e1f_float _SmoothLerpSDF_f60808ffc2f7481486a8a4737750df6a;
            float4 _SmoothLerpSDF_f60808ffc2f7481486a8a4737750df6a_OutVector4_1_Vector4;
            SG_SmoothLerpSDF_eb9da8909793e87438a92e17a6251e1f_float(_Property_ea523fd14892481aaa13f177314e567b_Out_0_Vector4, _Property_00c27b6fb4f248d4b169144b26e9e712_Out_0_Vector4, _Cylinder_4acfc0f95f9c43e4a1eeb319e073ec2b_Distance_1_Float, _Property_5736e850513b46209a9bf46685b1e882_Out_0_Float, _SmoothLerpSDF_f60808ffc2f7481486a8a4737750df6a, _SmoothLerpSDF_f60808ffc2f7481486a8a4737750df6a_OutVector4_1_Vector4);
            float _Split_3d33225f45704ae78faba9e49476c886_R_1_Float = _SmoothLerpSDF_f60808ffc2f7481486a8a4737750df6a_OutVector4_1_Vector4[0];
            float _Split_3d33225f45704ae78faba9e49476c886_G_2_Float = _SmoothLerpSDF_f60808ffc2f7481486a8a4737750df6a_OutVector4_1_Vector4[1];
            float _Split_3d33225f45704ae78faba9e49476c886_B_3_Float = _SmoothLerpSDF_f60808ffc2f7481486a8a4737750df6a_OutVector4_1_Vector4[2];
            float _Split_3d33225f45704ae78faba9e49476c886_A_4_Float = _SmoothLerpSDF_f60808ffc2f7481486a8a4737750df6a_OutVector4_1_Vector4[3];
            surface.BaseColor = (_SmoothLerpSDF_f60808ffc2f7481486a8a4737750df6a_OutVector4_1_Vector4.xyz);
            surface.Alpha = _Split_3d33225f45704ae78faba9e49476c886_A_4_Float;
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