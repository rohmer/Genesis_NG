using AhahGames.GenesisNoise.GNTerrain;
using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain
{
    [Serializable, NodeMenuItem("Terrain/Biome/Water Textures")]
    public class WaterTextureNode : GenesisNode
    {
        [Input(name = "Beach")]
        public IEnumerable<BiomeTextureSetData> BeachMaterial;

        [Input(name = "Water")]
        public IEnumerable<BiomeTextureSetData> WaterMaterial;

        public enum eClusterVariations
        {
            None = 0,
            [InspectorName("2 Variations")]
            Two = 2,
            [InspectorName("3 Variations")]
            Three = 3
        }
        public eClusterVariations clusterVariations = eClusterVariations.Two;
        /// <summary>
        /// 0 is Beach - Any underwater point with a height > 0 
        /// 1 is Ocean = Height == 0
        /// </summary>
        [Output(name = "Water Materials")]
        public WaterMaterialsData Output = new WaterMaterialsData();
        public bool AntiTileFeatures = true;

        protected override void Enable()
        {
            base.Enable();
        }

        private Texture2D copyTexture(Texture2D input)
        {
            Texture2D output = new Texture2D(input.width, input.height, input.format, false);
            Graphics.CopyTexture(input, output);
            return output;
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            


            return true;
        }

        [CustomPortBehavior(nameof(BeachMaterial))]
        IEnumerable<PortData> GetPortsForDiffuse(List<SerializableEdge> edges)
        {
            if (clusterVariations == eClusterVariations.None)
            {
                yield return new PortData { displayName = "Beach Set", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "beachMaterial1" };
            }
            if (clusterVariations == eClusterVariations.Two)
            {
                yield return new PortData { displayName = "Beach Set 1", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "beachMaterial1" };
                yield return new PortData { displayName = "Beach Set 2", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "beachMaterial2" };
            }
            if (clusterVariations == eClusterVariations.Three)
            {
                yield return new PortData { displayName = "Beach Set 1", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "beachMaterial1" };
                yield return new PortData { displayName = "Beach Set 2", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "beachMaterial2" };
                yield return new PortData { displayName = "Beach Set 3", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "beachMaterial3" };
            }
        }

        [CustomPortBehavior(nameof(WaterMaterial))]
        IEnumerable<PortData> GetPortsForWater(List<SerializableEdge> edges)
        {
            if (clusterVariations == eClusterVariations.None)
            {
                yield return new PortData { displayName = "Water Set", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "waterMaterial1" };
            }
            if (clusterVariations == eClusterVariations.Two)
            {
                yield return new PortData { displayName = "Water Set 1", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "waterMaterial1" };
                yield return new PortData { displayName = "Water Set 2", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "waterMaterial2" };
            }
            if (clusterVariations == eClusterVariations.Three)
            {
                yield return new PortData { displayName = "Water Set 1", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "waterMaterial1" };
                yield return new PortData { displayName = "Water Set 2", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "waterMaterial2" };
                yield return new PortData { displayName = "Water Set 3", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "waterMaterial3" };
            }
        }

        [CustomPortInput(nameof(BeachMaterial), typeof(Texture2D))]
        public void GetDiffuseInputs(List<SerializableEdge> edges)
        {
            BeachMaterial = edges.Select(e => (BiomeTextureSetData)e.passThroughBuffer);
        }

        [CustomPortInput(nameof(WaterMaterial), typeof(Texture2D))]
        public void GetWaterInputs(List<SerializableEdge> edges)
        {
            WaterMaterial = edges.Select(e => (BiomeTextureSetData)e.passThroughBuffer);
        }


    }
}
