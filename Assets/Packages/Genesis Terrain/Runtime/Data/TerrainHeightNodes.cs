using UnityEngine;

namespace AhahGames.GenesisNoise.GNTerrain
{
    public class TerrainHeightNode
    {
        internal TerrainNodes terrainNodes;
        internal Texture2D heightMap;
        internal Texture2D previewTexture;

        internal TerrainHeightNode()
        {
        }

        
        public object ShallowCopy()
        {
            TerrainHeightNode thn = new TerrainHeightNode();
            thn.heightMap=new Texture2D(this.heightMap.width, this.heightMap.height);
            thn.heightMap.SetPixels(this.heightMap.GetPixels());

            thn.previewTexture = new Texture2D(300,300);
            
            thn.terrainNodes = new TerrainNodes(this.terrainNodes.vPlane, this.terrainNodes.GetMapSize(), this.terrainNodes.nodes);
            return thn;
        }

        public bool UseCoasts
        {
            get { return terrainNodes.UseCoasts; }
            set { terrainNodes.UseCoasts = value; }
        }

        public bool AllowLakes
        {
            get { return terrainNodes.AllowLakes; }
            set { terrainNodes.AllowLakes = value; }
        }

        public TerrainNode GetNode(uint id)
        {
            return (TerrainNode)terrainNodes.GetNodeByID(id);
        }

        public uint GetNodeCount()
        {
            return terrainNodes.NodeCount;
        }

        public void SetNode(uint id, TerrainNode node)
        {
            terrainNodes.nodes[id] = node;  
        }

        public int GetTerrainSize()
        {
            return terrainNodes.GetMapSize();
        }

        public Texture2D GetHeightMap()
        {            
            return heightMap;
        }

        public Texture2D GetTerrainTypeMap()
        {
            return terrainNodes.terrainTypeMap;
        }
    }
}