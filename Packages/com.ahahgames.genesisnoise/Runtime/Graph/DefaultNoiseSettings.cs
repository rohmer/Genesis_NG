using AhahGames.GenesisNoise.Nodes;

using System.Collections.Generic;

using UnityEngine;

namespace AhahGames.GenesisNoise.Graph
{
    public static class DefaultNodeSettings
    {
        public static Dictionary<string, NodeTheme> CreateSettings()
        {
            Dictionary<string, NodeTheme> settings = new();
            //TODO: Eventually have nice ones for everything, right now, just groups
            /*
            settings = NoiseNode(settings);
            settings = PerlinNoise(settings);
            settings = WhiteNoise(settings);
            settings = RidgedPerlinNoise(settings);
            settings = VoronoiNoise(settings);*/
            settings = Constants(settings);
            settings = Generators(settings);
            settings = Colors(settings);
            return settings;
        }

        internal static Dictionary<string, NodeTheme> NoiseNode(Dictionary<string, NodeTheme> settings)
        {
            GradientSettings titleGradient = new();
            titleGradient.AddColorKeyToTop(new GradientColorKey(new Color(0.15f, 0.15f, 0.15f), 0.0f));
            titleGradient.AddColorKeyToTop(new GradientColorKey(new Color(0.25f, 0.25f, 0.25f), 0.5f));
            titleGradient.AddColorKeyToTop(new GradientColorKey(new Color(0.15f, 0.15f, 0.15f), 1.0f));
            titleGradient.AddColorKeyToBottom(new GradientColorKey(new Color(0.5f, 0.1f, 0.1f), 0.0f));
            titleGradient.AddColorKeyToBottom(new GradientColorKey(new Color(0.1f, 0.5f, 0.1f), 0.5f));
            titleGradient.AddColorKeyToBottom(new GradientColorKey(new Color(0.1f, 0.5f, 0.5f), 1.0f));
            titleGradient.AddAlphaKeyToTop(new GradientAlphaKey(0.7f, 0f));
            titleGradient.AddAlphaKeyToTop(new GradientAlphaKey(1f, 1f));
            titleGradient.AddAlphaKeyToBottom(new GradientAlphaKey(1f, 0f));
            titleGradient.AddAlphaKeyToBottom(new GradientAlphaKey(0.7f, 1f));

            NodeTheme theme = new();
            theme.TitleTextColor = new Color(0.4f, 0.4f, 0.4f);
            theme.TitleGradient = titleGradient;
            settings.Add("Noise", theme);

            return settings;
        }

        internal static Dictionary<string, NodeTheme> Generators(Dictionary<string, NodeTheme> settings)
        {

            GradientSettings Gsettings = new();
            Gsettings.CreateTriplet(Color.darkRed, Color.darkSalmon, Color.darkSlateBlue);
            NodeTheme theme = new();
            theme.TitleTextColor = Color.white;
            theme.TitleGradient = Gsettings;
            settings.Add("Generators", theme);
            return settings;
        }

        internal static Dictionary<string, NodeTheme> Colors(Dictionary<string, NodeTheme> settings)
        {

            GradientSettings Gsettings = new();
            Gsettings.CreateTriplet(Color.darkRed, Color.darkGreen, Color.darkBlue);
            NodeTheme theme = new();
            theme.TitleTextColor = Color.gray1;
            theme.TitleGradient = Gsettings;
            settings.Add("Color", theme);
            return settings;
        }


        internal static Dictionary<string, NodeTheme> RidgedPerlinNoise(Dictionary<string, NodeTheme> settings)
        {

            GradientSettings Gsettings = new();
            Gsettings.CreateTriplet(new Color(0.0f, 0.0f, 0.0f), new Color(0.5f, 0.45f, 0.45f), new Color(0.1f, 0.1f, 0.1f));
            NodeTheme theme = new();
            theme.TitleTextColor = Color.gray1;
            theme.TitleGradient = Gsettings;
            settings.Add("Ridged Perlin Noise", theme);
            return settings;
        }

        internal static Dictionary<string, NodeTheme> PerlinNoise(Dictionary<string, NodeTheme> settings)
        {

            GradientSettings Gsettings = new();
            Gsettings.CreateTriplet(new Color(0.0f, 0.0f, 0.0f), new Color(0.3f, 0.3f, 0.3f), new Color(0.1f, 0.1f, 0.1f));
            NodeTheme theme = new();
            theme.TitleTextColor = Color.whiteSmoke;
            theme.TitleGradient = Gsettings;
            settings.Add("Perlin Noise", theme);
            return settings;
        }

        internal static Dictionary<string, NodeTheme> RidgedCellularNoise(Dictionary<string, NodeTheme> settings)
        {

            GradientSettings Gsettings = new();
            Gsettings.CreateTriplet(new Color(0.0f, 0.0f, 0.0f), new Color(0.1f, 0.1f, 0.1f), new Color(0.0f, 0.0f, 0.0f));
            NodeTheme theme = new();
            theme.TitleTextColor = Color.whiteSmoke;
            theme.TitleGradient = Gsettings;
            settings.Add("Ridged Cellular Noise", theme);
            return settings;
        }

        internal static Dictionary<string, NodeTheme> VoronoiNoise(Dictionary<string, NodeTheme> settings)
        {

            GradientSettings Gsettings = new();
            Gsettings.AddColorKeyToTop(new GradientColorKey(Color.antiqueWhite, 0.0f));
            Gsettings.AddColorKeyToTop(new GradientColorKey(Color.floralWhite, 0.45f));
            Gsettings.AddColorKeyToTop(new GradientColorKey(Color.black, 0.5f));
            Gsettings.AddColorKeyToTop(new GradientColorKey(Color.floralWhite, 0.55f));
            Gsettings.AddColorKeyToTop(new GradientColorKey(Color.antiqueWhite, 1f));
            NodeTheme theme = new();
            theme.TitleGradient = Gsettings;
            theme.TitleTextColor = Color.black;
            settings.Add("Voronoi Noise", theme);
            return settings;
        }

        internal static Dictionary<string, NodeTheme> Constants(Dictionary<string, NodeTheme> settings)
        {

            GradientSettings Gsettings = new();
            Gsettings.AddColorKeyToTop(new GradientColorKey(Color.darkBlue, 0.0f));
            Gsettings.AddColorKeyToTop(new GradientColorKey(Color.darkCyan, 0.45f));
            Gsettings.AddColorKeyToTop(new GradientColorKey(Color.lightCyan, 0.5f));
            Gsettings.AddColorKeyToTop(new GradientColorKey(Color.darkCyan, 0.55f));
            Gsettings.AddColorKeyToTop(new GradientColorKey(Color.darkBlue, 1f));
            NodeTheme theme = new();
            theme.TitleGradient = Gsettings;
            theme.TitleTextColor = Color.black;
            settings.Add("Constants", theme);
            return settings;
        }

        internal static Dictionary<string, NodeTheme> WhiteNoise(Dictionary<string, NodeTheme> settings)
        {
            GradientSettings titleGradient = new();

            for (int i = 0; i <= 10; i += 3)
            {
                float v = (float)i / 10.0f;

                if (i == 0 || i % 2 == 0)
                {
                    if (i == 0)
                    {
                        titleGradient.AddColorKeyToTop(new GradientColorKey(new Color(0.35f, 0.35f, 0.35f), 0));
                        titleGradient.AddColorKeyToBottom(new GradientColorKey(new Color(0.1f, 0.1f, 0.1f), 0));
                    }
                    else
                    {
                        titleGradient.AddColorKeyToTop(new GradientColorKey(new Color(0.35f, 0.35f, 0.35f), v));
                        titleGradient.AddColorKeyToBottom(new GradientColorKey(new Color(0.1f, 0.1f, 0.1f), v));
                    }
                }
                else
                {
                    titleGradient.AddColorKeyToTop(new GradientColorKey(new Color(0.1f, 0.1f, 0.1f), v));
                    titleGradient.AddColorKeyToBottom(new GradientColorKey(new Color(0.35f, 0.35f, 0.35f), v));
                }
            }
            NodeTheme theme = new();
            theme.TitleTextColor = Color.black;
            theme.TitleGradient = titleGradient;
            settings.Add("White Noise", theme);
            return settings;
        }
    }



}