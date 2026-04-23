using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(VelvetNoisePointsNode))]
    public class VelvetNoisePointsNodeView : GenesisNodeView
    {
        VelvetNoisePointsNode node => nodeTarget as VelvetNoisePointsNode;

        IntegerField countField;
        TextField coordinatesField;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);

            countField = new IntegerField("Point Count");
            countField.SetEnabled(false);

            coordinatesField = new TextField("UV Coordinates")
            {
                multiline = true,
            };
            coordinatesField.SetEnabled(false);
            coordinatesField.style.height = 160;

            controlsContainer.Add(countField);
            controlsContainer.Add(coordinatesField);

            nodeTarget.onProcessed += RefreshOutputs;
            RefreshOutputs();
        }

        public override void Disable()
        {
            nodeTarget.onProcessed -= RefreshOutputs;
            base.Disable();
        }

        void RefreshOutputs()
        {
            if (node == null)
                return;

            countField?.SetValueWithoutNotify(node.pointCount);
            coordinatesField?.SetValueWithoutNotify(node.GetCoordinatesText());
        }
    }
}
