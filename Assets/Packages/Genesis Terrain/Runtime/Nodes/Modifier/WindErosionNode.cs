using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System;
using System.Collections.Generic;
using System.Text;

using Unity.Mathematics;

using UnityEditor;
using UnityEditor.Experimental.GraphView;

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Windows;

using static Unity.Burst.Intrinsics.X86.Avx;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{
    [Documentation(@"
Applies wind erosion to a heightfield
")]

    [Serializable, NodeMenuItem("Terrain/Modifiers/Wind Erosion")]
    public class WindErosionNode : GenesisNode
    {
        [SerializeField, Input(name = "Input", allowMultiple = false)]
        public HeightField TerrainInput;

        [SerializeField, Output(name = "Output", allowMultiple = true)]
        public HeightField TerrainOutput;
        internal int size;
        internal Vector2 direction = new Vector2(1, 0);
        internal float erodeRate = 0.02f;
        internal float cellSize = 1f;

        internal uint saltationSteps = 8;

        internal float talusAngle = 32f;
        internal int avalanceIterations = 3;
        internal int iterations = 5;

        internal ComputeShader compute;

        // -----------------------------
        // Internal RTs
        // -----------------------------
        RenderTexture windField;
        RenderTexture pickup;
        RenderTexture transport;
        RenderTexture temp;

        Material addMat; // Hidden/AddHeight

        public override string name => "Wind Erosion";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override bool hasSettings => false;

        public override float nodeWidth => 300;
        Texture2D preview;
        public override Texture previewTexture => preview;
        int kJFA, kPickup, kTransport, kAvalanche;

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
            if (compute == null)
            {
                compute = Resources.Load<ComputeShader>("Shaders/WindErosion");
                kJFA = compute.FindKernel("JFA_Wind");
                kPickup = compute.FindKernel("SaltationPickup");
                kTransport = compute.FindKernel("SaltationTransport");
                kAvalanche = compute.FindKernel("Avalanche");                
            }

            if(addMat==null)
                addMat = new Material(Shader.Find("Hidden/AddHeight"));

            if (TerrainInput == null)
                return;

            int res = TerrainInput.mapSize;

            TerrainOutput = new HeightField(res);
            // Allocate outputs
            EnsureRT(ref TerrainOutput.HeightMap, res, RenderTextureFormat.RFloat);
            EnsureRT(ref windField, res, RenderTextureFormat.RGFloat);
            EnsureRT(ref pickup, res, RenderTextureFormat.RFloat);
            EnsureRT(ref transport, res, RenderTextureFormat.RFloat);
            EnsureRT(ref temp, res, RenderTextureFormat.RFloat);

            // ------------------------------------------------------------
            // PASS 0 — Jump Flood Wind Field
            // ------------------------------------------------------------
            compute.SetTexture(kJFA, "Height", TerrainInput.HeightMap);
            compute.SetTexture(kJFA, "WindField", windField);
            compute.SetFloats("WindDir", direction.normalized.x, direction.normalized.y);
            compute.SetInt("Resolution", res);
            compute.Dispatch(kJFA, Groups(res), Groups(res), 1);

            // ------------------------------------------------------------
            // PASS 1 — Saltation Pickup
            // ------------------------------------------------------------
            compute.SetTexture(kPickup, "Height", TerrainInput.HeightMap);
            compute.SetTexture(kPickup, "WindField", windField);
            compute.SetTexture(kPickup, "Pickup", pickup);
            compute.SetFloat("ErodeRate", erodeRate);
            compute.SetFloat("CellSize", cellSize);
            compute.SetInt("Resolution", res);
            compute.Dispatch(kPickup, Groups(res), Groups(res), 1);

            // ------------------------------------------------------------
            // PASS 2 — Saltation Transport
            // ------------------------------------------------------------
            compute.SetTexture(kTransport, "Pickup", pickup);
            compute.SetTexture(kTransport, "WindField", windField);
            compute.SetTexture(kTransport, "Transport", transport);
            compute.SetInt("Resolution", res);
            compute.SetInt("Steps", (int)saltationSteps);
            compute.Dispatch(kTransport, Groups(res), Groups(res), 1);

            // ------------------------------------------------------------
            // PASS 2.5 — Apply Erosion (Height = Height - Pickup + Transport)
            // ------------------------------------------------------------
            addMat.SetTexture("_Pickup", pickup);
            addMat.SetTexture("_Transport", transport);
            Graphics.Blit(TerrainInput.HeightMap, TerrainOutput.HeightMap, addMat);

            // ------------------------------------------------------------
            // PASS 3 — Angle-of-Repose Avalanching
            // ------------------------------------------------------------
            for (int i = 0; i < avalanceIterations; i++)
            {
                compute.SetTexture(kAvalanche, "HeightIn", TerrainOutput.HeightMap);
                compute.SetTexture(kAvalanche, "HeightOut", temp);
                compute.SetFloat("TalusAngle", talusAngle);
                compute.SetFloat("CellSize", cellSize);
                compute.SetInt("Resolution", res);

                compute.Dispatch(kAvalanche, Groups(res), Groups(res), 1);

                // ping-pong
                (TerrainOutput.HeightMap, temp) = (temp, TerrainOutput.HeightMap);
            }




            preview = ToPreviewTexture(TerrainInput.HeightMap, 300);
        }

        // -----------------------------
        // Utility
        // -----------------------------
        void EnsureRT(ref RenderTexture rt, int res, RenderTextureFormat fmt)
        {
            if (rt != null && rt.width == res) return;

            if (rt != null) rt.Release();

            rt = new RenderTexture(res, res, 0, fmt)
            {
                enableRandomWrite = true,
                filterMode = FilterMode.Point
            };
            rt.Create();
        }

        int Groups(int res) => Mathf.CeilToInt(res / 8f);

        public static Texture2D ToTexture2D(RenderTexture rt)
        {
            int w = rt.width;
            int h = rt.height;

            Texture2D tex = new Texture2D(w, h, TextureFormat.RFloat, false, true);

            RenderTexture prev = RenderTexture.active;
            RenderTexture.active = rt;

            tex.ReadPixels(new Rect(0, 0, w, h), 0, 0);
            tex.Apply(false, false);

            RenderTexture.active = prev;
            return tex;
        }

        public static Texture2D ToPreviewTexture(RenderTexture rt, int previewSize = 256)
        {
            int w = rt.width;
            int h = rt.height;

            float scale = Mathf.Min((float)previewSize / w, (float)previewSize / h);
            int pw = Mathf.RoundToInt(w * scale);
            int ph = Mathf.RoundToInt(h * scale);

            RenderTexture tmp = RenderTexture.GetTemporary(pw, ph, 0, rt.format);
            Graphics.Blit(rt, tmp);

            Texture2D tex = new Texture2D(pw, ph, TextureFormat.RFloat, false, true);

            RenderTexture prev = RenderTexture.active;
            RenderTexture.active = tmp;

            tex.ReadPixels(new Rect(0, 0, pw, ph), 0, 0);
            tex.Apply(false, false);

            RenderTexture.active = prev;
            RenderTexture.ReleaseTemporary(tmp);

            return tex;
        }
    }
}
