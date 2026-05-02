using System;

namespace AhahGames.GenesisNoise.Nodes
{
    static class ILoopStartExtensions
    {
        public static Type GetLoopValueType(this ILoopStart loopStart)
        {
            // Default to object when the loop start doesn't expose a specific loop value type.
            // Adjust this implementation if you have a concrete loop-start node type that can provide a more specific Type.
            return typeof(object);
        }
    }
}