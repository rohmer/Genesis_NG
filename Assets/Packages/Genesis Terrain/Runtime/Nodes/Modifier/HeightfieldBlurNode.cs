using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{
    [Documentation(@"
Applies blur to a heightfield
")]

    [Serializable, NodeMenuItem("Terrain/Modifiers/Blur")]
    public class HeightfieldBlurNode : GenesisNode
    {
        [SerializeField, Input(name = "Input", allowMultiple = false)]
        public HeightField TerrainInput;

        [SerializeField, Output(name = "Output", allowMultiple = true)]
        public HeightField TerrainOutput;
        
        // Simulation parameters (tweak)
        public int radius = 3;
        public float sigma=2f;

        int kernel;

        internal Texture2D preview;
        Shader blurShader;
        
        public override string name => "Blur";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override bool hasSettings => false;
        public override float nodeWidth => 300;

        public override Texture previewTexture => preview;
        CustomRenderTexture _rt = null;

        private Material blurMat;
        RenderTexture tempRT;

        protected override void Enable()
        {
            base.Enable();
            preview = new Texture2D(300, 300);
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);
            Blur();
            return r;
        }

        


        internal void Blur()
        {
            preview = new Texture2D(300, 300);
            if (blurShader == null)
            {
                blurShader = Resources.Load<Shader>("Shaders/Blur");                
            }
            
            
            if (TerrainInput == null)
                return;

            TerrainOutput = new HeightField();
            TerrainOutput.HeightMap = new RenderTexture(TerrainInput.HeightMap.width, TerrainInput.HeightMap.height, 0,
                RenderTextureFormat.ARGB32);
            TerrainOutput.HeightMap.enableRandomWrite = true;
            TerrainInput.HeightMap.Create();
            if (_rt != null)
            {
                _rt.Release();
            }
            
            if (tempRT == null || tempRT.width != TerrainInput.HeightMap.width || tempRT.height != TerrainInput.HeightMap.height)
            {
                if (tempRT != null) tempRT.Release();
                tempRT = new RenderTexture(TerrainInput.HeightMap.width, TerrainInput.HeightMap.height, 0, TerrainInput.HeightMap.format);
            }
            if(blurMat==null)
                blurMat = new Material(blurShader);
            blurMat.SetFloat("_Radius", radius);
            // Horizontal pass
            blurMat.SetVector("_Direction", new Vector2(1, 0));
            Graphics.Blit(TerrainInput.HeightMap, tempRT, blurMat);

            // Vertical pass
            blurMat.SetVector("_Direction", new Vector2(0, 1));
            Graphics.Blit(tempRT, TerrainOutput.HeightMap, blurMat);

            Texture2D tmp = new Texture2D(TerrainOutput.HeightMap.width, TerrainOutput.HeightMap.height);
            
            RenderTexture.active= TerrainOutput.HeightMap;
            tmp.ReadPixels(new Rect(0,0, TerrainOutput.HeightMap.width, TerrainOutput.HeightMap.height), 0, 0);
            tmp.Apply();
            RenderTexture.active = null;


            preview = new Texture2D(300, 300);
            float modD = TerrainInput.HeightMap.width/ 300;
            for (int x = 0; x < 300; x++)
            {
                for (int y = 0; y < 300; y++)
                {
                    float c=tmp.GetPixel((int)(x * modD), (int)(y * modD)).r;
                    preview.SetPixel(x, y, new Color(c, c, c));
                }
            }
            preview.Apply();            
        }

        Texture2D ReadRenderTextureFloat(RenderTexture rt)
        {
            RenderTexture prev = RenderTexture.active;
            RenderTexture.active = rt;
            Texture2D tex = new Texture2D(rt.width, rt.height);
            tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            tex.Apply();
            RenderTexture.active = prev;
            return tex;
        }

        RenderTexture CreateFloatRT(int w, int h)
        {
            var rt = new RenderTexture(w, h, 0, TerrainInput.HeightMap.format);
            rt.enableRandomWrite = true;
            rt.filterMode=FilterMode.Bilinear;
            rt.Create();
            return rt;
        }

        RenderTexture CreateRenderTexture(int size)
        {
            var rt = new RenderTexture(size, size, 0, RenderTextureFormat.ARGBFloat);
            rt.enableRandomWrite = true;
            rt.Create();
            return rt;
        }
    }
}
