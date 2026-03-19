using GraphProcessor;

using System.Collections.Generic;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
[Documentation(@""
Convert RGB image to White and Black. With the Algorithm property you can change how the black and white color is computed:

Name | Description
Luminance | Uses the perceived luminance of the color to compute the grayscale value.
Average | Uses the average of the RGB values to compute the grayscale value.
Min/Max | Uses the minimum or maximum RGB value to compute the grayscale value.
Desaturation | Uses the desaturation of the color to compute the grayscale value.
One Channel | Uses only one of the RGB channels to compute the grayscale value.   The channel can be selected with the Channel property.
Gamma Corrected | Uses the gamma corrected RGB values to compute the grayscale value.
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
