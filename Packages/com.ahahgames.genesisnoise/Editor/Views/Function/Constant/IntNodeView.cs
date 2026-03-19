using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(IntNode))]
    public class IntNodeView : GenesisNodeView
    {
        IntNode node => nodeTarget as IntNode;
        IntegerField editorField;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            editorField = new IntegerField();
            editorField.RegisterValueChangedCallback(evt =>
            {
                node.output = evt.newValue;
                node.UpdateAllPorts();
                NotifyNodeChanged();
            });
            editorField.label = "Value: ";

            controlsContainer.Add(editorField);
        }

        void UpdateLabel()
        {
            editorField.value = node.output;
            node.UpdateAllPorts();
        }
    }
}
