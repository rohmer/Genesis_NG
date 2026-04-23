using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(ToVector2IntNode))]
    public class ToVector2IntNodeView : GenesisNodeView
    {
        ToVector2IntNode node => nodeTarget as ToVector2IntNode;
        Vector2IntField field;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.Process();
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            field = new Vector2IntField("Value: ");
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
