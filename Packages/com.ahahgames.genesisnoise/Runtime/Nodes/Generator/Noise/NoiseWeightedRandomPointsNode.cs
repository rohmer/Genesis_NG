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
Generates random 2D points using a noise texture as a probability map, so brighter areas are sampled more often than darker ones.

If no noise input is connected, the node falls back to uniform random sampling. The `Points` output contains normalized UV coordinates in the `[0, 1]` range.
")]
    [System.Serializable, NodeMenuItem("Generators/Points/Random Points From Noise")]
    public class NoiseWeightedRandomPointsNode : GenesisNode
    {
        const float epsilon = 0.0001f;

        [Input, SerializeField]
        public Texture noiseInput;

        [Input, SerializeField]
        public int seed = 0;

        [Input, SerializeField, Min(1)]
        public int numberOfPoints = 256;

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
        int lastPointRadiusPixels;

        [NonSerialized]
        Color lastBackgroundColor;

        [NonSerialized]
        Color lastPointColor;

        Texture2D readableNoise;
        Color32[] pixelBuffer;
        float[] cumulativeWeights;

        public override string name => "Random Points From Noise";
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

            if (noiseInput == null)
            {
                GenerateUniformPoints(random, safePointCount);
            }
            else if (UpdateReadableNoise(noiseInput) && TryBuildCumulativeWeights(out float totalWeight))
            {
                GenerateWeightedPoints(random, safePointCount, totalWeight);
            }

            pointCount = points.Count;
        }

        void GenerateWeightedPoints(System.Random random, int pointTarget, float totalWeight)
        {
            int width = readableNoise.width;
            int height = readableNoise.height;

            for (int i = 0; i < pointTarget; i++)
            {
                float sample = NextFloat(random) * totalWeight;
                int pixelIndex = Array.BinarySearch(cumulativeWeights, sample);

                if (pixelIndex < 0)
                    pixelIndex = ~pixelIndex;
                if (pixelIndex >= cumulativeWeights.Length)
                    pixelIndex = cumulativeWeights.Length - 1;

                int x = pixelIndex % width;
                int y = pixelIndex / width;

                float u = (x + NextFloat(random)) / width;
                float v = (y + NextFloat(random)) / height;
                points.Add(new Vector2(Mathf.Clamp01(u), Mathf.Clamp01(v)));
            }
        }

        void GenerateUniformPoints(System.Random random, int pointTarget)
        {
            for (int i = 0; i < pointTarget; i++)
                points.Add(new Vector2(NextFloat(random), NextFloat(random)));
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
                    name = "Weighted Random Noise",
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

        bool TryBuildCumulativeWeights(out float totalWeight)
        {
            Color[] pixels = readableNoise.GetPixels();
            if (cumulativeWeights == null || cumulativeWeights.Length != pixels.Length)
                cumulativeWeights = new float[pixels.Length];

            totalWeight = 0f;
            for (int i = 0; i < pixels.Length; i++)
            {
                totalWeight += Mathf.Max(0f, pixels[i].grayscale);
                cumulativeWeights[i] = totalWeight;
            }

            return totalWeight > epsilon;
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
                name = "Random Points From Noise",
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
                || numberOfPoints != lastNumberOfPoints
                || pointRadiusPixels != lastPointRadiusPixels)
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
            lastPointRadiusPixels = pointRadiusPixels;
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
            if (readableNoise != null)
                CoreUtils.Destroy(readableNoise);

            output = null;
            readableNoise = null;
            points?.Clear();
            pointCount = 0;
            pixelBuffer = null;
            cumulativeWeights = null;

            base.Disable();
        }
    }
}
