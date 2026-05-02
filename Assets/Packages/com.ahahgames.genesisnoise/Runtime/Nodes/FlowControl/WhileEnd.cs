using AhahGames.GenesisNoise;

using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Closes a while-loop flow block.
")]
    [UnityEngine.Scripting.APIUpdating.MovedFrom(false, sourceNamespace: "Genesis", sourceAssembly: "Genesis Noise", sourceClassName: "WhileEnd")]
    [System.Serializable, NodeMenuItem("Conditional/While End")]
    public class WhileEnd : ForEnd
    {
        public override string name => "While End";
    }
}
