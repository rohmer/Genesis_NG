using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System;
using System.Collections.Generic;
using System.Text;

using UnityEditor;
using UnityEditor.Experimental.GraphView;

using UnityEngine;
using UnityEngine.Rendering;

using static Unity.Burst.Intrinsics.X86.Avx;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{
    [Documentation(@"
Applies thermal erosion to a heightfield
")]

    [Serializable, NodeMenuItem("Terrain/Modifiers/Thermal Erosion")]
    public class ThermalErosionNode : GenesisNode
    {
        [SerializeField, Input(name = "Input", allowMultiple = false)]
        public HeightField TerrainInput;

        [SerializeField, Output(name = "Output", allowMultiple = true)]
        public HeightField TerrainOutput;
        internal int size;
        internal float angle = 0.02f;
        internal float strength = 0.5f;
        internal int iterations = 1;

        Material erosionMat;
        private RenderTexture _rtA;
        private RenderTexture _rtB;
        private bool _isRTAPrimary = true;

        public override string name => "Thermal Erosion";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override bool hasSettings => false;      

        public override float nodeWidth => 300;
        Texture2D preview;
        public override Texture previewTexture => preview;
        protected override void Enable()
        {
            preview = new Texture2D(300, 300);
            base.Enable();
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);
            Erode();
            return r;
        }


        internal void Erode()
        {
            if(erosionMat==null)
            {
                erosionMat = new Material(Resources.Load<Shader>("Shaders/ThermalErosion"));                
            }
            if (TerrainInput == null)
                return;
            int w = TerrainInput.mapSize;
            int h = TerrainInput.mapSize;


            // Initialize RenderTextures
            _rtA = CreateRT(w,h);
            _rtB = CreateRT(w,h);

            Graphics.Blit(TerrainInput.HeightMap, _rtA);

            erosionMat.SetFloat("_Talus", angle);
            erosionMat.SetFloat("_Strength", strength);

            for(int i=0; i<iterations; i++)
            {
                if (_isRTAPrimary)
                {
                    Graphics.Blit(_rtA, _rtB, erosionMat);
                }
                else
                {
                    Graphics.Blit(_rtB, _rtA, erosionMat);
                }

                // Swap buffers
                _isRTAPrimary = !_isRTAPrimary;
            }

            TerrainOutput = new HeightField();
            TerrainOutput.HeightMap = CreateRT(w, h);
            Graphics.Blit(GetCurrentHeightmap(), TerrainOutput.HeightMap);

            Texture2D tmp = new Texture2D(TerrainOutput.HeightMap.width, TerrainOutput.HeightMap.height);

            RenderTexture.active = TerrainOutput.HeightMap;
            tmp.ReadPixels(new Rect(0, 0, TerrainOutput.HeightMap.width, TerrainOutput.HeightMap.height), 0, 0);
            tmp.Apply();
            RenderTexture.active = null;

            preview = new Texture2D(300, 300);
            float modD = size / 300;
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

        public Texture GetCurrentHeightmap()
        {
            return _isRTAPrimary ? _rtA : _rtB;
        }

        void Swap(ref RenderTexture a, ref RenderTexture b)
        {
            var t = a; a = b; b = t;
        }


        RenderTexture CreateRT(int w, int h, RenderTextureFormat fmt = RenderTextureFormat.RFloat)
        {
            var rt = new RenderTexture(w, h, 0, fmt);
            rt.enableRandomWrite = false;
            rt.Create();
            return rt;
        }

    }
}
