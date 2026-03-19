using System.Collections.Generic;

using UnityEngine;

namespace AhahGames.GenesisNoise.Nodes
{
    /// <summary>
    /// Interface for nodes that can conditionally execute based on a boolean value.
    /// </summary>
    public interface IUseCustomRenderTextureProcessing
    {
        IEnumerable<CustomRenderTexture> GetCustomRenderTextures();
    }
}