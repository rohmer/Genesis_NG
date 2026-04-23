using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(Vector2IntNode))]
    public class Vector2IntNodeView : GenesisNodeView
    {
        Vector2IntNode node => nodeTarget as Vector2IntNode;
        Vector2IntField editorField;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            editorField = new Vector2IntField();
            editorField.RegisterValueChangedCallback(evt =>
            {
                node.output = evt.newValue;
                node.X = evt.newValue.x;
                node.Y = evt.newValue.y;
                NotifyNodeChanged();
            });
            editorField.label = "Value: ";

            controlsContainer.Add(editorField);
        }

        void UpdateLabel()
        {
            editorField.value = node.output;
        }
    }
}
