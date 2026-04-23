using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Utility
{
    public static class MaterialExtension
    {
        public static void SetKeywordEnabled(this Material material, string keyword, bool enabled)
        {
            if (enabled)
                material.EnableKeyword(keyword);
            else
                material.DisableKeyword(keyword);
        }

        public static bool HasTextureBound(this Material material, string baseName, TextureDimension dimension)
        {
            string property = baseName + GenesisNoiseUtility.shaderPropertiesDimensionSuffix[dimension];
            if (!material.HasProperty(property))
                return false;

            var texture = material.GetTexture(property);
            return texture != null && !texture.IsGenesisDefaultTexture();
        }

        public static Texture GetTextureWithDimension(this Material material, string baseName, TextureDimension dimension)
        {
            var texture = material.GetTexture(baseName + GenesisNoiseUtility.shaderPropertiesDimensionSuffix[dimension]);

            if (texture != null && texture.IsGenesisDefaultTexture())
                return null;
            else
                return texture;
        }
    }
}