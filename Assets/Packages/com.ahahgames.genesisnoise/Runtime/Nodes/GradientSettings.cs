using System;
using System.Collections.Generic;

using UnityEngine;

namespace AhahGames.GenesisNoise.Nodes
{
    [Serializable]
    public class GradientSettings
    {
        private List<GradientColorKey> _colorKeysHorizontalTop = new();
        private List<GradientColorKey> _colorKeysHorizontalBottom = new();
        private List<GradientAlphaKey> _alphaKeysHorizontalTop = new();
        private List<GradientAlphaKey> _alphaKeysHorizontalBottom = new();
        [SerializeField] private AnimationCurve _verticalLerp = AnimationCurve.EaseInOut(0, 0, 1, 1);

        public static GradientSettings CreateDefault()
        {
            var settings = new GradientSettings();
            settings.AddColorKeyToTop(new GradientColorKey(new Color(0.15f, 0.15f, 0.15f), 0f));
            settings.AddColorKeyToTop(new GradientColorKey(new Color(0.25f, 0.25f, 0.25f), 0.5f));
            settings.AddColorKeyToTop(new GradientColorKey(new Color(0.35f, 0.35f, 0.35f), 1f));
            settings.AddColorKeyToBottom(new GradientColorKey(new Color(0.35f, 0.35f, 0.35f), 0f));
            settings.AddColorKeyToBottom(new GradientColorKey(new Color(0.25f, 0.25f, 0.25f), 0.5f));
            settings.AddColorKeyToBottom(new GradientColorKey(new Color(0.15f, 0.15f, 0.15f), 1f));
            settings.AddAlphaKeyToTop(new GradientAlphaKey(0.8f, 0f));
            settings.AddAlphaKeyToTop(new GradientAlphaKey(0.8f, 1f));
            settings.AddAlphaKeyToBottom(new GradientAlphaKey(1f, 1f));
            settings.AddAlphaKeyToTop(new GradientAlphaKey(1f, 1f));
            return settings;
        }

        public void CreateTriplet(Color color1, Color color2, Color color3, bool bottomInversed = true)
        {
            AddColorKeyToTop(new GradientColorKey(color1, 0.0f));
            AddColorKeyToTop(new GradientColorKey(color2, 0.5f));
            AddColorKeyToTop(new GradientColorKey(color3, 1.0f));
            if (bottomInversed)
            {
                AddColorKeyToBottom(new GradientColorKey(color3, 0.0f));
                AddColorKeyToBottom(new GradientColorKey(color2, 0.5f));
                AddColorKeyToBottom(new GradientColorKey(color1, 1.0f));
            }
            else
            {
                AddColorKeyToBottom(new GradientColorKey(color1, 0.0f));
                AddColorKeyToBottom(new GradientColorKey(color2, 0.5f));
                AddColorKeyToBottom(new GradientColorKey(color3, 1.0f));
            }
            AddAlphaKeyToTop(new GradientAlphaKey(0.8f, 0f));
            AddAlphaKeyToTop(new GradientAlphaKey(0.8f, 1f));
            AddAlphaKeyToBottom(new GradientAlphaKey(1f, 1f));
            AddAlphaKeyToTop(new GradientAlphaKey(1f, 1f));
        }

        public void AddColorKeyToTop(GradientColorKey key)
        {
            _colorKeysHorizontalTop.Add(key);
        }

        public void AddColorKeyToBottom(GradientColorKey key)
        {
            _colorKeysHorizontalBottom.Add(key);
        }

        public void AddAlphaKeyToTop(GradientAlphaKey key)
        {
            _alphaKeysHorizontalTop.Add(key);
        }

        public void AddAlphaKeyToBottom(GradientAlphaKey key)
        {
            _alphaKeysHorizontalBottom.Add(key);
        }

        public void AddColorKeysToTop(IEnumerable<GradientColorKey> keys)
        {
            _colorKeysHorizontalTop.AddRange(keys);
        }

        public Texture2D GetGradient(int width, int height)
        {
            var texture = new Texture2D(width, height, TextureFormat.RGBA32, false, true)
            {
                filterMode = FilterMode.Bilinear,
                wrapMode = TextureWrapMode.Clamp
            };
            float tVertical = 0;
            Gradient _horizontalTop = new()
            {
                colorKeys = _colorKeysHorizontalTop.ToArray(),
                alphaKeys = _alphaKeysHorizontalTop.ToArray()
            };
            Gradient _horizontalBottom = new()
            {
                colorKeys = _colorKeysHorizontalBottom.ToArray(),
                alphaKeys = _alphaKeysHorizontalBottom.ToArray()
            };
            for (int y = 0; y < height; y++)
            {
                tVertical = _verticalLerp.Evaluate((float)y / height);

                for (int x = 0; x < width; x++)
                {
                    float tHorizontal = (float)x / width;

                    Color col = Color.Lerp(_horizontalBottom.Evaluate(tHorizontal),
                                           _horizontalTop.Evaluate(tHorizontal), tVertical);

                    texture.SetPixel(x, y, col);
                }
            }

            texture.Apply();
            return texture;
        }
    }
}
