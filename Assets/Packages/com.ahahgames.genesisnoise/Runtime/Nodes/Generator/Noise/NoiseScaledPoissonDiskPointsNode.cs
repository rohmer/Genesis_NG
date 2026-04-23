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
Generates adaptive Poisson disk points using a noise texture to scale the local disk size.

Darker areas use the smaller disk size and produce denser point placement, while brighter areas use the larger disk size and push points farther apart. The `Points` output contains normalized UV coordinates in the `[0, 1]` range.
")]
    [System.Serializable, NodeMenuItem("Generators/Points/Poisson Disk Points From Noise")]
    public class NoiseScaledPoissonDiskPointsNode : GenesisNode
    {
        const float epsilon = 0.0001f;

        [Input, SerializeField]
        public Texture noiseInput;

        [Input, SerializeField]
        public int seed = 0;

        [Input, SerializeField, Min(1)]
        public int maxPointCount = 256;

        [Input, SerializeField, Range(0.001f, 0.5f)]
        public float minimumDistance = 0.02f;

        [Input, SerializeField, Range(0.001f, 0.5f)]
        public float maximumDistance = 0.08f;

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
        float lastMaximumDistance = -1f;

        [NonSerialized]
        Color lastBackgroundColor;

        [NonSerialized]
        Color lastPointColor;

        Texture2D readableNoise;
        Color32[] pixelBuffer;
        readonly List<float> pointDistances = new();

        float minDistanceUsed;
        float maxDistanceUsed;

        public override string name => "Poisson Disk Points From Noise";
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
            pointDistances.Clear();

            minDistanceUsed = Mathf.Clamp(minimumDistance, 0.001f, 0.5f);
            maxDistanceUsed = Mathf.Clamp(Mathf.Max(minDistanceUsed, maximumDistance), minDistanceUsed, 0.5f);

            int safeMaxPointCount = Mathf.Max(1, maxPointCount);
            int safeAttemptsPerPoint = Mathf.Max(1, attemptsPerPoint);

            if (noiseInput != null)
                UpdateReadableNoise(noiseInput);
            else if (readableNoise != null)
            {
                CoreUtils.Destroy(readableNoise);
                readableNoise = null;
            }

            float cellSize = maxDistanceUsed;
            Dictionary<Vector2Int, List<int>> occupiedCells = new();
            List<int> activePoints = new(safeMaxPointCount);
            System.Random random = new(seed);

            Vector2 initialPoint = new(NextFloat(random), NextFloat(random));
            AddPoint(initialPoint, SampleDistance(initialPoint));

            while (activePoints.Count > 0 && points.Count < safeMaxPointCount)
            {
                int activeSlot = random.Next(activePoints.Count);
                int activeIndex = activePoints[activeSlot];
                Vector2 activePoint = points[activeIndex];
                float activeDistance = pointDistances[activeIndex];
                bool foundCandidate = false;

                for (int i = 0; i < safeAttemptsPerPoint; i++)
                {
                    Vector2 candidate = GenerateCandidate(activePoint, activeDistance, random);
                    if (!IsInsideBounds(candidate))
                        continue;

                    float candidateDistance = SampleDistance(candidate);
                    if (!IsFarEnough(candidate, candidateDistance))
                        continue;

                    AddPoint(candidate, candidateDistance);
                    foundCandidate = true;

                    if (points.Count >= safeMaxPointCount)
                        break;
                }

                if (!foundCandidate)
                {
                    int lastIndex = activePoints.Count - 1;
                    activePoints[activeSlot] = activePoints[lastIndex];
                    activePoints.RemoveAt(lastIndex);
                }
            }

            pointCount = points.Count;
            return;

            void AddPoint(Vector2 point, float distance)
            {
                int pointIndex = points.Count;
                points.Add(point);
                pointDistances.Add(distance);
                activePoints.Add(pointIndex);

                Vector2Int cell = GetCell(point, cellSize);
                if (!occupiedCells.TryGetValue(cell, out List<int> cellEntries))
                {
                    cellEntries = new List<int>();
                    occupiedCells[cell] = cellEntries;
                }

                cellEntries.Add(pointIndex);
            }

            bool IsFarEnough(Vector2 candidate, float candidateDistance)
            {
                Vector2Int cell = GetCell(candidate, cellSize);

                for (int y = cell.y - 1; y <= cell.y + 1; y++)
                {
                    for (int x = cell.x - 1; x <= cell.x + 1; x++)
                    {
                        if (!occupiedCells.TryGetValue(new Vector2Int(x, y), out List<int> cellEntries))
                            continue;

                        for (int i = 0; i < cellEntries.Count; i++)
                        {
                            int pointIndex = cellEntries[i];
                            float requiredDistance = Mathf.Max(candidateDistance, pointDistances[pointIndex]);
                            if ((points[pointIndex] - candidate).sqrMagnitude < requiredDistance * requiredDistance)
                                return false;
                        }
                    }
                }

                return true;
            }
        }

        float SampleDistance(Vector2 uv)
        {
            if (readableNoise == null)
                return minDistanceUsed;

            float grayscale = readableNoise.GetPixelBilinear(uv.x, uv.y).grayscale;
            return Mathf.Lerp(minDistanceUsed, maxDistanceUsed, grayscale);
        }

        static Vector2 GenerateCandidate(Vector2 center, float distance, System.Random random)
        {
            float angle = NextFloat(random) * Mathf.PI * 2f;
            float radius = Mathf.Lerp(distance, distance * 2f, NextFloat(random));
            return center + new Vector2(Mathf.Cos(angle), Mathf.Sin(angle)) * radius;
        }

        bool UpdateReadableNoise(Texture source)
        {
            int width = Mathf.Max(1, source.width);
            int height = Mathf.Max(1, source.height);

            if (readableNoise == null || readableNoise.width != width || readableNoise.height != height)
            {
                if (readableNoise != null)
                    CoreUtils.Destroy(readableNoise);

                readableNoise = new Texture2D(width, height, TextureFormat.RGBA32, false, true)
                {
                    name = "Poisson Disk Noise",
                    wrapMode = TextureWrapMode.Clamp,
                    filterMode = FilterMode.Bilinear,
                    hideFlags = HideFlags.HideAndDontSave,
                };
            }

            RenderTexture temporary = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
            RenderTexture previous = RenderTexture.active;

            try
            {
                Graphics.Blit(source, temporary);
                RenderTexture.active = temporary;
                readableNoise.ReadPixels(new Rect(0, 0, width, height), 0, 0, false);
                readableNoise.Apply(false, false);
                return true;
            }
            finally
            {
                RenderTexture.active = previous;
                RenderTexture.ReleaseTemporary(temporary);
            }
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
                name = "Poisson Disk Points From Noise",
                wrapMode = TextureWrapMode.Clamp,
                filterMode = FilterMode.Point,
                hideFlags = HideFlags.HideAndDontSave,
            };
        }

        bool NeedsRebuild(int width, int height)
        {
            if (noiseInput != null)
                return true;

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

            if (Mathf.Abs(minimumDistance - lastMinimumDistance) > epsilon
                || Mathf.Abs(maximumDistance - lastMaximumDistance) > epsilon)
            {
                return true;
            }

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
            lastMaximumDistance = maximumDistance;
            lastBackgroundColor = backgroundColor;
            lastPointColor = pointColor;
        }

        static bool IsInsideBounds(Vector2 point)
        {
            return point.x >= 0f && point.x <= 1f && point.y >= 0f && point.y <= 1f;
        }

        static Vector2Int GetCell(Vector2 point, float cellSize)
        {
            return new Vector2Int(
                Mathf.FloorToInt(point.x / cellSize),
                Mathf.FloorToInt(point.y / cellSize)
            );
        }

        static float NextFloat(System.Random random)
        {
            return (float)random.NextDouble();
        }

        protected override void Disable()
        {
            if (output != null)
                CoreUtils.Destroy(output);
            if (readableNoise != null)
                CoreUtils.Destroy(readableNoise);

            output = null;
            readableNoise = null;
            points?.Clear();
            pointDistances.Clear();
            pointCount = 0;
            pixelBuffer = null;

            base.Disable();
        }
    }
}
