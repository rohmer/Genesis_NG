using AhahGames.GenesisNoise.Graph;

using GraphProcessor;

using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Passes the input through and skips the rest of the current loop iteration when the condition is true.

Place this node on the loop's main value path when you want its input to become the loop end value for the continued iteration.
")]
    [System.Serializable, NodeMenuItem("Conditional/Continue")]
    public class ContinueNode : GenesisNode
    {
        [Input]
        public object input;

        [Input("Condition")]
        public bool condition = true;

        [Output]
        public object output;

        [SerializeField, HideInInspector]
        SerializableType inputType = new(typeof(object));

        public override string name => "Continue";
        public override string NodeGroup => "Conditional";
        public override bool hasPreview => false;
        public override bool hasSettings => false;
        public override bool showDefaultInspector => true;
        public override float nodeWidth => GenesisNoiseUtility.smallNodeWidth;

        [CustomPortBehavior(nameof(input))]
        public IEnumerable<PortData> InputPortType(List<SerializableEdge> edges)
        {
            yield return GenesisNoiseUtility.UpdateInputPortType(ref inputType, "Input", edges);
        }

        [CustomPortBehavior(nameof(output))]
        public IEnumerable<PortData> OutputPortType(List<SerializableEdge> edges)
        {
            yield return new PortData
            {
                identifier = nameof(output),
                displayName = "Output",
                acceptMultipleEdges = true,
                displayType = inputType.type,
            };
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            output = input;

            if (condition && graph != null)
                GenesisGraphProcessor.GetOrCreate(graph)?.RequestLoopControl(LoopControlSignal.Continue);

            return true;
        }
    }
}
