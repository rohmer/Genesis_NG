using GraphProcessor;

using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Conditionally outputs either the true of false value depending on the condition value.
")]

    [System.Serializable, NodeMenuItem("Conditional/Branch"), NodeMenuItem("Conditional/If")]
    public class Branch : GenesisNode
    {
        [Input]
        public object inputTrue;

        [Input]
        public object inputFalse;

        [Input]
        public bool condition;

        [Output]
        public object output;

        [HideInInspector, SerializeField]
        SerializableType inputType = new(typeof(object));

        public override string name => "Branch";

        public override string NodeGroup => "Conditional";
        public override bool hasPreview => false;
        public override bool showDefaultInspector => true;

        [CustomPortBehavior(nameof(inputTrue))]
        public IEnumerable<PortData> InputPortTypeTrue(List<SerializableEdge> edges)
        {
            yield return GenesisNoiseUtility.UpdateInputPortType(ref inputType, "True", edges);
        }

        [CustomPortBehavior(nameof(inputFalse))]
        public IEnumerable<PortData> InputPortTypeFalse(List<SerializableEdge> edges)
        {
            yield return GenesisNoiseUtility.UpdateInputPortType(ref inputType, "False", edges);
        }

        [CustomPortBehavior(nameof(output))]
        public IEnumerable<PortData> OutputTruePortType(List<SerializableEdge> edges)
        {
            yield return new PortData
            {
                identifier = nameof(inputTrue),
                displayName = "Result",
                acceptMultipleEdges = true,
                displayType = inputType.type,
            };
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            output = condition ? inputTrue : inputFalse;

            return true;
        }
    }
}