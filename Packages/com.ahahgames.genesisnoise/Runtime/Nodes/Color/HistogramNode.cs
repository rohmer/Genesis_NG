using GraphProcessor;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Color/Histogram")]
    public class HistogramNode : ComputeShaderNode
    {
        protected override string computeShaderResourcePath => "GenesisNoise/AdvHistogram";

        [Input]
        public Texture input;

        [Input]
        public float min = 0;
        [Input]
        public float max = 1;

        [Output]
        Texture output;

        public override string name => "Histogram";
        public override string NodeGroup => "Color";
        public override bool showDefaultInspector => true;


        internal static readonly int histogramBucketCount = 256;

        const int ThreadGroupSize = 64;

        Material _viewMaterial;

        GraphicsBuffer NewBuffer(int length)
            => new(GraphicsBuffer.Target.Structured, length, 4);

        (GraphicsBuffer temp, GraphicsBuffer total) _buffer;

        protected override void Enable()
        {
            base.Enable();

        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (!base.ProcessNode(cmd) || input == null)
                return false;

            var dims = new Vector2Int(input.width, input.height);

            _buffer.temp = NewBuffer(dims.y / ThreadGroupSize * histogramBucketCount);
            _buffer.total = NewBuffer(histogramBucketCount);

            // _viewMaterial = new Material(LoadComputeShader(computeShaderResourcePath));

            return true;
        }

        protected override void Disable()
        {
            base.Disable();
        }
    }
}