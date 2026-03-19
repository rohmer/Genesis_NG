using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text;

using UnityEditor;
using UnityEditor.Experimental.GraphView;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{
    [Documentation(@"
Applies a sharpen filter to a heightfield
")]

    [Serializable, NodeMenuItem("Terrain/Modifiers/Sharpen")]
    public class SharpenNode : GenesisNode
    {
        [SerializeField, Input(name = "Input", allowMultiple = false)]
        public HeightField TerrainInput;

        [SerializeField, Output(name = "Output", allowMultiple = true)]
        public HeightField TerrainOutput;

        internal Shader sharpenShader;
        internal Material sharpenMat;

        internal float sharpenAmount = 1.0f;
        internal float sharpenRadius = 1.5f;



        int kernel;
        int threadGroupX, threadGroupY;

        public override string name => "Sharpen";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override bool hasSettings => false;

        public override float nodeWidth => 300;
        Texture2D preview;
        public override Texture previewTexture => preview;
        RenderTexture blurA;
        
        protected override void Enable()
        {            
            base.Enable();
            preview = new Texture2D(300, 300);
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);
            Sharpen();
            return r;
        }

        internal void Sharpen()
        {
            if(sharpenShader==null)
            {
                sharpenShader = Resources.Load<Shader>("Shaders/HeightfieldSharpen");
                sharpenMat = new Material(sharpenShader);

            }

            if (TerrainInput == null)
                return;
            TerrainOutput = new HeightField(TerrainInput.mapSize);
          

            if (blurA == null || blurA.width != TerrainInput.mapSize || blurA.height != TerrainInput.mapSize)
            {
                if (blurA != null) blurA.Release();
                

                blurA = new RenderTexture(TerrainInput.mapSize, TerrainInput.mapSize, 0, TerrainInput.HeightMap.format);
                
            }


            int size = TerrainInput.mapSize;

            TerrainOutput = new HeightField(size);
            TerrainOutput.HeightMap = new RenderTexture(size, size, 0, RenderTextureFormat.ARGBFloat)
            {
                enableRandomWrite = true,
                wrapMode = TextureWrapMode.Clamp,
                autoGenerateMips = false
            };

            sharpenMat.SetFloat("_Radius", sharpenRadius);
            sharpenMat.SetFloat("_Amount", sharpenAmount);

            // Horiz
            sharpenMat.SetVector("_Direction", new Vector2(1, 0));
            Graphics.Blit(TerrainInput.HeightMap, blurA, sharpenMat);
            // Vert
            sharpenMat.SetVector("_Direction", new Vector2(0, 1));
            Graphics.Blit(blurA, TerrainOutput.HeightMap, sharpenMat);
            
            Texture2D tmp = new Texture2D(TerrainOutput.HeightMap.width, TerrainOutput.HeightMap.height);

            RenderTexture.active = TerrainOutput.HeightMap;
            tmp.ReadPixels(new Rect(0, 0, TerrainOutput.HeightMap.width, TerrainOutput.HeightMap.height), 0, 0);
            tmp.Apply();
            RenderTexture.active = null;
            
            preview = new Texture2D(300, 300);
            float modD = TerrainInput.mapSize / 300;
            for (int x = 0; x < 300; x++)
            {
                for (int y = 0; y < 300; y++)
                {
                    float c = tmp.GetPixel((int)(x * modD), (int)(y * modD)).r;
                    preview.SetPixel(x, y, new Color(c, c, c, 1));
                }
            }
            preview.Apply();
        }        
    }
}
