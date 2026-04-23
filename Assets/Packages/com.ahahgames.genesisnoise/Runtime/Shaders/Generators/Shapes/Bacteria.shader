Shader "Hidden/Genesis/Bacteria"
{
    Properties
    {
        [NoScaleOffset]_Input("Input", 2D) = "white" {}
        _Tiling("Tiling", Vector, 2) = (0.2, 0.15, 0, 0)
        _Seed("Seed", Float) = 52
        [Toggle(_SMOOTHSTEP)]_SMOOTHSTEP("Smoothstep", Float) = 0
        _Inner_Edge("Inner Edge", Vector, 2) = (0.1, 0.05, 0, 0)
        _Outer_Edge("Outer Edge", Vector, 2) = (0.2, 0.15, 0, 0)
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
            #pragma shader_feature_local _ _SMOOTHSTEP
        
        #if defined(_SMOOTHSTEP)
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
        float4 _Input_TexelSize;
        float2 _Tiling;
        float _Seed;
        float2 _Inner_Edge;
        float2 _Outer_Edge;
        CBUFFER_END
        
        
        // Object and Global properties
        TEXTURE2D(_Input);
        SAMPLER(sampler_Input);
        
        	// Graph Includes
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        	// Graph Functions
        	
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Floor_float2(float2 In, out float2 Out)
        {
            Out = floor(In);
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
        float2 i = floor(uv);
        float2 f = frac(uv);
        f = f * f * (3.0 - 2.0 * f);
        uv = abs(frac(uv) - 0.5);
        float2 c0 = i + float2(0.0, 0.0);
        float2 c1 = i + float2(1.0, 0.0);
        float2 c2 = i + float2(0.0, 1.0);
        float2 c3 = i + float2(1.0, 1.0);
        float r0; Hash_LegacySine_2_1_float(c0, r0);
        float r1; Hash_LegacySine_2_1_float(c1, r1);
        float r2; Hash_LegacySine_2_1_float(c2, r2);
        float r3; Hash_LegacySine_2_1_float(c3, r3);
        float bottomOfGrid = lerp(r0, r1, f.x);
        float topOfGrid = lerp(r2, r3, f.x);
        float t = lerp(bottomOfGrid, topOfGrid, f.y);
        return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
        float freq, amp;
        Out = 0.0f;
        freq = pow(2.0, float(0));
        amp = pow(0.5, float(3-0));
        Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        freq = pow(2.0, float(1));
        amp = pow(0.5, float(3-1));
        Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        freq = pow(2.0, float(2));
        amp = pow(0.5, float(3-2));
        Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Fraction_float(float In, out float Out)
        {
            Out = frac(In);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Fraction_float2(float2 In, out float2 Out)
        {
            Out = frac(In);
        }
        
        void Unity_OneMinus_float2(float2 In, out float2 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Preview_float(float In, out float Out)
        {
            Out = In;
        }
        
        void Unity_Preview_float2(float2 In, out float2 Out)
        {
            Out = In;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_BacteriaSmoothstep_e3991c0bfe9e06945833b46fb6e56055_float
        {
        };
        
        void SG_BacteriaSmoothstep_e3991c0bfe9e06945833b46fb6e56055_float(float2 Vector2_541D6BE4, float2 Vector2_3AFAAFE6, float2 Vector2_5166FA29, Bindings_BacteriaSmoothstep_e3991c0bfe9e06945833b46fb6e56055_float IN, out float Out_1)
        {
        float2 _Property_e259816b72fbe18e907d1a44b49251f0_Out_0_Vector2 = Vector2_3AFAAFE6;
        float _Split_deef33a018303e8c91496d0d7c77a21d_R_1_Float = _Property_e259816b72fbe18e907d1a44b49251f0_Out_0_Vector2[0];
        float _Split_deef33a018303e8c91496d0d7c77a21d_G_2_Float = _Property_e259816b72fbe18e907d1a44b49251f0_Out_0_Vector2[1];
        float _Split_deef33a018303e8c91496d0d7c77a21d_B_3_Float = 0;
        float _Split_deef33a018303e8c91496d0d7c77a21d_A_4_Float = 0;
        float2 _Property_e91c65c8af66438fb39b447cbf4c667a_Out_0_Vector2 = Vector2_541D6BE4;
        float _Length_8897e5ad5f40688ba17394236f0b2890_Out_1_Float;
        Unity_Length_float2(_Property_e91c65c8af66438fb39b447cbf4c667a_Out_0_Vector2, _Length_8897e5ad5f40688ba17394236f0b2890_Out_1_Float);
        float _Smoothstep_7e2a5a2f78d37f83a1e15ffea702115c_Out_3_Float;
        Unity_Smoothstep_float(_Split_deef33a018303e8c91496d0d7c77a21d_R_1_Float, _Split_deef33a018303e8c91496d0d7c77a21d_G_2_Float, _Length_8897e5ad5f40688ba17394236f0b2890_Out_1_Float, _Smoothstep_7e2a5a2f78d37f83a1e15ffea702115c_Out_3_Float);
        float2 _Property_01c5746870b92c87a4910d0bd365286e_Out_0_Vector2 = Vector2_5166FA29;
        float _Split_4346eae37b62fd88b704b23b79e85725_R_1_Float = _Property_01c5746870b92c87a4910d0bd365286e_Out_0_Vector2[0];
        float _Split_4346eae37b62fd88b704b23b79e85725_G_2_Float = _Property_01c5746870b92c87a4910d0bd365286e_Out_0_Vector2[1];
        float _Split_4346eae37b62fd88b704b23b79e85725_B_3_Float = 0;
        float _Split_4346eae37b62fd88b704b23b79e85725_A_4_Float = 0;
        float _Smoothstep_ec01d62c176669899e037678af6c23af_Out_3_Float;
        Unity_Smoothstep_float(_Split_4346eae37b62fd88b704b23b79e85725_R_1_Float, _Split_4346eae37b62fd88b704b23b79e85725_G_2_Float, _Length_8897e5ad5f40688ba17394236f0b2890_Out_1_Float, _Smoothstep_ec01d62c176669899e037678af6c23af_Out_3_Float);
        float _Subtract_cf0213744e9e4587b9b840a64693fba8_Out_2_Float;
        Unity_Subtract_float(_Smoothstep_7e2a5a2f78d37f83a1e15ffea702115c_Out_3_Float, _Smoothstep_ec01d62c176669899e037678af6c23af_Out_3_Float, _Subtract_cf0213744e9e4587b9b840a64693fba8_Out_2_Float);
        Out_1 = _Subtract_cf0213744e9e4587b9b840a64693fba8_Out_2_Float;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        struct Bindings_Bacteria_804c76ccbe9643147a24f07885bb47ba_float
        {
        half4 uv0;
        };
        
        void SG_Bacteria_804c76ccbe9643147a24f07885bb47ba_float(float2 _tiling, float _seed, Bindings_Bacteria_804c76ccbe9643147a24f07885bb47ba_float IN, out float Out_1)
        {
        float2 _Property_7e675751e85d1387be71b90322bb342d_Out_0_Vector2 = _tiling;
        float2 _TilingAndOffset_18cf456206c20f85ab692a51794df244_Out_3_Vector2;
        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_7e675751e85d1387be71b90322bb342d_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_18cf456206c20f85ab692a51794df244_Out_3_Vector2);
        float2 _Floor_811b25188fd59585af8407516c85918e_Out_1_Vector2;
        Unity_Floor_float2(_TilingAndOffset_18cf456206c20f85ab692a51794df244_Out_3_Vector2, _Floor_811b25188fd59585af8407516c85918e_Out_1_Vector2);
        float _Property_c612dbde7d6f4688b2264843bed01bdc_Out_0_Float = _seed;
        float _SimpleNoise_f0f9ddf1d8e6678eb34f8ce1b1ace106_Out_2_Float;
        Unity_SimpleNoise_LegacySine_float(_Floor_811b25188fd59585af8407516c85918e_Out_1_Vector2, _Property_c612dbde7d6f4688b2264843bed01bdc_Out_0_Float, _SimpleNoise_f0f9ddf1d8e6678eb34f8ce1b1ace106_Out_2_Float);
        float _Subtract_72c2ceffaebfdb8fa94c28d7e1836c6c_Out_2_Float;
        Unity_Subtract_float(_SimpleNoise_f0f9ddf1d8e6678eb34f8ce1b1ace106_Out_2_Float, float(0.5), _Subtract_72c2ceffaebfdb8fa94c28d7e1836c6c_Out_2_Float);
        float _Multiply_297d0e21ed44cd83a87c57405e66c13b_Out_2_Float;
        Unity_Multiply_float_float(2, _Subtract_72c2ceffaebfdb8fa94c28d7e1836c6c_Out_2_Float, _Multiply_297d0e21ed44cd83a87c57405e66c13b_Out_2_Float);
        float _Fraction_fc11758286aff389b2d776a273ac790e_Out_1_Float;
        Unity_Fraction_float(_Multiply_297d0e21ed44cd83a87c57405e66c13b_Out_2_Float, _Fraction_fc11758286aff389b2d776a273ac790e_Out_1_Float);
        float _Step_90e5426647a21c8bb5f680de67bb6a21_Out_2_Float;
        Unity_Step_float(float(0.75), _Fraction_fc11758286aff389b2d776a273ac790e_Out_1_Float, _Step_90e5426647a21c8bb5f680de67bb6a21_Out_2_Float);
        float2 _Fraction_42d717cd15a0ed81b517d54ee5d8673f_Out_1_Vector2;
        Unity_Fraction_float2(_TilingAndOffset_18cf456206c20f85ab692a51794df244_Out_3_Vector2, _Fraction_42d717cd15a0ed81b517d54ee5d8673f_Out_1_Vector2);
        float2 _OneMinus_3f3c4a9965798188b8b8f5ab51af3586_Out_1_Vector2;
        Unity_OneMinus_float2(_Fraction_42d717cd15a0ed81b517d54ee5d8673f_Out_1_Vector2, _OneMinus_3f3c4a9965798188b8b8f5ab51af3586_Out_1_Vector2);
        float2 _Multiply_327e9d1e928d6f8d8e0b72c5578b7b8e_Out_2_Vector2;
        Unity_Multiply_float2_float2((_Step_90e5426647a21c8bb5f680de67bb6a21_Out_2_Float.xx), _OneMinus_3f3c4a9965798188b8b8f5ab51af3586_Out_1_Vector2, _Multiply_327e9d1e928d6f8d8e0b72c5578b7b8e_Out_2_Vector2);
        float _Step_72916456c205ce84a47948fbfbe398af_Out_2_Float;
        Unity_Step_float(float(0.5), _Fraction_fc11758286aff389b2d776a273ac790e_Out_1_Float, _Step_72916456c205ce84a47948fbfbe398af_Out_2_Float);
        float _Subtract_5f6f48961196df8ca5637d782aee6d92_Out_2_Float;
        Unity_Subtract_float(_Step_72916456c205ce84a47948fbfbe398af_Out_2_Float, _Step_90e5426647a21c8bb5f680de67bb6a21_Out_2_Float, _Subtract_5f6f48961196df8ca5637d782aee6d92_Out_2_Float);
        float _Split_6deeea821e8e658c971fd7ef74c7a1ce_R_1_Float = _Fraction_42d717cd15a0ed81b517d54ee5d8673f_Out_1_Vector2[0];
        float _Split_6deeea821e8e658c971fd7ef74c7a1ce_G_2_Float = _Fraction_42d717cd15a0ed81b517d54ee5d8673f_Out_1_Vector2[1];
        float _Split_6deeea821e8e658c971fd7ef74c7a1ce_B_3_Float = 0;
        float _Split_6deeea821e8e658c971fd7ef74c7a1ce_A_4_Float = 0;
        float _OneMinus_b78b910b77e1058abf76a4e3bdccbc6b_Out_1_Float;
        Unity_OneMinus_float(_Split_6deeea821e8e658c971fd7ef74c7a1ce_R_1_Float, _OneMinus_b78b910b77e1058abf76a4e3bdccbc6b_Out_1_Float);
        float2 _Vector2_797c6780d72a948d8ea6a8ed6039b270_Out_0_Vector2 = float2(_OneMinus_b78b910b77e1058abf76a4e3bdccbc6b_Out_1_Float, _Split_6deeea821e8e658c971fd7ef74c7a1ce_G_2_Float);
        float2 _OneMinus_c6c995f8c397b189b0a44013b3f21a61_Out_1_Vector2;
        Unity_OneMinus_float2(_Vector2_797c6780d72a948d8ea6a8ed6039b270_Out_0_Vector2, _OneMinus_c6c995f8c397b189b0a44013b3f21a61_Out_1_Vector2);
        float2 _Multiply_b6db4dd7807a3783a20a83c1775e54d6_Out_2_Vector2;
        Unity_Multiply_float2_float2((_Subtract_5f6f48961196df8ca5637d782aee6d92_Out_2_Float.xx), _OneMinus_c6c995f8c397b189b0a44013b3f21a61_Out_1_Vector2, _Multiply_b6db4dd7807a3783a20a83c1775e54d6_Out_2_Vector2);
        float2 _Add_48d7ce5944312881a2c447a89e57f45e_Out_2_Vector2;
        Unity_Add_float2(_Multiply_327e9d1e928d6f8d8e0b72c5578b7b8e_Out_2_Vector2, _Multiply_b6db4dd7807a3783a20a83c1775e54d6_Out_2_Vector2, _Add_48d7ce5944312881a2c447a89e57f45e_Out_2_Vector2);
        float _Preview_698a52524ea2468f9971c155bf806245_Out_1_Float;
        Unity_Preview_float(_Fraction_fc11758286aff389b2d776a273ac790e_Out_1_Float, _Preview_698a52524ea2468f9971c155bf806245_Out_1_Float);
        float _Step_0144a40654394f8ab063b995c5e3bddc_Out_2_Float;
        Unity_Step_float(float(0.25), _Preview_698a52524ea2468f9971c155bf806245_Out_1_Float, _Step_0144a40654394f8ab063b995c5e3bddc_Out_2_Float);
        float _Subtract_303710196e42c0838eae8cb9bd33920a_Out_2_Float;
        Unity_Subtract_float(_Step_0144a40654394f8ab063b995c5e3bddc_Out_2_Float, _Step_72916456c205ce84a47948fbfbe398af_Out_2_Float, _Subtract_303710196e42c0838eae8cb9bd33920a_Out_2_Float);
        float2 _Multiply_a3eecb2d6922ac8197fe0cbb5bd0dc4e_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_797c6780d72a948d8ea6a8ed6039b270_Out_0_Vector2, (_Subtract_303710196e42c0838eae8cb9bd33920a_Out_2_Float.xx), _Multiply_a3eecb2d6922ac8197fe0cbb5bd0dc4e_Out_2_Vector2);
        float2 _Add_a30b12363777cb85833a28bbfd8dbf2d_Out_2_Vector2;
        Unity_Add_float2(_Add_48d7ce5944312881a2c447a89e57f45e_Out_2_Vector2, _Multiply_a3eecb2d6922ac8197fe0cbb5bd0dc4e_Out_2_Vector2, _Add_a30b12363777cb85833a28bbfd8dbf2d_Out_2_Vector2);
        float _OneMinus_b0c2f1e5ae0b7787b2b80aeff7f71bc6_Out_1_Float;
        Unity_OneMinus_float(_Step_0144a40654394f8ab063b995c5e3bddc_Out_2_Float, _OneMinus_b0c2f1e5ae0b7787b2b80aeff7f71bc6_Out_1_Float);
        float2 _Preview_03bfccdb70a0ae83b504cfa3eaaddd94_Out_1_Vector2;
        Unity_Preview_float2(_Fraction_42d717cd15a0ed81b517d54ee5d8673f_Out_1_Vector2, _Preview_03bfccdb70a0ae83b504cfa3eaaddd94_Out_1_Vector2);
        float2 _Multiply_b0a9a7f24c2ff480aef59ea8a63370c9_Out_2_Vector2;
        Unity_Multiply_float2_float2((_OneMinus_b0c2f1e5ae0b7787b2b80aeff7f71bc6_Out_1_Float.xx), _Preview_03bfccdb70a0ae83b504cfa3eaaddd94_Out_1_Vector2, _Multiply_b0a9a7f24c2ff480aef59ea8a63370c9_Out_2_Vector2);
        float2 _Add_74a08cea08e5e882ab76a96ca2eb6f15_Out_2_Vector2;
        Unity_Add_float2(_Add_a30b12363777cb85833a28bbfd8dbf2d_Out_2_Vector2, _Multiply_b0a9a7f24c2ff480aef59ea8a63370c9_Out_2_Vector2, _Add_74a08cea08e5e882ab76a96ca2eb6f15_Out_2_Vector2);
        Bindings_BacteriaSmoothstep_e3991c0bfe9e06945833b46fb6e56055_float _BacteriaSmoothstep_6aacbf9eb5711a87a071d7d7918ac3e0;
        float _BacteriaSmoothstep_6aacbf9eb5711a87a071d7d7918ac3e0_Out_1_Float;
        SG_BacteriaSmoothstep_e3991c0bfe9e06945833b46fb6e56055_float(_Add_74a08cea08e5e882ab76a96ca2eb6f15_Out_2_Vector2, float2 (0.45, 0.4), float2 (0.35, 0.3), _BacteriaSmoothstep_6aacbf9eb5711a87a071d7d7918ac3e0, _BacteriaSmoothstep_6aacbf9eb5711a87a071d7d7918ac3e0_Out_1_Float);
        Bindings_BacteriaSmoothstep_e3991c0bfe9e06945833b46fb6e56055_float _BacteriaSmoothstep_e26383c60af35e81bda682cc32a717a3;
        float _BacteriaSmoothstep_e26383c60af35e81bda682cc32a717a3_Out_1_Float;
        SG_BacteriaSmoothstep_e3991c0bfe9e06945833b46fb6e56055_float(_Add_74a08cea08e5e882ab76a96ca2eb6f15_Out_2_Vector2, float2 (0.7, 0.65), float2 (0.6, 0.55), _BacteriaSmoothstep_e26383c60af35e81bda682cc32a717a3, _BacteriaSmoothstep_e26383c60af35e81bda682cc32a717a3_Out_1_Float);
        float _Add_8d2195833ae0a68c99a9ae6be7da96e6_Out_2_Float;
        Unity_Add_float(_BacteriaSmoothstep_6aacbf9eb5711a87a071d7d7918ac3e0_Out_1_Float, _BacteriaSmoothstep_e26383c60af35e81bda682cc32a717a3_Out_1_Float, _Add_8d2195833ae0a68c99a9ae6be7da96e6_Out_2_Float);
        float2 _Subtract_631dfe2d8e990c8c906f8a19dbf14578_Out_2_Vector2;
        Unity_Subtract_float2(_Add_74a08cea08e5e882ab76a96ca2eb6f15_Out_2_Vector2, float2(0.5, 1), _Subtract_631dfe2d8e990c8c906f8a19dbf14578_Out_2_Vector2);
        Bindings_BacteriaSmoothstep_e3991c0bfe9e06945833b46fb6e56055_float _BacteriaSmoothstep_5212953ae9fbf78e9ffcfdb49d928a7c;
        float _BacteriaSmoothstep_5212953ae9fbf78e9ffcfdb49d928a7c_Out_1_Float;
        SG_BacteriaSmoothstep_e3991c0bfe9e06945833b46fb6e56055_float(_Subtract_631dfe2d8e990c8c906f8a19dbf14578_Out_2_Vector2, float2 (0.2, 0.15), float2 (0.1, 0.05), _BacteriaSmoothstep_5212953ae9fbf78e9ffcfdb49d928a7c, _BacteriaSmoothstep_5212953ae9fbf78e9ffcfdb49d928a7c_Out_1_Float);
        float2 _Subtract_220e583010d0428386952109d94fef82_Out_2_Vector2;
        Unity_Subtract_float2(_Add_74a08cea08e5e882ab76a96ca2eb6f15_Out_2_Vector2, float2(1, 0.5), _Subtract_220e583010d0428386952109d94fef82_Out_2_Vector2);
        Bindings_BacteriaSmoothstep_e3991c0bfe9e06945833b46fb6e56055_float _BacteriaSmoothstep_2b6e35f658447e898c7069e9e48335ec;
        float _BacteriaSmoothstep_2b6e35f658447e898c7069e9e48335ec_Out_1_Float;
        SG_BacteriaSmoothstep_e3991c0bfe9e06945833b46fb6e56055_float(_Subtract_220e583010d0428386952109d94fef82_Out_2_Vector2, float2 (0.2, 0.15), float2 (0.1, 0.05), _BacteriaSmoothstep_2b6e35f658447e898c7069e9e48335ec, _BacteriaSmoothstep_2b6e35f658447e898c7069e9e48335ec_Out_1_Float);
        float _Add_6c03c4030a9fd986a31d0d4d40fb500a_Out_2_Float;
        Unity_Add_float(_BacteriaSmoothstep_5212953ae9fbf78e9ffcfdb49d928a7c_Out_1_Float, _BacteriaSmoothstep_2b6e35f658447e898c7069e9e48335ec_Out_1_Float, _Add_6c03c4030a9fd986a31d0d4d40fb500a_Out_2_Float);
        float _Add_7c1ea28790a42b828955cdc678e6a807_Out_2_Float;
        Unity_Add_float(_Add_8d2195833ae0a68c99a9ae6be7da96e6_Out_2_Float, _Add_6c03c4030a9fd986a31d0d4d40fb500a_Out_2_Float, _Add_7c1ea28790a42b828955cdc678e6a807_Out_2_Float);
        Out_1 = _Add_7c1ea28790a42b828955cdc678e6a807_Out_2_Float;
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
            float2 _Property_b616276530f443cb92ced6d69dcef568_Out_0_Vector2 = _Tiling;
            float _Property_86d6e98a522544f0ba2668cbbf9e1341_Out_0_Float = _Seed;
            Bindings_Bacteria_804c76ccbe9643147a24f07885bb47ba_float _Bacteria_7d23078ab8484aa79afb57b5d23b9294;
            _Bacteria_7d23078ab8484aa79afb57b5d23b9294.uv0 = IN.uv0;
            float _Bacteria_7d23078ab8484aa79afb57b5d23b9294_Out_1_Float;
            SG_Bacteria_804c76ccbe9643147a24f07885bb47ba_float(_Property_b616276530f443cb92ced6d69dcef568_Out_0_Vector2, _Property_86d6e98a522544f0ba2668cbbf9e1341_Out_0_Float, _Bacteria_7d23078ab8484aa79afb57b5d23b9294, _Bacteria_7d23078ab8484aa79afb57b5d23b9294_Out_1_Float);
            float2 _Property_939fe11aff3746a1ad1500bec16398b9_Out_0_Vector2 = _Outer_Edge;
            float2 _Property_9dbff8ed3bd6438096526e13e2e65c1b_Out_0_Vector2 = _Inner_Edge;
            Bindings_BacteriaSmoothstep_e3991c0bfe9e06945833b46fb6e56055_float _BacteriaSmoothstep_0374f88add8c48c08eb19d03632bef1d;
            float _BacteriaSmoothstep_0374f88add8c48c08eb19d03632bef1d_Out_1_Float;
            SG_BacteriaSmoothstep_e3991c0bfe9e06945833b46fb6e56055_float((_Bacteria_7d23078ab8484aa79afb57b5d23b9294_Out_1_Float.xx), _Property_939fe11aff3746a1ad1500bec16398b9_Out_0_Vector2, _Property_9dbff8ed3bd6438096526e13e2e65c1b_Out_0_Vector2, _BacteriaSmoothstep_0374f88add8c48c08eb19d03632bef1d, _BacteriaSmoothstep_0374f88add8c48c08eb19d03632bef1d_Out_1_Float);
            #if defined(_SMOOTHSTEP)
            float _Smoothstep_3f288f8e923943cdb570850c1d4dbe6f_Out_0_Float = _BacteriaSmoothstep_0374f88add8c48c08eb19d03632bef1d_Out_1_Float;
            #else
            float _Smoothstep_3f288f8e923943cdb570850c1d4dbe6f_Out_0_Float = _Bacteria_7d23078ab8484aa79afb57b5d23b9294_Out_1_Float;
            #endif
            Bindings_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float _AlphaSplit_d1b94a2627b2447fb7b80d03d38bde6b;
            float3 _AlphaSplit_d1b94a2627b2447fb7b80d03d38bde6b_RGB_1_Vector3;
            float _AlphaSplit_d1b94a2627b2447fb7b80d03d38bde6b_Alpha_2_Float;
            SG_AlphaSplit_1586fe714d6c2424284e2ccf5296d73c_float((_Smoothstep_3f288f8e923943cdb570850c1d4dbe6f_Out_0_Float.xxxx), _AlphaSplit_d1b94a2627b2447fb7b80d03d38bde6b, _AlphaSplit_d1b94a2627b2447fb7b80d03d38bde6b_RGB_1_Vector3, _AlphaSplit_d1b94a2627b2447fb7b80d03d38bde6b_Alpha_2_Float);
            surface.BaseColor = _AlphaSplit_d1b94a2627b2447fb7b80d03d38bde6b_RGB_1_Vector3;
            surface.Alpha = _AlphaSplit_d1b94a2627b2447fb7b80d03d38bde6b_Alpha_2_Float;
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