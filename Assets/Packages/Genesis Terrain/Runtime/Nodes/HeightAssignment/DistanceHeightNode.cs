using AhahGames.GenesisNoise.Nodes;

using Codice.Client.BaseCommands.Import;
using Codice.CM.Client.Differences;

using GraphProcessor;

using Mono.Cecil;

using SharpVoronoiLib;

using System.Collections.Generic;

using UnityEngine;
using UnityEngine.AdaptivePerformance.Provider;
using UnityEngine.Experimental.AI;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{

    [Documentation(@"
This node generates the initial heightfield based on distance to coast
")]

    [System.Serializable, NodeMenuItem("Terrain/Height/Distance Height Node")]
    public class DistanceHeightNode : GenesisNode
    {
        [SerializeField, Input]
        TerrainNodes Input;

        [SerializeField, Output(name ="Height Field")]
        HeightField Output;
        

        [SerializeField]
        internal int MaximumIterations = 512;

        [SerializeField]
        internal float maxDistance = 0.0f;

        [SerializeField]
        internal float maxHeight = 16f;

        [SerializeField]
        internal float falloffPower = 2.0f;

        public override string name => "Distance Height";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override float nodeWidth => 300;
        internal Texture2D preview;

        public override Texture previewTexture => preview;
        public RenderTexture heightmapRT;
        public RenderTexture previewRT;      // full-size preview produced by compute
        [HideInInspector] public Texture2D preview300; // automatically generated 300x300 preview

        private ComputeShader compute;


        Color[] clearArray = new Color[300 * 300];
        protected override void Enable()
        {
            base.Enable();            
            preview = new Texture2D(300, 300);
            clearArray = preview.GetPixels();
            for (int i = 0; i < clearArray.Length; i++)
                clearArray[i] = Color.black;
            preview.SetPixels(clearArray);
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            Output = new HeightField(Input.GetMapSize());
            bool r = base.ProcessNode(cmd);
            UpdateAllPortsLocal();
            if(compute==null)
            {
                compute = Resources.Load<ComputeShader>("Shaders/HeightfieldDistance");
            }
            if(compute == null)
            {
                Debug.LogError("Failed to load HeightfieldDistance.compute");
            }
            Run();    
            return true;
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

        protected void Run()
        {
            // Create the input map from the generator

            Texture2D terrainTypeMap = new Texture2D(Input.GetMapSize(), Input.GetMapSize());
            for (int x = 0; x < terrainTypeMap.width; x++)
                for (int y = 0; y < terrainTypeMap.height; y++)
                    terrainTypeMap.SetPixel(x, y, Color.black);
            terrainTypeMap.Apply();
            
            foreach(KeyValuePair<uint,TerrainNode> kvp in Input.nodes)
            {
                TerrainNode node = kvp.Value;
                if(node.NodeType==eTerrainNodeType.LAND || node.NodeType==eTerrainNodeType.COAST)
                {
                    List<Vector2> pts= new List<Vector2>();
                    foreach(VoronoiPoint pt in node.Site.ClockwisePoints)
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
            heightmapRT = CreateFloatRT(size, size);
            Output.HeightMap = CreateFloatRT(size, size);

            int initKernel = compute.FindKernel("InitSeeds");
            int jfaKernel = compute.FindKernel("JumpFlood");
            int finKernel = compute.FindKernel("Finalize");
            // Init pass: write seeds into seedA
            compute.SetTexture(initKernel, "_SourceTex", terrainTypeMap);
            compute.SetTexture(initKernel, "_SeedWrite", seedA);
            compute.SetTexture(initKernel, "_Heightmap", heightmapRT);
            compute.SetInts("_TextureSize", new int[] { size, size });

            float maxDist = MaxDistance.GetMaxLandDistance(CreateRenderTextureFromTexture(terrainTypeMap));
            compute.SetFloat("_MaxDistance", maxDist);
            compute.SetFloat("_MaxHeight", maxHeight);
            compute.SetFloat("_FalloffPower", falloffPower);
            int tx = Mathf.CeilToInt(size / 8.0f);
            int ty = Mathf.CeilToInt(size / 8.0f);
            compute.Dispatch(initKernel, tx, ty, 1);

            // Jump Flood passes: ping-pong between seedA and seedB
            RenderTexture read = seedA;
            RenderTexture write = seedB;

            int step = Mathf.Max(size / 2, 1);
            while (step >= 1)
            {
                compute.SetTexture(jfaKernel, "_SeedRead", read);
                compute.SetTexture(jfaKernel, "_SeedWrite", write);
                compute.SetTexture(jfaKernel, "_SourceTex", terrainTypeMap);
                compute.SetInts("_TextureSize", new int[] { size, size });
                compute.SetInt("_Step", step);

                compute.Dispatch(jfaKernel, tx, ty, 1);

                // swap
                var temp = read; read = write; write = temp;

                step = step / 2;
            }

            // Finalize: read seeds from 'read' RT and write heightmap
            compute.SetTexture(finKernel, "_SeedRead", read);
            compute.SetTexture(finKernel, "_Heightmap", Output.HeightMap);
            compute.SetTexture(finKernel, "_SourceTex", terrainTypeMap);
            compute.SetInts("_TextureSize", new int[] { size, size });
            compute.SetFloat("_MaxDistance", maxDistance);
            compute.SetFloat("_MaxHeight", maxHeight);
            compute.SetFloat("_FalloffPower", falloffPower);

            compute.Dispatch(finKernel, tx, ty, 1);
                        
            // cleanup
            seedA.Release();
            seedB.Release();
            heightmapRT.Release();

            Texture2D tmp = ReadRenderTextureFloat(Output.HeightMap);
            // Generate preview
            preview = new Texture2D(300, 300);
            float dMod = (float)size / 300f;
            for(int x=0; x<300; x++)
            {
                for(int y=0; y<300; y++)
                {
                    float c=tmp.GetPixel((int)(x*dMod),(int)(y*dMod)).r;
                    preview.SetPixel(x, y, new Color(c, c, c));
                }
            }
            preview.Apply();
            UpdateAllPorts();
            UnityEngine.Debug.Log("DistanceHeightNode");
            Debug.Log("Heightmap generation complete.");
        }

        void FillPolygon(List<Vector2> points, Color color, Texture2D texture)
        {
            int textureWidth=texture.width;
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

        Texture2D ReadRenderTextureFloat(RenderTexture rt)
        {
            RenderTexture prev = RenderTexture.active;
            RenderTexture.active = rt;
            Texture2D tex = new Texture2D(rt.width, rt.height, TextureFormat.RGBAFloat, false, true);
            tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            tex.Apply();
            RenderTexture.active = prev;
            return tex;
        }


        void Update()
        {
        }
    }
}