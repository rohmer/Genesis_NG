using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using NUnit.Framework;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace AhahGames.GenesisNoise.Tests.Nodes.Functions
{
    public class FunctionNodeContractTests
    {
        const int minimumExpectedFunctionCount = 70;

        static readonly IReadOnlyList<FunctionNodeCase> functionNodes = FindFunctionNodes();

        static IReadOnlyList<FunctionNodeCase> FindFunctionNodes()
        {
            return typeof(GenesisNode).Assembly
                .GetTypes()
                .Where(t => !t.IsAbstract && typeof(BaseNode).IsAssignableFrom(t))
                .SelectMany(t => t.GetCustomAttributes<NodeMenuItemAttribute>()
                    .Where(a => a.menuTitle != null && a.menuTitle.StartsWith("Function/", StringComparison.Ordinal))
                    .Select(a => new FunctionNodeCase(t, a.menuTitle)))
                .OrderBy(c => c.MenuTitle, StringComparer.Ordinal)
                .ThenBy(c => c.NodeType.FullName, StringComparer.Ordinal)
                .ToList();
        }

        static IEnumerable<TestCaseData> FunctionNodeCases()
        {
            foreach (FunctionNodeCase nodeCase in functionNodes)
            {
                yield return new TestCaseData(nodeCase)
                    .SetName($"{nodeCase.NodeType.Name}_function_contract");
            }
        }

        static IEnumerable<TestCaseData> ConstantFunctionNodeCases()
        {
            foreach (FunctionNodeCase nodeCase in functionNodes.Where(c => typeof(ConstantNode).IsAssignableFrom(c.NodeType)))
            {
                yield return new TestCaseData(nodeCase)
                    .SetName($"{nodeCase.NodeType.Name}_constant_function_contract");
            }
        }

        static IEnumerable<TestCaseData> TextureFunctionNodeCases()
        {
            foreach (FunctionNodeCase nodeCase in functionNodes.Where(c => typeof(TextureMathNode).IsAssignableFrom(c.NodeType)))
            {
                yield return new TestCaseData(nodeCase)
                    .SetName($"{nodeCase.NodeType.Name}_texture_function_contract");
            }
        }

        static FieldInfo[] GetInstanceFields(Type type)
        {
            var fields = new List<FieldInfo>();

            for (Type current = type; current != null; current = current.BaseType)
            {
                fields.AddRange(current.GetFields(
                    BindingFlags.Public |
                    BindingFlags.NonPublic |
                    BindingFlags.Instance |
                    BindingFlags.DeclaredOnly));
            }

            return fields.ToArray();
        }

        [Test]
        public void AllFunctionNodesAreDiscovered()
        {
            Assert.That(functionNodes, Has.Count.GreaterThanOrEqualTo(minimumExpectedFunctionCount));
        }

        [Test]
        public void FunctionMenuEntriesAreUnique()
        {
            var duplicates = functionNodes
                .GroupBy(c => c.MenuTitle)
                .Where(g => g.Count() > 1)
                .Select(g => g.Key)
                .ToArray();

            Assert.That(duplicates, Is.Empty);
        }

        [TestCaseSource(nameof(FunctionNodeCases))]
        public void FunctionNodeCanBeCreatedAndHasUsableMetadata(FunctionNodeCase nodeCase)
        {
            var node = (BaseNode)Activator.CreateInstance(nodeCase.NodeType);
            var outputFields = GetInstanceFields(nodeCase.NodeType)
                .Where(f => f.GetCustomAttribute<OutputAttribute>() != null)
                .ToArray();

            Assert.That(node, Is.Not.Null);
            Assert.That(node.name, Is.Not.Null.And.Not.Empty);
            Assert.That(nodeCase.MenuTitle.Split('/'), Has.Length.GreaterThanOrEqualTo(3));
            Assert.That(outputFields, Is.Not.Empty, $"{nodeCase.NodeType.Name} should expose at least one output port.");

            if (node is GenesisNode genesisNode)
            {
                Assert.That(genesisNode.NodeGroup, Is.Not.Null.And.Not.Empty);
                Assert.That(genesisNode.nodeWidth, Is.GreaterThan(0f));
                Assert.That(genesisNode.supportedDimensions, Is.Not.Null.And.Not.Empty);
                Assert.That(genesisNode.supportedDimensions.All(d => d > 0), Is.True);
                Assert.That(genesisNode.defaultPreviewChannels, Is.Not.EqualTo((PreviewChannels)0));
            }
        }

        [TestCaseSource(nameof(ConstantFunctionNodeCases))]
        public void ConstantFunctionNodesUseConstantNodeBaseContract(FunctionNodeCase nodeCase)
        {
            var node = (ConstantNode)Activator.CreateInstance(nodeCase.NodeType);

            Assert.That(node.hasSettings, Is.False);
            Assert.That(node.nodeWidth, Is.GreaterThan(0f));
        }

        [TestCaseSource(nameof(TextureFunctionNodeCases))]
        public void TextureFunctionNodesExposeTextureMathPorts(FunctionNodeCase nodeCase)
        {
            var inputFields = GetInstanceFields(nodeCase.NodeType)
                .Where(f => f.GetCustomAttribute<InputAttribute>() != null)
                .Select(f => f.Name)
                .ToArray();
            var outputFields = GetInstanceFields(nodeCase.NodeType)
                .Where(f => f.GetCustomAttribute<OutputAttribute>() != null)
                .Select(f => f.Name)
                .ToArray();

            Assert.That(inputFields, Does.Contain("inputA"));
            Assert.That(inputFields, Does.Contain("inputB"));
            Assert.That(outputFields, Does.Contain("output"));
        }

        public readonly struct FunctionNodeCase
        {
            public FunctionNodeCase(Type nodeType, string menuTitle)
            {
                NodeType = nodeType;
                MenuTitle = menuTitle;
            }

            public Type NodeType { get; }
            public string MenuTitle { get; }

            public override string ToString() => $"{MenuTitle} ({NodeType.Name})";
        }
    }
}
