using AhahGames.GenesisNoise.GNTerrain.Nodes;
using AhahGames.GenesisNoise.Views;

using GraphProcessor;

using System;

using UnityEditor.UIElements;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.GNTerrain.Views
{
    [NodeCustomEditor(typeof(WaterLevelNode))]
    public class WaterLevelNodeView : GenesisNodeView
    {
        Slider levelSlider;
        WaterLevelNode node => nodeTarget as WaterLevelNode;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            levelSlider = new Slider("Water Level", 0, 1);
            levelSlider.value = node.WaterLevel;
            levelSlider.RegisterCallback<ChangeEvent<float>>(
                e =>
                {
                    node.WaterLevel = levelSlider.value;
                    node.GeneratePreview();
                });
            levelSlider.showInputField = true;
            controlsContainer.Add(levelSlider);
        }
    }
}
