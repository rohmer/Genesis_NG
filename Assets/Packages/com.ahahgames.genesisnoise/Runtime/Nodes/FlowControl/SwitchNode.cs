using GraphProcessor;

using System;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Selects one of several case inputs using an integer selection index.

If the selection is outside the available case range, the default input is returned instead.
")]
    [System.Serializable, NodeMenuItem("Conditional/Switch"), NodeMenuItem("Conditional/Switch Statement")]
    public class SwitchNode : GenesisNode
    {
        const int defaultCaseCount = 3;
        const int minimumCaseCount = 1;

        [Input("Selection")]
        public int selection;

        [Input("Default")]
        public object defaultInput;

        [Input, SerializeField, HideInInspector]
        public List<object> caseInputs = new() { null, null, null };

        [Output("Result")]
        public object output;

        [SerializeField, HideInInspector]
        int caseCount = defaultCaseCount;

        [SerializeField, HideInInspector]
        SerializableType inputType = new(typeof(object));

        public override string name => "Switch";
        public override string NodeGroup => "Conditional";
        public override bool hasPreview => false;
        public override bool hasSettings => false;
        public override bool showDefaultInspector => true;

        public int CaseCount => caseCount;

        public override void OnNodeCreated()
        {
            base.OnNodeCreated();
            SyncCaseInputs();
        }

        protected override void Enable()
        {
            base.Enable();
            SyncCaseInputs();
        }

        public void SetCaseCount(int value)
        {
            caseCount = Mathf.Max(minimumCaseCount, value);
            SyncCaseInputs();
        }

        [CustomPortBehavior(nameof(defaultInput))]
        public IEnumerable<PortData> DefaultInputPortType(List<SerializableEdge> edges)
        {
            yield return CreateValuePortData("Default", nameof(defaultInput), edges);
        }

        [CustomPortBehavior(nameof(caseInputs))]
        public IEnumerable<PortData> CaseInputPortType(List<SerializableEdge> edges)
        {
            SyncCaseInputs();
            inputType.type = ResolveValueInputType(edges);

            for (int i = 0; i < caseCount; i++)
            {
                yield return new PortData
                {
                    identifier = GetCaseIdentifier(i),
                    displayName = $"Case {i}",
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
            SyncCaseInputs();

            if (inputPort == null || !TryGetCaseIndex(inputPort.portData.identifier, out int caseIndex))
                return;

            if (caseIndex < 0 || caseIndex >= caseInputs.Count)
                return;

            caseInputs[caseIndex] = edges.Count > 0 ? edges[0].passThroughBuffer : null;
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            SyncCaseInputs();
            output = GetSelectedValue();
            return true;
        }

        internal void SyncCaseInputs()
        {
            caseCount = Mathf.Max(minimumCaseCount, caseCount);
            caseInputs ??= new List<object>();

            while (caseInputs.Count < caseCount)
                caseInputs.Add(null);

            while (caseInputs.Count > caseCount)
                caseInputs.RemoveAt(caseInputs.Count - 1);
        }

        object GetSelectedValue()
        {
            if (selection >= 0 && selection < caseInputs.Count)
                return caseInputs[selection];

            return defaultInput;
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
