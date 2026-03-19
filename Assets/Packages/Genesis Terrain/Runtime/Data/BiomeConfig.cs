using System;
using System.Collections.Generic;
using System.Text;

using UnityEngine;


namespace AhahGames.GenesisNoise.GNTerrain
{
    public class BiomeConfig
    {
        public IList<BiomeTextureSetData> BiomeConfiguration=new List<BiomeTextureSetData>();
        public int minimumMoisture, maximumMoisture;
        public int minimumTemp, maximumTemp;
        public string biomeName;
    }


}
