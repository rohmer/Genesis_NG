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
    [NodeCustomEditor(typeof(MoistureGenerator))]
    public class MoistureNodeView : GenesisNodeView
    {
        MoistureGenerator node => nodeTarget as MoistureGenerator;
        Slider moistureHeight, moistureFalloff;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);

            moistureHeight = new Slider("Max Moisture", 0.8f, 2f);
            moistureHeight.value = node.maxMoisture;
            moistureHeight.RegisterValueChangedCallback(
                e =>
                {
                    node.maxMoisture = e.newValue;
                    node.GenerateMoisture();
                });
            controlsContainer.Add(moistureHeight);

            moistureFalloff = new Slider("Moisture Falloff", 0.001f,1);
            moistureFalloff.value = node.falloffPower;
            moistureFalloff.RegisterValueChangedCallback(
                e =>
                {
                    node.falloffPower = e.newValue;
                    node.GenerateMoisture();
                });
            controlsContainer.Add(moistureFalloff);

        }
    }
}
