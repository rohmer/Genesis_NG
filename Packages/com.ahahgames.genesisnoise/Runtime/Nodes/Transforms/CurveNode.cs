using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
✔ Curve remapping
✔ Supports grayscale and color
✔ Sorted key interpolation
✔ Smooth or linear interpolation
")]

    [System.Serializable, NodeMenuItem("Transform/Curve")]
    public class CurveNode : FixedNoiseNode
    {
        public override string name => "Curve";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/Curve";
    }
}