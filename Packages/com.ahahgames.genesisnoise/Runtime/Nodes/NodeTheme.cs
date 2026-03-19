using System;

using UnityEngine;

namespace AhahGames.GenesisNoise.Nodes
{
    [Serializable]
    public class NodeTheme
    {
        [SerializeField] private Color _titleTextColor = new(0.5f, 0.5f, 0.5f);
        [SerializeField] private Color _borderColor = new(0.35f, 0.35f, 0.35f);
        [SerializeField] private GradientSettings _titleGradient = GradientSettings.CreateDefault();
        public GradientSettings TitleGradient
        {
            get { return _titleGradient; }
            set { _titleGradient = value; }
        }
        public Color TitleTextColor
        {
            get { return _titleTextColor; }
            set { _titleTextColor = value; }
        }
        public Color BorderColor
        {
            get { return _borderColor; }
            set { _borderColor = value; }
        }
    }
}