using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Normal Vector Rotation is a fantastic utility node — it lets you rotate a tangent‑space normal map by an arbitrary angle, which is incredibly useful for:
- Rotating detail normals
- Aligning normals to flow maps
- Procedural anisotropy
- Stylized shading
- Direction‑driven normal variation


")]

    [System.Serializable, NodeMenuItem("Normal/Normal Vector Rotation")]
    public class NormalVectorRotationNode : FixedNoiseNode
    {
        public override string name => "Normal Vector Rotation";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/NormalVectorRotation";
    }
}