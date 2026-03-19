using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(DebugNode))]
    public class DebugNodeView : GenesisNodeView
    {
        DebugNode node => nodeTarget as DebugNode;
        TextField debugValue;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            onPortConnected += DebugNodeView_onPortConnected;
            onPortDisconnected += DebugNodeView_onPortDisconnected;
            nodeTarget.onProcessed += NodeTarget_onProcessed;

            if (debugValue == null)
            {
                debugValue = new TextField();
                debugValue.SetEnabled(false);
                debugValue.label = "Value:";
                this.contentContainer.Add(debugValue);
            }
        }

        private void NodeTarget_onProcessed()
        {
            debugValue.value = node.value;
        }


        private void DebugNodeView_onPortDisconnected(PortView obj)
        {
            node.Update();
            this.RefreshPorts();
            debugValue.value = "Disconnected";
        }

        private void DebugNodeView_onPortConnected(PortView obj)
        {
            node.Update();
            this.RefreshPorts();
            debugValue.value = node.value;
        }
    }
}