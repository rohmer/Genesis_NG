using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(Vector4Node))]
    public class Vector4NodeView : GenesisNodeView
    {
        Vector4Node node => nodeTarget as Vector4Node;
        Vector4Field editorField;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            editorField = new Vector4Field();
            editorField.RegisterValueChangedCallback(evt =>
            {
                node.output = evt.newValue;
                node.X = evt.newValue.x;
                node.Y = evt.newValue.y;
                node.Z = evt.newValue.z;
                node.W = evt.newValue.w;
                NotifyNodeChanged();
            });
            editorField.label = "Value: ";

            editorField.Q<Label>().style.minWidth = 25;
            controlsContainer.Add(editorField);
        }

        void UpdateLabel()
        {
            editorField.value = node.output;
        }
    }
}
