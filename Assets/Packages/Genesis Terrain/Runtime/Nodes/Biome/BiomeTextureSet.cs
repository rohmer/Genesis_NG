using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using NUnit.Framework;

using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain
{
    [System.Serializable]
    [NodeMenuItem("Terrain/Biome/Biome Texture Set")]
    public class BiomeTextureSet : GenesisNode
    {
        [Input("Diffuse")]
        public Texture2D diffuseTexture = null;
        [Input("Normal")]
        public Texture2D normalTexture = null;
        [Input("Height")]
        public Texture2D heightTexture = null;
        [Input("Smoothness")]
        public Texture2D smoothnessTexture = null;
        [Input("AO")]
        public Texture2D aoTexture = null;
        [Input("Noise Normal")]
        public GenesisNode noiseNormal;
        [Input("Detail Mask")]
        public GenesisNode detailMask;
        [Input("Distance Mask")]
        public GenesisNode distanceMask;

        [Output("Biome Texture")]
        public BiomeTextureSetData biomeSet=new BiomeTextureSetData();

        public override bool hasPreview => false;
        public override string NodeGroup => "Biomes";
        public override string name => "Biome Texture Set";

        public override float nodeWidth => 300;

        public bool invertSmoothness = false;

        ComputeShader inverter;

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);
            processSmoothness();
            return r; 
        }

        internal void processSmoothness()
        {
            if(!invertSmoothness && smoothnessTexture!=null)
            {
                biomeSet.Smoothness = new Texture2D(smoothnessTexture.width, smoothnessTexture.height, smoothnessTexture.format, false);
                biomeSet.Smoothness = smoothnessTexture;
                biomeSet.Smoothness.Apply();
                return;
            }
            if(invertSmoothness && smoothnessTexture!=null)
            {
                if (inverter == null)
                    inverter = Resources.Load<ComputeShader>("Shaders/InvertTexture");
                int kernel = inverter.FindKernel("Invert");
                inverter.SetInt("_Width", smoothnessTexture.width);
                inverter.SetInt("_Height", smoothnessTexture.height);
                biomeSet.Smoothness = new Texture2D(smoothnessTexture.width, smoothnessTexture.height, TextureFormat.RGBA32, false);
                inverter.SetTexture(kernel, "_Input", smoothnessTexture);
                RenderTexture output = new RenderTexture(smoothnessTexture.width, smoothnessTexture.height,32);
                output.enableRandomWrite = true;
                output.Create();
                inverter.SetTexture(kernel, "_Output", output);
                int tx = Mathf.CeilToInt(smoothnessTexture.width / 8.0f);
                int ty = Mathf.CeilToInt(smoothnessTexture.height / 8.0f);

                inverter.Dispatch(kernel, tx, ty, 1);
                Graphics.CopyTexture(output, biomeSet.Smoothness);
            }
        }
    }
}
