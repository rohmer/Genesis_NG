using System;
using System.Collections.Generic;
using System.Text;

using Unity.Mathematics;

using UnityEngine;

namespace AhahGames.GenesisNoise.Runtime.Utility.Themes
{
    public class ThemeManager
    {
        private static ThemeManager instance = null;
        Dictionary<string, NodeTheme> groupThemes = new Dictionary<string, NodeTheme>();
        Dictionary<string, NodeTheme> nodeThemes= new Dictionary<string, NodeTheme>();

        NodeTheme defaultTheme;

        private ThemeManager() 
        {
            defaultTheme = new NodeTheme();
            defaultTheme.HeaderTextColor = Color.white;
            defaultTheme.HeaderLeftColor = Color.darkRed;
            defaultTheme.HeaderRightColor = Color.red;
            defaultTheme.BorderColors = new UnityEngine.Color[4] { Color.white, Color.white, Color.white, Color.white };            
            defaultTheme.BackgroundColor = Color.black;
            defaultTheme.HeaderTextColor = Color.black;
            // TODO: Load the themes from the asset database

            // Failing those:
            if (groupThemes.Count==0)
            {
                createDefaultThemes();
            }
        }
        
        public static ThemeManager GetInstance()
        {
            if (instance == null)
                instance = new ThemeManager();
            return instance;
        }

        private void createDefaultThemes()
        {
            NodeTheme colorTheme = new NodeTheme();
            colorTheme.BorderColors = new UnityEngine.Color[4] { Color.white, Color.white, Color.white, Color.white };
            colorTheme.HeaderLeftColor = Color.darkGreen;
            colorTheme.HeaderRightColor = Color.darkBlue;
            colorTheme.HeaderTextColor = Color.white;
            colorTheme.BackgroundColor = Color.antiqueWhite;
            groupThemes.Add("Color", colorTheme);
            NodeTheme blurTheme = new NodeTheme();
            blurTheme.BorderColors = new UnityEngine.Color[4] { Color.white, Color.white, Color.white, Color.white };
            blurTheme.HeaderLeftColor = Color.yellow;
            blurTheme.HeaderRightColor = Color.orange;
            blurTheme.HeaderTextColor = Color.black;
            blurTheme.BackgroundColor = Color.gray;
            groupThemes.Add("Blur", blurTheme);
            NodeTheme mathTheme = new NodeTheme();
            mathTheme.BorderColors = new UnityEngine.Color[4] { Color.cyan, Color.cyan, Color.cyan, Color.cyan};
            mathTheme.HeaderLeftColor = Color.darkCyan;
            mathTheme.HeaderRightColor = Color.darkBlue;
            mathTheme.HeaderTextColor = Color.white;
            mathTheme.BackgroundColor = Color.cyan;
            groupThemes.Add("Math", mathTheme);
            NodeTheme constantTheme = new NodeTheme();
            constantTheme.BorderColors = new UnityEngine.Color[4] { Color.cyan, Color.cyan, Color.cyan, Color.cyan };
            constantTheme.HeaderLeftColor = Color.darkGreen;
            constantTheme.HeaderRightColor = Color.green;
            constantTheme.HeaderTextColor = Color.white;
            constantTheme.BackgroundColor = Color.lightSteelBlue;
            groupThemes.Add("Constant", constantTheme);
            NodeTheme castTheme = new NodeTheme();
            castTheme.BorderColors = new UnityEngine.Color[4] { Color.cyan, Color.cyan, Color.cyan, Color.cyan };
            castTheme.HeaderLeftColor = Color.gray1;
            castTheme.HeaderRightColor = Color.gray5;
            castTheme.HeaderTextColor = Color.white;
            castTheme.BackgroundColor = Color.lightSteelBlue;
            groupThemes.Add("Cast", castTheme); 
            NodeTheme randomTheme= new NodeTheme();
            randomTheme.BorderColors = new UnityEngine.Color[4] { Color.cyan, Color.cyan, Color.cyan, Color.cyan };
            randomTheme.HeaderLeftColor = new Color(0.38f, 0, 0.35f);
            randomTheme.HeaderRightColor = new Color(0.612f, 0.408f, 0);
            randomTheme.HeaderTextColor = Color.white;
            randomTheme.BackgroundColor = Color.lightSteelBlue;
            groupThemes.Add("Random", randomTheme);
        }

        public Color GetTextColor(string NodeGroup, string Name)
        {
            if (nodeThemes.ContainsKey(Name))
                return nodeThemes[Name].HeaderTextColor;
            if (groupThemes.ContainsKey(NodeGroup))
                return groupThemes[NodeGroup].HeaderTextColor;

            return defaultTheme.HeaderTextColor;
        }
        public Texture2D GetNodeIcon(string NodeGroup, string Name)
        {
            if (nodeThemes.ContainsKey(Name))
                return nodeThemes[Name].NodeIcon;
            if (groupThemes.ContainsKey(NodeGroup))
                return groupThemes[NodeGroup].NodeIcon;

            return defaultTheme.NodeIcon;
        }

        public Texture2D GetBackground(string NodeGroup, string Name, int width, int height)
        {
            if (nodeThemes.ContainsKey(Name))
                return nodeThemes[Name].GetHeader(width, height);
            if (groupThemes.ContainsKey(NodeGroup))
                return groupThemes[NodeGroup].GetHeader(width, height);
            return defaultTheme.GetHeader(width, height);
        }

        public Color[] GetBorderColors(string NodeGroup, string Name)
        {
            if (nodeThemes.ContainsKey(Name))
                return nodeThemes[Name].BorderColors;
            if (groupThemes.ContainsKey(NodeGroup))
                return groupThemes[NodeGroup].BorderColors;
            return defaultTheme.BorderColors;
        }

        public Color GetBackgroundColor(string NodeGroup, string Name)
        {
            if (nodeThemes.ContainsKey(Name))
                return nodeThemes[Name].BackgroundColor;
            if (groupThemes.ContainsKey(NodeGroup))
                return groupThemes[NodeGroup].BackgroundColor;
            return defaultTheme.BackgroundColor;
        }
    }
}
