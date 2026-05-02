using GraphProcessor;

using System;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Selects one of several case inputs by matching the selection value's text against named case labels.

This is useful for enum-like branching where the incoming selection value can be converted to a readable label with ToString().
")]
    [System.Serializable, NodeMenuItem("Conditional/Enum Switch")]
    public class EnumSwitchNode : GenesisNode
    {
        const int defaultCaseCount = 3;
        const int minimumCaseCount = 1;

        [Input("Selection")]
        public object selection;

        [Input("Default")]
        public object defaultInput;

        [Input, SerializeField, HideInInspector]
        public List<object> caseInputs = new() { null, null, null };

        [Output("Result")]
        public object output;

        [SerializeField, HideInInspector]
        int caseCount = defaultCaseCount;

        [SerializeField, HideInInspector]
        List<string> caseLabels = new() { "Case 0", "Case 1", "Case 2" };

        [SerializeField, HideInInspector]
        SerializableType inputType = new(typeof(object));

        public override string name => "Enum Switch";
        public override string NodeGroup => "Conditional";
        public override bool hasPreview => false;
        public override bool hasSettings => false;
        public override bool showDefaultInspector => true;

        public int CaseCount => caseCount;

        public override void OnNodeCreated()
        {
            base.OnNodeCreated();
            SyncCaseData();
        }

        protected override void Enable()
        {
            base.Enable();
            SyncCaseData();
        }

        public void SetCaseCount(int value)
        {
            caseCount = Mathf.Max(minimumCaseCount, value);
            SyncCaseData();
        }

        public string GetCaseLabel(int index)
        {
            SyncCaseData();
            return index >= 0 && index < caseLabels.Count ? caseLabels[index] : $"Case {index}";
        }

        public void SetCaseLabel(int index, string label)
        {
            SyncCaseData();
            if (index < 0 || index >= caseLabels.Count)
                return;

            caseLabels[index] = string.IsNullOrWhiteSpace(label) ? $"Case {index}" : label.Trim();
        }

        [CustomPortBehavior(nameof(defaultInput))]
        public IEnumerable<PortData> DefaultInputPortType(List<SerializableEdge> edges)
        {
            yield return CreateValuePortData("Default", nameof(defaultInput), edges);
        }

        [CustomPortBehavior(nameof(caseInputs))]
        public IEnumerable<PortData> CaseInputPortType(List<SerializableEdge> edges)
        {
            SyncCaseData();
            inputType.type = ResolveValueInputType(edges);

            for (int i = 0; i < caseCount; i++)
            {
                yield return new PortData
                {
                    identifier = GetCaseIdentifier(i),
                    displayName = GetDisplayLabel(i),
                    acceptMultipleEdges = false,
                    displayType = inputType.type,
                };
            }
        }

        [CustomPortBehavior(nameof(output))]
        public IEnumerable<PortData> OutputPortType(List<SerializableEdge> edges)
        {
            yield return new PortData
            {
                identifier = nameof(output),
                displayName = "Result",
                acceptMultipleEdges = true,
                displayType = inputType.type,
            };
        }

        [CustomPortInput(nameof(caseInputs), typeof(object), true)]
        public void PullCaseInputs(List<SerializableEdge> edges, NodePort inputPort)
        {
            SyncCaseData();

            if (inputPort == null || !TryGetCaseIndex(inputPort.portData.identifier, out int caseIndex))
                return;

            if (caseIndex < 0 || caseIndex >= caseInputs.Count)
                return;

            caseInputs[caseIndex] = edges.Count > 0 ? edges[0].passThroughBuffer : null;
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            SyncCaseData();

            string selectionLabel = selection?.ToString();
            int caseIndex = caseLabels.FindIndex(label => string.Equals(label, selectionLabel, StringComparison.Ordinal));
            output = caseIndex >= 0 && caseIndex < caseInputs.Count ? caseInputs[caseIndex] : defaultInput;

            return true;
        }

        internal void SyncCaseData()
        {
            caseCount = Mathf.Max(minimumCaseCount, caseCount);
            caseInputs ??= new List<object>();
            caseLabels ??= new List<string>();

            while (caseInputs.Count < caseCount)
                caseInputs.Add(null);

            while (caseInputs.Count > caseCount)
                caseInputs.RemoveAt(caseInputs.Count - 1);

            while (caseLabels.Count < caseCount)
                caseLabels.Add($"Case {caseLabels.Count}");

            while (caseLabels.Count > caseCount)
                caseLabels.RemoveAt(caseLabels.Count - 1);

            for (int i = 0; i < caseLabels.Count; i++)
            {
                if (string.IsNullOrWhiteSpace(caseLabels[i]))
                    caseLabels[i] = $"Case {i}";
            }
        }

        string GetDisplayLabel(int index)
        {
            string label = GetCaseLabel(index);
            return string.IsNullOrWhiteSpace(label) ? $"Case {index}" : label;
        }

        PortData CreateValuePortData(string displayName, string identifier, List<SerializableEdge> edges)
        {
            inputType.type = ResolveValueInputType(edges);

            return new PortData
            {
                identifier = identifier,
                displayName = displayName,
                acceptMultipleEdges = false,
                displayType = inputType.type,
            };
        }

        Type ResolveValueInputType(List<SerializableEdge> edges)
        {
            if (TryGetConnectedPortType(edges, out Type resolvedType))
                return resolvedType;

            if (inputPorts != null)
            {
                foreach (var port in inputPorts)
                {
                    if (port.fieldName != nameof(defaultInput) && port.fieldName != nameof(caseInputs))
                        continue;

                    if (TryGetConnectedPortType(port.GetEdges(), out resolvedType))
                        return resolvedType;
                }
            }

            return typeof(object);
        }

        static bool TryGetConnectedPortType(List<SerializableEdge> edges, out Type resolvedType)
        {
            if (edges != null && edges.Count > 0)
            {
                var edge = edges[0];
                resolvedType = edge.outputPort.portData.displayType ?? edge.outputPort.fieldInfo.FieldType;
                return resolvedType != null;
            }

            resolvedType = null;
            return false;
        }

        static string GetCaseIdentifier(int index) => $"Case_{index}";

        static bool TryGetCaseIndex(string identifier, out int caseIndex)
        {
            caseIndex = -1;

            if (string.IsNullOrEmpty(identifier) || !identifier.StartsWith("Case_", StringComparison.Ordinal))
                return false;

            return int.TryParse(identifier.Substring("Case_".Length), out caseIndex);
        }
    }
}
