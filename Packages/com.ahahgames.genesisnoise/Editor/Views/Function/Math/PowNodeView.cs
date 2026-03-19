using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(PowNode))]
    public class PowNodeWiew : GenesisNodeView
    {
        PowNode addNode => nodeTarget as PowNode;
        Label value;
        public override void Enable(bool fromInspector)
        {
            onPortConnected += PowNodeWiew_onPortConnected;
            onPortDisconnected += PowNodeWiew_onPortDisconnected;

            base.Enable(fromInspector);
            nodeTarget.Process();
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            value = new Label();
            value.RegisterValueChangedCallback(evt =>
            {
                addNode.output = evt.newValue;
                NotifyNodeChanged();
            });
            value.SetEnabled(false);

            controlsContainer.Add(value);
        }

        private void PowNodeWiew_onPortDisconnected(PortView obj)
        {
            value.SetEnabled(false);
        }

        private void PowNodeWiew_onPortConnected(PortView obj)
        {
            value.SetEnabled(true);
            if (addNode.output != null)
                value.text = addNode.output.ToString();
        }

        void UpdateLabel()
        {
            addNode.Process();
            if (addNode.output == null)
            {
                value.text = "null";
                return;
            }
            value.text = addNode.output.ToString();
        }
    }
}
