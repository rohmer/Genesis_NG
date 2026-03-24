using AhahGames.GenesisNoise.Nodes;

using System;
using System.Collections.Generic;
using System.Text;

using Unity.Mathematics;

using UnityEditor.Build;

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
            blurTheme.HeaderLeftColor = Color.darkOrchid;
            blurTheme.HeaderRightColor = Color.orange;
            blurTheme.HeaderTextColor = Color.black;
            blurTheme.BackgroundColor = Color.cyan;
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
            NodeTheme effectsTheme = new NodeTheme();
            effectsTheme.BorderColors = new UnityEngine.Color[4] { Color.cyan, Color.cyan, Color.cyan, Color.cyan };
            effectsTheme.HeaderLeftColor = Color.darkBlue;
            effectsTheme.HeaderRightColor = Color.cadetBlue;
            effectsTheme.HeaderTextColor = Color.white;
            effectsTheme.BackgroundColor = Color.cyan;
            groupThemes.Add("Effects", effectsTheme);
            NodeTheme modifiers = new NodeTheme();
            modifiers.BorderColors = new UnityEngine.Color[4] { Color.cyan, Color.cyan, Color.cyan, Color.cyan };
            modifiers.HeaderLeftColor = Color.darkSlateBlue;
            modifiers.HeaderRightColor = Color.slateBlue;
            modifiers.HeaderTextColor = Color.white;
            modifiers.BackgroundColor = Color.cyan;
            groupThemes.Add("Modifiers", modifiers);
            NodeTheme  noise = new NodeTheme();
            noise.BorderColors = new UnityEngine.Color[4] { Color.cyan, Color.cyan, Color.cyan, Color.cyan };
            noise.HeaderLeftColor = Color.gray1;
            noise.HeaderRightColor = Color.gray6;
            noise.HeaderTextColor = Color.white;
            noise.BackgroundColor = Color.darkRed;
            groupThemes.Add("Noise", noise);
            NodeTheme pattern = new NodeTheme();
            pattern.BorderColors = new UnityEngine.Color[4] { Color.cyan, Color.cyan, Color.cyan, Color.cyan };
            pattern.HeaderLeftColor = Color.gray1;
            pattern.HeaderRightColor = Color.chartreuse;
            pattern.HeaderTextColor = Color.white;
            pattern.BackgroundColor = Color.darkRed;
            groupThemes.Add("Pattern", pattern);
            NodeTheme shape = new NodeTheme();
            shape.BorderColors = new UnityEngine.Color[4] { Color.cyan, Color.cyan, Color.cyan, Color.cyan };
            shape.HeaderLeftColor = Color.gray1;
            shape.HeaderRightColor = Color.orchid;
            shape.HeaderTextColor = Color.white;
            shape.BackgroundColor = Color.darkRed;
            groupThemes.Add("Shape", shape);
            NodeTheme normal = new NodeTheme();
            normal.BorderColors = new UnityEngine.Color[4] { Color.cyan, Color.cyan, Color.cyan, Color.cyan };
            normal.HeaderLeftColor = new Color(48f / 255f, 110f / 255f, 110f / 255f);
            normal.HeaderRightColor = new Color(20f / 255f, 217f / 255f, 217f / 255f); ;
            normal.HeaderTextColor = Color.white;
            normal.BackgroundColor = new Color(0, 1, 1);
            groupThemes.Add("Normal", normal);
            NodeTheme operations = new NodeTheme();
            operations.BorderColors = new UnityEngine.Color[4] { Color.cyan, Color.cyan, Color.cyan, Color.cyan };
            operations.HeaderLeftColor = new Color(32f / 255f, 0, 43f / 255f);
            operations.HeaderRightColor = new Color(133f / 255f, 36f / 255f, 166f / 255f); ;
            operations.HeaderTextColor = Color.white;
            operations.BackgroundColor = new Color(188f / 255f, 2f / 255f, 250f / 255f);
            groupThemes.Add("Operations", operations);
            NodeTheme transform = new NodeTheme();
            transform.BorderColors = new UnityEngine.Color[4] { Color.cyan, Color.cyan, Color.cyan, Color.cyan };
            transform.HeaderLeftColor = new Color(6f / 255f, 61f/255f, 2f / 255f);
            transform.HeaderRightColor = new Color(81f / 255f, 158f / 255f, 76f / 255f); ;
            transform.HeaderTextColor = Color.white;
            transform.BackgroundColor = new Color(15f / 255f, 255f / 255f,1f / 255f);
            groupThemes.Add("Transforms", transform);
            NodeTheme utility = new NodeTheme();
            utility.BorderColors = new UnityEngine.Color[4] { Color.cyan, Color.cyan, Color.cyan, Color.cyan };
            utility.HeaderLeftColor = Color.black;
            utility.HeaderRightColor = Color.gray1;
            utility.HeaderTextColor = Color.white;
            utility.BackgroundColor = Color.white;
            groupThemes.Add("Utility", utility);
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
