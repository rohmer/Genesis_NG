using AhahGames.GenesisNoise.Nodes;


using GraphProcessor;

using System;
using System.Collections.Generic;
using System.Linq;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{

    [Documentation(@"
Point Generation is the basis for all other terrain generatiion functions.
Random point generation is just that, a number of points is selected and that many random points will be created
")]

    [Serializable, NodeMenuItem("Terrain/Point Generation/Blue Noise")]
    public class BlueNoisePointGenerationNode : GenesisNode
    {
        [SerializeField, ShowInInspector]
        public int NumberOfPoints = 4096;

        [SerializeField, ShowInInspector]
        public eTerrainSize TerrainSize = eTerrainSize.x4096;

        [SerializeField, Output]
        public PointGenerationData Output = new PointGenerationData();

        [SerializeField]
        public float Radius = 2.5f;

        [SerializeField]
        public int Seed = 52;

        public override bool hasPreview => false;
        public override string NodeGroup => "Terrain";
        public override string name => "Blue Noise Pt Generator";
        public override bool showDefaultInspector => false;
        private ComputeShader shader = null;

        public override float nodeWidth => 300;
        internal Texture2D pointPreview;
        Color[] clearArray = new Color[300 * 300];

        // Buffers
        ComputeBuffer positions;   // float2
        ComputeBuffer priority;    // uint
        ComputeBuffer valid;       // uint
        ComputeBuffer next;        // int
        ComputeBuffer cellHead;    // int
        ComputeBuffer outPoints;   // float2 (Append)
        ComputeBuffer outCount;    // uint (1)

        int kClear, kGenBin, kCull, kEmit;

        float size;

        protected override void Enable()
        {
            base.Enable();
            pointPreview = new Texture2D(300, 300);
            clearArray = pointPreview.GetPixels();
            for (int i = 0; i < clearArray.Length; i++)
                clearArray[i] = Color.black;
        }

        internal void GeneratePoints()
        {
            Output = new PointGenerationData();
            Output.Points = new List<Vector2>(NumberOfPoints);
            Output.TerrainSize = TerrainSize;
            pointPreview = new Texture2D(300, 300);
            pointPreview.SetPixels(clearArray);
            pointPreview.Apply();
            float mod = 300.0f / (float)Output.GetSize();

            if (shader == null)
            {
                shader = Resources.Load<ComputeShader>("GenesisNoise/Terrain/PointGenerator/BlueNoisePointGenerator");
                kClear = shader.FindKernel("CS_ClearGrid");
                kGenBin = shader.FindKernel("CS_GenerateAndBin");
                kCull = shader.FindKernel("CS_CullConflicts");
                kEmit = shader.FindKernel("CS_EmitValid");
            }
            size = Output.GetSize();

            releaseAll();

            int gSize = Mathf.Max(1, Mathf.CeilToInt(size / Mathf.Max(1e-6f, Radius)));
            int cellCount = gSize * gSize;
            // Allocate
            positions = new ComputeBuffer(NumberOfPoints, sizeof(float) * 2);
            priority = new ComputeBuffer(NumberOfPoints, sizeof(uint));
            valid = new ComputeBuffer(NumberOfPoints, sizeof(uint));
            next = new ComputeBuffer(NumberOfPoints, sizeof(int));
            cellHead = new ComputeBuffer(cellCount, sizeof(int));
            outPoints = new ComputeBuffer(NumberOfPoints, sizeof(float) * 2, ComputeBufferType.Append);
            outCount = new ComputeBuffer(1, sizeof(uint), ComputeBufferType.Raw);

            outPoints.SetCounterValue(0);
            // Set params
            shader.SetInt("_CandidateCount", NumberOfPoints);
            shader.SetInt("_GridDimX", gSize);
            shader.SetInt("_GridDimY", gSize);
            shader.SetInt("_Seed", Seed);
            shader.SetFloat("_Width", size);
            shader.SetFloat("_Height", size);
            shader.SetFloat("_Radius", Radius);

            // Bind buffers
            foreach (var k in new[] { kClear, kGenBin, kCull, kEmit })
            {
                shader.SetBuffer(k, "Positions", positions);
                shader.SetBuffer(k, "Priority", priority);
                shader.SetBuffer(k, "Valid", valid);
                shader.SetBuffer(k, "Next", next);
                shader.SetBuffer(k, "CellHead", cellHead);
            }
            shader.SetBuffer(kEmit, "OutPoints", outPoints);
            // Dispatch
            int groupsCandidates = Mathf.CeilToInt(NumberOfPoints / 128.0f);
            int groupsCells = Mathf.CeilToInt(cellCount / 128.0f);

            shader.Dispatch(kClear, groupsCells, 1, 1);
            shader.Dispatch(kGenBin, groupsCandidates, 1, 1);
            shader.Dispatch(kCull, groupsCandidates, 1, 1);
            shader.Dispatch(kEmit, groupsCandidates, 1, 1);
            // Read back count
            ComputeBuffer.CopyCount(outPoints, outCount, 0);
            uint[] countArr = { 0 };
            outCount.GetData(countArr);
            int outN = (int)countArr[0];

            Vector2[] points = new Vector2[NumberOfPoints];
            // Read back points
            outPoints.GetData(points, 0, 0, outN);
            uint[] pointCount = new uint[1];
            outCount.GetData(pointCount);
            for (int i = 0; i < (int)pointCount[0]; i++)
            {
                Output.Points.Add(points[i]);
                int prevX = Mathf.RoundToInt(points[i].x * mod);
                int prevY = Mathf.RoundToInt(points[i].y * mod);
                pointPreview.SetPixel(prevX, prevY, Color.white);

            }

            pointPreview.Apply();
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            base.ProcessNode(cmd);
            // Since this one is so fast, and we have to iterate anyway, we can do it on CPU
            GeneratePoints();
            return true;
        }

        void releaseAll()
        {
            positions?.Release(); positions = null;
            priority?.Release(); priority = null;
            valid?.Release(); valid = null;
            next?.Release(); next = null;
            cellHead?.Release(); cellHead = null;
            outPoints?.Release(); outPoints = null;
            outCount?.Release(); outCount = null;
        }
    }
}
