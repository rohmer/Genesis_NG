using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEditor.UIElements;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(Texture2DNode))]
    public class Texture2DNodeView : GenesisNodeView
    {
        Texture2DNode node => nodeTarget as Texture2DNode;
        ObjectField objField;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            objField = new ObjectField();
            objField.objectType = typeof(Texture2D);
            objField.RegisterCallback<ChangeEvent<UnityEngine.Object>>(evt =>
            {
                node.output = (Texture2D)evt.newValue;
                ForceUpdatePorts();
            });
            objField.label = "Value: ";

            controlsContainer.Add(objField);
        }

        void UpdateLabel()
        {
            objField.value = node.output;
        }
    }
}
