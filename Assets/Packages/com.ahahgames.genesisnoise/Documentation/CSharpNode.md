## Creating a custom Genesis Noise Node (ShaderNode)

Most of the time Genesis Noise nodes classes are 95% similar to each other

```csharp
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using GraphProcessor;
using System.Linq;
using  AhahGames.GenesisNoise.Nodes;

namespace YourNameSpace
{
	[System.Serializable, NodeMenuItem("Custom/#NAME#")]
	public class #SCRIPTNAME# : GenesisNode
	{
		public override string name => "#NAME#";

		public override string shaderName => "Hidden/Genesis/#NAME#";

		public override bool displayMaterialInspector => true;

		// Enumerate the list of material properties that you don't want to be turned into a connectable port.
		protected override IEnumerable<string> filteredOutProperties => new string[]{};

		// Override this if you node is not compatible with all dimensions
		// public override List<OutputDimension> supportedDimensions => new List<OutputDimension>() {
		// 	OutputDimension.Texture2D,
		// 	OutputDimension.Texture3D,
		// 	OutputDimension.CubeMap,
		// };
	}
}
```
#NAME# is the name of your node, and #SCRIPTNAME# is the name of your C# script file (without the .cs extension). You should replace these placeholders with the actual name of your node and script.

