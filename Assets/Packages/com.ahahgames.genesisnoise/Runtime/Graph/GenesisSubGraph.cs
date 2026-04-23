using System;

using UnityEditor.Experimental.GraphView;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Graph
{
    [Serializable]
    public class GenesisSubGraph : GraphElement
    {
        public GenesisSubGraph()
        {
            style.width = 400;
            style.height = 300;
            style.backgroundColor = new Color(0.2f, 0.2f, 0.3f, 0.8f);
            Add(new Label("Subgraph"));
            capabilities |= Capabilities.Movable | Capabilities.Resizable;

        }

    }
}