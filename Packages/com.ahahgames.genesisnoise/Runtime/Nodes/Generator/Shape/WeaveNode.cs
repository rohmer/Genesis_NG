using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
This node produces a woven over/under pattern using two perpendicular stripe sets, with:
- adjustable thread width
- adjustable gap
- over/under alternation
- optional random variation
- rotation
- softness
- contrast

")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Weave")]
    public class WeaveNode : FixedShaderNode
    {
        public override string name => "Weave";

        public override string ShaderName => "Hidden/Genesis/Weave";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}