using AhahGames.GenesisNoise.Nodes;

using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

[System.Serializable]
public abstract class FixedNoiseNode : FixedShaderNode
{
    public override bool DisplayMaterialInspector => true;
    public override string NodeGroup => "Noise";
    public override PreviewChannels defaultPreviewChannels => PreviewChannels.RGB; // Hide alpha channel for noise preview

    // Enumerate the list of material properties that you don't want to be turned into a connectable port.
    protected override IEnumerable<string> filteredOutProperties => new string[] { "_OutputRange", "_TilingMode", "_CellSize", "_Octaves", "_Channels", "_UVMode" };

    protected override bool ProcessNode(CommandBuffer cmd)
    {
        if (!base.ProcessNode(cmd))
            return false;

        if (material.IsKeywordEnabled("_TILINGMODE_TILED"))
        {
            if(material.HasProperty("_Lacunarity"))
                material.SetFloat("_Lacunarity", Mathf.Round(material.GetFloat("_Lacunarity")));
            if(material.HasProperty("_Frequency"))
                material.SetFloat("_Frequency", Mathf.Round(material.GetFloat("_Frequency")));
        }

        return true;
    }
}