using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
✔ Full color‑ramp remapping

✔ Arbitrary number of keys (up to 8)
You can expand to 16 if you want — the structure is already modular.

✔ Sorted key interpolation

✔ HDR color support
")]

    [System.Serializable, NodeMenuItem("Color/Gradient Map")]
    public class GradientMapNode : FixedShaderNode
    {
        public override string name => "Gradient Map";
        public override string NodeGroup => "Color";

        public override string ShaderName => "Hidden/Genesis/GradientMap";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { };
    }
}
