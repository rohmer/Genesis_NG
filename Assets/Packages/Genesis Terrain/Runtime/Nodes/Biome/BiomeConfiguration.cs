using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using NUnit.Framework;

using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain
{
    [System.Serializable]
    [NodeMenuItem("Terrain/Biome/Biome Configuration")]
    public class BiomeConfiguration : GenesisNode
    {
        [Input("Texture Set")]
        public IEnumerable<BiomeTextureSetData> textureSets = null;

        [Output("Configuration")]
        public BiomeConfig biomeConfig = new BiomeConfig();

        public override bool hasPreview => true;
        public override string NodeGroup => "Biomes";
        public override string name => "Biome Configuration";

        public override float nodeWidth => 300;
        Texture2D preview;
        public override Texture previewTexture => preview;
        public enum eClusterVariations
        {
            None = 0,
            [InspectorName("2 Variations")]
            Two = 2,
            [InspectorName("3 Variations")]
            Three = 3
        }

        public enum eBiomeMoisture
        {
            DRIEST = 0,
            VERY_DRY = 1,
            DRY = 3,
            AVERAGE = 4,
            WET = 5,
            VERY_WET = 6,
            WETTEST = 7
        }

        public enum eElevation
        {
            LOWEST = 0,
            LOW = 1,
            AVERAGE = 2,
            HIGH = 3,
            HIGHEST = 4
        }

        public string BiomeName = "Biome";

        public eBiomeMoisture MoistureMin = eBiomeMoisture.AVERAGE;
        public eElevation ElevationMin = eElevation.AVERAGE;
        public eBiomeMoisture MoistureMax = eBiomeMoisture.AVERAGE;
        public eElevation ElevationMax = eElevation.AVERAGE;

        private eClusterVariations clusterVariations = eClusterVariations.Two;
        public eClusterVariations ClusterVariations
        {
            get
            {
                if (AntiTileFeatures)
                    return clusterVariations;
                return eClusterVariations.None;
            }
            set
            {
                if (clusterVariations != value)
                {
                    clusterVariations = value;
                }
            }

        }

        private BiomeChart biomeChart;

        public bool AntiTileFeatures = true;

        protected override void Enable()
        {
            base.Enable();
            drawBiomeMap();
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);

            if ( textureSets==null)
            {
                return false;
            }
            biomeConfig.BiomeConfiguration.Clear();
            foreach (BiomeTextureSetData btsd in textureSets)
            {
                biomeConfig.BiomeConfiguration.Add(btsd);
            }
            biomeConfig.biomeName = BiomeName;
            biomeConfig.maximumTemp = (int)ElevationMax;
            biomeConfig.minimumTemp= (int)ElevationMin;
            biomeConfig.maximumMoisture = (int)MoistureMax;
            biomeConfig.minimumMoisture = (int)MoistureMin;
            return r;
        }
        
        [CustomPortBehavior(nameof(textureSets))]
        IEnumerable<PortData> GetPortsForDiffuse(List<SerializableEdge> edges)
        {
            if (ClusterVariations == eClusterVariations.None)
            {
                yield return new PortData { displayName = "Texture Set", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "textureSet" };
            }
            if (ClusterVariations == eClusterVariations.Two)
            {
                yield return new PortData { displayName = "Texture Set 1", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "textureSet1" };
                yield return new PortData { displayName = "Texture Set 2", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "textureSet2" };
            }
            if (ClusterVariations == eClusterVariations.Three)
            {
                yield return new PortData { displayName = "Texture Set 1", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "textureSet1" };
                yield return new PortData { displayName = "Texture Set 2", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "textureSet2" };
                yield return new PortData { displayName = "Texture Set 3", displayType = typeof(BiomeTextureSetData), acceptMultipleEdges = false, identifier = "textureSet3" };
            }
        }

        [CustomPortInput(nameof(textureSets), typeof(Texture2D))]
        public void GetDiffuseInputs(List<SerializableEdge> edges)
        {
            textureSets = edges.Select(e => (BiomeTextureSetData)e.passThroughBuffer);
        }        

        internal void drawBiomeMap()
        {
            if(biomeChart==null)
            {
                biomeChart = new BiomeChart(300, 300);
            }
            biomeChart.ClearBiomes();
            biomeChart.AddBiome(
                BiomeName,
                (int)ElevationMin,
                (int)ElevationMax,
                (int)MoistureMin,
                (int)MoistureMax);
            preview = biomeChart.GetChart();
        }
    }
}