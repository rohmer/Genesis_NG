using UnityEngine;

namespace AhahGames.GenesisNoise.Graph
{
    public enum LoopControlSignal
    {
        Break,
        Continue
    }

    public static class GenesisGraphProcessorExtensions
    {
        public static void RequestLoopControl(this GenesisGraphProcessor processor, LoopControlSignal signal)
        {
            if (processor == null) return;
            // Minimal compatibility shim: record or signal loop control.
            // Implementation is intentionally lightweight to avoid changing processor internals.
            Debug.Log($"RequestLoopControl called with: {signal}");
        }
    }
}