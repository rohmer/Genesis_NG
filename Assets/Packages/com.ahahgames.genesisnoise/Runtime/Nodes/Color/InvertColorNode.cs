using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Inverts colors of input (Optionally inverts alpha as well")]

    [System.Serializable, NodeMenuItem("Color/Invert")]
    public class InvertColorNode : FixedNoiseNode
    {
        public override string name => "Invert Color";

        public override string ShaderName => "Hidden/Genesis/Invert";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Color";
    }
}