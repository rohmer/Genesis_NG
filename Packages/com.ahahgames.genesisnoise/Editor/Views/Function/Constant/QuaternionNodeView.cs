using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(QuaternionNode))]
    public class QuaternionNodeView : GenesisNodeView
    {
        QuaternionNode node => nodeTarget as QuaternionNode;
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
                node.output = new UnityEngine.Quaternion(evt.newValue.x, evt.newValue.y, evt.newValue.z, evt.newValue.w);
                node.X = node.output.x;
                node.Y = node.output.y;
                node.Z = node.output.z;
                node.W = node.output.w;
                NotifyNodeChanged();
            });
            editorField.label = "Value: ";
            editorField.Q<Label>().style.minWidth = 25;
            controlsContainer.Add(editorField);
        }

        void UpdateLabel()
        {
            editorField.value = new UnityEngine.Vector4(node.output.x, node.output.y, node.output.z, node.output.w);
        }
    }
}
