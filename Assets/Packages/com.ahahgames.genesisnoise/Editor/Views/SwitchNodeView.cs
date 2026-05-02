using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(SwitchNode))]
    public class SwitchNodeView : GenesisNodeView
    {
        SwitchNode node => nodeTarget as SwitchNode;

        IntegerField caseCountField;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);

            caseCountField = new IntegerField("Case Count")
            {
                isDelayed = true,
            };
            caseCountField.SetValueWithoutNotify(node.CaseCount);
            caseCountField.RegisterValueChangedCallback(OnCaseCountChanged);

            controlsContainer.Add(caseCountField);
        }

        public override void Disable()
        {
            if (caseCountField != null)
                caseCountField.UnregisterValueChangedCallback(OnCaseCountChanged);

            base.Disable();
        }

        void OnCaseCountChanged(ChangeEvent<int> evt)
        {
            if (node == null)
                return;

            int clampedValue = evt.newValue < 1 ? 1 : evt.newValue;
            if (clampedValue != evt.newValue)
                caseCountField.SetValueWithoutNotify(clampedValue);

            if (clampedValue == node.CaseCount)
                return;

            node.SetCaseCount(clampedValue);
            node.UpdateAllPorts();
            RefreshPorts();
            NotifyNodeChanged();
        }
    }
}
