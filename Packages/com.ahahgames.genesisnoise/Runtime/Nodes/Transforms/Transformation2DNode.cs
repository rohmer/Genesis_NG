using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Translation

Rotation

Uniform / non‑uniform scale

Pivot control

Optional tiling or clamping

CRT‑safe 2D/3D/Cube behavior

Deterministic, sampler‑free UV math
")]

    [System.Serializable, NodeMenuItem("Operations/Transformation 2D")]
    public class Transformation2DNode : FixedShaderNode
    {
        public override string name => "Transformation";
        public override string NodeGroup => "Transforms";

        public override string ShaderName => "Hidden/Genesis/Transform2D";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { };
    }
}
