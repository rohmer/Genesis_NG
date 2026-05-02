using GraphProcessor;

using System;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Begins a while-loop flow block.

The loop body only runs while the condition is already true before the first iteration, and it continues while the condition stays true and the max-iteration safety cap is not reached.
")]
    [System.Serializable, NodeMenuItem("Conditional/While Start"), NodeMenuItem("Conditional/While")]
    public class WhileStart : GenesisNode, ILoopStart
    {
        [Input]
        public object input;

        [Input("Condition")]
        public bool condition = false;

        [Input("Max Iterations")]
        public int maxIterations = 32;

        [Output]
        public object output;

        [System.NonSerialized]
        [Output("Index")]
        public int index = 0;

        [Output("Max Iterations")]
        public int outputMaxIterations = 0;

        [HideInInspector, SerializeField]
        internal SerializableType inputType = new(typeof(object));

        [NonSerialized]
        bool continueLoop;

        public override string name => "While Start";
        public override string NodeGroup => "Conditional";
        public override bool hasPreview => false;
        public override bool hasSettings => false;
        public override bool showDefaultInspector => true;
        public override float nodeWidth => GenesisNoiseUtility.smallNodeWidth;

        public object CurrentLoopValue
        {
            get => output;
            set => output = value;
        }

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
            index++;
            return true;
        }

        public void UpdateLoopState()
        {
            if (inputPorts != null && inputPorts.Count > 0)
                inputPorts.PullDatas();

            outputMaxIterations = maxIterations;
            continueLoop = condition && index < maxIterations;
        }

        public bool IsLastIteration() => !continueLoop;

        public bool CanEnterLoop() => condition && maxIterations > 0;

        public Type GetLoopValueType() => inputType.type;

        public void PrepareLoopStart()
        {
            if (inputPorts != null && inputPorts.Count > 0)
                inputPorts.PullDatas();

            index = 0;
            output = input;
            outputMaxIterations = maxIterations;
            continueLoop = condition && maxIterations > 0;
        }
    }
}
