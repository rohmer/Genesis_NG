using GraphProcessor;

using System.Collections.Generic;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Instead of a single spiral, this variant gives you multiple spiral arms, each with its own:
- Angle offset
- Radius growth
- Angle step
- Jitter
- Scale variation
- Rotation variation
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Spiral Arms Splatter Shape")]
    public class SpiralArmsSplatterShapeNode : FixedShaderNode
    {
        public override string name => "Spiral Arms Splatter Shape";

        public override string ShaderName => "Hidden/Genesis/ShapeSplatterCircularSpiralArms";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
        public override string NodeGroup => "Shape";
    }
}