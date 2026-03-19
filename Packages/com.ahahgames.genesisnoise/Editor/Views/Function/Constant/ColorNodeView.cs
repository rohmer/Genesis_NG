using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEditor.UIElements;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(ColorNode))]
    public class ColorNodeView : GenesisNodeView
    {
        ColorNode colorNode => nodeTarget as ColorNode;
        ColorField color;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            nodeTarget.onProcessed += NodeTarget_onProcessed;
            color = new ColorField();
            color.RegisterValueChangedCallback(evt =>
            {
                colorNode.output = evt.newValue;
                colorNode.Red = evt.newValue.r;
                colorNode.Green = evt.newValue.g;
                colorNode.Blue = evt.newValue.b;
                colorNode.Alpha = evt.newValue.a;
                NotifyNodeChanged();
            });

            controlsContainer.Add(color);
        }

        private void NodeTarget_onProcessed()
        {
            UpdateLabel();
        }

        void UpdateLabel()
        {
            color.value = colorNode.output;
        }
    }
}
