using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEditor.UIElements;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(ToColorNode))]
    public class ToColorNodeView : GenesisNodeView
    {
        ToColorNode node => nodeTarget as ToColorNode;
        ColorField field;


        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.Process();
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            field = new ColorField("Color: ");
            field.RegisterValueChangedCallback(evt =>
            {
                node.output = evt.newValue;
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
