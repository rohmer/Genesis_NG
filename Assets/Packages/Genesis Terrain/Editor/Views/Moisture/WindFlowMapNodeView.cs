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
    [NodeCustomEditor(typeof(WindFlowMapNode))]
    public class WindFlowMapNodeView : GenesisNodeView
    {
        WindFlowMapNode node => nodeTarget as WindFlowMapNode;
        Vector2Field windDirection;
        Slider terrainInf, occStr, advStr, advStepSize;
        SliderInt advectionSteps;

        Slider macro, meso, micro;
        SliderInt sampleMacro, sampleMeso, sampleMicro;

        EnumField debugMode;
        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);

            debugMode = new EnumField("Vizualsation", node.debugMode);
            debugMode.value = node.debugMode;
            debugMode.RegisterCallback<ChangeEvent<Enum>>(e=>
            {
                node.debugMode = (WindFlowMapNode.eDebugViz)e.newValue;
                node.GenerateWindFlow();
            });
            controlsContainer.Add(debugMode);

            windDirection = new Vector2Field("Wind Direction");
            windDirection.value = node.baseWind;
            windDirection.RegisterValueChangedCallback(e =>
            {
                node.baseWind = e.newValue;
                node.GenerateWindFlow();
            });
            controlsContainer.Add(windDirection);

            terrainInf = new Slider("Terrain Influence", 0, 2);
            terrainInf.value = node.terrainInfluence;
            terrainInf.RegisterValueChangedCallback(e =>
            {
                node.terrainInfluence = e.newValue;
                node.GenerateWindFlow();
            });
            controlsContainer.Add(terrainInf);

            occStr = new Slider("Occulsion Strength", 0, 1);
            occStr.value = node.occlusionStrength;
            occStr.RegisterValueChangedCallback(e =>
            {
                node.occlusionStrength= e.newValue;
                node.GenerateWindFlow();
            });
            controlsContainer.Add(occStr);

            advStr = new Slider("Advection Strength", 0, 1);
            advStr.value = node.advectionStrength;
            advStr.RegisterValueChangedCallback(e =>
            {
                node.advectionStrength = e.newValue;
                node.GenerateWindFlow();
            });
            controlsContainer.Add(advStr);

            advectionSteps = new SliderInt("Advection Steps", 1, 128);
            advectionSteps.value= node.advectionSteps;
            advectionSteps.RegisterValueChangedCallback(e =>
            {
                node.advectionSteps = e.newValue;
                node.GenerateWindFlow();
            });
            controlsContainer.Add(advectionSteps);

            advStepSize = new Slider("Advection Step Size", 0.25f, 2f);
            advStepSize.value = node.stepSize;
            advStepSize.RegisterValueChangedCallback(e =>
            {
                node.stepSize = e.newValue;
                node.GenerateWindFlow();
            });
            controlsContainer.Add(advStepSize);

            macro = new Slider("Macro Scale", 0, 1);
            macro.value = node.wMacro;
            macro.RegisterValueChangedCallback(e =>
            {
                node.wMacro = e.newValue;
                node.GenerateWindFlow();
            });
            controlsContainer.Add(macro);
            meso = new Slider("Meso Scale", 0, 1);
            meso.value = node.wMeso;
            meso.RegisterValueChangedCallback(e =>
            {
                node.wMeso = e.newValue;
                node.GenerateWindFlow();
            });
            controlsContainer.Add(meso);

            micro = new Slider("Micro Scale", 0, 1);
            micro.value = node.wMicro;
            micro.RegisterValueChangedCallback(e =>
            {
                node.wMicro = e.newValue;
                node.GenerateWindFlow();
            });
            controlsContainer.Add(micro);

            sampleMacro = new SliderInt("Sampling Macro", 1, 64);
            sampleMacro.value = node.rMacro;
            sampleMacro.RegisterValueChangedCallback(e =>
            {
                node.rMacro = e.newValue;
                node.GenerateWindFlow();
            });
            controlsContainer.Add(sampleMacro);

            sampleMeso = new SliderInt("Sampling Meso", 1, 64);
            sampleMeso.value = node.rMeso;
            sampleMeso.RegisterValueChangedCallback(e =>
            {
                node.rMeso = e.newValue;
                node.GenerateWindFlow();
            });
            controlsContainer.Add(sampleMeso);

            sampleMicro = new SliderInt("Sampling Micro", 1, 64);
            sampleMicro.value = node.rMicro;
            sampleMicro.RegisterValueChangedCallback(e =>
            {
                node.rMicro = e.newValue;
                node.GenerateWindFlow();
            });
            controlsContainer.Add(sampleMicro);


        }
    }
}