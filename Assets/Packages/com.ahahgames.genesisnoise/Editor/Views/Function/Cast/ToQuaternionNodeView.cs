using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(ToQuaternionNode))]
    public class ToQuaternionNodeView : GenesisNodeView
    {
        ToQuaternionNode node => nodeTarget as ToQuaternionNode;
        Vector3Field field;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.Process();
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            field = new Vector3Field("Value: ");
            field.RegisterValueChangedCallback(evt =>
            {
                node.output = UnityEngine.Quaternion.Euler(node.EulerX, node.EulerY, node.EulerZ);
                NotifyNodeChanged();
            });
            field.SetEnabled(false);

            controlsContainer.Add(field);
        }

        void UpdateLabel()
        {
            node.Process();
            field.value = new UnityEngine.Vector3(node.EulerX, node.EulerY, node.EulerZ);
        }
    }
}
