using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Node
{
    [Documentation(@"
Make the input texture tile by wrapping and blending the borders of the texture.
")]

    [System.Serializable, NodeMenuItem("Operations/Textures/Tile Wrap")]
    public class TileWrapNode : FixedShaderNode
    {
        public override string name => "Tile & Wrap";

        public override string ShaderName => "Hidden/Genesis/TileWrap";

        public override bool DisplayMaterialInspector => true;

        // Override this if you node is not compatible with all dimensions
        public override List<OutputDimension> supportedDimensions => new() {
            OutputDimension.Texture2D,
            OutputDimension.Texture3D
        };

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (!base.ProcessNode(cmd))
                return false;

            CustomRenderTextureUpdateZone[] updateZones;

            // Setup the custom render texture multi-pass for the blur:
            switch (output.dimension)
            {
                default:
                case TextureDimension.Cube:
                    throw new NotImplementedException();
                case TextureDimension.Tex2D:
                    updateZones = new CustomRenderTextureUpdateZone[] {
                        new() {
                            needSwap = false,
                            passIndex = 0,
                            rotation = 0f,
                            updateZoneCenter = new Vector3(0.5f, 0.5f, 0.5f),
                            updateZoneSize = new Vector3(1f, 1f, 1f),
                        },
                        new() {
                            needSwap = true,
                            passIndex = 1,
                            rotation = 0f,
                            updateZoneCenter = new Vector3(0.5f, 0.5f, 0.5f),
                            updateZoneSize = new Vector3(1f, 1f, 1f),
                        },
                        new() {
                            needSwap = true,
                            passIndex = 3,
                            rotation = 0f,
                            updateZoneCenter = new Vector3(0.5f, 0.5f, 0.5f),
                            updateZoneSize = new Vector3(1f, 1f, 1f),
                        },
                        // CRT Workaround: we need to add an additional pass because there is a bug in the swap
                        // of the double buffered CRTs: the last pudate zone will not be passed to the next CRT in the chain.
                        // So we add a dummy pass to force a copy
                        new() {
                            needSwap = true,
                            passIndex = 1,
                            rotation = 0f,
                            updateZoneCenter = new Vector3(0.0f, 0.0f, 0.0f),
                            updateZoneSize = new Vector3(0f, 0f, 0f),
                        },
                    };
                    break;
                case TextureDimension.Tex3D:
                    updateZones = new CustomRenderTextureUpdateZone[] {
                        new() {
                            needSwap = false,
                            passIndex = 0,
                            rotation = 0f,
                            updateZoneCenter = new Vector3(0.5f, 0.5f, 0.5f),
                            updateZoneSize = new Vector3(1f, 1f, 1f),
                        },
                        new() {
                            needSwap = true,
                            passIndex = 1,
                            rotation = 0f,
                            updateZoneCenter = new Vector3(0.5f, 0.5f, 0.5f),
                            updateZoneSize = new Vector3(1f, 1f, 1f),
                        },
                        new() {
                            needSwap = true,
                            passIndex = 2,
                            rotation = 0f,
                            updateZoneCenter = new Vector3(0.5f, 0.5f, 0.5f),
                            updateZoneSize = new Vector3(1f, 1f, 1f),
                        },
                        new() {
                            needSwap = true,
                            passIndex = 3,
                            rotation = 0f,
                            updateZoneCenter = new Vector3(0.5f, 0.5f, 0.5f),
                            updateZoneSize = new Vector3(1f, 1f, 1f),
                        },
                        // CRT Workaround: we need to add an additional pass because there is a bug in the swap
                        // of the double buffered CRTs: the last update zone will not be passed to the next CRT in the chain.
                        // So we add a dummy pass to force a copy
                        new() {
                            needSwap = true,
                            passIndex = 1,
                            rotation = 0f,
                            updateZoneCenter = new Vector3(0.0f, 0.0f, 0.0f),
                            updateZoneSize = new Vector3(0f, 0f, 0f),
                        },
                    };
                    break;
            }

            settings.doubleBuffered = true;

            // Setup the successive passes needed or the blur
            output.SetUpdateZones(updateZones);

            return true;
        }

    }
}