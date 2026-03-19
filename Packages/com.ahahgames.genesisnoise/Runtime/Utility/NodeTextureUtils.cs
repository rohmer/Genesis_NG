using UnityEngine;
using UnityEngine.Rendering;

using static AhahGames.GenesisNoise.Nodes.TextureNode;

namespace AhahGames.GenesisNoise.Utility
{
    public class NodeTextureUtils
    {
        public struct TextureInfo
        {
            public Texture texture;
            public bool isNormalMap;
            public Vector2Int size;
        }
        public bool IsPowerOf2(Texture t)
        {
            bool isPOT = false;

            if (!Mathf.IsPowerOfTwo(t.width))
                return false;

            // Check if texture is POT
            if (t.dimension == TextureDimension.Tex2D)
                isPOT = t.width == t.height;
            else if (t.dimension == TextureDimension.Cube)
                isPOT = true;
            else if (t.dimension == TextureDimension.Tex3D)
                isPOT = t.width == t.height && t.width == TextureUtils.GetSliceCount(t);

            return isPOT;
        }

        TextureInfo NodeToTexture(Texture textureAsset, PowerOf2Mode POTMode = PowerOf2Mode.None)
        {


            return new TextureInfo();
        }
    }
}