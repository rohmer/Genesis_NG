using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
A normal map encodes:
N=(n_x,n_y,n_z)
Where n_x and n_y are proportional to the slope of the height field:
\frac{\partial h}{\partial x}=-\frac{n_x}{n_z},\quad \frac{\partial h}{\partial y}=-\frac{n_y}{n_z}
So to reconstruct height, we need to:
✔ Convert normal to slope
✔ Integrate slope across the image
✔ Use iterative accumulation (CRT‑safe)
✔ Provide intensity + bias controls
✔ Keep everything deterministic

")]

    [System.Serializable, NodeMenuItem("Normal/Normal To Height")]
    public class NormalToHeightNode : FixedNoiseNode
    {
        public override string name => "Normal To Height";
        public override string NodeGroup => "Normal";
        public override string ShaderName => "Hidden/Genesis/NormalToHeight";
    }
}