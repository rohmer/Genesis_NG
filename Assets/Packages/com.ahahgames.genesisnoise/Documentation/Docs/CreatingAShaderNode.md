# Creating a Shader Node

A shader node in Genesis Noise is a node who's back end is a HLSL shader.

## Parts of a Shader Node
The node consists of three main parts:
1. The HLSL shader file, which contains the actual shader code.
2. The C# class that defines the node's properties and how it interacts with the shader.
3. (Optional) A custom editor class that defines how the node is displayed in the editor.

## Creating the HLSL Shader
To create the HLSL shader, you need to create a new .hlsl file in your project. This file will contain the shader code that defines how the node processes its inputs and produces its output.
See [Creating an HLSL Shader](HLSLShader.md) for more details on how to write the HLSL shader for your node.

## Creating the C# Class
To create the C# class for your shader node, you need to create a new class that inherits from `ShaderNode`. This class will define the properties of your node and how it interacts with the shader.
See [Creating a C# Node](CSharpNode.md) for more details on how to write the C# class for your node.

The nodes are called WhatItDoesNode , so for example if you were creating a node that converts a grayscale texture to a heightmap, you might name your class GrayscaleToHeightNode.

## (Optional) Creating a Custom Editor (A view)
Most of the time creating a view is unnecessary, as the default view provided by the base class is sufficient for most nodes. However, if you want to create a custom view for your node, you can create a new class that inherits from `ShaderNodeView`. This class will define

Genesis Noise will create properties for each of the shader properties you defined in your HLSL shader, so you can use those properties to create custom UI elements in your view. For example, if you have a property named _Blur in your shader, you can create a slider in your view that allows the user to adjust the value of _Blur.

See [Creating a Custom View](CustomEditor.md) for more details on how to write a custom editor for your node.