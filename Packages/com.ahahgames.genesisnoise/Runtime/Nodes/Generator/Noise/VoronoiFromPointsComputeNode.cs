using AhahGames.GenesisNoise.Graph;

using GraphProcessor;

using System;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Builds a Voronoi texture from an input list of normalized 2D points on the GPU.

Connect the `Points` output from a point generator to drive the cell layout directly. This compute version mirrors the CPU node's distance, borders, hashed grayscale IDs, and hashed cell color modes while scaling better to larger previews and denser point sets.
")]
    [System.Serializable, NodeMenuItem("Generators/Noise/Voronoi From Points (Compute)")]
    public class VoronoiFromPointsComputeNode : ComputeShaderNode
    {
        public enum OutputMode
        {
            Distance,
            Borders,
            CellId,
            CellColor,
        }

        [Input, SerializeField]
        public List<Vector2> inputPoints = new();

        [SerializeField]
        public OutputMode outputMode = OutputMode.Distance;

        [SerializeField, Range(0.001f, 1f)]
        public float distanceScale = 0.25f;

        [SerializeField, Range(0.0001f, 0.25f)]
        public float borderWidth = 0.02f;

        [SerializeField]
        public bool invert = false;

        [SerializeField]
        public Color emptyColor = Color.black;

        [Output("Image"), NonSerialized]
        public Texture output;

        [Output("Count"), NonSerialized]
        public int pointCount;

        ComputeBuffer pointBuffer;
        Vector2[] pointUploadData;
        readonly Vector2[] emptyPointData = new Vector2[1];

        int renderKernel = -1;

        static readonly int _Points = Shader.PropertyToID("_Points");
        static readonly int _PointCount = Shader.PropertyToID("_PointCount");
        static readonly int _OutputMode = Shader.PropertyToID("_OutputMode");
        static readonly int _DistanceScale = Shader.PropertyToID("_DistanceScale");
        static readonly int _BorderWidth = Shader.PropertyToID("_BorderWidth");
        static readonly int _Invert = Shader.PropertyToID("_Invert");
        static readonly int _EmptyColor = Shader.PropertyToID("_EmptyColor");

        public override string name => "Voronoi From Points (Compute)";
        public override string NodeGroup => "Noise";
        public override bool showDefaultInspector => true;
        protected override string computeShaderResourcePath => "GenesisNoise/VoronoiFromPoints";
        public override List<OutputDimension> supportedDimensions => new() { OutputDimension.Texture2D };
        protected override GenesisNoiseSettings defaultSettings => Get2DOnlyRTSettings(base.defaultSettings);

        protected override void Enable()
        {
            base.Enable();
            EnsurePointBufferCapacity(1);
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (!base.ProcessNode(cmd) || computeShader == null)
                return false;

            if (renderKernel == -1)
                renderKernel = computeShader.FindKernel("RenderVoronoi");

            int count = inputPoints?.Count ?? 0;
            EnsurePointBufferCapacity(Mathf.Max(1, count));
            UploadPointData(count);

            cmd.SetComputeBufferParam(computeShader, renderKernel, _Points, pointBuffer);
            cmd.SetComputeIntParam(computeShader, _PointCount, count);
            cmd.SetComputeIntParam(computeShader, _OutputMode, (int)outputMode);
            cmd.SetComputeFloatParam(computeShader, _DistanceScale, distanceScale);
            cmd.SetComputeFloatParam(computeShader, _BorderWidth, borderWidth);
            cmd.SetComputeIntParam(computeShader, _Invert, invert ? 1 : 0);
            cmd.SetComputeVectorParam(computeShader, _EmptyColor, emptyColor);

            DispatchComputePreview(cmd, renderKernel);

            output = tempRenderTexture;
            pointCount = count;
            return true;
        }

        void UploadPointData(int count)
        {
            if (pointBuffer == null)
                return;

            if (count <= 0)
            {
                emptyPointData[0] = Vector2.zero;
                pointBuffer.SetData(emptyPointData);
                return;
            }

            if (pointUploadData == null || pointUploadData.Length < count)
                pointUploadData = new Vector2[Mathf.NextPowerOfTwo(count)];

            for (int i = 0; i < count; i++)
                pointUploadData[i] = inputPoints[i];

            pointBuffer.SetData(pointUploadData, 0, 0, count);
        }

        void EnsurePointBufferCapacity(int requiredCount)
        {
            requiredCount = Mathf.Max(1, requiredCount);

            if (pointBuffer != null && pointBuffer.count >= requiredCount)
                return;

            pointBuffer?.Dispose();
            pointBuffer = new ComputeBuffer(Mathf.NextPowerOfTwo(requiredCount), sizeof(float) * 2, ComputeBufferType.Structured);
        }

        protected override void Disable()
        {
            pointBuffer?.Dispose();
            pointBuffer = null;
            pointUploadData = null;
            output = null;
            pointCount = 0;
            renderKernel = -1;

            base.Disable();
        }
    }
}
