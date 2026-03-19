using System;
using System.Collections.Generic;

using UnityEngine;

namespace AhahGames.GenesisNoise.GNTerrain
{
    public enum eTerrainSize
    {
        x256,
        x512,
        x1024,
        x2048,
        x4096,
        x8192,
        x16384
    }

    public enum eNoiseFunction
    {
        Perlin = 1,
        FBM = 2,
        Simplex = 3
    }
    public class PointGenerationData
    {
        public eTerrainSize TerrainSize = eTerrainSize.x4096;
        public int NumberOfPoints = 4096;
        public List<Vector2> Points;

        public int GetSize()
        {
            switch (TerrainSize)
            {
                case eTerrainSize.x256:
                    return 256;
                case eTerrainSize.x512:
                    return 512;
                case eTerrainSize.x1024:
                    return 1024;
                case eTerrainSize.x2048:
                    return 2048;
                case eTerrainSize.x4096:
                    return 4096;
                case eTerrainSize.x8192:
                    return 8192;
                case eTerrainSize.x16384:
                    return 16384;
                default:
                    return 4096;
            }
        }
    }
}
