using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a Truchet pattern
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Truchet")]
    public class TruchetNode : FixedShaderNode
    {
        public override string name => "Truchet";

        public override string ShaderName => "Hidden/Genesis/Truchet";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";

    }
}