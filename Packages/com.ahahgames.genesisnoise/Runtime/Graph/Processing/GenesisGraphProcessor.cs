using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System;
using System.Collections.Generic;
using System.Linq;

using UnityEngine;
using UnityEngine.Rendering;


namespace AhahGames.GenesisNoise.Graph
{
    public class ComputeOrderInfo
    {
        public Dictionary<BaseNode, int> forLoopLevel = new();

        public void Clear() => forLoopLevel.Clear();
    }

    public class GenesisGraphProcessor : BaseGraphProcessor, IDisposable
    {
        // A Multiton, oh my god I never thought i'd be writing one in my life
        internal static Dictionary<GenesisGraph, HashSet<GenesisGraphProcessor>> processorInstances = new();

        internal new GenesisGraph graph => base.graph as GenesisGraph;
        public ComputeOrderInfo info { get; private set; } = new ComputeOrderInfo();

        struct ProcessingScope : IDisposable
        {
            GenesisGraphProcessor processor;

            public ProcessingScope(GenesisGraphProcessor processor)
            {
                this.processor = processor;
                processor.isProcessing++;
            }

            public void Dispose() => processor.isProcessing--;
        }

        internal int isProcessing = 0;

        public GenesisGraphProcessor(BaseGraph graph) : base(graph)
        {
            processorInstances.TryGetValue(graph as GenesisGraph, out var hashset);
            if (hashset == null)
                hashset = processorInstances[graph as GenesisGraph] = new HashSet<GenesisGraphProcessor>();

            hashset.Add(this);
        }

        public static GenesisGraphProcessor GetOrCreate(GenesisGraph graph)
        {
            GenesisGraphProcessor.processorInstances.TryGetValue(graph, out var processorSet);
            if (processorSet == null)
                return new GenesisGraphProcessor(graph);
            else
                return processorSet.FirstOrDefault(p => p != null);
        }

        public static void RunOnce(GenesisGraph graph)
        {
            var processor = GetOrCreate(graph);
            processor.Run();
        }

        ~GenesisGraphProcessor() => Dispose();

        public void Dispose() => processorInstances.Remove(graph);

        public override void UpdateComputeOrder()
        {
            // TODO: update infos
            info.Clear();

            var sortedNodes = graph.nodes.Where(n => n.computeOrder >= 0).OrderBy(n => n.computeOrder).ToList();

            int loopIndex = 0;
            foreach (var node in sortedNodes)
            {
                if (node is ILoopStart fs)
                    loopIndex++;
                info.forLoopLevel[node] = loopIndex;
                if (node is ILoopEnd fe)
                    loopIndex--;
            }
        }

        internal void BeforeCustomRenderTextureUpdate(CommandBuffer cmd, CustomRenderTexture crt)
        {
            if (isProcessing == 0)
            {


                // TODO: cache
                // Trigger the graph processing from a CRT update if we weren't processing
                BaseNode node = graph.nodes.FirstOrDefault(n => n is IUseCustomRenderTextureProcessing i && i.GetCustomRenderTextures().Any(c => c == crt));


                // node can be null if the CRT doesn't belong to the graph.
                if (node != null)
                    ProcessGraphOutputs(cmd, new List<BaseNode> { node });
                else // In that case we process the graph output
                    ProcessGraphOutputs(cmd, graph.graphOutputs);
            }
            else
            {
                // We don't do anything
            }
        }

        public static void AddGPUAndCPUBarrier(CommandBuffer currentCmd)
        {
            Graphics.ExecuteCommandBuffer(currentCmd);
            currentCmd.Clear();
        }

        void ProcessGraphOutputs(CommandBuffer cmd, IEnumerable<BaseNode> graphOutputs)
        {
            using (new ProcessingScope(this))
            {
                HashSet<BaseNode> finalNodes = new();

                // Gather all nodes to process:
                foreach (var node in graphOutputs)
                {
                    // TODO: cache node dependencies
                    foreach (var dep in GetNodeDependencies(node))
                    {
                        if (graph.nodes.Contains(dep))
                            finalNodes.Add(dep);
                    }
                }

                ProcessNodeList(cmd, finalNodes);
            }
        }

        void ProcessGraphNodes(CommandBuffer cmd, IEnumerable<BaseNode> nodes)
        {
            using (new ProcessingScope(this))
            {
                HashSet<BaseNode> finalNodes = new();

                // Gather all nodes to process:
                foreach (var node in nodes)
                {
                    // TODO: cache node dependencies
                    foreach (var dep in GetNodeChildren(node))
                    {
                        if (graph.nodes.Contains(dep))
                            finalNodes.Add(dep);
                    }
                }

                ProcessNodeList(cmd, finalNodes);
            }
        }

        List<BaseNode> GetNodeDependencies(BaseNode node)
        {
            HashSet<BaseNode> dependencies = new();
            Stack<BaseNode> inputNodes = new(node.GetInputNodes());

            dependencies.Add(node);

            while (inputNodes.Count > 0)
            {
                var child = inputNodes.Pop();

                if (!dependencies.Add(child))
                    continue;

                foreach (var parent in child.GetInputNodes())
                    inputNodes.Push(parent);


                // Max dependencies on a node, maybe we can put a warning if it's reached?
                if (dependencies.Count > 2000)
                    break;
            }

            return dependencies.OrderBy(d => d.computeOrder).ToList();
        }

        List<BaseNode> GetNodeChildren(BaseNode node)
        {
            HashSet<BaseNode> children = new();
            Stack<BaseNode> outputNodes = new(node.GetOutputNodes());

            children.Add(node);

            while (outputNodes.Count > 0)
            {
                var child = outputNodes.Pop();

                if (!children.Add(child))
                    continue;

                foreach (var parent in child.GetOutputNodes())
                    outputNodes.Push(parent);


                // Max children on a node, maybe we can put a warning if it's reached?
                if (children.Count > 2000)
                    break;
            }

            return children.OrderBy(d => d.computeOrder).ToList();
        }

        void ProcessNodeList(CommandBuffer cmd, HashSet<BaseNode> nodes)
        {
            HashSet<ILoopStart> starts = new();
            HashSet<ILoopEnd> ends = new();
            HashSet<INeedLoopReset> iNeedLoopReset = new();

            // Note that this jump pattern doesn't handle correctly the multiple dependencies a for loop
            // can have and it may cause some nodes to be processed multiple times unnecessarily, depending on the compute order.
            Stack<(ILoopStart node, int index)> jumps = new();

            // TODO: cache?
            var sortedNodes = nodes.Where(n => n.computeOrder >= 0).OrderBy(n => n.computeOrder).ToList();

            int maxLoopCount = 0;
            jumps.Clear();
            starts.Clear();
            ends.Clear();
            iNeedLoopReset.Clear();

            for (int executionIndex = 0; executionIndex < sortedNodes.Count; executionIndex++)
            {
                maxLoopCount++;
                if (maxLoopCount > 10000)
                    return;

                var node = sortedNodes[executionIndex];

                if (node is ILoopStart loopStart)
                {
                    if (!starts.Contains(loopStart))
                    {
                        loopStart.PrepareLoopStart();
                        jumps.Push((loopStart, executionIndex));
                        starts.Add(loopStart);
                    }
                }

                bool finalIteration = false;
                if (node is ILoopEnd loopEnd)
                {
                    if (jumps.Count == 0)
                    {
                        Debug.Log("Aborted execution, for end without start");
                        return;
                    }

                    var startLoop = jumps.Peek();
                    if (!ends.Contains(loopEnd))
                    {
                        loopEnd.PrepareLoopEnd(startLoop.node);
                        ends.Add(loopEnd);
                    }

                    // Jump back to the foreach start
                    if (!startLoop.node.IsLastIteration())
                    {
                        executionIndex = startLoop.index - 1;
                    }
                    else
                    {
                        var fs2 = jumps.Pop();
                        starts.Remove(fs2.node);
                        ends.Remove(loopEnd);
                        finalIteration = true;
                    }
                }

                if (node is INeedLoopReset i)
                {
                    if (!iNeedLoopReset.Contains(i))
                    {
                        i.PrepareNewIteration();
                        iNeedLoopReset.Add(i);
                    }

                    // TODO: remove this node form iNeedLoopReset when we go over a foreach start again
                }

                if (finalIteration && node is ILoopEnd le)
                {
                    le.FinalIteration();
                }

                ProcessNode(cmd, node);
            }
        }

        public override void Run()
        {
            var cmd = CommandBufferPool.Get("Genesis: " + graph.name);
            Run(cmd);
            Graphics.ExecuteCommandBuffer(cmd);
            graph.InvokeCommandBufferExecuted();
        }

        public void Run(CommandBuffer cmd)
        {
            using (new ProcessingScope(this))
            {
                UpdateComputeOrder();

                ProcessGraphOutputs(cmd, graph.graphOutputs);
            }
        }

        public void RunFromNode(BaseNode node)
        {
            using (new ProcessingScope(this))
            {
                UpdateComputeOrder();

                var cmd = CommandBufferPool.Get("Genesis");
                ProcessGraphNodes(cmd, new List<BaseNode> { node });

                Graphics.ExecuteCommandBuffer(cmd);

                graph.InvokeCommandBufferExecuted();
            }
        }

        void ProcessNode(CommandBuffer cmd, BaseNode node)
        {
            if (node.computeOrder < 0 || !node.canProcess)
                return;

            if (node is GenesisNode m)
            {
                m.OnProcess(cmd);
                if (node is IUseCustomRenderTextureProcessing iUseCRT)
                {
                    foreach (var crt in iUseCRT.GetCustomRenderTextures())
                    {
                        if (crt != null)
                        {
                            crt.Update();
                            CustomTextureManager.UpdateCustomRenderTexture(cmd, crt);
                        }
                    }
                }
            }
            else
                node.OnProcess();
        }
    }
}