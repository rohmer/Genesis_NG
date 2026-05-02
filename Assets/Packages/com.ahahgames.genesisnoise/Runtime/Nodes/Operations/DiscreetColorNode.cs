using AhahGames.GenesisNoise;
using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Round the color components to a specified number of steps in the image.
This node can also be used to make a posterize effect.

By default the input values are considered to be between 0 and 1, you can change these values in the node inspector to adapt the effect to your input data.
")]
    [UnityEngine.Scripting.APIUpdating.MovedFrom(false, sourceNamespace: "Mixture", sourceAssembly: "Genesis Noise", sourceClassName: "DiscreetColorNode")]
    [System.Serializable, NodeMenuItem("Operations/Discretize")]
    public class DiscreetColorNode : FixedShaderNode
    {
        public override string name => "Discretize";
        public override string NodeGroup => "Operations";
        public override string ShaderName => "Hidden/Genesis/Discretize";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { };
    }
}
