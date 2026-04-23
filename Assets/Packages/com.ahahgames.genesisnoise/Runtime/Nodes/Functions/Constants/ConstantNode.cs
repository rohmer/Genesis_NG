namespace AhahGames.GenesisNoise.Nodes
{
    /// <summary>
    /// Base class for constant nodes.
    /// </summary>
    [System.Serializable]
    public abstract class ConstantNode : GenesisNode
    {
        public override string NodeGroup => "Constant";

        /// <summary>
        /// Gets the width of the node.
        /// </summary>

        internal override float processingTime => 0.0f;
        public override float nodeWidth => 150f;

        public override bool hasSettings => false;       
    }
}