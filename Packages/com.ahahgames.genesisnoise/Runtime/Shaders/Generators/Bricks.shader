Shader "Hidden/Genesis/Bricks"
{
    Properties
    {
        _Tiling("Tiling", Vector, 2) = (2, 4, 0, 0)
        _Size("Size", Float) = 0.65
        _Offset("Offset", Float) = 0.5
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
        float _Offset;
        CBUFFER_END
        
        
        // Object and Global properties
        
        	// Graph Includes
        	// GraphIncludes: <None>
        
        	// Graph Functions
        	
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Modulo_float(float A, float B, out float Out)
        {
            Out = fmod(A, B);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
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
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Sign_float(float In, out float Out)
        {
            Out = sign(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Minimum_float(float A, float B, out float Out)
        {
            Out = min(A, B);
        };
        
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
        
        void Unity_Floor_float2(float2 In, out float2 Out)
        {
            Out = floor(In);
        }
        
        void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
        {
             float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
             Out = lerp(Min, Max, randomno);
        }
        
        struct Bindings_Brick_aa594629bd691e649abe52f379f329b1_float
        {
        half4 uv0;
        };
        
        void SG_Brick_aa594629bd691e649abe52f379f329b1_float(float _width, float2 _tiling, float _offset, float2 _luminance_MM, Bindings_Brick_aa594629bd691e649abe52f379f329b1_float IN, out float Bricks_1, out float Luminance_2)
        {
        float _Property_360bc1b1cd690f86bc70e8f9cb64dd62_Out_0_Float = _offset;
        float2 _Property_372660d10ff02e85a219c963d16063f1_Out_0_Vector2 = _tiling;
        float2 _TilingAndOffset_7ef98bf5d80d3e80920e877b157d97a2_Out_3_Vector2;
        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_372660d10ff02e85a219c963d16063f1_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_7ef98bf5d80d3e80920e877b157d97a2_Out_3_Vector2);
        float _Split_f0b81b5f36b230828dd0ebd0c92835ab_R_1_Float = _TilingAndOffset_7ef98bf5d80d3e80920e877b157d97a2_Out_3_Vector2[0];
        float _Split_f0b81b5f36b230828dd0ebd0c92835ab_G_2_Float = _TilingAndOffset_7ef98bf5d80d3e80920e877b157d97a2_Out_3_Vector2[1];
        float _Split_f0b81b5f36b230828dd0ebd0c92835ab_B_3_Float = 0;
        float _Split_f0b81b5f36b230828dd0ebd0c92835ab_A_4_Float = 0;
        float _Modulo_c07a4bc27232418aa72f0c61a301dc45_Out_2_Float;
        Unity_Modulo_float(_Split_f0b81b5f36b230828dd0ebd0c92835ab_G_2_Float, float(2), _Modulo_c07a4bc27232418aa72f0c61a301dc45_Out_2_Float);
        float _Step_461c99ec31d84085a47b2348095312d8_Out_2_Float;
        Unity_Step_float(float(1), _Modulo_c07a4bc27232418aa72f0c61a301dc45_Out_2_Float, _Step_461c99ec31d84085a47b2348095312d8_Out_2_Float);
        float _Multiply_76f867be51007e8cbdda055751ae4db6_Out_2_Float;
        Unity_Multiply_float_float(_Property_360bc1b1cd690f86bc70e8f9cb64dd62_Out_0_Float, _Step_461c99ec31d84085a47b2348095312d8_Out_2_Float, _Multiply_76f867be51007e8cbdda055751ae4db6_Out_2_Float);
        float _Add_341d2d4008e41688940e9c6d1a920274_Out_2_Float;
        Unity_Add_float(_Multiply_76f867be51007e8cbdda055751ae4db6_Out_2_Float, _Split_f0b81b5f36b230828dd0ebd0c92835ab_R_1_Float, _Add_341d2d4008e41688940e9c6d1a920274_Out_2_Float);
        float2 _Vector2_25aa176118bbf889b9fcc25d7c1b628f_Out_0_Vector2 = float2(_Add_341d2d4008e41688940e9c6d1a920274_Out_2_Float, _Split_f0b81b5f36b230828dd0ebd0c92835ab_G_2_Float);
        float2 _Fraction_af7153cf8516cb83813f2fa644312c46_Out_1_Vector2;
        Unity_Fraction_float2(_Vector2_25aa176118bbf889b9fcc25d7c1b628f_Out_0_Vector2, _Fraction_af7153cf8516cb83813f2fa644312c46_Out_1_Vector2);
        float _Property_213c9e6e95ba64828704c5ad7e10ffe4_Out_0_Float = _width;
        float2 _Property_dd75dab9ab162c879158d8f520dc99ca_Out_0_Vector2 = _tiling;
        float _Split_767f19bf96d6788f9f9c457fa575c629_R_1_Float = _Property_dd75dab9ab162c879158d8f520dc99ca_Out_0_Vector2[0];
        float _Split_767f19bf96d6788f9f9c457fa575c629_G_2_Float = _Property_dd75dab9ab162c879158d8f520dc99ca_Out_0_Vector2[1];
        float _Split_767f19bf96d6788f9f9c457fa575c629_B_3_Float = 0;
        float _Split_767f19bf96d6788f9f9c457fa575c629_A_4_Float = 0;
        float _Divide_9475c6a5c0bb908e81e210dd7d6d173b_Out_2_Float;
        Unity_Divide_float(float(1), _Split_767f19bf96d6788f9f9c457fa575c629_G_2_Float, _Divide_9475c6a5c0bb908e81e210dd7d6d173b_Out_2_Float);
        float2 _Property_5087edf83f6d8d80b134da351eb0e0c0_Out_0_Vector2 = _tiling;
        float _Split_830f9f1e927cc482a16a0b0b8c4e4d6e_R_1_Float = _Property_5087edf83f6d8d80b134da351eb0e0c0_Out_0_Vector2[0];
        float _Split_830f9f1e927cc482a16a0b0b8c4e4d6e_G_2_Float = _Property_5087edf83f6d8d80b134da351eb0e0c0_Out_0_Vector2[1];
        float _Split_830f9f1e927cc482a16a0b0b8c4e4d6e_B_3_Float = 0;
        float _Split_830f9f1e927cc482a16a0b0b8c4e4d6e_A_4_Float = 0;
        float _Subtract_effececa9cf8f1858856ec2f76c08839_Out_2_Float;
        Unity_Subtract_float(_Split_830f9f1e927cc482a16a0b0b8c4e4d6e_G_2_Float, _Split_830f9f1e927cc482a16a0b0b8c4e4d6e_R_1_Float, _Subtract_effececa9cf8f1858856ec2f76c08839_Out_2_Float);
        float _Sign_3c97e7286b5b088cb347991992044448_Out_1_Float;
        Unity_Sign_float(_Subtract_effececa9cf8f1858856ec2f76c08839_Out_2_Float, _Sign_3c97e7286b5b088cb347991992044448_Out_1_Float);
        float _Maximum_bb8bf526e11e4d85b01a1f46cd683115_Out_2_Float;
        Unity_Maximum_float(_Sign_3c97e7286b5b088cb347991992044448_Out_1_Float, float(0), _Maximum_bb8bf526e11e4d85b01a1f46cd683115_Out_2_Float);
        float _Multiply_a115ff149142a580bac0b299f13969db_Out_2_Float;
        Unity_Multiply_float_float(_Divide_9475c6a5c0bb908e81e210dd7d6d173b_Out_2_Float, _Maximum_bb8bf526e11e4d85b01a1f46cd683115_Out_2_Float, _Multiply_a115ff149142a580bac0b299f13969db_Out_2_Float);
        float _Add_4bc3a346e7dc7683bc3757ce07aa04fb_Out_2_Float;
        Unity_Add_float(_Property_213c9e6e95ba64828704c5ad7e10ffe4_Out_0_Float, _Multiply_a115ff149142a580bac0b299f13969db_Out_2_Float, _Add_4bc3a346e7dc7683bc3757ce07aa04fb_Out_2_Float);
        float _Property_f29e2628341b9584874421047b52fa5b_Out_0_Float = _width;
        float2 _Property_6f42d6f68e71a989b9342ffea1bee4d6_Out_0_Vector2 = _tiling;
        float _Split_25f2b5a039a8ce8d85c47ed81c21b835_R_1_Float = _Property_6f42d6f68e71a989b9342ffea1bee4d6_Out_0_Vector2[0];
        float _Split_25f2b5a039a8ce8d85c47ed81c21b835_G_2_Float = _Property_6f42d6f68e71a989b9342ffea1bee4d6_Out_0_Vector2[1];
        float _Split_25f2b5a039a8ce8d85c47ed81c21b835_B_3_Float = 0;
        float _Split_25f2b5a039a8ce8d85c47ed81c21b835_A_4_Float = 0;
        float _Divide_e7112e56c78462829447a6e4dcdaebfa_Out_2_Float;
        Unity_Divide_float(float(-1), _Split_25f2b5a039a8ce8d85c47ed81c21b835_R_1_Float, _Divide_e7112e56c78462829447a6e4dcdaebfa_Out_2_Float);
        float _Minimum_101ba23489be8a8990d97a9ec40ac589_Out_2_Float;
        Unity_Minimum_float(_Sign_3c97e7286b5b088cb347991992044448_Out_1_Float, float(0), _Minimum_101ba23489be8a8990d97a9ec40ac589_Out_2_Float);
        float _Multiply_eef33b4d984fb48eb35d8214d0260a42_Out_2_Float;
        Unity_Multiply_float_float(_Divide_e7112e56c78462829447a6e4dcdaebfa_Out_2_Float, _Minimum_101ba23489be8a8990d97a9ec40ac589_Out_2_Float, _Multiply_eef33b4d984fb48eb35d8214d0260a42_Out_2_Float);
        float _Add_d0c98a00e92bf18eb6c132d8e1f30e19_Out_2_Float;
        Unity_Add_float(_Property_f29e2628341b9584874421047b52fa5b_Out_0_Float, _Multiply_eef33b4d984fb48eb35d8214d0260a42_Out_2_Float, _Add_d0c98a00e92bf18eb6c132d8e1f30e19_Out_2_Float);
        float _Rectangle_60dc71b9aa2e6084b4873c8f50fb6a1b_Out_3_Float;
        Unity_Rectangle_Fastest_float(_Fraction_af7153cf8516cb83813f2fa644312c46_Out_1_Vector2, _Add_4bc3a346e7dc7683bc3757ce07aa04fb_Out_2_Float, _Add_d0c98a00e92bf18eb6c132d8e1f30e19_Out_2_Float, _Rectangle_60dc71b9aa2e6084b4873c8f50fb6a1b_Out_3_Float);
        float2 _Floor_2651089126cd4181a89307237070a17a_Out_1_Vector2;
        Unity_Floor_float2(_Vector2_25aa176118bbf889b9fcc25d7c1b628f_Out_0_Vector2, _Floor_2651089126cd4181a89307237070a17a_Out_1_Vector2);
        float2 _Property_bb91d940e8cf358b9c9dc354ce0e2fcb_Out_0_Vector2 = _luminance_MM;
        float _Split_0750c061179ce78bae2dedf39e277020_R_1_Float = _Property_bb91d940e8cf358b9c9dc354ce0e2fcb_Out_0_Vector2[0];
        float _Split_0750c061179ce78bae2dedf39e277020_G_2_Float = _Property_bb91d940e8cf358b9c9dc354ce0e2fcb_Out_0_Vector2[1];
        float _Split_0750c061179ce78bae2dedf39e277020_B_3_Float = 0;
        float _Split_0750c061179ce78bae2dedf39e277020_A_4_Float = 0;
        float _RandomRange_72a1f8723b8b0d89beba8d71fb3b6cb9_Out_3_Float;
        Unity_RandomRange_float(_Floor_2651089126cd4181a89307237070a17a_Out_1_Vector2, _Split_0750c061179ce78bae2dedf39e277020_R_1_Float, _Split_0750c061179ce78bae2dedf39e277020_G_2_Float, _RandomRange_72a1f8723b8b0d89beba8d71fb3b6cb9_Out_3_Float);
        float _Multiply_5cca750cc1984f8386f57d2ff4d5ada1_Out_2_Float;
        Unity_Multiply_float_float(_RandomRange_72a1f8723b8b0d89beba8d71fb3b6cb9_Out_3_Float, _Rectangle_60dc71b9aa2e6084b4873c8f50fb6a1b_Out_3_Float, _Multiply_5cca750cc1984f8386f57d2ff4d5ada1_Out_2_Float);
        Bricks_1 = _Rectangle_60dc71b9aa2e6084b4873c8f50fb6a1b_Out_3_Float;
        Luminance_2 = _Multiply_5cca750cc1984f8386f57d2ff4d5ada1_Out_2_Float;
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
            float _Property_79872766530b4b81831f53438b3c3c02_Out_0_Float = _Offset;
            Bindings_Brick_aa594629bd691e649abe52f379f329b1_float _Brick_6ccdb1f52b224037a672ef07e0c155eb;
            _Brick_6ccdb1f52b224037a672ef07e0c155eb.uv0 = IN.uv0;
            float _Brick_6ccdb1f52b224037a672ef07e0c155eb_Bricks_1_Float;
            float _Brick_6ccdb1f52b224037a672ef07e0c155eb_Luminance_2_Float;
            SG_Brick_aa594629bd691e649abe52f379f329b1_float(_Property_08b08894e5dd42e5a93d3c4964258bf9_Out_0_Float, _Property_23c0ef2244e145be840e3b30e3acbc6d_Out_0_Vector2, _Property_79872766530b4b81831f53438b3c3c02_Out_0_Float, float2 (0, 1), _Brick_6ccdb1f52b224037a672ef07e0c155eb, _Brick_6ccdb1f52b224037a672ef07e0c155eb_Bricks_1_Float, _Brick_6ccdb1f52b224037a672ef07e0c155eb_Luminance_2_Float);
            Bindings_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68;
            float3 _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3;
            float _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float;
            SG_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float((_Brick_6ccdb1f52b224037a672ef07e0c155eb_Bricks_1_Float.xxxx), _AlphaSplit_ef5448ee86a64148a89692eca4a45a68, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_RGB_1_Vector3, _AlphaSplit_ef5448ee86a64148a89692eca4a45a68_Alpha_2_Float);
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