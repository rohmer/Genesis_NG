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
    [NodeCustomEditor(typeof(HydraulicErosionNode))]
    public class HydraulicErosionNodeView : GenesisNodeView
    {
        HydraulicErosionNode node => nodeTarget as HydraulicErosionNode;
        SliderInt iterations;
        Slider gravity, damping, erodeRate, depositRate, capacity, evaporation;


        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);           
            
            iterations= new SliderInt("Iterations", 1, 10);
            iterations.value = node.iterations;
            iterations.showInputField = true;
            iterations.RegisterCallback<ChangeEvent<int>>(
                e=>
                {
                    node.iterations = e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(iterations);
            
            
            gravity = new Slider("Gravity", 1f, 30.0f);
            gravity.value = node.gravity;
            gravity.showInputField = true;
            gravity.RegisterCallback<ChangeEvent<float>>(
                e =>
                {
                    node.gravity = e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(gravity);

            damping = new Slider("Velocity Damping", 0.01f, 1.0f);
            damping.value = node.damping;
            damping.showInputField = true;
            damping.RegisterCallback<ChangeEvent<float>>(
                e =>
                {
                    node.damping = e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(damping);

            erodeRate = new Slider("Erode Rate", 0.01f,1f);
            erodeRate.value = node.erodeRate;
            erodeRate.showInputField = true;
            erodeRate.RegisterCallback<ChangeEvent<float>>(
                e =>
                {
                    node.erodeRate = e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(erodeRate);

            depositRate = new Slider("Deposit Rate", 0.01f, 1f);
            depositRate.value = node.deposit;
            depositRate.showInputField = true;
            depositRate.RegisterCallback<ChangeEvent<float>>(
                e =>
                {
                    node.deposit = e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(depositRate);

            capacity = new Slider("Sediment Capacity", 0.1f, 2f);
            capacity.value = node.capacity;
            capacity.showInputField = true;
            capacity.RegisterCallback<ChangeEvent<float>>(
                e =>
                {
                    node.capacity= e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(capacity);

            evaporation = new Slider("Evaporation", 0.001f, 1f);
            evaporation.value = node.evaportation;
            evaporation.showInputField = true;
            evaporation.RegisterCallback<ChangeEvent<float>>(
                e =>
                {
                    node.evaportation= e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(evaporation);


        }


    }
}
