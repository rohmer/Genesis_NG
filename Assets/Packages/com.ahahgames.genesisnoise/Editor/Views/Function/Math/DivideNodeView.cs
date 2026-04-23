using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(DivideNode))]
    public class DivideNodeWiew : GenesisNodeView
    {
        DivideNode divideNode => nodeTarget as DivideNode;
        Label value;
        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            onPortConnected += DivideNodeWiew_onPortConnected;
            onPortDisconnected += DivideNodeWiew_onPortDisconnected;

            nodeTarget.Process();
            nodeTarget.onProcessed += Process;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            value = new Label();
            value.RegisterValueChangedCallback(evt =>
            {
                divideNode.output = evt.newValue;
                NotifyNodeChanged();
            });
            value.SetEnabled(false);

            controlsContainer.Add(value);
        }

        private void DivideNodeWiew_onPortDisconnected(PortView obj)
        {
            value.SetEnabled(false);
        }

        private void DivideNodeWiew_onPortConnected(PortView obj)
        {
            divideNode.Process();
            value.SetEnabled(true);
            if (divideNode.output != null)
                value.text = divideNode.output.ToString();
        }

        void Process()
        {
            if (divideNode.output == null)
            {
                value.text = "null";
                value.SetEnabled(false);
                return;
            }
            value.text = divideNode.output.ToString();
            value.SetEnabled(true);
        }
        void UpdateLabel()
        {
            divideNode.Process();
            if (divideNode.output == null)
            {
                value.text = "null";
                return;
            }
            value.text = divideNode.output.ToString();

        }
    }
}
