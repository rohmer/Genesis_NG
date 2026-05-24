using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Fleur-de-Lis Shape Generator

Creates a repeating heraldic lily pattern with mirrored side petals, a central spear, banding, and ornamental relief.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Fleur-de-Lis")]
    public class FleurDeLisNode : FixedShaderNode
    {
        public override string name => "Fleur-de-Lis";

        public override string ShaderName => "Hidden/Genesis/FleurDeLis";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
