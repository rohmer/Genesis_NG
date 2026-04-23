using AhahGames.GenesisNoise.Graph;

using GraphProcessor;

using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a 2D Poisson disk point set and outputs both a point image and the generated coordinates.

This node uses Bridson-style Poisson disk sampling to keep points evenly spaced while still feeling organic. The `Points` output contains normalized UV coordinates in the `[0, 1]` range.
")]
    [System.Serializable, NodeMenuItem("Generators/Points/Poisson Disk Points")]
    public class PoissonDiskPointsNode : GenesisNode
    {
        const float epsilon = 0.0001f;

        [Input, SerializeField]
        public int seed = 0;

        [Input, SerializeField, Min(1)]
        public int maxPointCount = 256;

        [Input, SerializeField, Range(0.001f, 0.5f)]
        public float minimumDistance = 0.05f;

        [Input, SerializeField, Range(1, 64)]
        public int attemptsPerPoint = 30;

        [SerializeField, Range(1, 16)]
        public int pointRadiusPixels = 2;

        [SerializeField]
        public Color backgroundColor = Color.black;

        [SerializeField]
        public Color pointColor = Color.white;

        [Output("Image"), NonSerialized]
        public Texture2D output;

        [Output("Points"), NonSerialized]
        public List<Vector2> points = new();

        [Output("Count"), NonSerialized]
        public int pointCount;

        [NonSerialized]
        int lastWidth = -1;

        [NonSerialized]
        int lastHeight = -1;

        [NonSerialized]
        int lastSeed;

        [NonSerialized]
        int lastMaxPointCount;

        [NonSerialized]
        int lastAttemptsPerPoint;

        [NonSerialized]
        int lastPointRadiusPixels;

        [NonSerialized]
        float lastMinimumDistance = -1f;

        [NonSerialized]
        Color lastBackgroundColor;

        [NonSerialized]
        Color lastPointColor;

        Color32[] pixelBuffer;

        public override string name => "Poisson Disk Points";
        public override string NodeGroup => "Noise";
        public override Texture previewTexture => output;
        public override bool showDefaultInspector => true;
        public override float nodeWidth => 360f;
        public override PreviewChannels defaultPreviewChannels => PreviewChannels.RGB;
        public override List<OutputDimension> supportedDimensions => new() { OutputDimension.Texture2D };
        protected override GenesisNoiseSettings defaultSettings => Get2DOnlyRTSettings(base.defaultSettings);

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            int width = Mathf.Max(1, graph != null ? settings.GetResolvedWidth(graph) : 256);
            int height = Mathf.Max(1, graph != null ? settings.GetResolvedHeight(graph) : 256);

            if (!NeedsRebuild(width, height))
                return true;

            GeneratePoints();
            BuildTexture(width, height);
            CacheSettings(width, height);

            return true;
        }

        public string GetCoordinatesText()
        {
            if (points == null || points.Count == 0)
                return "No points generated.";

            StringBuilder builder = new(points.Count * 20);
            for (int i = 0; i < points.Count; i++)
            {
                Vector2 point = points[i];
                builder.Append(i.ToString("D3", CultureInfo.InvariantCulture));
                builder.Append(": (");
                builder.Append(point.x.ToString("0.####", CultureInfo.InvariantCulture));
                builder.Append(", ");
                builder.Append(point.y.ToString("0.####", CultureInfo.InvariantCulture));
                builder.Append(')');

                if (i < points.Count - 1)
                    builder.AppendLine();
            }

            return builder.ToString();
        }

        void GeneratePoints()
        {
            points ??= new List<Vector2>();
            points.Clear();

            float radius = Mathf.Clamp(minimumDistance, 0.001f, 0.5f);
            int safeMaxPointCount = Mathf.Max(1, maxPointCount);
            int safeAttemptsPerPoint = Mathf.Max(1, attemptsPerPoint);
            float cellSize = radius / Mathf.Sqrt(2f);

            int gridWidth = Mathf.Max(1, Mathf.CeilToInt(1f / cellSize));
            int gridHeight = Mathf.Max(1, Mathf.CeilToInt(1f / cellSize));
            int[] grid = new int[gridWidth * gridHeight];
            for (int i = 0; i < grid.Length; i++)
                grid[i] = -1;

            System.Random random = new(seed);
            List<Vector2> activePoints = new(safeMaxPointCount);

            AddPoint(new Vector2(NextFloat(random), NextFloat(random)));

            while (activePoints.Count > 0 && points.Count < safeMaxPointCount)
            {
                int activeIndex = random.Next(activePoints.Count);
                Vector2 activePoint = activePoints[activeIndex];
                bool foundCandidate = false;

                for (int i = 0; i < safeAttemptsPerPoint; i++)
                {
                    Vector2 candidate = GenerateCandidate(activePoint, radius, random);

                    if (!IsInsideBounds(candidate))
                        continue;

                    if (!IsFarEnough(candidate, radius, grid, gridWidth, gridHeight))
                        continue;

                    AddPoint(candidate);
                    foundCandidate = true;

                    if (points.Count >= safeMaxPointCount)
                        break;
                }

                if (!foundCandidate)
                {
                    int lastIndex = activePoints.Count - 1;
                    activePoints[activeIndex] = activePoints[lastIndex];
                    activePoints.RemoveAt(lastIndex);
                }
            }

            pointCount = points.Count;
            return;

            void AddPoint(Vector2 point)
            {
                int pointIndex = points.Count;
                points.Add(point);
                activePoints.Add(point);

                int gx = Mathf.Clamp((int)(point.x / cellSize), 0, gridWidth - 1);
                int gy = Mathf.Clamp((int)(point.y / cellSize), 0, gridHeight - 1);
                grid[gx + gy * gridWidth] = pointIndex;
            }
        }

        static Vector2 GenerateCandidate(Vector2 center, float radius, System.Random random)
        {
            float angle = NextFloat(random) * Mathf.PI * 2f;
            float distance = Mathf.Sqrt(Mathf.Lerp(radius * radius, 4f * radius * radius, NextFloat(random)));
            return center + new Vector2(Mathf.Cos(angle), Mathf.Sin(angle)) * distance;
        }

        bool IsFarEnough(Vector2 candidate, float radius, int[] grid, int gridWidth, int gridHeight)
        {
            float cellSize = radius / Mathf.Sqrt(2f);
            int candidateX = Mathf.Clamp((int)(candidate.x / cellSize), 0, gridWidth - 1);
            int candidateY = Mathf.Clamp((int)(candidate.y / cellSize), 0, gridHeight - 1);
            float minimumDistanceSquared = radius * radius;

            for (int y = Mathf.Max(0, candidateY - 2); y <= Mathf.Min(gridHeight - 1, candidateY + 2); y++)
            {
                for (int x = Mathf.Max(0, candidateX - 2); x <= Mathf.Min(gridWidth - 1, candidateX + 2); x++)
                {
                    int pointIndex = grid[x + y * gridWidth];
                    if (pointIndex < 0)
                        continue;

                    if ((points[pointIndex] - candidate).sqrMagnitude < minimumDistanceSquared)
                        return false;
                }
            }

            return true;
        }

        void BuildTexture(int width, int height)
        {
            EnsureOutputTexture(width, height);

            Color32 background = backgroundColor;
            Color32 point = pointColor;

            int totalPixels = width * height;
            pixelBuffer ??= new Color32[totalPixels];
            if (pixelBuffer.Length != totalPixels)
                pixelBuffer = new Color32[totalPixels];

            for (int i = 0; i < totalPixels; i++)
                pixelBuffer[i] = background;

            int radius = Mathf.Max(1, pointRadiusPixels);
            int radiusSquared = radius * radius;

            foreach (Vector2 normalizedPoint in points)
            {
                int x = Mathf.Clamp(Mathf.RoundToInt(normalizedPoint.x * (width - 1)), 0, width - 1);
                int y = Mathf.Clamp(Mathf.RoundToInt(normalizedPoint.y * (height - 1)), 0, height - 1);

                for (int offsetY = -radius + 1; offsetY < radius; offsetY++)
                {
                    int drawY = y + offsetY;
                    if (drawY < 0 || drawY >= height)
                        continue;

                    for (int offsetX = -radius + 1; offsetX < radius; offsetX++)
                    {
                        if (offsetX * offsetX + offsetY * offsetY >= radiusSquared)
                            continue;

                        int drawX = x + offsetX;
                        if (drawX < 0 || drawX >= width)
                            continue;

                        pixelBuffer[drawX + drawY * width] = point;
                    }
                }
            }

            output.SetPixels32(pixelBuffer);
            output.Apply(false, false);
        }

        void EnsureOutputTexture(int width, int height)
        {
            if (output != null && output.width == width && output.height == height)
            {
                output.wrapMode = TextureWrapMode.Clamp;
                output.filterMode = FilterMode.Point;
                return;
            }

            if (output != null)
                CoreUtils.Destroy(output);

            output = new Texture2D(width, height, TextureFormat.RGBA32, false, true)
            {
                name = "Poisson Disk Points",
                wrapMode = TextureWrapMode.Clamp,
                filterMode = FilterMode.Point,
                hideFlags = HideFlags.HideAndDontSave,
            };
        }

        bool NeedsRebuild(int width, int height)
        {
            if (output == null)
                return true;

            if (width != lastWidth || height != lastHeight)
                return true;

            if (seed != lastSeed
                || maxPointCount != lastMaxPointCount
                || attemptsPerPoint != lastAttemptsPerPoint
                || pointRadiusPixels != lastPointRadiusPixels)
            {
                return true;
            }

            if (Mathf.Abs(minimumDistance - lastMinimumDistance) > epsilon)
                return true;

            if (backgroundColor != lastBackgroundColor || pointColor != lastPointColor)
                return true;

            return false;
        }

        void CacheSettings(int width, int height)
        {
            lastWidth = width;
            lastHeight = height;
            lastSeed = seed;
            lastMaxPointCount = maxPointCount;
            lastAttemptsPerPoint = attemptsPerPoint;
            lastPointRadiusPixels = pointRadiusPixels;
            lastMinimumDistance = minimumDistance;
            lastBackgroundColor = backgroundColor;
            lastPointColor = pointColor;
        }

        static bool IsInsideBounds(Vector2 point)
        {
            return point.x >= 0f && point.x <= 1f && point.y >= 0f && point.y <= 1f;
        }

        static float NextFloat(System.Random random)
        {
            return (float)random.NextDouble();
        }

        protected override void Disable()
        {
            if (output != null)
                CoreUtils.Destroy(output);

            output = null;
            points?.Clear();
            pointCount = 0;
            pixelBuffer = null;

            base.Disable();
        }
    }
}
