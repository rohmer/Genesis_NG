using GraphProcessor;

using System.Collections.Generic;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Converts the input image to grayscale.

Use the `Algorithm` property to choose how the grayscale value is computed:

| Name | Description |
| --- | --- |
| Luminance | Uses the perceived luminance of the color. |
| Average | Uses the average of the RGB values. |
| Min/Max | Uses the minimum or maximum RGB value. |
| Desaturation | Uses the desaturation of the color. |
| One Channel | Uses a single RGB channel selected by the `Channel` property. |
| Gamma Corrected | Uses gamma-corrected RGB values. |
")]

[System.Serializable, NodeMenuItem("Color/Grayscale")]
    public class GrayscaleNode : FixedShaderNode
    {
        public override string name => "Grayscale";

        public override string ShaderName => "Hidden/Genesis/Grayscale";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Color";
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Algorithm" };

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);

            return r;
        }
    }
}

