using AhahGames.GenesisNoise;
using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

namespace Mixture
{
    [Documentation(@"
Converts vector data into a texture representation.
")]

    [System.Serializable, NodeMenuItem("Operations/Vector To Texture")]
    public class VectorToTexture : GenesisNode
    {
        [Input, ShowAsDrawer]
        public Vector4 input;

        [Output]
        public RenderTexture output;

        public override string name => "Vector To Texture";
        public override bool showDefaultInspector => true;
        public override Texture previewTexture => null;

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (!base.ProcessNode(cmd))
                return false;

            if (output == null)
                output = new RenderTexture(1, 1, 0, GraphicsFormat.R16G16B16A16_SFloat, 0);

            cmd.SetRenderTarget(output);
            cmd.ClearRenderTarget(false, true, (Color)input, 0);

            return true;
        }

        protected override void Disable()
        {
            if(output!=null)
                output?.Release();
            base.Disable();
        }
    }
}
