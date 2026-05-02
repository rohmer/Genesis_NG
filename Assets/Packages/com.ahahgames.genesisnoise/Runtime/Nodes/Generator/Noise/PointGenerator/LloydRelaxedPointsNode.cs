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
Generates a Lloyd-relaxed point distribution and outputs both the preview image and normalized UV coordinates.

This node starts from a jittered distribution, then repeatedly computes Voronoi-style nearest-cell ownership and moves each point toward its centroid. When a density texture is connected, the relaxation becomes density-weighted so brighter regions attract more points.
")]
    [System.Serializable, NodeMenuItem("Generators/Points/Lloyd Relaxed Points")]
    public class LloydRelaxedPointsNode : GenesisNode
    {
        const float epsilon = 0.0001f;

        [Input, SerializeField]
        public Texture densityInput;

        [Input, SerializeField]
        public int seed = 0;

        [Input, SerializeField, Min(1)]
        public int numberOfPoints = 128;

        [SerializeField, Range(0, 24)]
        public int relaxationIterations = 8;

        [SerializeField, Range(16, 512)]
        public int relaxationResolution = 128;

        [SerializeField, Range(0f, 1f)]
        public float jitter = 1f;

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
        int lastNumberOfPoints;

        [NonSerialized]
        int lastRelaxationIterations;

        [NonSerialized]
        int lastRelaxationResolution;

        [NonSerialized]
        int lastPointRadiusPixels;

        [NonSerialized]
        float lastJitter = -1f;

        [NonSerialized]
        Color lastBackgroundColor;

        [NonSerialized]
        Color lastPointColor;

        Texture2D readableDensity;
        Color32[] pixelBuffer;

        public override string name => "Lloyd Relaxed Points";
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

            int safePointCount = Mathf.Max(1, numberOfPoints);
            System.Random random = new(seed);
            CreateInitialPoints(random, safePointCount, points);

            int safeResolution = Mathf.Clamp(relaxationResolution, 16, 512);
            bool hasDensity = densityInput != null && UpdateReadableDensity(densityInput, safeResolution);
            Color[] densityPixels = hasDensity ? readableDensity.GetPixels() : null;

            for (int iteration = 0; iteration < Mathf.Max(0, relaxationIterations); iteration++)
                RelaxPointSet(safeResolution, densityPixels);

            pointCount = points.Count;
        }

        void CreateInitialPoints(System.Random random, int safePointCount, List<Vector2> destination)
        {
            int gridSize = Mathf.CeilToInt(Mathf.Sqrt(safePointCount));
            int totalCells = gridSize * gridSize;
            int[] cellOrder = new int[totalCells];

            for (int i = 0; i < totalCells; i++)
                cellOrder[i] = i;

            for (int i = totalCells - 1; i > 0; i--)
            {
                int swapIndex = random.Next(i + 1);
                (cellOrder[i], cellOrder[swapIndex]) = (cellOrder[swapIndex], cellOrder[i]);
            }

            float inverseGrid = 1f / gridSize;
            float jitterDistance = 0.5f * inverseGrid * Mathf.Clamp01(jitter);

            for (int i = 0; i < safePointCount; i++)
            {
                int cellIndex = cellOrder[i];
                int x = cellIndex % gridSize;
                int y = cellIndex / gridSize;

                Vector2 point = new(
                    (x + 0.5f) * inverseGrid,
                    (y + 0.5f) * inverseGrid);

                if (jitterDistance > epsilon)
                {
                    point.x += (NextFloat(random) * 2f - 1f) * jitterDistance;
                    point.y += (NextFloat(random) * 2f - 1f) * jitterDistance;
                }

                destination.Add(new Vector2(Mathf.Clamp01(point.x), Mathf.Clamp01(point.y)));
            }
        }

        void RelaxPointSet(int resolution, Color[] densityPixels)
        {
            if (points == null || points.Count == 0)
                return;

            Vector2[] accumulators = new Vector2[points.Count];
            float[] weights = new float[points.Count];

            for (int y = 0; y < resolution; y++)
            {
                float v = (y + 0.5f) / resolution;
                for (int x = 0; x < resolution; x++)
                {
                    float weight = 1f;
                    if (densityPixels != null)
                    {
                        weight = Mathf.Max(0f, densityPixels[x + y * resolution].grayscale);
                        if (weight <= epsilon)
                            continue;
                    }

                    Vector2 sample = new((x + 0.5f) / resolution, v);
                    int nearestIndex = FindNearestPointIndex(sample);

                    accumulators[nearestIndex] += sample * weight;
                    weights[nearestIndex] += weight;
                }
            }

            for (int i = 0; i < points.Count; i++)
            {
                if (weights[i] <= epsilon)
                    continue;

                Vector2 relaxed = accumulators[i] / weights[i];
                points[i] = new Vector2(Mathf.Clamp01(relaxed.x), Mathf.Clamp01(relaxed.y));
            }
        }

        int FindNearestPointIndex(Vector2 sample)
        {
            int nearestIndex = 0;
            float nearestDistance = float.MaxValue;

            for (int i = 0; i < points.Count; i++)
            {
                float distance = (points[i] - sample).sqrMagnitude;
                if (distance < nearestDistance)
                {
                    nearestDistance = distance;
                    nearestIndex = i;
                }
            }

            return nearestIndex;
        }

        bool UpdateReadableDensity(Texture source, int resolution)
        {
            int safeResolution = Mathf.Clamp(resolution, 16, 512);

            if (readableDensity == null || readableDensity.width != safeResolution || readableDensity.height != safeResolution)
            {
                if (readableDensity != null)
                    CoreUtils.Destroy(readableDensity);

                readableDensity = new Texture2D(safeResolution, safeResolution, TextureFormat.RGBA32, false, true)
                {
                    name = "Lloyd Density",
                    wrapMode = TextureWrapMode.Clamp,
                    filterMode = FilterMode.Bilinear,
                    hideFlags = HideFlags.HideAndDontSave,
                };
            }

            RenderTexture temporary = RenderTexture.GetTemporary(safeResolution, safeResolution, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
            RenderTexture previous = RenderTexture.active;

            try
            {
                Graphics.Blit(source, temporary);
                RenderTexture.active = temporary;
                readableDensity.ReadPixels(new Rect(0, 0, safeResolution, safeResolution), 0, 0, false);
                readableDensity.Apply(false, false);
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
                name = "Lloyd Relaxed Points",
                wrapMode = TextureWrapMode.Clamp,
                filterMode = FilterMode.Point,
                hideFlags = HideFlags.HideAndDontSave,
            };
        }

        bool NeedsRebuild(int width, int height)
        {
            if (densityInput != null)
                return true;

            if (output == null)
                return true;

            if (width != lastWidth || height != lastHeight)
                return true;

            if (seed != lastSeed
                || numberOfPoints != lastNumberOfPoints
                || relaxationIterations != lastRelaxationIterations
                || relaxationResolution != lastRelaxationResolution
                || pointRadiusPixels != lastPointRadiusPixels)
            {
                return true;
            }

            if (Mathf.Abs(jitter - lastJitter) > epsilon)
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
            lastNumberOfPoints = numberOfPoints;
            lastRelaxationIterations = relaxationIterations;
            lastRelaxationResolution = relaxationResolution;
            lastPointRadiusPixels = pointRadiusPixels;
            lastJitter = jitter;
            lastBackgroundColor = backgroundColor;
            lastPointColor = pointColor;
        }

        static float NextFloat(System.Random random)
        {
            return (float)random.NextDouble();
        }

        protected override void Disable()
        {
            if (output != null)
                CoreUtils.Destroy(output);
            if (readableDensity != null)
                CoreUtils.Destroy(readableDensity);

            output = null;
            readableDensity = null;
            points?.Clear();
            pointCount = 0;
            pixelBuffer = null;

            base.Disable();
        }
    }
}
