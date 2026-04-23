using GraphProcessor;

using System.Collections.Generic;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Blend between two textures, you can use different blend mode depending which texture you want to blend (depth, color, ect.).

You also have the possibility to provide a mask texture that will affect the opacity of the blend depending on the mask value.
The Mask Mode property is used to select which channel you want the mask value to use for the blending operation.

Note that for normal blending, please use the Normal Blend node.
")]

    [System.Serializable, NodeMenuItem("Operations/Blend")]
    public class BlendNode : FixedShaderNode
    {
        public override string name => "Blend";

        public override string ShaderName => "Hidden/Genesis/Blend";

        public override bool DisplayMaterialInspector => true;

        public override string NodeGroup => "Operations";
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_BlendMode", "_MaskMode", "_RemoveNegative" };

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);

            return r;
        }
    }
}