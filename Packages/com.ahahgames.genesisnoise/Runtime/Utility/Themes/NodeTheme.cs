using System;
using System.Collections.Generic;
using System.Text;

using UnityEngine;

namespace AhahGames.GenesisNoise.Runtime.Utility.Themes
{
    [Serializable]
    public class NodeTheme
    {
        public Color HeaderTextColor;

        /// <summary>
        /// If 1 color, the header block is a solid color
        /// If 2 colors, 0 is the left color, 1 is the right color        
        /// </summary>
        public Color HeaderLeftColor=Color.darkRed;
        public Color HeaderRightColor=Color.darkBlue;

        public Color[] BorderColors;
        public Texture2D NodeIcon;

        public Color BackgroundColor;

        private Texture2D header = null;

        public Texture2D GetHeader(int width, int height)
        {
            if (header != null)
                return header;

            header = new Texture2D(width, height);
            Gradient g = new Gradient();
            g.colorKeys = new GradientColorKey[2]
            {
                new GradientColorKey(HeaderLeftColor,0),
                new GradientColorKey(HeaderRightColor,1)
            }; 

            for(int x=0; x<width; x++)
            {
                float time = (1.0f / width)*x;
                Color color = g.Evaluate(time);
                for (int y = 0; y < height; y++)
                {
                    header.SetPixel(x, y, color);
                }
            }
            header.Apply();            
            return header;
        }
    }
}
