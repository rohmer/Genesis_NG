using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Weave Complex is where things get really interesting — this is the complex twill variant:
2‑over‑1‑under, 3‑over‑1‑under, 4‑over‑2‑under, etc.
In other words:
➡️ You control how many horizontal threads go over before going under, and vice‑versa.
This is how you get denim‑style twill, herringbone precursors, carbon‑fiber‑like diagonals, and stylized woven sci‑fi surfaces.
This version is:
- deterministic
- CRT‑safe
- sampler‑free
- fully modular

")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Weave Complex")]
    public class WeaveComplexNode : FixedShaderNode
    {
        public override string name => "Weave Complex";

        public override string ShaderName => "Hidden/Genesis/Weave3";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}