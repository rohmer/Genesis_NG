using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using NUnit.Framework;

using System.Linq;
using System.Reflection;

namespace AhahGames.GenesisNoise.Tests.Nodes.Conditional
{
    public class SwitchNodeContractTests
    {
        [Test]
        public void SwitchMetadataMatchesMenuAndDefaults()
        {
            var node = new SwitchNode();
            var menuItems = typeof(SwitchNode).GetCustomAttributes<NodeMenuItemAttribute>().ToArray();

            Assert.That(node.name, Is.EqualTo("Switch"));
            Assert.That(node.NodeGroup, Is.EqualTo("Conditional"));
            Assert.That(node.hasPreview, Is.False);
            Assert.That(node.hasSettings, Is.False);
            Assert.That(node.showDefaultInspector, Is.True);
            Assert.That(menuItems.Select(m => m.menuTitle), Is.EquivalentTo(new[]
            {
                "Conditional/Switch",
                "Conditional/Switch Statement",
            }));
            Assert.That(node.CaseCount, Is.EqualTo(3));
            Assert.That(node.caseInputs.Count, Is.EqualTo(3));
        }

        [Test]
        public void SetCaseCountResizesCasesAndPreservesExistingValues()
        {
            var node = new SwitchNode();
            node.caseInputs[0] = "zero";
            node.caseInputs[1] = "one";
            node.caseInputs[2] = "two";

            node.SetCaseCount(5);

            Assert.That(node.CaseCount, Is.EqualTo(5));
            Assert.That(node.caseInputs.Count, Is.EqualTo(5));
            Assert.That(node.caseInputs[0], Is.EqualTo("zero"));
            Assert.That(node.caseInputs[1], Is.EqualTo("one"));
            Assert.That(node.caseInputs[2], Is.EqualTo("two"));
            Assert.That(node.caseInputs[3], Is.Null);
            Assert.That(node.caseInputs[4], Is.Null);

            node.SetCaseCount(1);

            Assert.That(node.CaseCount, Is.EqualTo(1));
            Assert.That(node.caseInputs.Count, Is.EqualTo(1));
            Assert.That(node.caseInputs[0], Is.EqualTo("zero"));
        }

        [Test]
        public void ProcessSelectsMatchingCaseOrFallsBackToDefault()
        {
            var node = new SwitchNode
            {
                defaultInput = "fallback",
                selection = 1,
            };
            node.caseInputs[0] = "zero";
            node.caseInputs[1] = "one";
            node.caseInputs[2] = "two";

            InvokeProcessNode(node);
            Assert.That(node.output, Is.EqualTo("one"));

            node.selection = 9;

            InvokeProcessNode(node);
            Assert.That(node.output, Is.EqualTo("fallback"));
        }

        static void InvokeProcessNode(SwitchNode node)
        {
            var processNode = typeof(SwitchNode).GetMethod("ProcessNode", BindingFlags.Instance | BindingFlags.NonPublic);
            processNode.Invoke(node, new object[] { null });
        }
    }
}
