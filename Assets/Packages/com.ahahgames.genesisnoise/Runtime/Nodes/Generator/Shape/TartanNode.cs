using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Tartan Shape Generator

Creates a plaid textile pattern with crossing broad bands, pinstripes, overlap darkening, and woven thread relief.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Tartan")]
    public class TartanNode : FixedShaderNode
    {
        public override string name => "Tartan";

        public override string ShaderName => "Hidden/Genesis/Tartan";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
