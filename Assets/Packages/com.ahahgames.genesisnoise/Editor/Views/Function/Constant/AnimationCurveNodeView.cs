using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEditor.UIElements;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(AnimationCurveNode))]
    public class AnimationCurveNodeView : GenesisNodeView
    {
        AnimationCurveNode acNode => nodeTarget as AnimationCurveNode;
        CurveField curveField;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            nodeTarget.onProcessed += NodeTarget_onProcessed;

            curveField = new CurveField();
            curveField.RegisterValueChangedCallback(evt =>
            {
                acNode.output = evt.newValue;
                acNode.UpdateAllPorts();
                acNode.outputPorts[0].PushData();
                NotifyNodeChanged();
            });

            controlsContainer.Add(curveField);
        }

        private void NodeTarget_onProcessed()
        {
            UpdateLabel();
        }

        void UpdateLabel()
        {
            curveField.value = acNode.output;
        }
    }
}
