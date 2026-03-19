using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(ToVector2Node))]
    public class ToVector2NodeView : GenesisNodeView
    {
        ToVector2Node node => nodeTarget as ToVector2Node;
        Vector2Field field;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.Process();
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            field = new Vector2Field("Value: ");
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
