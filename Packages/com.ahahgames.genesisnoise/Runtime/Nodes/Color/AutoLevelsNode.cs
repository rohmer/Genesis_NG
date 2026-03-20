using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Per texture min/max remap, stretching the histogram so the darkest pixel is 0 and the brightest is 1
")]

    [System.Serializable, NodeMenuItem("Color/Auto Levels")]
    public class AutoLevelsNode : FixedShaderNode
    {
        public override string name => "Auto Levels";

        public override string ShaderName => "Hidden/Genesis/AutoLevels";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => GenesisNoiseUtility.smallNodeWidth;

        public override bool hasPreview => true;
    }
}