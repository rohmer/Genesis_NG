using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a cobblestone pattern, which is a type of pattern that consists of irregularly shaped stones that are arranged in a random manner. The pattern is often used in architecture and landscaping, and can be generated using a variety of algorithms, such as Perlin noise or Voronoi diagrams.
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Cobblestone")]
    public class CobblestoneNode : FixedNoiseNode
    {
        public override string name => "Cobblestone";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Cobblestone";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}