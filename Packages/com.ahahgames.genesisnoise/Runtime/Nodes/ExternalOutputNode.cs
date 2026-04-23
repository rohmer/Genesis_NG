using AhahGames.GenesisNoise.Graph;

using GraphProcessor;

using System;
using System.Linq;

using UnityEngine;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
TODO: Make every node able to export their data, this node is just a placeholder for now.
Export a texture from the graph, the texture can also be exported outside of unity.

Note that for 2D textures, the file is exported either in png or exr depending on the current floating precision.
For 3D and Cube textures, the file is exported as a .asset and can be use in another Unity project.
")]
    [Serializable, NodeMenuItem("Output/External Output")]
    public class ExternalOutputNode : OutputNode
    {

        public new string name = "External Output";
        public enum ExternalOutputDimension
        {
            Texture2D,
            Texture3D,
            Cubemap,
        }
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


        public Texture asset;

        public ExternalOutputDimension externalOutputDimension = ExternalOutputDimension.Texture2D;
        public External2DOutputType external2DOoutputType = External2DOutputType.Color;
        public ExternalFileType externalFileType = ExternalFileType.PNG;
        public ConversionFormat external3DFormat = ConversionFormat.RGBA32;
        public bool exportAlpha = true;

        public override Texture previewTexture => outputTextureSettings.Count > 0 ? (Texture)mainOutput.finalCopyRT : Texture2D.blackTexture;

        public override bool hasSettings => true;

        public override bool canEditPreviewSRGB => false;

        protected override GenesisNoiseSettings defaultSettings
        {
            get
            {
                POTSize size = (settings.GetResolvedTextureDimension(graph) == TextureDimension.Tex3D) ? POTSize._32 : POTSize._1024;
                return new GenesisNoiseSettings
                {
                    sizeMode = OutputSizeMode.Absolute,
                    potSize = size,
                    height = (int)size,
                    width = (int)size,
                    depth = (int)size,
                    dimension = OutputDimension.InheritFromParent,
                    outputChannels = OutputChannel.InheritFromParent,
                    outputPrecision = OutputPrecision.InheritFromParent,
                    editFlags = EditFlags.Height | EditFlags.Width | EditFlags.TargetFormat,
                    wrapMode = OutputWrapMode.Repeat,
                    filterMode = OutputFilterMode.Bilinear,
                };
            }
        }

        protected override void Enable()
        {
            base.Enable();

            onSettingsChanged += () => { graph.NotifyNodeChanged(this); };
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (!base.ProcessNode(cmd))
                return false;

            uniqueMessages.Clear();

            if (settings.GetResolvedTextureDimension(graph) != TextureDimension.Cube)
            {
                outputTextureSettings.First().sRGB = false;
                return base.ProcessNode(cmd);
            }
            else
            {
                if (uniqueMessages.Add("CubemapNotSupported"))
                    AddMessage("Using texture cubes with this node is not supported.", NodeMessageType.Warning);
                return false;
            }

        }
    }
}