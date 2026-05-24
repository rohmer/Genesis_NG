# Skeleton HLSL Shader

```hlsl
Shader "Hidden/Genesis/GrayscaleToHeight"
{
    Properties
    {
        [InlineTexture]_MainTex("Input Texture", 2D) = "white" {}
        _LumaWeights("Luminance Weights (R,G,B)", Vector) = (0.2126,0.7152,0.0722,0)
        _Blur("Blur Radius (0=off,1=3x3)", Range(0,1)) = 0.0
        _Contrast("Contrast", Range(0.1,4.0)) = 1.0
        _Exposure("Exposure", Range(-2,2)) = 0.0
        _Invert("Invert", Range(0,1)) = 0
        _MicroDetail("Micro Detail Strength", Range(0,1)) = 0.0
        _MicroFreq("Micro Frequency", Range(1,32)) = 8.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_MainTex);

            float4 _LumaWeights;
            float _Blur, _Contrast, _Exposure, _Invert;
            float _MicroDetail, _MicroFreq;

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv3 = i.localTexcoord.xyz;
                float2 uv = i.localTexcoord.xy;

                float4 returnColor= float4(0,0,0,1);
                return float4(returnColor);
            }
            ENDHLSL
        }
    }
}
```

## Description of the Skeleton
```hlsl
Shader "Hidden/Genesis/GrayscaleToHeight"
```
This line defines the name of the shader. The "Hidden/" prefix means that this shader will not appear in the shader dropdowns in the Unity editor, which is common for shaders that are only used internally by scripts.

```hlsl
    Properties
    {
        [InlineTexture]_MainTex("Input Texture", 2D) = "white" {}
        _LumaWeights("Luminance Weights (R,G,B)", Vector) = (0.2126,0.7152,0.0722,0)
        _Blur("Blur Radius (0=off,1=3x3)", Range(0,1)) = 0.0
        _Contrast("Contrast", Range(0.1,4.0)) = 1.0
        _Exposure("Exposure", Range(-2,2)) = 0.0
        _Invert("Invert", Range(0,1)) = 0
        _MicroDetail("Micro Detail Strength", Range(0,1)) = 0.0
        _MicroFreq("Micro Frequency", Range(1,32)) = 8.0
    }
```
Properties define the parameters that can be set on the shader from C#. Each property has a name, a type, and a default value. The attributes (like [InlineTexture] and Range) provide additional information about how the property should be displayed in the editor.
See [Shader Properties](ShaderProperties.md) for more details on shader properties in Genesis Noise
These are just example properties from the Levels node, you can define any properties you need for your shader.

Remember, you must define a variable in HLSL for each property you want to use in your shader code. The variable name must match the property name (with an underscore prefix). For example, the _MainTex property corresponds to a variable named _MainTex in the HLSL code.
```hlsl
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Pass
        {
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            TEXTURE_SAMPLER_X(_MainTex);
            float4 _LumaWeights;
            float _Blur, _Contrast, _Exposure, _Invert;
            float _MicroDetail, _MicroFreq;
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv3 = i.localTexcoord.xyz;
                float2 uv = i.localTexcoord.xy;
                float4 returnColor= float4(0,0,0,1);
                return float4(returnColor);
            }
            ENDHLSL
        }
    }
```
The SubShader block contains the actual shader code. The Tags and LOD lines provide information about how the shader should be rendered. The Pass block contains the HLSL code for the vertex and fragment shaders. The #include line includes a common HLSL file that contains useful functions and definitions for Genesis Noise shaders. The #pragma lines specify which vertex and fragment shaders to use, as well as any shader features that should be enabled.

The work done by the shader is defined or called from the genesis function, which is the fragment shader. The input to this function is a structure that contains the local texture coordinates (i.localTexcoord), and the output is a color value (returnColor) that will be written to the render target. In this skeleton, the shader simply returns black, but in a real shader, you would replace this with your actual shader code to generate the desired effect.

**TEXTURE_SAMPLER_X(_MainTex);** is a macro defined in the included GenesisFixed.hlsl file that sets up the necessary sampler state for sampling the _MainTex texture. This allows you to use the _MainTex variable in your shader code to sample the input texture.
