using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Leather has a very distinct wear signature compared to fabric or stone:
• 	Crease brightening
• 	Oil darkening in cavities
• 	Scuffing along direction of motion
• 	Crackle micro‑cracks
• 	Edge burnishing
• 	Pore darkening
• 	Dryness (desaturation + roughness increase)
• 	Micro‑grain breakup
We can simulate all of this in a single‑pass, deterministic Genesis CRT node using:
• 	Analytic curvature
• 	Directional abrasion
• 	Micro‑crackle noise
• 	Pore darkening
• 	Edge burnish
• 	Dryness shaping
")]

    [System.Serializable, NodeMenuItem("Wear/Leather")]
    public class LeatherWearNode : FixedNoiseNode
    {
        public override string name => "Leather";
        public override string NodeGroup => "Wear";
        public override string ShaderName => "Hidden/Genesis/LeatherWeathering";
    }
}