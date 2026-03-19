using GraphProcessor;

using System;

using UnityEngine;

namespace AhahGames.GenesisNoise.Nodes
{
    /// <summary>
    /// An output node for a recipe graph
    /// When minimized this will be an output port
    /// </summary>
    [Serializable, NodeMenuItem("Recipe/Recipe Output")]
    public class RecipeOutputNode : GenesisNode
    {
        [Input(name = "Input", allowMultiple = false)]
        public object input;
        [Output(name = "Output", allowMultiple = true)]
        public object output;
        public override Color color => Color.aliceBlue;
        public override string name => "Recipe Node Output";

        public override string NodeGroup => "Recipe";


        public override void Process()
        {
            base.Process();
            output = input;
        }
    }
}