using System;

using UnityEngine;

namespace AhahGames.GenesisNoise.Graph
{
    [System.Serializable]
    public class RecipeData
    {
        public string title;
        public string description;
        public Version version = new(0, 0, 1);
        public Rect position;
        public System.Collections.Generic.List<string> containedNodeGuids = new();
        public Color bgColor;

        public bool genesisRecipe = false;

    }
}