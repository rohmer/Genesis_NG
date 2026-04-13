using GraphProcessor;

using System;

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Windows;

using static UnityEditor.Rendering.CameraUI;

namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable]
    public class TextureMathNode : GenesisNode
    {
        [Input(name = "A")]
        public RenderTexture inputA;

        [Input(name = "B")]
        public object inputB;

        [Output(name = "Output")]
        public RenderTexture output;

        protected ComputeShader shader = null;
                      
    }
}