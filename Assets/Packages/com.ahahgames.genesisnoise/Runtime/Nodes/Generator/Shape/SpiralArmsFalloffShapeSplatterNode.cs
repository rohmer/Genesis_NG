using GraphProcessor;

using System.Collections.Generic;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
This variant keeps everything from Spiral Per‑Arm Variation, but adds:
- Per‑instance falloff (fade along each arm)
- Multiple falloff modes (linear, smoothstep, exponential)
- Optional per‑arm falloff offset
- Optional per‑arm falloff strengt

")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Spiral Arms Falloff Splatter Shape")]
    public class SpiralArmsFalloffSplatterShapeNode : FixedShaderNode
    {
        public override string name => "Spiral Arms Falloff Splatter Shape";

        public override string ShaderName => "Hidden/Genesis/ShapeSplatterCircularSpiralArmsFalloff";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
        public override string NodeGroup => "Shape";
    }
}