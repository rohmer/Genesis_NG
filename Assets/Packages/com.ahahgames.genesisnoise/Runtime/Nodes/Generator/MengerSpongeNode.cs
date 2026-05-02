using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a Menger sponge style fractal mask or UV visualization.

This surfaces the existing procedural fractal shader as a first-class generator node so it can be used directly in graph workflows.
")]
    [System.Serializable, NodeMenuItem("Generators/Other/Menger Sponge")]
    public class MengerSpongeNode : FixedNoiseNode
    {
        public override string name => "Menger Sponge";
        public override string ShaderName => "Hidden/Genesis/MengerSponge";
        public override string NodeGroup => "Other";
    }
}
