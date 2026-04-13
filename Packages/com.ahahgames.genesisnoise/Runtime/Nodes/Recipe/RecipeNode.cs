using GraphProcessor;

using System;
using System.Collections.Generic;

using UnityEditor.Experimental.GraphView;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Defines a reusable recipe graph.
")]

    [Serializable, NodeMenuItem("Recipe/Recipe")]
    public class RecipeNode : GraphProcessor.Group
    {
        public List<Port> inputPorts = new();
        public List<Port> outputPorts = new();

        // For serialization loading
        public RecipeNode() { }

        /// <summary>
        /// Create a new group with a title and a position
        /// </summary>
        /// <param name="title"></param>
        /// <param name="position"></param>
        public RecipeNode(string title, Vector2 position)
        {
            this.title = title;
            this.position.position = position;
        }

        /// <summary>
        /// Called when the Group is created
        /// </summary>
        public virtual void OnCreated()
        {
            size = new Vector2(400, 400);
            position.size = size;
        }
    }
}

