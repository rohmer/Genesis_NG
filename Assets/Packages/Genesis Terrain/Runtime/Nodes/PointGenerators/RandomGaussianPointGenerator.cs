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

    [Serializable, NodeMenuItem("Terrain/Point Generation/Gaussian Random")]
    public class RandomGaussianPointGenerationNode : GenesisNode
    {
        [SerializeField, ShowInInspector]
        public int NumberOfPoints = 4096;

        [SerializeField, ShowInInspector]
        public eTerrainSize TerrainSize = eTerrainSize.x4096;

        [SerializeField, Output]
        public PointGenerationData Output = new PointGenerationData();

        public override bool hasPreview => false;
        public override string NodeGroup => "Terrain";
        public override string name => "Gaussian Random Point Generator";
        public override bool showDefaultInspector => false;
        private ComputeShader shader = null;

        public override float nodeWidth => 300;
        public Texture2D pointPreview;
        Color[] clearArray = new Color[300 * 300];
        protected override void Enable()
        {
            base.Enable();
            pointPreview = new Texture2D(300, 300);
            clearArray = pointPreview.GetPixels();
            for (int i = 0; i < clearArray.Length; i++)
                clearArray[i] = Color.black;
        }

        protected float GetNextRandomValue(float min, float max)
        {
            float stdDev = 1.0f / 3.0f;
            float mid = (max + min) / 2.0f;
            do
            {
                float u1 = 1.0f - UnityEngine.Random.Range(0.0f, 1.0f);
                float u2 = 1.0f - UnityEngine.Random.Range(0.0f, 1.0f);
                float randStdNormal = Mathf.Sqrt(-2.0f * Mathf.Log(u1)) * Mathf.Sin(2.0f * Mathf.PI * u2);
                float value = stdDev * randStdNormal;
                float coord = mid + value * mid;
                if (coord >= min && coord <= max)
                    return coord;
            } while (true);
        }

        public void GeneratePoints()
        {
            Output = new PointGenerationData();
            Output.Points = new List<Vector2>(NumberOfPoints);
            Output.TerrainSize = TerrainSize;
            pointPreview = new Texture2D(300, 300);
            pointPreview.SetPixels(clearArray);
            pointPreview.Apply();
            HashSet<Vector2> points = new HashSet<Vector2>();
            float mod = 300.0f / (float)Output.GetSize();
            for (int i = 0; i < NumberOfPoints; i++)
            {
                Vector2 pt = new Vector2(GetNextRandomValue(0, Output.GetSize()), GetNextRandomValue(0, Output.GetSize()));
                points.Add(pt);
                int prevX = Mathf.RoundToInt(pt.x * mod);
                int prevY = Mathf.RoundToInt(pt.y * mod);
                pointPreview.SetPixel(prevX, prevY, Color.white);
            }
            pointPreview.Apply();
            Output.Points.AddRange(points);
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            base.ProcessNode(cmd);
            // Since this one is so fast, and we have to iterate anyway, we can do it on CPU
            GeneratePoints();
            return true;
        }
    }
}
