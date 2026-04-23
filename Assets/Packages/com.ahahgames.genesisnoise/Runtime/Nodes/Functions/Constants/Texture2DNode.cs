using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Outputs a constant texture 2d value.
")]

    [System.Serializable, NodeMenuItem("Function/Constant/Texture 2D")]
    public class Texture2DNode : ConstantNode
    {
        [Output("Texture 2D")]
        public Texture2D output = null;
        public override string name => "Texture 2D";
        public override string NodeGroup => "Constant";
    }
}
