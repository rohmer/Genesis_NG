using AhahGames.GenesisNoise;
using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Closes a loop flow block and aggregates the loop-end input values across iterations.
")]
    [UnityEngine.Scripting.APIUpdating.MovedFrom(false, sourceNamespace: "Genesis", sourceAssembly: "Genesis Noise", sourceClassName: "AggregateEnd")]
    [System.Serializable, NodeMenuItem("Conditional/Aggregate End"), NodeMenuItem("Conditional/Reduce End")]
    public class AggregateEnd : GenesisNode, ILoopEnd
    {
        public enum AggregateMode
        {
            CollectValues = 0,
            FirstValue = 1,
            LastValue = 2,
            CountIterations = 3,
        }

        [Input("Input")]
        public object input;

        [Output("Output")]
        public object output;

        [Output("Count")]
        public int iterationCount;

        public AggregateMode mode = AggregateMode.CollectValues;

        [System.NonSerialized]
        BaseNode loopStartNode;

        [SerializeField, HideInInspector]
        string loopStartGUID;

        [SerializeField, HideInInspector]
        SerializableType inputType = new(typeof(object));

        readonly List<object> values = new();

        public override string name => "Aggregate End";
        public override string NodeGroup => "Conditional";
        public override bool hasPreview => false;
        public override bool hasSettings => false;
        public override bool showDefaultInspector => true;

        protected override void Enable()
        {
            base.Enable();
            onAfterEdgeConnected += EdgeConnectionCallback;
            onAfterEdgeDisconnected += EdgeConnectionCallback;
            RegisterLoopStart();
        }

        void RegisterLoopStart()
        {
            if (loopStartNode == null && !string.IsNullOrEmpty(loopStartGUID) && graph.nodesPerGUID.ContainsKey(loopStartGUID))
                loopStartNode = graph.nodesPerGUID[loopStartGUID];

            if (loopStartNode != null)
            {
                loopStartNode.onAfterEdgeConnected += EdgeConnectionCallback;
                loopStartNode.onAfterEdgeDisconnected += EdgeConnectionCallback;
            }
        }

        void UnregisterLoopStart()
        {
            if (loopStartNode != null)
            {
                loopStartNode.onAfterEdgeConnected -= EdgeConnectionCallback;
                loopStartNode.onAfterEdgeDisconnected -= EdgeConnectionCallback;
            }
        }

        void EdgeConnectionCallback(SerializableEdge edge)
        {
            if (edge.inputPort == inputPorts[0])
            {
                var newLoopStart = FindInDependencies(n => n is ILoopStart);
                if (newLoopStart != loopStartNode)
                {
                    UnregisterLoopStart();
                    loopStartNode = newLoopStart;
                    RegisterLoopStart();
                }
                else
                {
                    loopStartNode = newLoopStart;
                }

                if (loopStartNode != null)
                    loopStartGUID = loopStartNode.GUID;

                UpdateAllPorts();
            }
            else if (loopStartNode != null && loopStartNode.inputPorts.Count > 0 && edge.inputPort == loopStartNode.inputPorts[0])
            {
                UpdateAllPorts();
            }
        }

        [CustomPortBehavior(nameof(input))]
        public IEnumerable<PortData> InputPortType(List<SerializableEdge> edges)
        {
            inputType.type = ResolveInputType(edges);

            yield return new PortData
            {
                identifier = nameof(input),
                displayName = "Input",
                acceptMultipleEdges = false,
                displayType = inputType.type,
            };
        }

        [CustomPortBehavior(nameof(output))]
        public IEnumerable<PortData> OutputPortType(List<SerializableEdge> edges)
        {
            yield return new PortData
            {
                identifier = nameof(output),
                displayName = "Output",
                acceptMultipleEdges = true,
                displayType = typeof(object),
            };
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            values.Add(input);
            iterationCount = values.Count;
            output = input;
            return true;
        }

        public void PrepareLoopEnd(ILoopStart loopStartNode)
        {
            values.Clear();
            iterationCount = 0;
            output = null;
        }

        public void FinalIteration()
        {
            output = BuildAggregateOutput();
        }

        public void ZeroIteration(ILoopStart loopStartNode)
        {
            values.Clear();
            iterationCount = 0;

            output = mode switch
            {
                AggregateMode.CollectValues => new List<object>(),
                AggregateMode.CountIterations => 0,
                _ => loopStartNode?.CurrentLoopValue,
            };
        }

        protected override void Disable()
        {
            UnregisterLoopStart();
            base.Disable();
        }

        object BuildAggregateOutput()
        {
            return mode switch
            {
                AggregateMode.CollectValues => new List<object>(values),
                AggregateMode.FirstValue => values.Count > 0 ? values[0] : null,
                AggregateMode.LastValue => values.Count > 0 ? values[values.Count - 1] : null,
                AggregateMode.CountIterations => iterationCount,
                _ => output,
            };
        }

        Type ResolveInputType(List<SerializableEdge> edges)
        {
            if (edges != null && edges.Count > 0)
            {
                var edge = edges[0];
                return edge.outputPort.portData.displayType ?? edge.outputPort.fieldInfo.FieldType;
            }

            return (loopStartNode as ILoopStart)?.GetLoopValueType() ?? typeof(object);
        }
    }
}
