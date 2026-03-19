using System;
using System.Collections.Generic;
using System.Text;

using UnityEngine;

namespace AhahGames.GenesisNoise.Nodes
{
    public class ThemeManager
    {
        private static ThemeManager instance = null;
        private ThemeManager() { }

        public static ThemeManager GetInstance()
        {
            if (instance == null)
                instance = new ThemeManager();
            return instance;
        }
       
        public Texture2D GetNodeIcon(string NodeGroup, string NodeName)
        {
            return new Texture2D(32, 32);
        }

        public Color GetBackgroundColor(string NodeGroup, string NodeName)
        {
            return Color.red;
        }

        public Texture2D GetHeaderGradient(string NodeGroup, string NodeName)
        {
            return new Texture2D(32, 32);
        }

        public Color[] GetBorderColors(string NodeGroup, string NodeName)
        {
            return new Color[4] { Color.red, Color.red, Color.red, Color.red };
        }

        public Texture2D GetNodeGradient(string NodeGroup, string NodeName, int nodeWidth)
        {
            return new Texture2D(nodeWidth, 32);
        }
    }
}
