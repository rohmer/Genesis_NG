using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using NUnit.Framework;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace AhahGames.GenesisNoise.Tests.Nodes.Generators
{
    public class GeneratorNodeContractTests
    {
        const int minimumExpectedGeneratorCount = 140;

        static readonly IReadOnlyList<GeneratorNodeCase> generatorNodes = FindGeneratorNodes();

        static IReadOnlyList<GeneratorNodeCase> FindGeneratorNodes()
        {
            return typeof(GenesisNode).Assembly
                .GetTypes()
                .Where(t => !t.IsAbstract && typeof(BaseNode).IsAssignableFrom(t))
                .SelectMany(t => t.GetCustomAttributes<NodeMenuItemAttribute>()
                    .Where(a => a.menuTitle != null && a.menuTitle.StartsWith("Generators/", StringComparison.Ordinal))
                    .Select(a => new GeneratorNodeCase(t, a.menuTitle)))
                .OrderBy(c => c.MenuTitle, StringComparer.Ordinal)
                .ThenBy(c => c.NodeType.FullName, StringComparer.Ordinal)
                .ToList();
        }

        static IEnumerable<TestCaseData> GeneratorNodeCases()
        {
            foreach (GeneratorNodeCase nodeCase in generatorNodes)
            {
                yield return new TestCaseData(nodeCase)
                    .SetName($"{nodeCase.NodeType.Name}_generator_contract");
            }
        }

        [Test]
        public void AllGeneratorNodesAreDiscovered()
        {
            Assert.That(generatorNodes, Has.Count.GreaterThanOrEqualTo(minimumExpectedGeneratorCount));
        }

        [Test]
        public void GeneratorMenuEntriesAreUnique()
        {
            var duplicates = generatorNodes
                .GroupBy(c => c.MenuTitle)
                .Where(g => g.Count() > 1)
                .Select(g => g.Key)
                .ToArray();

            Assert.That(duplicates, Is.Empty);
        }

        [TestCaseSource(nameof(GeneratorNodeCases))]
        public void GeneratorNodeCanBeCreatedAndHasUsableMetadata(GeneratorNodeCase nodeCase)
        {
            var node = (BaseNode)Activator.CreateInstance(nodeCase.NodeType);
            var outputFields = nodeCase.NodeType.GetFields(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance)
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

        [TestCaseSource(nameof(GeneratorNodeCases))]
        public void FixedShaderGeneratorNodeHasShaderContract(GeneratorNodeCase nodeCase)
        {
            if (!typeof(FixedShaderNode).IsAssignableFrom(nodeCase.NodeType))
                Assert.Ignore($"{nodeCase.NodeType.Name} is not a fixed shader generator.");

            var node = (FixedShaderNode)Activator.CreateInstance(nodeCase.NodeType);

            Assert.That(node.ShaderName, Is.Not.Null.And.Not.Empty);
            Assert.That(node.ShaderName, Does.StartWith("Hidden/Genesis/"));
        }

        public readonly struct GeneratorNodeCase
        {
            public GeneratorNodeCase(Type nodeType, string menuTitle)
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
