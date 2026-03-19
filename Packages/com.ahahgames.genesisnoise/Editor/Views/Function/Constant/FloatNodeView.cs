using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(FloatNode))]
    public class FloatNodeView : GenesisNodeView
    {
        FloatNode node => nodeTarget as FloatNode;
        FloatField editorField;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            nodeTarget.onProcessed += NodeTarget_onProcessed;
            editorField = new FloatField();
            editorField.RegisterValueChangedCallback(evt =>
            {
                node.output = evt.newValue;
                NotifyNodeChanged();
            });
            editorField.label = "Value: ";

            controlsContainer.Add(editorField);
        }

        private void NodeTarget_onProcessed()
        {
            UpdateLabel();
        }

        void UpdateLabel()
        {
            editorField.value = node.output;
        }
    }
}
