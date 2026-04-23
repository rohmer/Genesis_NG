using GraphProcessor;

using System;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Histogram Scan
")]

    [System.Serializable, NodeMenuItem("Color/Histogram Scan")]
    public class HistogramScanNode : FixedShaderNode
    {
        public override string name => "Histogram Scan";

        public override string ShaderName => "Hidden/Genesis/HistogramScan";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => GenesisNoiseUtility.smallNodeWidth;

        public override bool hasPreview => true;
    }
}
