using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Apply a threshold value to a channel of the input texture and output the result. You can use the Feather parameter to smooth the step.
")]

    [System.Serializable, NodeMenuItem("Color/Threshold")]
    public class ThresholdNode : FixedShaderNode
    {
        public override string name => "Threshold";

        public override string ShaderName => "Hidden/Genesis/Threshold";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Color";
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Channel" };
    }
}