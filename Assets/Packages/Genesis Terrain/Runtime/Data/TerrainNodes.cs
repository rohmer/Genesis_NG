using ProtoTurtle.BitmapDrawing;

using SharpVoronoiLib;

using System.Collections.Generic;
using System.Linq;

using UnityEngine;

namespace AhahGames.GenesisNoise.GNTerrain
{
    public enum eTerrainNodeType
    {
        UNCLASSIFIED = 0, // Hasnt been sorted out yet
        OCEAN = 1,
        LAND = 2,
        COAST = 3,        // Land touching water
        LAKE = 4,         // Water not contiguous with ocean
    }

    public struct TerrainNode
    {
        public uint id;
        public Vector2 centroid;
        public bool isEdge;
        VoronoiSite site;
        eTerrainNodeType nodeType;

        public TerrainNode(uint id, VoronoiSite site)
        {
            this.id = id;
            site.ID = id;
            this.site = site;

            this.centroid = new Vector2((float)site.Centroid.X, (float)site.Centroid.Y);
            if (site.LiesOnEdge != null || site.LiesOnCorner != null)
            {
                isEdge = true;
            }
            else
            {
                isEdge = false;
            }
            nodeType = eTerrainNodeType.UNCLASSIFIED;

        }

        public Vector2 Centroid
        {
            get { return centroid; }
        }

        public eTerrainNodeType NodeType
        {
            get { return nodeType; }
            set { nodeType = value; }
        }

        public VoronoiSite Site
        {
            get { return site; }
            set { site = value; }
        }

        public bool IsEdge
        {
            get { return isEdge; }
        }
    }

    // This class will be used for most things post Geometry
    public class TerrainNodes
    {
        public VoronoiPlane vPlane;
        public Dictionary<uint, TerrainNode> nodes;
        public Texture2D terrainTypeMap;
        public Texture2D previewTexture;
        public Texture2D terrainHeightMap;

        public bool UseCoasts, AllowLakes;
        int mapSize;

        public TerrainNodes() { }
        public TerrainNodes(VoronoiPlane vPlane, int mapSize)
        {
            this.vPlane = vPlane;
            nodes = new Dictionary<uint, TerrainNode>();
            uint i = 0;
            foreach (var site in vPlane.Sites)
            {
                nodes.Add(i, new TerrainNode(i, site));
                i++;
            }

            this.mapSize = mapSize;
        }

        public TerrainNodes(VoronoiPlane plane, int mapSize, Dictionary<uint, TerrainNode> nodes)
        {
            this.nodes=new Dictionary<uint, TerrainNode>(nodes);
            this.vPlane = plane;
            this.mapSize = mapSize;
        }

        public int GetMapSize() { return mapSize; }

        public void SetNodeType(uint id, eTerrainNodeType type)
        {
            if (nodes.ContainsKey(id))
            {
                TerrainNode node = nodes[id];
                node.NodeType = type;
                nodes[id] = node;
            }
        }

        public TerrainNode? GetNodeByID(uint id)
        {
            if (nodes.ContainsKey(id))
                return nodes[id];
            return null;
        }

        public void SetNode(uint id, TerrainNode node)
        {
            nodes[id] = node;
        }

        public uint NodeCount
        {
            get { return (uint)nodes.Count; }
        }

        public void MarkOcean(uint startID)
        {
            HashSet<uint> visited = new HashSet<uint>();
            Queue<uint> queue = new Queue<uint>();
            // Enqueue all of the edge water nodes
            foreach(KeyValuePair<uint,TerrainNode> node in nodes)
            {
                if(node.Value.NodeType==eTerrainNodeType.LAKE && node.Value.isEdge)
                    queue.Enqueue(node.Value.id);
            }
            queue.Enqueue(startID); queue.Enqueue(startID);
            uint currentID;
            while (queue.TryDequeue(out currentID))
            {
                if (nodes[currentID].NodeType == eTerrainNodeType.LAKE)
                {
                    SetNodeType(currentID, eTerrainNodeType.OCEAN);
                    visited.Add(currentID);
                    foreach (VoronoiSite site in nodes[currentID].Site.Neighbours)
                    {
                        if (!visited.Contains(site.ID) && nodes[site.ID].NodeType == eTerrainNodeType.LAKE)
                            queue.Enqueue(site.ID);
                    }
                }
            }
        }

        internal void MarkCoast()
        {
            List<uint> nodeIDs = new List<uint>();
            foreach(KeyValuePair<uint, TerrainNode> node in nodes)
                nodeIDs.Add(node.Key);  

            foreach(uint id in nodeIDs)
            {
                TerrainNode node=nodes[id];
                if(node.NodeType==eTerrainNodeType.LAND)
                {
                    foreach(VoronoiSite site in node.Site.Neighbours)
                    {
                        if (nodes[site.ID].NodeType==eTerrainNodeType.OCEAN)
                        {
                            SetNodeType(id, eTerrainNodeType.COAST);
                            break;
                        }
                    }
                }
            }            
        }

        struct Vertex
        {
            public Vector2 position; // normalized screen space
        }

        public Texture2D CopyRenderTextureToTexture2D(RenderTexture sourceRT)
        {
            // Ensure the source is active
            RenderTexture currentRT = RenderTexture.active;
            RenderTexture.active = sourceRT;

            // Create a new Texture2D with matching dimensions and format
            Texture2D tex = new Texture2D(sourceRT.width, sourceRT.height, TextureFormat.RGBA32, false);

            // Read pixels from the active RenderTexture
            tex.ReadPixels(new Rect(0, 0, sourceRT.width, sourceRT.height), 0, 0);
            tex.Apply();

            // Restore previous active  
            RenderTexture.active = currentRT;

            return tex;
        }

        public void GenerateMapGPU(int mapSize)
        {
            terrainTypeMap = new Texture2D(mapSize, mapSize);
            foreach (VoronoiEdge edge in vPlane.Edges)
            {
                int x1 = Mathf.RoundToInt((float)edge.Start.X);
                int y1 = Mathf.RoundToInt((float)edge.Start.Y);
                int x2 = Mathf.RoundToInt((float)edge.End.X);
                int y2 = Mathf.RoundToInt((float)edge.End.Y);
                terrainTypeMap.DrawLine(x1, y1, x2, y2, Color.black);
            }
            terrainTypeMap.Apply();

            List<Vector2Int> centroidPoints = new List<Vector2Int>();
            List<Color> centroidColors = new List<Color>();
            for (uint i = 0; i < NodeCount; i++)
            {
                Color c = Color.hotPink;
                switch (nodes[i].NodeType)
                {
                    case eTerrainNodeType.UNCLASSIFIED:
                        c = Color.hotPink; break;
                    case eTerrainNodeType.OCEAN:
                        c = Color.black; break;
                    case eTerrainNodeType.LAND:
                        c = Color.white; break;
                    case eTerrainNodeType.COAST:
                        c = Color.sandyBrown; break;
                    case eTerrainNodeType.LAKE:
                        c = Color.lightBlue; break;
                }
                centroidPoints.Add(new Vector2Int((int)nodes[i].Centroid.x, (int)nodes[i].Centroid.y));
                centroidColors.Add(c);
            }

            RenderTexture renderTexture = new RenderTexture(mapSize, mapSize, 0, RenderTextureFormat.RFloat);
            renderTexture.enableRandomWrite = true;
            renderTexture.Create();
            Graphics.Blit(terrainTypeMap, renderTexture);

            ComputeShader shader = Resources.Load<ComputeShader>("Shaders/IslandShapePreview");
            //int initKernel = shader.FindKernel("CSInitSeeds");
            //int fillKernel = shader.FindKernel("CSFloodFill");
            int kernel = shader.FindKernel("CSVoronoiFill");
            // Convert to GPU-friendly formats
            ComputeBuffer seedPointBuffer = new ComputeBuffer(centroidPoints.Count, sizeof(int) * 2);
            seedPointBuffer.SetData(centroidPoints);

            ComputeBuffer seedColorBuffer = new ComputeBuffer(centroidColors.Count, sizeof(float) * 4);
            seedColorBuffer.SetData(centroidColors);

            RenderTexture OutputRT = new RenderTexture(mapSize, mapSize, 0, RenderTextureFormat.ARGB32);
            OutputRT.enableRandomWrite = true;
            OutputRT.Create();

            // Initialize seeds
            shader.SetBuffer(kernel, "_SeedPoints", seedPointBuffer);
            shader.SetBuffer(kernel, "_SeedColors", seedColorBuffer);
            shader.SetTexture(kernel, "_GridMask", renderTexture);
            shader.SetTexture(kernel, "_OutputTex", OutputRT);
            shader.SetInts("_TextureSize", mapSize, mapSize);
            shader.Dispatch(kernel, mapSize / 8, mapSize / 8, 1);


            // Clean up the fill lines
            RenderTexture FinalRT = new RenderTexture(mapSize, mapSize, 0, RenderTextureFormat.ARGB32);
            FinalRT.enableRandomWrite = true;
            FinalRT.Create();
            shader = Resources.Load<ComputeShader>("Shaders/FillLines");
            kernel = shader.FindKernel("CSFillLines");
            shader.SetInt("TextureSize", mapSize);
            shader.SetTexture(kernel, "_inputImage", OutputRT);
            shader.SetTexture(kernel, "_outputTexture", FinalRT);
            shader.Dispatch(kernel, mapSize / 8, mapSize / 8, 1);

            RenderTexture.active = FinalRT;
            terrainTypeMap.ReadPixels(new Rect(0, 0, mapSize, mapSize), 0, 0);
            terrainTypeMap.Apply();
            RenderTexture.active = null;
            seedPointBuffer?.Release();
            seedColorBuffer?.Release();

        }

        public Texture2D GeneratePreview(int previewSize)
        {
            RenderTexture preview = new RenderTexture(previewSize, previewSize, 24);
            RenderTexture prev = RenderTexture.active;
            RenderTexture.active = preview;
            Graphics.Blit(terrainTypeMap, preview);
            Texture2D result = new Texture2D(previewSize, previewSize);
            result.ReadPixels(new Rect(0, 0, previewSize, previewSize), 0, 0);
            result.Apply();
            RenderTexture.active = prev;
            return result;
        }
    }
}
