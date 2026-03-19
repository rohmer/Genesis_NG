using AhahGames.GenesisNoise.GNTerrain.Nodes;
using AhahGames.GenesisNoise.Views;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.GNTerrain.Views
{
    [NodeCustomEditor(typeof(WindErosionNode))]
    public class WindErosionNodeView : GenesisNodeView
    {
        WindErosionNode node => nodeTarget as WindErosionNode;
        SliderInt iterations, saltationSteps, avalancheIterations;
        Slider erode, talusAngle, dirV, dirH;

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

            dirH = new Slider("Horizontal Direction", -1f, 1f);
            dirH.value = node.direction.x;
            dirH.showInputField = true;
            dirH.RegisterCallback<ChangeEvent<float>>(
                e =>
                {
                    node.direction.x = e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(dirH);

            dirV = new Slider("Vertical Direction", -1f, 1f);
            dirV.value = node.direction.y;
            dirV.showInputField = true;
            dirV.RegisterCallback<ChangeEvent<float>>(
                e =>
                {
                    node.direction.y = e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(dirV);

            erode = new Slider("Erode Rate", 0.01f, 1f);
            erode.value = node.erodeRate;
            erode.showInputField = true;
            erode.RegisterCallback<ChangeEvent<float>>(
                e =>
                {
                    node.erodeRate = e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(erode);

            saltationSteps = new SliderInt("Saltation Steps", 1, 20);
            saltationSteps.value = (int)node.saltationSteps;
            saltationSteps.showInputField = true;
            saltationSteps.RegisterCallback<ChangeEvent<int>>(
                e =>
                {
                    node.saltationSteps = (uint)e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(saltationSteps);

            talusAngle = new Slider("Talus Angle", 0f, 90f);
            talusAngle.value = node.talusAngle;
            talusAngle.showInputField = true;
            talusAngle.RegisterCallback<ChangeEvent<float>>(
                e =>
                {
                    node.talusAngle = e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(talusAngle);

            avalancheIterations = new SliderInt("Avalanche Iterations", 1, 20);
            avalancheIterations.value = node.avalanceIterations;
            avalancheIterations.showInputField = true;
            avalancheIterations.RegisterCallback<ChangeEvent<int>>(
                e =>
                {
                    node.avalanceIterations = e.newValue;
                    node.Erode();
                });
            controlsContainer.Add(avalancheIterations);
        }
    }
}