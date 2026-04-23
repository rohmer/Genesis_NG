
using AhahGames.GenesisNoise;

using GraphProcessor;

[Documentation(@"
It computes distance to a feature (usually black/white mask) along a specified direction, not radially.

- ✔ Direction map (angle or vector)
- ✔ Distance accumulation along direction
- ✔ Adjustable max distance
- ✔ Height/mask thresholding
- ✔ Works for 2D / 3D / Cube
- ✔ Deterministic, no loops dependent on texture size
")]

[System.Serializable, NodeMenuItem("Effects/Directional Distance")]
public class DirectionalDistanceNode : FixedNoiseNode
{
    public override string name => "Directional Distance";
    public override string NodeGroup => "Effects";
    public override string ShaderName => "Hidden/Genesis/DirectionalDistance";
}
 