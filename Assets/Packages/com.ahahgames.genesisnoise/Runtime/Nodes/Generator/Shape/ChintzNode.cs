using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Chintz Shape Generator

Creates a dense floral textile pattern with sprig bouquets, leaves, stems, and small filler blossoms.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Chintz")]
    public class ChintzNode : FixedShaderNode
    {
        public override string name => "Chintz";

        public override string ShaderName => "Hidden/Genesis/Chintz";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
