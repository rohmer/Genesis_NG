using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using SharpVoronoiLib;

using System;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{
    [Documentation(@"
Creates a moisture map from a heightfield. Initially the moisture is based on the distance to the nearest water body, it is then modified by a gaussian directional blur to simulate the effect of wind on moisture transport. The direction and strength of the blur can be modified to create different moisture patterns.
")]

    [Serializable, NodeMenuItem("Terrain/Moisture/Simple Generator")]
    public class MoistureGenerator : GenesisNode
    {
        [SerializeField, Input]
        TerrainNodes Input;

        [SerializeField, Output(name = "Moisture Map", allowMultiple = true)]
        public RenderTexture MoistureOut;

        public override string name => "Moisture";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override bool hasSettings => false;
        public override float nodeWidth => 300;
        internal Texture2D preview;
        public override Texture previewTexture => preview;

        ComputeShader moistureCompute;
        [SerializeField]
        internal int MaximumIterations = 2048;

        [SerializeField]
        internal float maxDistance = 0.0f;

        [SerializeField]
        internal float maxMoisture = 1f;

        [SerializeField]
        internal float falloffPower = 0.5f;

        protected override void Enable()
        {
            base.Enable();
            preview = new Texture2D(300, 300);
        }

        static Texture2D ToPreviewTexture(RenderTexture rt, int previewres = 256)
        {
            int w = rt.width;
            int h = rt.height;

            float scale = Mathf.Min((float)previewres / w, (float)previewres / h);
            int pw = Mathf.RoundToInt(w * scale);
            int ph = Mathf.RoundToInt(h * scale);

            RenderTexture tmp = RenderTexture.GetTemporary(pw, ph, 0, rt.format);
            Graphics.Blit(rt, tmp);

            Texture2D tex = new Texture2D(pw, ph, TextureFormat.RGBAFloat, false, true);

            RenderTexture prev = RenderTexture.active;
            RenderTexture.active = tmp;

            tex.ReadPixels(new Rect(0, 0, pw, ph), 0, 0);
            tex.Apply(false, false);

            RenderTexture.active = prev;
            RenderTexture.ReleaseTemporary(tmp);

            return tex;
        }


        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);
            GenerateMoisture();

            return r;
        }

        void FillPolygon(List<Vector2> points, Color color, Texture2D texture)
        {
            int textureWidth = texture.width;
            int textureHeight = texture.height;
            if (points.Count < 3) return; // Not a polygon

            // Find polygon bounds
            float minY = float.MaxValue, maxY = float.MinValue;
            foreach (var p in points)
            {
                if (p.y < minY) minY = p.y;
                if (p.y > maxY) maxY = p.y;
            }

            // Scanline fill
            for (int y = Mathf.RoundToInt(minY); y <= Mathf.RoundToInt(maxY); y++)
            {
                List<float> intersections = new List<float>();

                for (int i = 0; i < points.Count; i++)
                {
                    Vector2 p1 = points[i];
                    Vector2 p2 = points[(i + 1) % points.Count];

                    // Check if the scanline intersects the edge
                    if ((p1.y <= y && p2.y > y) || (p2.y <= y && p1.y > y))
                    {
                        float x = p1.x + (y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y);
                        intersections.Add(x);
                    }
                }

                intersections.Sort();

                // Fill between pairs of intersections
                for (int i = 0; i < intersections.Count; i += 2)
                {
                    if (i + 1 >= intersections.Count) break;
                    int startX = Mathf.RoundToInt(intersections[i]);
                    int endX = Mathf.RoundToInt(intersections[i + 1]);

                    for (int x = startX; x <= endX; x++)
                    {
                        if (x >= 0 && x < textureWidth && y >= 0 && y < textureHeight)
                            texture.SetPixel(x, y, color);
                    }
                }
            }
        }

        internal void GenerateMoisture()
        {
            if (Input == null)
                return;
            if (moistureCompute == null)
                moistureCompute = Resources.Load<ComputeShader>("Shaders/AdvMoisture/DistanceMoisture");

            Texture2D terrainTypeMap = new Texture2D(Input.GetMapSize(), Input.GetMapSize());
            for (int x = 0; x < terrainTypeMap.width; x++)
                for (int y = 0; y < terrainTypeMap.height; y++)
                    terrainTypeMap.SetPixel(x, y, Color.black);
            terrainTypeMap.Apply();

            foreach (KeyValuePair<uint, TerrainNode> kvp in Input.nodes)
            {
                TerrainNode node = kvp.Value;
                if (node.NodeType == eTerrainNodeType.LAND || node.NodeType == eTerrainNodeType.COAST)
                {
                    List<Vector2> pts = new List<Vector2>();
                    foreach (VoronoiPoint pt in node.Site.ClockwisePoints)
                    {
                        pts.Add(new Vector2((float)pt.X, (float)pt.Y));
                    }
                    FillPolygon(pts, Color.white, terrainTypeMap);
                }
            }
            terrainTypeMap.Apply();
            int size = Input.terrainTypeMap.width;
            // create RTs
            RenderTexture seedA = CreateIntRT(size, size);
            RenderTexture seedB = CreateIntRT(size, size);
            RenderTexture heightmapRT = CreateFloatRT(size, size);
            MoistureOut = CreateFloatRT(size, size);

            int initKernel = moistureCompute.FindKernel("InitSeeds");
            int jfaKernel = moistureCompute.FindKernel("JumpFlood");
            int finKernel = moistureCompute.FindKernel("Finalize");
            // Init pass: write seeds into seedA
            moistureCompute.SetTexture(initKernel, "_SourceTex", terrainTypeMap);
            moistureCompute.SetTexture(initKernel, "_SeedWrite", seedA);
            moistureCompute.SetTexture(initKernel, "_Heightmap", heightmapRT);
            moistureCompute.SetInts("_TextureSize", new int[] { size, size });

            float maxDist = MaxDistance.GetMaxLandDistance(CreateRenderTextureFromTexture(terrainTypeMap));
            moistureCompute.SetFloat("_MaxDistance", maxDist);
            moistureCompute.SetFloat("_MaxHeight", maxMoisture);
            moistureCompute.SetFloat("_FalloffPower", falloffPower);
            int tx = Mathf.CeilToInt(size / 8.0f);
            int ty = Mathf.CeilToInt(size / 8.0f);
            moistureCompute.Dispatch(initKernel, tx, ty, 1);

            // Jump Flood passes: ping-pong between seedA and seedB
            RenderTexture read = seedA;
            RenderTexture write = seedB;

            int step = Mathf.Max(size / 2, 1);
            while (step >= 1)
            {
                moistureCompute.SetTexture(jfaKernel, "_SeedRead", read);
                moistureCompute.SetTexture(jfaKernel, "_SeedWrite", write);
                moistureCompute.SetTexture(jfaKernel, "_SourceTex", terrainTypeMap);
                moistureCompute.SetInts("_TextureSize", new int[] { size, size });
                moistureCompute.SetInt("_Step", step);

                moistureCompute.Dispatch(jfaKernel, tx, ty, 1);

                // swap
                var temp = read; read = write; write = temp;

                step = step / 2;
            }

            // Finalize: read seeds from 'read' RT and write heightmap
            moistureCompute.SetTexture(finKernel, "_SeedRead", read);
            moistureCompute.SetTexture(finKernel, "_Heightmap", MoistureOut);
            moistureCompute.SetTexture(finKernel, "_SourceTex", terrainTypeMap);
            moistureCompute.SetInts("_TextureSize", new int[] { size, size });
            moistureCompute.SetFloat("_MaxDistance", maxDistance);
            moistureCompute.SetFloat("_MaxHeight", maxMoisture);
            moistureCompute.SetFloat("_FalloffPower", falloffPower);

            moistureCompute.Dispatch(finKernel, tx, ty, 1);

            // cleanup
            seedA.Release();
            seedB.Release();
            heightmapRT.Release();
            preview = ToPreviewTexture(MoistureOut, 300);
        }


        RenderTexture CreateIntRT(int w, int h)
        {
            var rt = new RenderTexture(w, h, 0, RenderTextureFormat.ARGBInt);
            rt.enableRandomWrite = true;
            rt.Create();
            return rt;
        }

        RenderTexture CreateFloatRT(int w, int h)
        {
            var rt = new RenderTexture(w, h, 0, RenderTextureFormat.ARGBFloat);
            rt.enableRandomWrite = true;
            rt.Create();
            return rt;
        }

        RenderTexture CreateRenderTextureFromTexture(Texture2D source)
        {
            // 1. Create the RenderTexture descriptor
            // ARGBFloat matches your requirement for the land distance shader
            RenderTexture rt = new RenderTexture(source.width, source.height, 0, RenderTextureFormat.ARGBFloat);

            rt.enableRandomWrite = true; // Required for Compute Shaders
            rt.Create();

            // 2. Copy the Texture2D data to the RenderTexture
            Graphics.Blit(source, rt);

            return rt;
        }
    }
}