using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using NUnit.Framework;

using System;
using System.Linq;
using System.Reflection;

namespace AhahGames.GenesisNoise.Tests.Nodes.Conditional
{
    public class ConditionalNodeContractTests
    {
        [Test]
        public void ForEndMetadataMatchesMenuAndConditionalContract()
        {
            var node = new ForEnd();
            var menuItems = typeof(ForEnd).GetCustomAttributes<NodeMenuItemAttribute>().ToArray();

            Assert.That(node.name, Is.EqualTo("For End"));
            Assert.That(node.NodeGroup, Is.EqualTo("Conditional"));
            Assert.That(node.hasPreview, Is.False);
            Assert.That(node.hasSettings, Is.False);
            Assert.That(node.showDefaultInspector, Is.True);
            Assert.That(menuItems.Select(m => m.menuTitle), Is.EquivalentTo(new[] { "Conditional/For End" }));
        }

        [Test]
        public void WhileDoStartMetadataMatchesMenuAndLoopContract()
        {
            var node = new WhileDoStart();
            var menuItems = typeof(WhileDoStart).GetCustomAttributes<NodeMenuItemAttribute>().ToArray();

            Assert.That(node.name, Is.EqualTo("While Do Start"));
            Assert.That(node.NodeGroup, Is.EqualTo("Conditional"));
            Assert.That(node.hasPreview, Is.False);
            Assert.That(node.hasSettings, Is.False);
            Assert.That(node.showDefaultInspector, Is.True);
            Assert.That(node.nodeWidth, Is.EqualTo(GenesisNoiseUtility.smallNodeWidth));
            Assert.That(menuItems.Select(m => m.menuTitle), Is.EquivalentTo(new[]
            {
                "Conditional/While Do Start",
                "Conditional/Do While Start",
            }));
            Assert.That(node.GetLoopValueType(), Is.EqualTo(typeof(object)));
            Assert.That(node.CurrentLoopValue, Is.Null);
        }

        [Test]
        public void WhileDoStartLoopStateUsesConditionAndMaxIterations()
        {
            var node = new WhileDoStart
            {
                input = "seed",
                condition = true,
                maxIterations = 3,
            };

            node.PrepareLoopStart();

            Assert.That(node.CurrentLoopValue, Is.EqualTo("seed"));
            Assert.That(node.index, Is.EqualTo(0));
            Assert.That(node.outputMaxIterations, Is.EqualTo(3));

            node.index = 1;
            node.UpdateLoopState();
            Assert.That(node.IsLastIteration(), Is.False);

            node.condition = false;
            node.UpdateLoopState();
            Assert.That(node.IsLastIteration(), Is.True);

            node.condition = true;
            node.index = 3;
            node.UpdateLoopState();
            Assert.That(node.IsLastIteration(), Is.True);
        }
    }
}
