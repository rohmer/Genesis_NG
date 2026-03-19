using AhahGames.GenesisNoise.GNTerrain.Nodes;
using AhahGames.GenesisNoise.Views;

using GraphProcessor;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.GNTerrain.Views
{
    [NodeCustomEditor(typeof(ThermalErosionNode))]
    public class ThermalErosionNodeView : GenesisNodeView
    {
        ThermalErosionNode node => nodeTarget as ThermalErosionNode;
        SliderInt iterations;
        Slider angle, strength;


        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            iterations = new SliderInt("Iterations", 1, 200);
            iterations.value = node.iterations;
            iterations.showInputField = true;
            iterations.RegisterCallback<ChangeEvent<int>>(
                e =>
                {
                    node.iterations = e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(iterations);

            angle = new Slider("Angle", 0.001f, 0.2f);
            angle.value = node.angle;
            angle.showInputField = true;
            angle.RegisterCallback<ChangeEvent<float>>(
                e =>
                {
                    node.angle = e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(angle);

            strength = new Slider("Strength", 0f, 1f);
            strength.value = node.strength;
            strength.showInputField = true;
            strength.RegisterCallback<ChangeEvent<float>>(
                e =>
                {
                    node.strength = e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(strength);
        }
    }
}