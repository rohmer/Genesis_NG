using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using NUnit.Framework;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

using UnityEngine;

namespace AhahGames.GenesisNoise.Tests.Nodes
{
    public class AssemblyNodeLifecycleTests
    {
        static readonly Type genesisNodeType = typeof(GenesisNode);
        static readonly Type[] assemblyNodeTypes = GetAssemblyNodeTypes();

        static Type[] GetAssemblyNodeTypes()
        {
            try
            {
                return genesisNodeType.Assembly
                    .GetTypes()
                    .Where(IsConcreteGenesisNodeType)
                    .OrderBy(type => type.FullName)
                    .ToArray();
            }
            catch (ReflectionTypeLoadException exception)
            {
                return exception.Types
                    .Where(type => type != null && IsConcreteGenesisNodeType(type))
                    .OrderBy(type => type.FullName)
                    .ToArray();
            }
        }

        static bool IsConcreteGenesisNodeType(Type type)
        {
            return type != null
                && type != genesisNodeType
                && genesisNodeType.IsAssignableFrom(type)
                && type.IsClass
                && !type.IsAbstract
                && !type.ContainsGenericParameters;
        }

        public static IEnumerable<TestCaseData> AssemblyNodeCreationCases()
        {
            foreach (Type nodeType in assemblyNodeTypes)
            {
                yield return new TestCaseData(nodeType)
                    .SetName($"{nodeType.Name}_can_be_instantiated_on_a_graph");
            }
        }

        public static IEnumerable<TestCaseData> AssemblyNodeDeletionCases()
        {
            foreach (Type nodeType in assemblyNodeTypes)
            {
                yield return new TestCaseData(nodeType)
                    .SetName($"{nodeType.Name}_can_be_deleted_from_a_graph");
            }
        }

        [Test]
        public void AllAssemblyNodesAreDiscovered()
        {
            Assert.That(assemblyNodeTypes, Is.Not.Empty);
        }

        [TestCaseSource(nameof(AssemblyNodeCreationCases))]
        public void AssemblyNodeCanBeInstantiatedOnAGraph(Type nodeType)
        {
            GenesisGraph graph = CreateGraph();

            try
            {
                int baselineCount = graph.nodes.Count;
                BaseNode node = BaseNode.CreateFromType(nodeType, Vector2.zero);

                Assert.That(node, Is.Not.Null, $"Failed to create node instance for {nodeType.FullName}.");

                graph.AddNode(node);

                Assert.That(graph.nodes.Count, Is.EqualTo(baselineCount + 1));
                Assert.That(graph.nodes, Contains.Item(node));
                Assert.That(graph.nodesPerGUID.ContainsKey(node.GUID), Is.True);
                Assert.That(graph.nodesPerGUID[node.GUID], Is.SameAs(node));
                Assert.That(node, Is.InstanceOf(nodeType));
            }
            finally
            {
                DestroyGraph(graph);
            }
        }

        [TestCaseSource(nameof(AssemblyNodeDeletionCases))]
        public void AssemblyNodeCanBeDeletedFromAGraph(Type nodeType)
        {
            GenesisGraph graph = CreateGraph();

            try
            {
                int baselineCount = graph.nodes.Count;
                BaseNode node = BaseNode.CreateFromType(nodeType, Vector2.zero);

                Assert.That(node, Is.Not.Null, $"Failed to create node instance for {nodeType.FullName}.");

                graph.AddNode(node);
                graph.RemoveNode(node);

                Assert.That(graph.nodes.Count, Is.EqualTo(baselineCount));
                Assert.That(graph.nodes.Contains(node), Is.False);
                Assert.That(graph.nodesPerGUID.ContainsKey(node.GUID), Is.False);
            }
            finally
            {
                DestroyGraph(graph);
            }
        }

        static GenesisGraph CreateGraph()
        {
            GenesisGraph graph = ScriptableObject.CreateInstance<GenesisGraph>();
            graph.hideFlags = HideFlags.HideAndDontSave;
            return graph;
        }

        static void DestroyGraph(GenesisGraph graph)
        {
            if (graph != null)
                UnityEngine.Object.DestroyImmediate(graph);
        }
    }
}
