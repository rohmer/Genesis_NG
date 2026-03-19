using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Constant/Animation Curve")]
    public class AnimationCurveNode : ConstantNode
    {
        [Output(name = "Animation Curve", allowMultiple =true)]
        public AnimationCurve output = new();
        public override string name => "Animation Curve";
        public override float nodeWidth => 150f;

    }
}