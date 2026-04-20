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
Generates random 2D points from an internally generated grey-noise density field.

Grey noise uses a more balanced, equalized spread of octaves than pink or Brownian noise, so no single frequency band dominates the point placement. The `Points` output contains normalized UV coordinates in the `[0, 1]` range.
")]
    [System.Serializable, NodeMenuItem("Generators/Points/Grey Noise Points")]
    public class GreyNoisePointsNode : GenesisNode
    {
        const float epsilon = 0.0001f;

        [Input, SerializeField]
        public int seed = 0;

        [Input, SerializeField, Min(1)]
        public int numberOfPoints = 256;

        [SerializeField, Range(16, 2048)]
        public int distributionResolution = 512;

        [Input, SerializeField, Range(0.25f, 16f)]
        public float baseFrequency = 2.5f;

        [Input, SerializeField, Range(1, 10)]
        public int octaves = 6;

        [Input, SerializeField, Range(0f, 2f)]
        public float highFrequencyLift = 0.75f;

        [Input, SerializeField, Range(0.1f, 4f)]
        public float densityPower = 1.25f;

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
        int lastDistributionResolution;

        [NonSerialized]
        int lastOctaves;

        [NonSerialized]
        int lastPointRadiusPixels;

        [NonSerialized]
        float lastBaseFrequency = -1f;

        [NonSerialized]
        float lastHighFrequencyLift = -1f;

        [NonSerialized]
        float lastDensityPower = -1f;

        [NonSerialized]
        Color lastBackgroundColor;

        [NonSerialized]
        Color lastPointColor;

        Color32[] pixelBuffer;
        float[] cumulativeWeights;

        public override string name => "Grey Noise Points";
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
            int safeResolution = Mathf.Clamp(distributionResolution, 16, 2048);
            System.Random random = new(seed);

            if (!TryBuildCumulativeWeights(safeResolution, out float totalWeight))
            {
                GenerateUniformFallback(random, safePointCount);
                pointCount = points.Count;
                return;
            }

            for (int i = 0; i < safePointCount; i++)
            {
                float sample = NextFloat(random) * totalWeight;
                int index = Array.BinarySearch(cumulativeWeights, sample);

                if (index < 0)
                    index = ~index;
                if (index >= cumulativeWeights.Length)
                    index = cumulativeWeights.Length - 1;

                int x = index % safeResolution;
                int y = index / safeResolution;

                float u = (x + NextFloat(random)) / safeResolution;
                float v = (y + NextFloat(random)) / safeResolution;
                points.Add(new Vector2(Mathf.Clamp01(u), Mathf.Clamp01(v)));
            }

            pointCount = points.Count;
        }

        bool TryBuildCumulativeWeights(int resolution, out float totalWeight)
        {
            int totalCells = resolution * resolution;
            if (cumulativeWeights == null || cumulativeWeights.Length != totalCells)
                cumulativeWeights = new float[totalCells];

            int safeOctaves = Mathf.Clamp(octaves, 1, 10);
            float safeBaseFrequency = Mathf.Max(epsilon, baseFrequency);
            float safeHighFrequencyLift = Mathf.Clamp(highFrequencyLift, 0f, 2f);
            float safeDensityPower = Mathf.Max(epsilon, densityPower);

            totalWeight = 0f;

            for (int y = 0; y < resolution; y++)
            {
                float v = (y + 0.5f) / resolution;
                for (int x = 0; x < resolution; x++)
                {
                    float u = (x + 0.5f) / resolution;
                    float density = GreyNoise01(u, v, safeBaseFrequency, safeOctaves, safeHighFrequencyLift, seed);
                    float weight = Mathf.Pow(Mathf.Clamp01(density), safeDensityPower);

                    totalWeight += Mathf.Max(0f, weight);
                    cumulativeWeights[x + y * resolution] = totalWeight;
                }
            }

            return totalWeight > epsilon;
        }

        static float GreyNoise01(float u, float v, float baseFrequency, int octaves, float highFrequencyLift, int seed)
        {
            float frequency = baseFrequency;
            float sum = 0f;
            float weightSum = 0f;

            for (int octave = 0; octave < octaves; octave++)
            {
                float octavePosition = octaves > 1 ? octave / (float)(octaves - 1) : 0f;
                float weight = Mathf.Lerp(1f, 1f + highFrequencyLift, octavePosition);

                sum += ValueNoise(u * frequency, v * frequency, seed + octave * 1223) * weight;
                weightSum += weight;
                frequency *= 2f;
            }

            return weightSum > epsilon ? sum / weightSum : 0f;
        }

        static float ValueNoise(float x, float y, int seed)
        {
            int xi = Mathf.FloorToInt(x);
            int yi = Mathf.FloorToInt(y);
            float tx = x - xi;
            float ty = y - yi;

            float a = Hash01(xi, yi, seed);
            float b = Hash01(xi + 1, yi, seed);
            float c = Hash01(xi, yi + 1, seed);
            float d = Hash01(xi + 1, yi + 1, seed);

            float sx = Smooth(tx);
            float sy = Smooth(ty);
            float x0 = Mathf.Lerp(a, b, sx);
            float x1 = Mathf.Lerp(c, d, sx);

            return Mathf.Lerp(x0, x1, sy);
        }

        static float Smooth(float t)
        {
            return t * t * t * (t * (t * 6f - 15f) + 10f);
        }

        static float Hash01(int x, int y, int seed)
        {
            unchecked
            {
                uint hash = (uint)seed;
                hash ^= (uint)x * 374761393u;
                hash ^= (uint)y * 668265263u;
                hash = (hash ^ (hash >> 13)) * 1274126177u;
                hash ^= hash >> 16;
                return (hash & 0x00FFFFFFu) / 16777215f;
            }
        }

        void GenerateUniformFallback(System.Random random, int pointTarget)
        {
            for (int i = 0; i < pointTarget; i++)
                points.Add(new Vector2(NextFloat(random), NextFloat(random)));
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
                name = "Grey Noise Points",
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
                || numberOfPoints != lastNumberOfPoints
                || distributionResolution != lastDistributionResolution
                || octaves != lastOctaves
                || pointRadiusPixels != lastPointRadiusPixels)
            {
                return true;
            }

            if (Mathf.Abs(baseFrequency - lastBaseFrequency) > epsilon
                || Mathf.Abs(highFrequencyLift - lastHighFrequencyLift) > epsilon
                || Mathf.Abs(densityPower - lastDensityPower) > epsilon)
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
            lastNumberOfPoints = numberOfPoints;
            lastDistributionResolution = distributionResolution;
            lastOctaves = octaves;
            lastPointRadiusPixels = pointRadiusPixels;
            lastBaseFrequency = baseFrequency;
            lastHighFrequencyLift = highFrequencyLift;
            lastDensityPower = densityPower;
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

            output = null;
            points?.Clear();
            pointCount = 0;
            pixelBuffer = null;
            cumulativeWeights = null;

            base.Disable();
        }
    }
}
