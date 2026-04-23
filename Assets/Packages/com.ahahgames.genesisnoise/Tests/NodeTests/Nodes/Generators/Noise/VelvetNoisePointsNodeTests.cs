using AhahGames.GenesisNoise.Nodes;

using NUnit.Framework;

using System.Collections.Generic;

using UnityEngine;

namespace AhahGames.GenesisNoise.Tests.Nodes.Generators.Noise
{
    public class VelvetNoisePointsNodeTests
    {
        [Test]
        public void GeneratesCenteredGridWhenDensityIsFullAndJitterIsZero()
        {
            var node = new TestableVelvetNoisePointsNode
            {
                seed = 42,
                frequency = 2,
                impulseDensity = 1f,
                jitter = 0f,
                maxPointCount = 8,
            };

            try
            {
                Assert.That(node.Execute(), Is.True);

                Assert.That(node.pointCount, Is.EqualTo(4));
                Assert.That(node.points, Is.EqualTo(new[]
                {
                    new Vector2(0.25f, 0.25f),
                    new Vector2(0.75f, 0.25f),
                    new Vector2(0.25f, 0.75f),
                    new Vector2(0.75f, 0.75f),
                }));
                Assert.That(node.output, Is.Not.Null);
                Assert.That(node.output.width, Is.EqualTo(256));
                Assert.That(node.output.height, Is.EqualTo(256));
            }
            finally
            {
                node.Cleanup();
            }
        }

        [Test]
        public void GeneratedPointsRespectMaxCountAndStayNormalized()
        {
            var node = new TestableVelvetNoisePointsNode
            {
                seed = 123,
                frequency = 32,
                impulseDensity = 1f,
                jitter = 1f,
                maxPointCount = 10,
            };

            try
            {
                Assert.That(node.Execute(), Is.True);

                Assert.That(node.pointCount, Is.EqualTo(10));
                Assert.That(node.points, Has.Count.EqualTo(10));
                foreach (Vector2 point in node.points)
                {
                    Assert.That(point.x, Is.InRange(0f, 1f));
                    Assert.That(point.y, Is.InRange(0f, 1f));
                }
            }
            finally
            {
                node.Cleanup();
            }
        }

        [Test]
        public void SameSettingsGenerateSamePointSet()
        {
            List<Vector2> first = GeneratePoints(seed: 77);
            List<Vector2> second = GeneratePoints(seed: 77);

            Assert.That(second, Has.Count.EqualTo(first.Count));
            for (int i = 0; i < first.Count; i++)
            {
                Assert.That(second[i].x, Is.EqualTo(first[i].x).Within(0.000001f));
                Assert.That(second[i].y, Is.EqualTo(first[i].y).Within(0.000001f));
            }
        }

        [Test]
        public void ZeroDensityProducesNoPointsAndEmptyCoordinateText()
        {
            var node = new TestableVelvetNoisePointsNode
            {
                seed = 9,
                frequency = 8,
                impulseDensity = 0f,
                jitter = 1f,
                maxPointCount = 20,
            };

            try
            {
                Assert.That(node.Execute(), Is.True);

                Assert.That(node.pointCount, Is.Zero);
                Assert.That(node.points, Is.Empty);
                Assert.That(node.GetCoordinatesText(), Is.EqualTo("No points generated."));
            }
            finally
            {
                node.Cleanup();
            }
        }

        static List<Vector2> GeneratePoints(int seed)
        {
            var node = new TestableVelvetNoisePointsNode
            {
                seed = seed,
                frequency = 16,
                impulseDensity = 0.25f,
                jitter = 0.75f,
                maxPointCount = 24,
            };

            try
            {
                Assert.That(node.Execute(), Is.True);
                return new List<Vector2>(node.points);
            }
            finally
            {
                node.Cleanup();
            }
        }

        class TestableVelvetNoisePointsNode : VelvetNoisePointsNode
        {
            public bool Execute() => base.ProcessNode(null);

            public void Cleanup() => base.Disable();
        }
    }
}
