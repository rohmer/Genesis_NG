namespace AhahGames.GenesisNoise.GNTerrain.Views
{    
    using global::AhahGames.GenesisNoise.Views;

    using GraphProcessor;

    using System;

    using UnityEngine.UIElements;

    [NodeCustomEditor(typeof(BiomeConfiguration))]
    public class BiomeConfigurationView : GenesisNodeView
    {
        BiomeConfiguration node => nodeTarget as BiomeConfiguration;
        TextField biomeName;
        EnumField minMoist, maxMoist, minElevation, maxElevation;
        Box matFeatures;
        UnityEngine.UIElements.Toggle antiTile;
        EnumField clusterVariations;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            biomeName = new TextField("Biome Name");
            biomeName.value = node.BiomeName;
            biomeName.RegisterCallback<ChangeEvent<string>>(e =>
            {
                node.BiomeName = e.newValue;
            });
            controlsContainer.Add(biomeName);

            minMoist = new EnumField("Minimum Moisture", node.MoistureMin);
            controlsContainer.Add(minMoist);
            minMoist.RegisterCallback<ChangeEvent<Enum>>(e =>
            {
                node.MoistureMin = (BiomeConfiguration.eBiomeMoisture)e.newValue;
                node.drawBiomeMap();
            });

            maxMoist = new EnumField("Maximum Moisture", node.MoistureMax);
            controlsContainer.Add(maxMoist);
            maxMoist.RegisterCallback<ChangeEvent<Enum>>(e =>
            {
                node.MoistureMax = (BiomeConfiguration.eBiomeMoisture)e.newValue;
                node.drawBiomeMap();
            });

            minElevation = new EnumField("Minimum Elevation", node.ElevationMin);
            controlsContainer.Add(minElevation);
            minElevation.RegisterCallback<ChangeEvent<Enum>>(e =>
            {
                node.ElevationMin = (BiomeConfiguration.eElevation)e.newValue;
                node.drawBiomeMap();
            });

            maxElevation = new EnumField("Maximum Elevation", node.ElevationMax);
            controlsContainer.Add(maxElevation);
            maxElevation.RegisterCallback<ChangeEvent<Enum>>(e =>
            {
                node.ElevationMax = (BiomeConfiguration.eElevation)e.newValue;
                node.drawBiomeMap();
            });

            matFeatures = new Box();
            TextElement matFeatLabel = new TextElement { text = "Material Features" };
            matFeatures.Add(matFeatLabel);

            antiTile = new UnityEngine.UIElements.Toggle("Anti-Tiling");
            antiTile.value = node.AntiTileFeatures;
            antiTile.RegisterCallback<ChangeEvent<bool>>(e =>
            {
                node.AntiTileFeatures = e.newValue;
                if (node.AntiTileFeatures)
                {
                    if (clusterVariations == null)
                    {
                        clusterVariations = new EnumField("Cluster Variations", node.ClusterVariations);
                        clusterVariations.RegisterCallback<ChangeEvent<Enum>>(ev =>
                        {
                            node.ClusterVariations = (BiomeConfiguration.eClusterVariations)ev.newValue;
                            node.UpdateAllPortsLocal();
                        });
                    }
                    matFeatures.Add(clusterVariations);
                }
                else
                {
                    if (clusterVariations != null)
                        matFeatures.Remove(clusterVariations);
                }
                node.UpdateAllPortsLocal();
            });
            matFeatures.Add(antiTile);

            if (node.AntiTileFeatures)
            {
                clusterVariations = new EnumField("Cluster Variations", node.ClusterVariations);
                clusterVariations.RegisterCallback<ChangeEvent<Enum>>(e =>
                {
                    node.ClusterVariations = (BiomeConfiguration.eClusterVariations)e.newValue;
                    node.UpdateAllPortsLocal();
                });
                matFeatures.Add(clusterVariations);
                node.UpdateAllPortsLocal();
            }
            else
            {
                if (clusterVariations != null && matFeatures.Contains(clusterVariations))
                    matFeatures.Remove(clusterVariations);
                node.UpdateAllPortsLocal();
            }

            controlsContainer.Add(matFeatures);


        }
    }
}