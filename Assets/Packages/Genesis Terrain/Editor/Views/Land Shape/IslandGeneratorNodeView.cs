using AhahGames.GenesisNoise.GNTerrain.Nodes;
using AhahGames.GenesisNoise.Views;

using GraphProcessor;

using System;

using UnityEditor.UIElements;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.GNTerrain.Views
{    
    [NodeCustomEditor(typeof(IslandGeneratorNode))]
    public class IslandGeneratorNodeView : GenesisNodeView
    {
        IslandGeneratorNode node => nodeTarget as IslandGeneratorNode;        
        Toggle forceEdge, useCoasts, forceEdgeOcean, allowLakes;
        
        Slider noiseInfluence;
        CurveField heightCurve;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);

            forceEdge = new Toggle("Force Edge Ocean");
            forceEdge.value = node.forceEdgeOcean;
            forceEdge.RegisterCallback<ChangeEvent<bool>>(e =>
            {
                node.forceEdgeOcean = e.newValue;
                node.MarkWater();
            });
            controlsContainer.Add(forceEdge);

            useCoasts = new Toggle("Use Coasts");
            useCoasts.value = node.useCoasts;
            useCoasts.RegisterCallback<ChangeEvent<bool>>(e =>
            {
                node.useCoasts = e.newValue;

                // TODO: Call node mark coasts
            });
            controlsContainer.Add(useCoasts);

            forceEdgeOcean = new Toggle("Force Edge Ocean");
            forceEdgeOcean.value = node.forceEdgeOcean;
            forceEdgeOcean.RegisterCallback<ChangeEvent<bool>>(e =>
            {
                node.forceEdgeOcean = e.newValue;
                // TODO: Call node force edge ocean
            });
            controlsContainer.Add(forceEdgeOcean);

            allowLakes = new Toggle("Allow Lakes");
            allowLakes.value = node.allowLakes;
            allowLakes.RegisterCallback<ChangeEvent<bool>>(e =>
            {
                node.allowLakes = e.newValue;
                //TODO: Call mark lakes
            });
            controlsContainer.Add(allowLakes);

            
            heightCurve = new CurveField();
            heightCurve = new CurveField("Height Curve");
            heightCurve.value = node.heightCurve;
            heightCurve.RegisterCallback<ChangeEvent<AnimationCurve>>(
                e =>
                {
                    node.heightCurve = e.newValue;
                    node.MarkWater();
                });
            controlsContainer.Add(heightCurve);

            noiseInfluence = new Slider("Noise Influence", 0f, 1f);
            noiseInfluence.value = node.noiseInfluence;
            noiseInfluence.RegisterCallback<ChangeEvent<float>>(e =>
            {
                node.noiseInfluence = e.newValue;
                node.MarkWater();
            });
            controlsContainer.Add(noiseInfluence);                        
        }
        

    }
}