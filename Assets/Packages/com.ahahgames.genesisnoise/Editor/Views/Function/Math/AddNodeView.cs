using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(AddNode))]
    public class AddNodeWiew : GenesisNodeView
    {
        AddNode addNode => nodeTarget as AddNode;
        DisplayValue displayValue;
        public override void Enable(bool fromInspector)
        {
            onPortConnected += AddNodeWiew_onPortConnected;
            onPortDisconnected += AddNodeWiew_onPortDisconnected;

            base.Enable(fromInspector);
            nodeTarget.Process();
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();

            onPortDisconnected += (p) => UpdateLabel();
            displayValue = new DisplayValue(controlsContainer, typeof(string), "Value");
        }

        private void AddNodeWiew_onPortDisconnected(PortView obj)
        {
            addNode.Process();
            if (addNode.output != null)
            {
                displayValue.SetValue(addNode.output);
            }
        }

        private void AddNodeWiew_onPortConnected(PortView obj)
        {
            addNode.Process();
            if (addNode.output != null)
            {
                displayValue.SetValue(addNode.output);
            }
        }

        void UpdateLabel()
        {
            addNode.Process();
            if (addNode.output == null)
            {
                displayValue.SetValue("null");
                return;
            }
            displayValue.SetValue(addNode.output);
        }
    }
}
