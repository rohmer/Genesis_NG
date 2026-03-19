using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(BoolNode))]
    public class BoolNodeView : GenesisNodeView
    {
        BoolNode boolNode => nodeTarget as BoolNode;
        Toggle toggle;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            nodeTarget.onProcessed += NodeTarget_onProcessed;

            toggle = new Toggle();
            toggle.RegisterValueChangedCallback(evt =>
            {
                boolNode.output = evt.newValue;
                boolNode.UpdateAllPorts();
                boolNode.outputPorts[0].PushData();
                NotifyNodeChanged();
            });
            toggle.label = "Value: ";

            controlsContainer.Add(toggle);
        }

        private void NodeTarget_onProcessed()
        {
            UpdateLabel();
        }

        void UpdateLabel()
        {
            toggle.value = boolNode.output;
        }
    }
}
