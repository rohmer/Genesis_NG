using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
The WarpNoise node performs procedural UV warping, chromatic aberration, and optional color generation using a combination of:
- Directional sine warping
- FBM turbulence
- Barrel/pincushion distortion
- Chromatic shift
- Input‑based or procedurally generated color
This node is ideal for:
- Stylized distortion effects
- Glitch and hologram shaders
- Psychedelic or vaporwave looks
- Heat haze and underwater distortion
- Magical FX
- Animated noise‑driven warping
- Chromatic aberration overlays
It can operate in two modes:
- Input Mode — warps an input texture
- Generated Mode — generates color procedurally using a color gradient
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Warp Noise"), NodeMenuItem("Effects/Modifications/Warp Noise")]
    public class WarpNoise : FixedNoiseNode
    {
        public override string NodeGroup => "Noise";
        public override string name => "Warp";        
        public override string ShaderName => "Hidden/Genesis/WarpNoise";
    }
}