using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Strong Emboss is one of the most feature‑rich shape‑to‑height operators in the entire library. It’s basically a unified emboss engine that blends:
- Bevel
- Emboss
- Inner/Outer height offsets
- Softness
- Height profile shaping
- Light direction
- Intensity
- Distance‑based falloff
To recreate this in Genesis CRT, we need to build a height‑from‑shape gradient solver with:
✔ Normal‑style gradient from the shape mask
✔ Light direction
✔ Height profile curve
✔ Inner/outer emboss
✔ Softness (feathering)
✔ Intensity
✔ Deterministic, CRT‑safe sampling
")]

    [System.Serializable, NodeMenuItem("Filters/Distort/Strong Emboss")]
    public class StrongEmbossNode: FixedNoiseNode
    {
        public override string name => "Strong Emboss";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/UberEmboss";
    }
}