using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(Vector3Node))]
    public class Vector3NodeView : GenesisNodeView
    {
        Vector3Node node => nodeTarget as Vector3Node;
        Vector3Field editorField;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            editorField = new Vector3Field();
            editorField.RegisterValueChangedCallback(evt =>
            {
                node.output = evt.newValue;
                node.X = evt.newValue.x;
                node.Y = evt.newValue.y;
                node.Z = evt.newValue.z;
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
