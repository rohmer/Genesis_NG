using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
• 	A height‑based normal offset
• 	Applied in a user‑defined direction
• 	With positive/negative embossing
• 	And a soft profile that blends between bump‑map‑like and relief‑map‑like shading
")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Emboss")]
    public class EmbossNode : FixedNoiseNode
    {
        public override string name => "Emboss";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/Emboss";
    }
}