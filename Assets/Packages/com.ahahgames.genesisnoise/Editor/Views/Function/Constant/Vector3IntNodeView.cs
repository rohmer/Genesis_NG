using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(Vector3IntNode))]
    public class Vector3IntNodeView : GenesisNodeView
    {
        Vector3IntNode node => nodeTarget as Vector3IntNode;
        Vector3IntField editorField;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            editorField = new Vector3IntField();
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
