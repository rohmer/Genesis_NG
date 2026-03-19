using AhahGames.GenesisNoise.GNTerrain.Nodes;
using AhahGames.GenesisNoise.Views;

using GraphProcessor;

using PlasticGui.WorkspaceWindow.PendingChanges;

using System;

using UnityEditor.UIElements;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.GNTerrain.Views
{
    [NodeCustomEditor(typeof(SharpenNode))]
    public class SharpenNodeView : GenesisNodeView
    {
        SharpenNode node => nodeTarget as SharpenNode;
        Slider amount, radius;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            amount = new Slider("Amount", 0.1f, 4f);
            amount.value = node.sharpenAmount;
            amount.showInputField = true;
            amount.RegisterCallback<ChangeEvent<float>>(e =>
            {
                node.sharpenAmount = amount.value;
                node.Sharpen();
            });
            controlsContainer.Add(amount);

            radius = new Slider("Radius", 1f, 32f);
            radius.value = node.sharpenRadius;
            radius.showInputField = true;
            radius.RegisterCallback<ChangeEvent<float>>(e =>
            {
                node.sharpenRadius = amount.value;
                node.Sharpen();
            });
            controlsContainer.Add(radius);
        }

    }
}
