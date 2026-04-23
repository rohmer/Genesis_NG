using GraphProcessor;

using System;

using UnityEngine;

namespace AhahGames.GenesisNoise.Nodes
{
    /// <summary>
    /// An input node for a recipe graph
    /// When minimized this will be an input port
    /// </summary>
    [Documentation(@"
Declares an input for a reusable recipe graph.
")]

    [Serializable, NodeMenuItem("Recipe/Recipe Input")]
    public class RecipeInputNode : GenesisNode
    {
        [Input(name = "Input", allowMultiple = false)]
        public object input;
        [Output(name = "Output", allowMultiple = true)]
        public object output;
        public override Color color => Color.rebeccaPurple;
        public override string name => "Recipe Node input";

        public override string NodeGroup => "Recipe";


        public override void Process()
        {
            base.Process();
            output = input;
        }
    }
}
