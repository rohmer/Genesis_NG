using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(Vector2Node))]
    public class Vector2NodeView : GenesisNodeView
    {
        Vector2Node node => nodeTarget as Vector2Node;
        Vector2Field editorField;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            editorField = new Vector2Field();
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
