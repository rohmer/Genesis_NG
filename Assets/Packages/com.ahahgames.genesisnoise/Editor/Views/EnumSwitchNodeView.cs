using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(EnumSwitchNode))]
    public class EnumSwitchNodeView : GenesisNodeView
    {
        EnumSwitchNode node => nodeTarget as EnumSwitchNode;

        IntegerField caseCountField;
        VisualElement caseLabelsContainer;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);

            caseCountField = new IntegerField("Case Count")
            {
                isDelayed = true,
            };
            caseCountField.SetValueWithoutNotify(node.CaseCount);
            caseCountField.RegisterValueChangedCallback(OnCaseCountChanged);

            caseLabelsContainer = new VisualElement();

            controlsContainer.Add(caseCountField);
            controlsContainer.Add(caseLabelsContainer);

            RefreshCaseLabels();
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
            RefreshCaseLabels();
            NotifyNodeChanged();
        }

        void RefreshCaseLabels()
        {
            if (caseLabelsContainer == null || node == null)
                return;

            caseLabelsContainer.Clear();

            for (int i = 0; i < node.CaseCount; i++)
            {
                int caseIndex = i;
                var labelField = new TextField($"Label {caseIndex}");
                labelField.SetValueWithoutNotify(node.GetCaseLabel(caseIndex));
                labelField.RegisterValueChangedCallback(evt =>
                {
                    node.SetCaseLabel(caseIndex, evt.newValue);
                    node.UpdateAllPorts();
                    RefreshPorts();
                    NotifyNodeChanged();
                });

                caseLabelsContainer.Add(labelField);
            }
        }
    }
}
