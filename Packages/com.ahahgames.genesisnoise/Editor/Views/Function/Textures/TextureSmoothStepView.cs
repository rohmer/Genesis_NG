using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(SmoothStepTexture))]
    public class SmoothStepTextureView : GenesisNodeView
    {
        SmoothStepTexture node => nodeTarget as SmoothStepTexture;
        FloatField min, max;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            node.Process();
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            min = new FloatField();
            min.value = node.LowerBound;
            min.RegisterValueChangedCallback(evt =>
            {
                node.LowerBound = evt.newValue;
                node.Process();
                NotifyNodeChanged();
            });
            min.label = "Minimum: ";
            controlsContainer.Add(min);
            max = new FloatField();
            max.value = node.UpperBound;
            max.RegisterValueChangedCallback(evt =>
            {
                node.UpperBound= evt.newValue;
                node.Process();
                NotifyNodeChanged();
            });
            max.label = "Maximum: ";
            controlsContainer.Add(max);
        }

        void UpdateLabel()
        {
            node.Process();
        }
    }
}
