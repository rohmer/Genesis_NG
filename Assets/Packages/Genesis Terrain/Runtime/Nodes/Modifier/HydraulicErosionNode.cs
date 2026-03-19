using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System;
using System.Collections.Generic;
using System.Security.Policy;
using System.Text;

using UnityEditor;
using UnityEditor.Experimental.GraphView;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{
    [Documentation(@"
Applies hydraulic erosion to a heightfield
")]

    [Serializable, NodeMenuItem("Terrain/Modifiers/Hydraulic Erosion")]
    public class HydraulicErosionNode : GenesisNode
    {
        [SerializeField, Input(name = "Input", allowMultiple = false)]
        public HeightField TerrainInput;

        [SerializeField, Output(name = "Output", allowMultiple = true)]
        public HeightField TerrainOutput;

        // Simulation parameters (tweak)
        internal float gravity = 9.8f;
        internal float damping = 0.4f;
        internal float erodeRate = 0.3f;       
        internal float deposit = 0.3f;
        internal float capacity = 1.0f;
        internal float evaportation = 0.02f;
        internal int iterations = 25;

        internal Material fluxMat;
        internal Material velocityMat;
        internal Material erodeMat;
        internal Material depositMat;
        internal Material waterMat;

        RenderTexture H, W, S, V;
        RenderTexture tmpH, tmpW, tmpS, tmpV;
        RenderTexture fluxRT;


        Color[] clearArray = new Color[300 * 300];
        
        Texture2D preview;
        
        public override string name => "Hydraulic Erosion";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override bool hasSettings => false;

        public override float nodeWidth => 300;        
        public override Texture previewTexture => preview;
        protected override void Enable()
        {
            base.Enable();
            preview = new Texture2D(300, 300);
            for (int i = 0; i < clearArray.Length; i++)
                clearArray[i] = Color.black;            
        }
        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);
            Erode();
            return r;
        }
        internal void Erode()
        {
            if (TerrainInput == null)
                return;
            TerrainOutput = new HeightField(TerrainInput);

            if(fluxMat==null)
            {
                fluxMat = new Material(Resources.Load<Shader>("Shaders/Erosion_Flux"));
                velocityMat=new Material(Resources.Load<Shader>("Shaders/Erosion_Velocity"));
                erodeMat=new Material(Resources.Load<Shader>("Shaders/Erosion_Erode"));
                depositMat=new Material(Resources.Load<Shader>("Shaders/Erosion_Deposit"));
                waterMat=new Material(Resources.Load<Shader>("Shaders/Erosion_WaterUpdate"));
            }
           

            int w= TerrainInput.mapSize;
            int h= TerrainInput.mapSize;


            // Initialize
            H = CreateRT(w, h);
            W = CreateRT(w, h);
            S = CreateRT(w, h);
            V = CreateRT(w, h, RenderTextureFormat.RGFloat);
            tmpH = CreateRT(w, h);
            tmpW = CreateRT(w, h);
            tmpS = CreateRT(w, h);
            tmpV = CreateRT(w, h, RenderTextureFormat.RGFloat);

            fluxRT = CreateRT(w, h, RenderTextureFormat.ARGBFloat);
            TerrainOutput.HeightMap = CreateRT(w, h, TerrainInput.HeightMap.format);
            Graphics.Blit(TerrainInput.HeightMap, H);
            Graphics.Blit(Texture2D.blackTexture, W);
            Graphics.Blit(Texture2D.blackTexture, S);
            Graphics.Blit(Texture2D.blackTexture, V);

            // Erode
            for(int i=0; i<iterations; i++)
            {
                // PASS 1: Flux
                fluxMat.SetTexture("_Height", H);
                fluxMat.SetTexture("_Water", W);
                Graphics.Blit(null, fluxRT, fluxMat);

                // PASS 2: Velocity
                velocityMat.SetTexture("_Height", H);
                velocityMat.SetTexture("_Water", W);
                velocityMat.SetTexture("_Velocity", V);
                velocityMat.SetFloat("_Gravity", gravity);
                velocityMat.SetFloat("_Damping", damping);

                Graphics.Blit(null, tmpV, velocityMat);
                Swap(ref V, ref tmpV);

                // PASS 3: Erosion
                erodeMat.SetTexture("_Height", H);
                erodeMat.SetTexture("_Water", W);
                erodeMat.SetTexture("_Sed", S);
                erodeMat.SetTexture("_Velocity", V);
                erodeMat.SetFloat("_ErodeRate", erodeRate);
                erodeMat.SetFloat("_Capacity", capacity);

                Graphics.Blit(null, tmpH, erodeMat);
                Swap(ref H, ref tmpH);

                // PASS 4: Deposition
                depositMat.SetTexture("_Height", H);
                depositMat.SetTexture("_Sed", S);
                depositMat.SetTexture("_Velocity", V);
                depositMat.SetFloat("_Deposit", deposit);
                depositMat.SetFloat("_SedimentCapacity", capacity);
                Graphics.Blit(null, tmpH, depositMat);
                Swap(ref H, ref tmpH);

                // PASS 5: Water Update
                waterMat.SetTexture("_Water", W);
                waterMat.SetTexture("_Flux", fluxRT);
                waterMat.SetFloat("_Evaporation", evaportation);

                Graphics.Blit(null, tmpW, waterMat);
                Swap(ref W, ref tmpW);

            }

            Graphics.Blit(H, TerrainOutput.HeightMap);


            Texture2D tmp = new Texture2D(w, h);
            RenderTexture.active = TerrainOutput.HeightMap;
            tmp.ReadPixels(new Rect(0, 0, w, h), 0, 0);
            tmp.Apply();
            RenderTexture.active = null;

        
            preview = new Texture2D(300, 300);
            float modD = w / 300;
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

        void Swap(ref RenderTexture a, ref RenderTexture b)
        {
            var t = a;
            a = b;
            b = t;
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
