using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(RandomFloatNode))]
    public class RandomFloatNodeView : GenesisNodeView
    {
        RandomFloatNode node => nodeTarget as RandomFloatNode;
        FloatField min, max;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            node.Process();
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            min = new FloatField();
            min.value = node.min;
            min.RegisterValueChangedCallback(evt =>
            {
                node.min = evt.newValue;
                node.Process();
                NotifyNodeChanged();
            });
            min.label = "Minimum: ";
            controlsContainer.Add(min);
            max = new FloatField();
            max.value = node.max;
            max.RegisterValueChangedCallback(evt =>
            {
                node.max = evt.newValue;
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
