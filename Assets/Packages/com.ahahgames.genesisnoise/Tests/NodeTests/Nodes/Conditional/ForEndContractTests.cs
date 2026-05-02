using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using NUnit.Framework;

using System.Linq;

namespace AhahGames.GenesisNoise.Tests.Nodes.Conditional
{
    public class ForEndContractTests
    {
        [Test]
        public void ForEndMetadataMatchesMenuAndConditionalContract()
        {
            var node = new ForEnd();
            var menuItems = typeof(ForEnd).GetCustomAttributes(typeof(NodeMenuItemAttribute), false)
                .Cast<NodeMenuItemAttribute>()
                .ToArray();

            Assert.That(node.name, Is.EqualTo("For End"));
            Assert.That(node.NodeGroup, Is.EqualTo("Conditional"));
            Assert.That(node.hasPreview, Is.False);
            Assert.That(node.hasSettings, Is.False);
            Assert.That(node.showDefaultInspector, Is.True);
            Assert.That(menuItems.Select(m => m.menuTitle), Is.EquivalentTo(new[] { "Conditional/For End" }));
        }
    }
}
