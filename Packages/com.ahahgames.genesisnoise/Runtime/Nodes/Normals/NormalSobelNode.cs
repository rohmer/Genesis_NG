using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
it converts a height map into a tangent‑space normal map using Sobel gradients.
✔ Sobel X/Y gradient from height
✔ Adjustable intensity
✔ Proper tangent‑space normal reconstruction
✔ Deterministic, CRT‑safe sampling
✔ No derivatives, no mip bias, no nondeterminism

")]

    [System.Serializable, NodeMenuItem("Normal/Normal Sobel")]
    public class NormalSobelNode : FixedNoiseNode
    {
        public override string name => "Normal Sobel";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/NormalSobel";
    }
}