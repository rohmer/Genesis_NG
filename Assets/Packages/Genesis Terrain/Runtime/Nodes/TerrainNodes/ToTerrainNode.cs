using ahahgames.genesisnoise;

using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System.Collections.ObjectModel;
using System.Diagnostics;

using Unity.Mathematics;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{
    [Documentation(@"Takes the output of height nodes and generates a terrain")]
    [System.Serializable, NodeMenuItem("Terrain/Terrain/Terrain Creation")]
    public class ToTerrainNode : GenesisNode
    {
        [SerializeField, Input(name = "Height Field", allowMultiple = false)]
        public TerrainHeightNode TerrainInput;

        [SerializeField, Output(name = "Terrain")]
        public Terrain terrain;
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override float nodeWidth => 300;
        public override string NodeGroup => "Terrain";
        
        protected override void Enable()
        {
            base.Enable();
        }        

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            base.ProcessNode(cmd);

            if (TerrainInput == null || TerrainInput.heightMap== null)
                return false;
            Texture2D heightTexture =TerrainInput.heightMap;            
            UnityEngine.TerrainData terrainData = new UnityEngine.TerrainData();
            if (TerrainInput.heightMap.width <= 33)
                terrainData.heightmapResolution = 33;
            else
                if (TerrainInput.heightMap.width <= 65)
                terrainData.heightmapResolution = 65;
            else
                if (TerrainInput.heightMap.width <= 129)
                terrainData.heightmapResolution = 129;
            else
                if (TerrainInput.heightMap.width <= 257)
                terrainData.heightmapResolution = 257;
            else
                if (TerrainInput.heightMap.width <= 513)
                terrainData.heightmapResolution = 513;
            else
                if (TerrainInput.heightMap.width <= 1025)
                terrainData.heightmapResolution = 1025;
            else
                if (TerrainInput.heightMap.width <= 2049)
                terrainData.heightmapResolution = 2049;
            else
                terrainData.heightmapResolution = 4097;
            terrainData.size = new Vector3(TerrainInput.heightMap.width, 512, TerrainInput.heightMap.height);
            int size = terrainData.heightmapResolution;
            Texture2D scaled = new Texture2D(size,size, TextureFormat.RFloat, false, true);
            for(int y=0;y<size; y++)
            {
                for(int x=0;x<size;x++)
                {
                    float u = (x + 0.5f) / size;
                    float v = (y + 0.5f) / size;
                    Color c = TerrainInput.heightMap.GetPixelBilinear(u, v);
                    scaled.SetPixel(x, y, c);
                }
            }
            scaled.Apply();

            if (terrain == null)
            {
                GameObject terrainGO = UnityEngine.Terrain.CreateTerrainGameObject(terrainData);
                terrain = terrainGO.GetComponent<UnityEngine.Terrain>();
                terrainGO.name = "Generated Terrain";
                terrainGO.transform.position = new Vector3(0, 0, 0);
                TerrainCollider terrainCollider = terrainGO.GetComponent<TerrainCollider>();
                if(terrainCollider != null)
                {
                    //terrainCollider=terrainGO.AddComponent<TerrainCollider>();
                    terrainCollider.terrainData = terrainData;
                }
            } else
            {
                GameObject terrainGO = terrain.gameObject;
                TerrainCollider tc=terrainGO.GetComponent<TerrainCollider>();
                if(tc==null)
                {
                    tc=terrainGO.AddComponent<TerrainCollider>();
                }
                tc.terrainData= terrainData;    
            }


                float max = float.MinValue;
            float min = float.MaxValue; 
            float[,] heights = new float[size, size];
            UnityEngine.Debug.LogError("Size=" + size);
            for (int y = 0; y < size; y++)
                for (int x = 0; x < size; x++)
                {
                    float val = scaled.GetPixel(x, y).r;
                    heights[y, x] = val;
                    if (val < min)
                        min = val;
                    if (val > max)
                        max = val; 
                }
            UnityEngine.Debug.LogError("Max=" + max);
            UnityEngine.Debug.LogError("Min=" + min);
            terrain.terrainData.SetHeights(0, 0, heights);            
            return true;

        }
    }
}
