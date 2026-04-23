using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(MultiplyNode))]
    public class MultiplyNodeWiew : GenesisNodeView
    {
        MultiplyNode multiplyNode => nodeTarget as MultiplyNode;
        Label value;
        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            onPortConnected += MultiplyNodeWiew_onPortConnected;
            onPortDisconnected += MultiplyNodeWiew_onPortDisconnected;

            nodeTarget.Process();
            nodeTarget.onProcessed += Process;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            value = new Label();
            value.RegisterValueChangedCallback(evt =>
            {
                multiplyNode.output = evt.newValue;
                NotifyNodeChanged();
            });
            value.SetEnabled(false);

            controlsContainer.Add(value);
        }

        private void MultiplyNodeWiew_onPortDisconnected(PortView obj)
        {
            value.SetEnabled(false);
        }

        private void MultiplyNodeWiew_onPortConnected(PortView obj)
        {
            multiplyNode.Process();
            value.SetEnabled(true);
            if (multiplyNode.output != null)
                value.text = multiplyNode.output.ToString();
        }


        void Process()
        {
            multiplyNode.Process();
            if (multiplyNode.output == null)
            {
                value.text = "null";
                return;
            }
            value.text = multiplyNode.output.ToString();
        }
        void UpdateLabel()
        {
            multiplyNode.Process();
            if (multiplyNode.output == null)
            {
                value.text = "null";
                return;
            }
            value.text = multiplyNode.output.ToString();
        }
    }
}
