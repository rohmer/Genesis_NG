using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Calculate the slope of the input heightmap. The slope is calculated as the difference between the current pixel and its neighbors, giving you a measure of how steep the terrain is at that point. This can be used for various effects, such as erosion, texturing, or masking based on steepness.
")]

    [System.Serializable, NodeMenuItem("Filters/Slope")]
    public class SlopeNode : FixedShaderNode
    {
        public override string name => "Slope";

        public override string ShaderName => "Hidden/Genesis/Slope";

        public override bool DisplayMaterialInspector => true;
    }
}