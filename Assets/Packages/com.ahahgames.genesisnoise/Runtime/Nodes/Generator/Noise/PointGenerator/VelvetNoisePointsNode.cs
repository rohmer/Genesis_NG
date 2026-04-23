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
Generates 2D points from an internally generated velvet-noise impulse field.

Velvet noise is a sparse field of random impulses, so this node emits jittered points from randomly activated grid cells. The `Points` output contains normalized UV coordinates in the `[0, 1]` range.
")]
    [System.Serializable, NodeMenuItem("Generators/Points/Velvet Noise Points")]
    public class VelvetNoisePointsNode : GenesisNode
    {
        const float epsilon = 0.0001f;

        [Input, SerializeField]
        public int seed = 0;

        [Input, SerializeField, Min(1)]
        public int maxPointCount = 256;

        [Input, SerializeField, Range(1, 512)]
        public int frequency = 64;

        [Input, SerializeField, Range(0f, 1f)]
        public float impulseDensity = 0.18f;

        [Input, SerializeField, Range(0f, 1f)]
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
        int lastMaxPointCount;

        [NonSerialized]
        int lastFrequency;

        [NonSerialized]
        int lastPointRadiusPixels;

        [NonSerialized]
        float lastImpulseDensity = -1f;

        [NonSerialized]
        float lastJitter = -1f;

        [NonSerialized]
        Color lastBackgroundColor;

        [NonSerialized]
        Color lastPointColor;

        Color32[] pixelBuffer;

        public override string name => "Velvet Noise Points";
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

            int safeMaxPointCount = Mathf.Max(1, maxPointCount);
            int safeFrequency = Mathf.Clamp(frequency, 1, 512);
            float safeDensity = Mathf.Clamp01(impulseDensity);
            float safeJitter = Mathf.Clamp01(jitter);
            int activeCandidateCount = 0;
            System.Random reservoirRandom = new(seed ^ 104729);

            for (int y = 0; y < safeFrequency; y++)
            {
                for (int x = 0; x < safeFrequency; x++)
                {
                    if (Hash01(x, y, seed + 521) > safeDensity)
                        continue;

                    Vector2 point = CreateImpulsePoint(x, y, safeFrequency, safeJitter, seed);
                    activeCandidateCount++;

                    if (points.Count < safeMaxPointCount)
                    {
                        points.Add(point);
                        continue;
                    }

                    int replacementIndex = reservoirRandom.Next(activeCandidateCount);
                    if (replacementIndex < safeMaxPointCount)
                        points[replacementIndex] = point;
                }
            }

            pointCount = points.Count;
        }

        static Vector2 CreateImpulsePoint(int x, int y, int frequency, float jitter, int seed)
        {
            float offsetX = Mathf.Lerp(0.5f, Hash01(x, y, seed + 137), jitter);
            float offsetY = Mathf.Lerp(0.5f, Hash01(x, y, seed + 271), jitter);
            float inverseFrequency = 1f / frequency;

            return new Vector2(
                Mathf.Clamp01((x + offsetX) * inverseFrequency),
                Mathf.Clamp01((y + offsetY) * inverseFrequency));
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
                name = "Velvet Noise Points",
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
                || frequency != lastFrequency
                || pointRadiusPixels != lastPointRadiusPixels)
            {
                return true;
            }

            if (Mathf.Abs(impulseDensity - lastImpulseDensity) > epsilon
                || Mathf.Abs(jitter - lastJitter) > epsilon)
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
            lastFrequency = frequency;
            lastPointRadiusPixels = pointRadiusPixels;
            lastImpulseDensity = impulseDensity;
            lastJitter = jitter;
            lastBackgroundColor = backgroundColor;
            lastPointColor = pointColor;
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
