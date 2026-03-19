using UnityEngine;
using ProtoTurtle.BitmapDrawing;
using System.Collections.Generic;
using System;

namespace AhahGames.GenesisNoise.GNTerrain
{
    public class BiomeChart
    {
        private Texture2D chart;

        private struct sBiome
        {
            public sBiome(
                string name, 
                int beginningHeight, 
                int endingHeight, 
                int beginningMoisture, 
                int endingMoisture,
                Tuple<Color,Color> colors)
            {
                biomeName = name;
                this.beginningHeight = beginningHeight;
                this.endingHeight = endingHeight;
                this.beginningMoisture = beginningMoisture;
                this.endingMoisture = endingMoisture;
                this.bgColor= colors.Item1;
                this.textColor= colors.Item2;
            }

            public int beginningHeight, endingHeight, beginningMoisture, endingMoisture;
            public string biomeName;
            public Color bgColor, textColor;
        }

        List<sBiome> biomes = new List<sBiome>();

        List<Tuple<Color,Color>> colors = new List<Tuple<Color,Color>>();

        public BiomeChart(int width, int height)
        {
            chart= new Texture2D(width, height);
            colors.Add(new Tuple<Color, Color>(Color.darkGreen, Color.white));
            colors.Add(new Tuple<Color, Color>(Color.darkRed, Color.white));
            colors.Add(new Tuple<Color, Color>(Color.darkGoldenRod, Color.white));
            colors.Add(new Tuple<Color, Color>(Color.darkCyan, Color.white));
            colors.Add(new Tuple<Color, Color>(Color.darkKhaki, Color.white));
            colors.Add(new Tuple<Color, Color>(Color.darkViolet, Color.white));
            colors.Add(new Tuple<Color, Color>(Color.darkTurquoise, Color.white));
            colors.Add(new Tuple<Color, Color>(Color.darkSlateBlue, Color.white));
            colors.Add(new Tuple<Color, Color>(Color.darkSeaGreen, Color.white));
            colors.Add(new Tuple<Color, Color>(Color.darkOrange, Color.white));
            colors.Add(new Tuple<Color, Color>(Color.darkMagenta, Color.white));
            colors.Add(new Tuple<Color, Color>(Color.darkBlue, Color.white));
            colors.Add(new Tuple<Color, Color>(Color.deepSkyBlue, Color.white));
            colors.Add(new Tuple<Color, Color>(Color.lightBlue, Color.black));
            colors.Add(new Tuple<Color, Color>(Color.lightCoral, Color.black));
            colors.Add(new Tuple<Color, Color>(Color.lightCyan, Color.black));
            colors.Add(new Tuple<Color, Color>(Color.lightGoldenRod, Color.black));
            colors.Add(new Tuple<Color, Color>(Color.lightGoldenRodYellow, Color.black));
            colors.Add(new Tuple<Color, Color>(Color.lightGray, Color.black));
            colors.Add(new Tuple<Color, Color>(Color.lightGreen, Color.black));
            colors.Add(new Tuple<Color, Color>(Color.lightPink, Color.black));
            colors.Add(new Tuple<Color, Color>(Color.lightSalmon, Color.black));
            colors.Add(new Tuple<Color, Color>(Color.lightSeaGreen, Color.black));
            colors.Add(new Tuple<Color, Color>(Color.lightSkyBlue, Color.black));
            colors.Add(new Tuple<Color, Color>(Color.lightSlateBlue, Color.black));
            drawChart();            
        }
        
        public void AddBiome(string biomeName, 
            int beginningHeight, 
            int endingHeight,
            int beginningMoisture,
            int endingMoisture)
        {
            int cCounter = biomes.Count;
            while (cCounter > colors.Count)
                cCounter -= colors.Count;
            biomes.Add(
                new sBiome(
                    biomeName,
                    beginningHeight,
                    endingHeight,
                    beginningMoisture,
                    endingMoisture,
                    colors[cCounter]
                    )
            );
            drawChart();
        }

        public Texture2D GetChart() { return chart; }
        
        public void ClearBiomes()
        {
            biomes.Clear();
        }

        private void addTextToChart(Texture2D texture, string text, Vector2 position, Color textColor, Color backgroundColor)
        {            
        }

        private string biomeName(int moisture, int height)
        {
            foreach(var biome in biomes)
            {
                if(biome.beginningMoisture<=moisture && biome.endingMoisture>=moisture)
                {
                    if(biome.beginningHeight<=height && biome.endingHeight>=height)
                    {
                        return biome.biomeName;
                    }
                }
            }

            return String.Empty;
        }


        internal void drawChart()
        {
            chart.DrawFilledRectangle(new Rect(0,0,chart.width,chart.height), Color.darkGray);
            int bcounter = 0;
            string biome = string.Empty;
            for(int moisture=6; moisture>=1; moisture--)
            { 
                for(int height=1; height<=6; height++)
                {
                    string v = biomeName(moisture, height);
                    if(!(v.Length==0))
                    {
                        if (v != biome)
                            bcounter++;
                        biome = v;  
                        chart.DrawFilledRectangle(
                            new Rect((height - 1) * 50, (Mathf.Abs(moisture - 6) * 50), 50, 50),
                            colors[bcounter].Item1);
                    } else
                    {
                        chart.DrawFilledRectangle(
                            new Rect((height - 1) * 50, (Mathf.Abs(moisture - 6) * 50), 50, 50),
                            Color.white);
                    }
                    chart.DrawRectangle(
                        new Rect((height - 1) * 50, (Mathf.Abs(moisture - 6) * 50), 50, 50),
                        Color.black);

                }
            }
            
            chart.Apply();
        }
        

    }
}