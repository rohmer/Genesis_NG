using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Jacquard Shape Generator

Creates a structured woven pattern with stepped motif repeats, satin-like floats, and thread relief.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Jacquard")]
    public class JacquardNode : FixedShaderNode
    {
        public override string name => "Jacquard";

        public override string ShaderName => "Hidden/Genesis/Jacquard";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
