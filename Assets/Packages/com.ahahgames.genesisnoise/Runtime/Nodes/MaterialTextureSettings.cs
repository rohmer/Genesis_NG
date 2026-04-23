using System;

using UnityEditor;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Serializable]
    public class MaterialTextureSettings
    {
        public Texture texture;
        public string name;
        public bool enableCompression = true;
        public bool hasMipMaps = false;
        public int mipMapCount = 0;
        public TextureFormat compressionFormat = TextureFormat.DXT5;
        public TextureCompressionQuality compressionQuality = TextureCompressionQuality.Best;

        public bool enableConversion = false;
        public ConversionFormat conversionFormat;

        public bool sRGB = false;

        public Material finalCopyMaterial = null;

        [NonSerialized]
        public CustomRenderTexture finalCopyRT = null;

        public bool IsCompressionEnabled()
            => enableCompression && (finalCopyRT.dimension == TextureDimension.Tex2D || finalCopyRT.dimension == TextureDimension.Cube);

        public bool IsConversionEnabled()
            => enableConversion && (finalCopyRT.dimension == TextureDimension.Tex3D || finalCopyRT.dimension == TextureDimension.Cube);

    }
}