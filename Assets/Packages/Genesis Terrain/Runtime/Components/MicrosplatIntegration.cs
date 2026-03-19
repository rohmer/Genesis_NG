#if __MICROSPLAT__
using JBooth.MicroSplat;

using System.Collections.Generic;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.GNTerrain
{
    public class MicrosplatIntegration
    {
        public MicrosplatIntegration(UnityEngine.Terrain terrain)
        {
            MicroSplatTerrain msTerrain=terrain.GetComponent<MicroSplatTerrain>();
            if (msTerrain==null)
            {
                msTerrain=terrain.gameObject.AddComponent<MicroSplatTerrain>();
                Debug.Log("Added MicroSplatTerrain component to terrain");
                convertTerrain(terrain, msTerrain);
            }
        }

        private void convertTerrain(UnityEngine.Terrain terrain, MicroSplatTerrain msTerrain)
        {
            List<UnityEngine.Terrain> terrains=new List<UnityEngine.Terrain> { terrain  };
            UnityEngine.Terrain[] trs = terrain.GetComponentsInChildren<UnityEngine.Terrain>();
            for (int x = 0; x < trs.Length; ++x)
            {
                if (!terrains.Contains(trs[x]))
                {
                    terrains.Add(trs[x]);
                }
            }

            var config=JBooth.MicroSplat.MicroSplatTerrainEditor.ConvertTerrains(terrains.ToArray(), terrains[0].terrainData.terrainLayers);
            if (config != null)
            {
                Selection.SetActiveObjectWithContext(config, config);
            }
        }
    }
}

#endif