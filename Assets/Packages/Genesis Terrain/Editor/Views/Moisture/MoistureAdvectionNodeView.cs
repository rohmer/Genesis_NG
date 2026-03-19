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
    [NodeCustomEditor(typeof(MoistureAdvectionNode))]
    public class MoistureAdvectionNodeView : GenesisNodeView
    {
        MoistureAdvectionNode node => nodeTarget as MoistureAdvectionNode;

        EnumField debugField;
        SliderInt iterations;
        Slider stepSize, advStr, valleyPull, rainShadow, evaporation, heightInf, moistMin, moistMax;

        Slider condThresh, precipRate, valleyRainBoost, rainShadowSupression;
        Slider recomb;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            debugField = new EnumField("Display Mode", node.debugMode);
            debugField.value = node.debugMode;
            debugField.RegisterValueChangedCallback(
                e =>
                {
                    node.debugMode = (MoistureAdvectionNode.eDebugViz)e.newValue;
                    node.ProcessFlowMap();
                });
            controlsContainer.Add(debugField);

            iterations = new SliderInt("Iterations", 1, 32);
            iterations.value = node.iterations;
            iterations.RegisterValueChangedCallback(
                e =>
                {
                    node.iterations = e.newValue;
                    node.ProcessFlowMap();
                });
            controlsContainer.Add(iterations);

            stepSize = new Slider("Step Size", 0.1f, 2f);
            stepSize.value = node.stepSize;
            stepSize.RegisterValueChangedCallback(
                e =>
                {
                    node.stepSize = e.newValue;
                    node.ProcessFlowMap();
                });
            controlsContainer.Add(stepSize);

            valleyPull = new Slider("Valley Pull", 0f, 1f);
            valleyPull.value = node.valleyPull;
            valleyPull.RegisterValueChangedCallback(
                e =>
                {
                    node.valleyPull = e.newValue;
                    node.ProcessFlowMap();
                });
            controlsContainer.Add(valleyPull);

            rainShadow = new Slider("Rain Shadow Strength", 0f, 1f);
            rainShadow.value = node.rainShadowStrength;
            rainShadow.RegisterValueChangedCallback(
                e =>
                {
                    node.rainShadowStrength= e.newValue;
                    node.ProcessFlowMap();
                });
            controlsContainer.Add(rainShadow);

            evaporation = new Slider("Evaporation", 0f, 1f);
            evaporation.value = node.evaporation;
            evaporation.RegisterValueChangedCallback(
                e =>
                {
                    node.evaporation= e.newValue;
                    node.ProcessFlowMap();
                });
            controlsContainer.Add(evaporation);

            heightInf = new Slider("Height Influence", 0f, 1f);
            heightInf.value = node.heightInfluence;
            heightInf.RegisterValueChangedCallback(
                e =>
                {
                    node.heightInfluence= e.newValue;
                    node.ProcessFlowMap();
                });
            controlsContainer.Add(heightInf);

            moistMin= new Slider("Moisture Minimum", 0f, 1f);
            moistMin.value = node.moistureMin;
            moistMin.RegisterValueChangedCallback(
                e =>
                {
                    node.moistureMin= e.newValue;
                    node.ProcessFlowMap();
                });
            controlsContainer.Add(moistMin);

            moistMax= new Slider("Moisture Max", 0f, 1f);
            moistMax.value = node.moistureMax;
            moistMax.RegisterValueChangedCallback(
                e =>
                {
                    node.moistureMax= e.newValue;
                    node.ProcessFlowMap();
                });
            controlsContainer.Add(moistMax);

            condThresh = new Slider("Condensation Threshold", 0f, 1f);
            condThresh.value = node.condensationThreshold;
            condThresh.RegisterValueChangedCallback(
                e =>
                {
                    node.condensationThreshold= e.newValue;
                    node.ProcessFlowMap();
                });
            controlsContainer.Add(condThresh);

            precipRate = new Slider("Precipitation Rate", 0f, 2f);
            precipRate.value = node.precipitationRate;
            precipRate.RegisterValueChangedCallback(
                e =>
                {
                    node.precipitationRate= e.newValue;
                    node.ProcessFlowMap();
                });
            controlsContainer.Add(precipRate);

            valleyRainBoost = new Slider("Valley Rain Boost", 0f, 2f);
            valleyRainBoost.value = node.valleyRainBoost;
            valleyRainBoost.RegisterValueChangedCallback(
                e =>
                {
                    node.valleyRainBoost= e.newValue;
                    node.ProcessFlowMap();
                });
            controlsContainer.Add(valleyRainBoost);

            rainShadowSupression = new Slider("Rain Shadow Suppression", 0f, 1f);
            rainShadowSupression.value = node.rainShadowSuppression;
            rainShadowSupression.RegisterValueChangedCallback(
                e =>
                {
                    node.rainShadowSuppression= e.newValue;
                    node.ProcessFlowMap();
                });
            controlsContainer.Add(rainShadowSupression);

            recomb= new Slider("Recombination Factor", 0f, 1f);
            recomb.value = node.recombFactor;
            recomb.RegisterValueChangedCallback(
                e =>
                {
                    node.recombFactor= e.newValue;
                    node.ProcessFlowMap();
                });
            controlsContainer.Add(recomb);

        }
    }
}
