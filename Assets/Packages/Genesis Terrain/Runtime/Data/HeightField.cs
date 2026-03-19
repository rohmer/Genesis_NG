using System;
using System.Collections.Generic;
using System.Text;

using UnityEngine;


namespace AhahGames.GenesisNoise.GNTerrain
{
    public class HeightField
    {
        internal Dictionary<uint, TerrainNode> terrainNodes=new Dictionary<uint,TerrainNode>();
        public RenderTexture HeightMap;
        internal int mapSize;
        public bool UseCoasts, AllowLakes;

        public int NodeCount
        {
            get { return terrainNodes.Count; }
        }

        public TerrainNode GetNodeByID(uint id)
        {
            return terrainNodes[id]; 
        }

        public void SetNodeType(uint id, eTerrainNodeType nodeType)
        {
            TerrainNode tn = terrainNodes[id];
            tn.NodeType = nodeType;
            terrainNodes[id] = tn;
        }

        public HeightField()
        {
        }

        public HeightField(int size)
        {
            mapSize = size;
            terrainNodes = new Dictionary<uint, TerrainNode>();
           
        }

       
        public HeightField(HeightField other)
        {
            terrainNodes = new Dictionary<uint, TerrainNode>();
            if (other != null)
            {
                foreach (KeyValuePair<uint, TerrainNode> node in other.terrainNodes)
                {
                    terrainNodes.Add(node.Key, node.Value);
                }
                mapSize = other.mapSize;
                HeightMap = CreateFloatRT(mapSize, mapSize);
                if (other.HeightMap != null)
                    Graphics.CopyTexture(other.HeightMap, HeightMap);
                UseCoasts = other.UseCoasts;
                AllowLakes = other.AllowLakes;                        
            }
            
        }
        RenderTexture CreateFloatRT(int w, int h)
        {
            var rt = new RenderTexture(w, h, 0, RenderTextureFormat.ARGBFloat);
            rt.enableRandomWrite = true;
            rt.Create();
            return rt;
        }
    }
}
