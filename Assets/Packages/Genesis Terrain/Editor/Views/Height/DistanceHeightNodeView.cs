namespace AhahGames.GenesisNoise.GNTerrain.Views
{
    using global::AhahGames.GenesisNoise.GNTerrain.Nodes;
    using global::AhahGames.GenesisNoise.Views;

    using GraphProcessor;

    using System;

    using UnityEditor.UIElements;

    using UnityEngine;
    using UnityEngine.UIElements;

    [NodeCustomEditor(typeof(DistanceHeightNode))]
    public class DistanceHeightNodeView : GenesisNodeView
    {
        DistanceHeightNode node => nodeTarget as DistanceHeightNode;
        SliderInt iterations;
        Slider maxHeight, maxDepth, falloffPower;
        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            iterations = new SliderInt("Max Iterations", 1, 2048);
            iterations.value = node.MaximumIterations;
            iterations.showInputField = true;
            iterations.RegisterValueChangedCallback(evt =>
            {
                node.MaximumIterations = evt.newValue;

                node.Process();
                // TODO: Run compute shader
            });

            controlsContainer.Add(iterations);
            
            maxHeight = new Slider("Maximum Height", 0.0f, 1.0f);
            maxHeight.value = node.maxHeight;
            maxHeight.showInputField = true;
            maxHeight.RegisterValueChangedCallback(evt =>
            {
                node.maxHeight = evt.newValue;
                // TODO: Run compute shader
            });
            controlsContainer.Add(maxHeight);
          
            controlsContainer.Add(maxDepth);

            falloffPower = new Slider("Falloff Power", 0.0f, 1.0f);
            falloffPower.value = node.falloffPower;
            falloffPower.showInputField= true;
            falloffPower.RegisterValueChangedCallback(evt =>
            {
                node.falloffPower = evt.newValue;
                //TODO: Run compute shader
            });
            controlsContainer.Add(falloffPower);
        }
        
    }
}
