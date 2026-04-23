using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(ToBoolNode))]
    public class ToBoolNodeView : GenesisNodeView
    {
        ToBoolNode boolNode => nodeTarget as ToBoolNode;
        Toggle toggle;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.Process();
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            toggle = new Toggle();
            toggle.RegisterValueChangedCallback(evt =>
            {
                boolNode.output = evt.newValue;
                NotifyNodeChanged();
            });
            toggle.label = "Value: ";
            toggle.SetEnabled(false);

            controlsContainer.Add(toggle);
        }

        void UpdateLabel()
        {
            boolNode.Process();
            toggle.value = boolNode.output;
        }
    }
}
