using GraphProcessor;

using System.Collections.Generic;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The cross section node allow you to generate 2D texture by taking either a slice of a texture 2D or 3D.
Right now this node is limited to slices on the Y axis. 
")]
    [System.Serializable, NodeMenuItem("Operations/Cross Section")]
    public class CrossSectionNode : FixedShaderNode
    {
        public override string name => "Cross Section";

        public override string ShaderName => "Hidden/Genesis/CrossSection";
        public override string NodeGroup => "Operations";
        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        protected override TextureDimension GetTempTextureDimension() => TextureDimension.Tex2D;
    }
}