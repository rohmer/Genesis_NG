using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
	[Documentation(@"
✔ Long directional scratches
✔ Chaotic micro‑scratches
✔ Dirt buildup in recesses
✔ Multi‑scale breakup
✔ High‑contrast “dirty” shaping
✔ Fully procedural, no textures

")]

	[System.Serializable, NodeMenuItem("Generators/Pattern/Scratches Dirty")]
	public class ScratchesDirtyNode : FixedNoiseNode
	{
		public override string name => "Scratches Dirty";
		public override string NodeGroup => "Pattern";
		public override string ShaderName => "Hidden/Genesis/GrungeScratchesDirty";
		protected override IEnumerable<string> filteredOutProperties => new string[] { };

		public override float nodeWidth => 300;
	}
}