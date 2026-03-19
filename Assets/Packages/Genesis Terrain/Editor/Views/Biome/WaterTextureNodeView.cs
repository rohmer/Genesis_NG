namespace AhahGames.GenesisNoise.GNTerrain.Views
{
    using global::AhahGames.GenesisNoise.Views;

    using GraphProcessor;

    using System;

    using UnityEngine.UIElements;

    [NodeCustomEditor(typeof(WaterTextureNode))]
    public class WaterTextureNodeView : GenesisNodeView
    {
        WaterTextureNode node => nodeTarget as WaterTextureNode;

        EnumField clusterVariations;
        Box matFeatures;
        UnityEngine.UIElements.Toggle antiTile;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
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
                        clusterVariations = new EnumField("Cluster Variations", node.clusterVariations);
                        clusterVariations.RegisterCallback<ChangeEvent<Enum>>(ev =>
                        {
                            node.clusterVariations = (WaterTextureNode.eClusterVariations)ev.newValue;
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
                clusterVariations = new EnumField("Cluster Variations", node.clusterVariations);
                clusterVariations.RegisterCallback<ChangeEvent<Enum>>(e =>
                {
                    node.clusterVariations = (WaterTextureNode.eClusterVariations)e.newValue;
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

            controlsContainer.Add(matFeatures); ;
        }
    }
}