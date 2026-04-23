using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(ToVector3Node))]
    public class ToVector3NodeView : GenesisNodeView
    {
        ToVector3Node node => nodeTarget as ToVector3Node;
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
                NotifyNodeChanged();
            });
            field.SetEnabled(false);

            controlsContainer.Add(field);
        }

        void UpdateLabel()
        {
            node.Process();
            field.value = node.output;
        }
    }
}
