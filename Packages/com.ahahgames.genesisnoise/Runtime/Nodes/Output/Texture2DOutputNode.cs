using GraphProcessor;

using System;

using UnityEngine;

using UnityEngine.Rendering;

using static UnityEditor.Rendering.CameraUI;

namespace AhahGames.GenesisNoise.Nodes
{
    public enum External2DOutputType
    {
        Color,
        Normal,
        Linear,
        LatLongCubemapColor,
        LatLongCubemapLinear,
    }
    public enum ExternalFileType
    {
        PNG,
        EXR,
        TGA
    }

    [Documentation(@"
Writes the graph result to a 2D texture output.
")]


    [Serializable, NodeMenuItem("Output/Texture 2D")]
    public class Texture2DOutputNode : GenesisNode
    {
        [Input("Input", allowMultiple: false)]
        internal RenderTexture input;

        [Output("Texture 2D", allowMultiple: true)]
        internal Texture2D Output;

        public Texture asset;
        internal External2DOutputType external2DOoutputType;
        internal ExternalFileType externalFileType;
        public TextureWrapMode wrapMode = TextureWrapMode.Repeat;
        public FilterMode filterMode = FilterMode.Bilinear;
        internal bool exportAlpha = true;
        internal CustomRenderTexture finalCopyRT = null;
        internal Material finalCopyMaterial;
        public bool hasMipMaps = false;
        public override Texture previewTexture => Output;

        public override string name => "Texture2D Output";

        public event Action onTempRenderTextureUpdated;

        protected override void Enable()
        {
            base.Enable();
            onSettingsChanged += () => { graph.NotifyNodeChanged(this); };
        }


        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (!base.ProcessNode(cmd))
                return false;

            previewSRGB = false;
            if (input == null)
            {
                Output = null;
                return true;
            }

            RenderTexture.active = input;

            Output = new Texture2D(input.width, input.height, TextureFormat.ARGB32, input.useMipMap);
            Output.ReadPixels(new Rect(0, 0, input.width, input.height), 0, 0);
            Output.Apply();
            RenderTexture.active = null;
            return true;

        }

        protected override void Disable()
        {
            base.Disable();
        }

    }
}
