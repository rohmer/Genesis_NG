using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using NUnit.Framework;

using System;
using System.Linq;

namespace AhahGames.GenesisNoise.Tests.Nodes
{
    public class NodeMenuContractTests
    {
        [Test]
        public void AllNodeMenuEntriesAreUnique()
        {
            string[] duplicates = typeof(GenesisNode).Assembly
                .GetTypes()
                .Where(t => !t.IsAbstract && typeof(BaseNode).IsAssignableFrom(t))
                .SelectMany(t => t.GetCustomAttributes(typeof(NodeMenuItemAttribute), false)
                    .Cast<NodeMenuItemAttribute>()
                    .Where(a => !string.IsNullOrWhiteSpace(a.menuTitle))
                    .Select(a => a.menuTitle))
                .GroupBy(title => title, StringComparer.Ordinal)
                .Where(group => group.Count() > 1)
                .Select(group => group.Key)
                .ToArray();

            Assert.That(duplicates, Is.Empty);
        }
    }
}
