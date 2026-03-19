using AhahGames.GenesisNoise.GNTerrain.Nodes;
using AhahGames.GenesisNoise.Views;

using GraphProcessor;

using System;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.GNTerrain.Views
{
    [NodeCustomEditor(typeof(HeightfieldBlurNode))]
    public class HeightfieldBlurNodeView : GenesisNodeView
    {
        HeightfieldBlurNode node => nodeTarget as HeightfieldBlurNode;
        SliderInt amount;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            amount = new SliderInt("Radius", 2, 63);
            amount.value = node.radius;
            amount.showInputField = true;
            amount.RegisterCallback<ChangeEvent<int>>(e =>
            {
                node.radius = amount.value;
                node.Blur();
            });
            controlsContainer.Add(amount);
        }

    }
}