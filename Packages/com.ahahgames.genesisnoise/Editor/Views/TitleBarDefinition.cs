using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

using UnityEngine;

namespace AhahGames.GenesisNoise.Views
{
    [Serializable]
    public class GNAlphaKey
    {
        float time;
        float alpha;
        public GNAlphaKey(GradientAlphaKey key)
        {
            time = key.time;
            alpha = key.alpha;
        }
        public GNAlphaKey(float time, float alpha)
        {
            this.time = time;
            this.alpha = alpha;
        }

        public GradientAlphaKey GetAlphaKey()
        {
            return new GradientAlphaKey(time, alpha);
        }

        public float Time
        {
            get { return time; }
            set { time = value; }
        }
        public float Alpha
        {
            get { return alpha; }
            set { alpha = value; }
        }
    }

    [Serializable]
    public class GNColorKey
    {
        float time;
        Color color;
        public GNColorKey(GradientColorKey key)
        {
            time = key.time;
            color = key.color;
        }

        public GNColorKey(float time, Color color)
        {
            this.time = time;
            this.color = color;
        }

        public GradientColorKey GetColorKey()
        {
            return new GradientColorKey(color, time);
        }

        public float Time
        {
            get { return time; }
            set { time = value; }
        }
        public Color Color
        {
            get { return color; }
            set { color = value; }
        }
    }

    [Serializable]
    public class GNGradient
    {
        private Gradient gradient = null;
        private GradientMode mode;
        IList<GNAlphaKey> alphaKeys = new List<GNAlphaKey>();
        IList<GNColorKey> colorKeys = new List<GNColorKey>();
        public GNGradient(Gradient gradient)
        {
            this.mode = gradient.mode;
            alphaKeys.Clear();
            foreach (var akey in gradient.alphaKeys)
                alphaKeys.Add(new GNAlphaKey(akey));
            foreach (var ckey in gradient.colorKeys)
                colorKeys.Add(new GNColorKey(ckey));
            this.gradient = gradient;
        }

        public Gradient Gradient()
        {
#if GENESIS_DEBUG
#else

            if(gradient!=null) return gradient;
#endif
            gradient = new Gradient();
            gradient.mode = mode;
            List<GradientAlphaKey> akeys = new();
            foreach (var akey in alphaKeys)
                akeys.Add(new GradientAlphaKey(akey.Alpha, akey.Time));
            gradient.alphaKeys = akeys.ToArray();
            List<GradientColorKey> ckeys = new();
            foreach (var ckey in colorKeys)
                ckeys.Add(new GradientColorKey(ckey.Color, ckey.Time));
            gradient.colorKeys = ckeys.ToArray();
            return gradient;
        }

        public void AddAlphaKey(GNAlphaKey key)
        {
            alphaKeys.Add(key);
        }

        public void AddColorKey(GNColorKey key)
        {
            colorKeys.Add(key);
        }

        public void SetMode(GradientMode mode)
        {
            this.mode = mode;
        }

        public GNGradient(IList<GNAlphaKey> alphaKeys, IList<GNColorKey> colorKeys, GradientMode mode = GradientMode.PerceptualBlend)
        {
            gradient = new Gradient();
            gradient.mode = mode;
            IList<GradientAlphaKey> gradientAlphaKeys = new List<GradientAlphaKey>();
            foreach (var akey in alphaKeys)
                gradientAlphaKeys.Add(akey.GetAlphaKey());
            gradient.alphaKeys = gradientAlphaKeys.ToArray();
            IList<GradientColorKey> gradientColorKeys = new List<GradientColorKey>();
            foreach (var akey in colorKeys)
                gradientColorKeys.Add(akey.GetColorKey());
            gradient.colorKeys = gradientColorKeys.ToArray();
        }
    }

    /// <summary>
    /// TitleBarDefinition
    /// Gradients:
    ///     1 - Top to bottom
    ///     2 - First is top left, second is bottom right
    ///     3 - Top Left, Bottom Left, Right
    ///     4 - Top Left, Top Right, Bottom Right,Bottom Left
    /// titleColor - If Clear it will be defined as white against a dark background, black against a light background
    /// </summary>
    [Serializable]
    public class TitleBarDefinition
    {
        [SerializeField]
        private readonly string nodeTitle;
        [SerializeField]
        private readonly string nodeGroup;
        [SerializeField]
        private readonly string nodeIcon;
        [SerializeField] private Color borderTop = Color.lightGray;
        [SerializeField] private Color borderRight = Color.lightGray;
        [SerializeField] private Color borderBottom = Color.lightGray;
        [SerializeField] private Color borderLeft = Color.lightGray;

        [SerializeField] private Color titleColor = Color.clear;
        [SerializeField] private Color backgroundColor = Color.gray;
        [NonSerialized]
        private Texture2D titleBarImage = null;

        [SerializeField] private List<GNGradient> gradients = new();

        public TitleBarDefinition(string NodeTitle, string NodeGroup, string nodeIcon = "Icons/Node Icons/Default")
        {
            nodeTitle = NodeTitle;
            nodeGroup = NodeGroup;
            this.titleColor = Color.clear;
            this.backgroundColor = Color.gray;
            this.nodeIcon = nodeIcon;
        }

        public TitleBarDefinition(string NodeTitle, string NodeGroup, Color backgroundColor, Color titleColor, string nodeIcon = "Icons/Node Icons/Default")
        {
            nodeTitle = NodeTitle;
            nodeGroup = NodeGroup;
            this.titleColor = titleColor;
            this.backgroundColor = backgroundColor;
            this.nodeIcon = nodeIcon;
        }

        public void AddGradientDefinition(GNGradient gradientDef)
        {
            this.gradients.Add(gradientDef);
        }

        public Color[] BorderColors
        {
            get
            {
                List<Color> borderColors = new()
                {
                    borderTop,
                    borderRight,
                    borderBottom,
                    borderLeft
                };
                return borderColors.ToArray();
            }
            set
            {
                BorderColors = value;
            }
        }


        public Color TitleColor
        {
            get { return this.titleColor; }
            set { this.titleColor = value; }
        }

        public Color BackgroundColor
        {
            get { return this.backgroundColor; }
            set { this.backgroundColor = value; }
        }

        public string NodeGroup
        {
            get { return nodeGroup; }
        }

        public string NodeTitle
        { get { return nodeTitle; } }

        static Texture2D LoadIcon(string resourceName)
        {
            if (UnityEditorInternal.InternalEditorUtility.HasPro())
            {
                string darkIconPath = Path.GetDirectoryName(resourceName) + "/d_" + Path.GetFileName(resourceName);
                var darkIcon = Resources.Load<Texture2D>(darkIconPath);
                if (darkIcon != null)
                    return darkIcon;
            }

            return Resources.Load<Texture2D>(resourceName);
        }

        public Texture2D GetNodeIcon()
        {
            return LoadIcon(nodeIcon);
        }

        public Color GetTitleColor() { return titleColor; }

        public Texture2D GetBackground(int width, int height)
        {
#if GENESIS_DEBUG
#else
            if (titleBarImage != null && titleBarImage.width == width && titleBarImage.height == height)
                return titleBarImage;
#endif
            titleBarImage = new Texture2D(width, height);
            if (gradients.Count == 0)
            {
                // This is a solid color BG
                titleBarImage = new Texture2D(1, 1);
                titleBarImage.SetPixel(0, 0, backgroundColor);
                titleBarImage.Reinitialize(width, height);
                return titleBarImage;
            }

            if (gradients.Count == 1 && gradients[0] != null)
            {
                //Top down                
                Gradient g = gradients[0].Gradient();
                for (int y = 0; y < height; y++)
                {
                    float t = (float)y / (float)height;
                    Color c = g.Evaluate(t);

                    for (int x = 0; x < width; x++)
                    {
                        titleBarImage.SetPixel(x, y, c);
                    }
                }
                return titleBarImage;
            }

            Vector2Int tlV = new(0, 0);
            Vector2Int brV = new(width, height);
            int mid = Mathf.RoundToInt(height / 2);
            Vector2Int rMid = new(width, mid);
            Vector2Int lMid = new(0, mid);
            Vector2Int blV = new(0, height);
            Vector2Int trV = new(width, 0);

            if (gradients.Count == 2 && gradients[0] != null && gradients[1] != null)
            {
                // TL, BR
                Gradient tl = gradients[0].Gradient();
                Gradient br = gradients[1].Gradient();
                for (int y = 0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        float maxDist = Vector2.Distance(tlV, brV);
                        float curDist1 = Vector2.Distance(tlV, new Vector2Int(x, y)) / maxDist;
                        float curDist2 = Vector2.Distance(brV, new Vector2Int(x, y)) / maxDist;
                        Color c = Color.Lerp(tl.Evaluate(curDist1), br.Evaluate(curDist2), curDist2);
                        titleBarImage.SetPixel(x, y, c);
                    }
                }
                return titleBarImage;
            }

            if (
                gradients.Count == 3 &&
                gradients[0] != null &&
                gradients[1] != null &&
                gradients[2] != null
                )
            {
                Gradient tl = gradients[0].Gradient();
                Gradient bl = gradients[1].Gradient();
                Gradient right = gradients[2].Gradient();

                float maxDist = Vector2.Distance(tlV, brV);

                for (int y = 0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        float tlDist = Vector2.Distance(tlV, new Vector2Int(x, y)) / maxDist;
                        float blDist = Vector2.Distance(blV, new Vector2Int(x, y)) / maxDist;
                        float midDist = Vector2.Distance(new Vector2Int(x, y), new Vector2Int(width, y));

                        // Normalize first distance to 1.0
                        float mult = (float)((tlDist + blDist) / 1.0);
                        float tlTime = tlDist * mult;
                        float blTime = blDist * mult;
                        Color c = Color.Lerp(tl.Evaluate(tlTime), bl.Evaluate(blTime), tlTime);
                        c = Color.Lerp(c, right.Evaluate((float)(midDist)), (float)(1.0 - midDist));
                        titleBarImage.SetPixel(x, y, c);
                    }
                }
                return titleBarImage;
            }

            if (
                gradients.Count == 4 &&
                gradients[0] != null &&
                gradients[1] != null &&
                gradients[2] != null &&
                gradients[3] != null)
            {
                Gradient tl = gradients[0].Gradient();
                Gradient tr = gradients[1].Gradient();
                Gradient bl = gradients[2].Gradient();
                Gradient br = gradients[3].Gradient();


                float maxDist = Vector2.Distance(tlV, brV);
                for (int y = 0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        Vector2Int currentV = new(x, y);
                        float tlD = Vector2.Distance(tlV, currentV) / maxDist;
                        float trD = Vector2.Distance(trV, currentV) / maxDist;
                        float blD = Vector2.Distance(blV, currentV) / maxDist;
                        float brD = Vector2.Distance(brV, currentV) / maxDist;

                        Color c = Color.Lerp(tl.Evaluate(tlD), tl.Evaluate(brD), brD);      // Eval TL vs BR
                        Color c2 = Color.Lerp(br.Evaluate(brD), tr.Evaluate(trD), trD);      // Eval TL vs BR

                        // We can merge left to right
                        float lrDistance = Vector2.Distance(new Vector2Int(x, 0), tlV) / (float)width;

                        Color final = Color.Lerp(c2, c, lrDistance);
                        titleBarImage.SetPixel(x, y, final);
                    }
                }
                return titleBarImage;
            }

            // This is a solid color BG
            titleBarImage = new Texture2D(1, 1);
            titleBarImage.SetPixel(0, 0, backgroundColor);
            titleBarImage.Reinitialize(width, height);
            return titleBarImage;
        }
    }
}
