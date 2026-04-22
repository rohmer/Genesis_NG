using OdinSerializer;

using System;
using System.Collections.Generic;
using System.IO;

using UnityEngine;

namespace AhahGames.GenesisNoise.Views
{
    public class TitleBarManager
    {
        IDictionary<string, TitleBarDefinition> nodeToDef = new Dictionary<string, TitleBarDefinition>();
        IDictionary<string, TitleBarDefinition> groupToDef = new Dictionary<string, TitleBarDefinition>();

        private static TitleBarManager _instance;

        private TitleBarDefinition defaultTBD;

        private TitleBarManager()
        {
            loadTitleBars();
        }

        private void loadTitleBars()
        {
            string filePath = Path.Combine(Application.persistentDataPath, "titleBarDefintions.dat");
            if (!File.Exists(filePath))
            {
                createDefaults();
                saveTitleBars();
                return;
            }
            IList<TitleBarDefinition> defs;
            try
            {
                byte[] bytes = File.ReadAllBytes(filePath);
#if GENESIS_DEBUG
                defs = SerializationUtility.DeserializeValue<IList<TitleBarDefinition>>(bytes, DataFormat.JSON);
#else
                defs=SerializationUtility.DeserializeValue<IList<TitleBarDefinition>>(bytes, DataFormat.Binary);
#endif
                foreach (TitleBarDefinition tbd in defs)
                {
                    if (!String.IsNullOrEmpty(tbd.NodeTitle))
                        nodeToDef.Add(tbd.NodeTitle, tbd);
                    if (!String.IsNullOrEmpty(tbd.NodeGroup))
                        groupToDef.Add(tbd.NodeGroup, tbd);
                }
            }
            catch (Exception)
            {
                createDefaults();
                saveTitleBars();
            }
        }

        private void saveTitleBars()
        {
            string filePath = Path.Combine(Application.persistentDataPath, "titleBarDefintions.dat");
            try
            {
                IList<TitleBarDefinition> tbds = new List<TitleBarDefinition>();
                foreach (var v in nodeToDef)
                    tbds.Add(v.Value);
                foreach (var v in groupToDef)
                    tbds.Add(v.Value);
                byte[] bytes;
#if GENESIS_DEBUG
                bytes = SerializationUtility.SerializeValue(tbds, DataFormat.JSON);
#else
                bytes = SerializationUtility.SerializeValue(tbds, DataFormat.Binary);
#endif
                File.WriteAllBytes(filePath, bytes);
            }
            catch (Exception ex)
            {
                LogSaveException(ex);
            }
        }

        [System.Diagnostics.Conditional("GENESIS_DEBUG")]
        private static void LogSaveException(Exception ex)
        {
            Debug.LogException(ex);
        }

        public int nodesDefined
        {
            get
            {
                return nodeToDef.Count + groupToDef.Count;
            }
        }

        public void Reload()
        {
            loadTitleBars();
        }

        public static TitleBarManager Instance
        {
            get
            {
                if (_instance == null)
                    _instance = new TitleBarManager();
                if (_instance.nodesDefined == 0)
                    _instance.Reload();

                return _instance;
            }

        }

        public Texture2D GetTitleBarTexture(string NodeType, string NodeGroup, int width, int height)
        {
            TitleBarDefinition tbd = null;
            if (nodeToDef.ContainsKey(NodeType))
            {
                tbd = nodeToDef[NodeType];
            }
            if (groupToDef.ContainsKey(NodeGroup))
            {
                tbd = groupToDef[NodeGroup];
            }
            else
            {
                tbd = nodeToDef["default"];
            }


            if (tbd == null)
                return new Texture2D(width, height);

            Texture2D tbt = tbd.GetBackground(width, height);
            return tbt;
        }

        public Color[] GetBorderColors(string NodeType, string NodeGroup)
        {
            TitleBarDefinition tbd = null;
            if (nodeToDef.ContainsKey(NodeType))
            {
                tbd = nodeToDef[NodeType];
            }
            if (groupToDef.ContainsKey(NodeType))
            {
                tbd = groupToDef[NodeType];
            }
            else
            {
                tbd = nodeToDef["default"];
            }

            return tbd.BorderColors;
        }

        public Texture2D GetIcon(string NodeType, string NodeGroup)
        {
            TitleBarDefinition tbd = null;
            if (nodeToDef.ContainsKey(NodeType))
            {
                tbd = nodeToDef[NodeType];
            }
            if (groupToDef.ContainsKey(NodeType))
            {
                tbd = groupToDef[NodeType];
            }
            else
            {
                tbd = nodeToDef["default"];
            }


            if (tbd == null)
                return null;
            return tbd.GetNodeIcon();
        }

        public Color GetTitleColor(string NodeType, string NodeGroup)
        {
            TitleBarDefinition tbd = null;
            if (nodeToDef.ContainsKey(NodeType))
            {
                tbd = nodeToDef[NodeType];
            }
            if (groupToDef.ContainsKey(NodeType))
            {
                tbd = groupToDef[NodeType];
            }
            else
            {
                tbd = nodeToDef["default"];
            }


            if (tbd == null)
                return Color.antiqueWhite;

            if (tbd.GetTitleColor() == Color.clear)
            {
                Texture2D small = tbd.GetBackground(20, 20);
                Color[] pixels = small.GetPixels();
                float total = 0f;
                foreach (Color c in pixels)
                {
                    float luminance = 0.2126f * c.r + 0.7152f * c.g + 0.722f * c.b;
                    total += luminance;
                }
                float avgLuminace = total / pixels.Length;
                if (avgLuminace > 0.65)
                {
                    return Color.black;
                }
                return Color.antiqueWhite;
            }

            return tbd.GetTitleColor();
        }

        public Color GetBackgroundColor(string node, string group)
        {
            if (nodeToDef.ContainsKey(node))
            {
                return nodeToDef[node].BackgroundColor;
            }
            if (groupToDef.ContainsKey(node))
            {
                return groupToDef[node].BackgroundColor;
            }

            return nodeToDef["default"].BackgroundColor;
        }
        private void createDefaults()
        {
            // The default is a 4 corner gray scheme, with whiteish text
            defaultTBD = new TitleBarDefinition("default", "");
            defaultTBD.BackgroundColor = Color.darkSlateGray;
            /*Gradient g= new Gradient();
            List<GradientColorKey> colors= new List<GradientColorKey>();
            colors.Add(new GradientColorKey(new Color(0.5902f, 0.502f, 0.502f),0));
            colors.Add(new GradientColorKey(new Color(0, 0, 0), 1));
            g.colorKeys = colors.ToArray();

            defaultTBD.AddGradientDefinition(new GNGradient(g));
            defaultTBD.AddGradientDefinition(new GNGradient(g));           
            //defaultTBD.AddGradientDefinition(new GNGradient(g));
            //defaultTBD.AddGradientDefinition(new GNGradient(g));
            */
            defaultTBD.TitleColor = new Color(1, 1, 0.94902f);
            nodeToDef.Add("default", defaultTBD);

            TitleBarDefinition colorTBD = new("", "Color");
            colorTBD.BackgroundColor = Color.blue;
            colorTBD.TitleColor = Color.yellow;
            groupToDef.Add("Color", colorTBD);

        }
    }
}
