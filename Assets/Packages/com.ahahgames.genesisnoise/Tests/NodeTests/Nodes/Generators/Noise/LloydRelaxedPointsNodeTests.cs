using AhahGames.GenesisNoise.Nodes;

using NUnit.Framework;

using System.Collections.Generic;

using UnityEngine;

namespace AhahGames.GenesisNoise.Tests.Nodes.Generators.Noise
{
    public class LloydRelaxedPointsNodeTests
    {
        [Test]
        public void GeneratesRequestedPointCountAndPreviewTexture()
        {
            var node = new TestableLloydRelaxedPointsNode
            {
                seed = 12,
                numberOfPoints = 16,
                relaxationIterations = 4,
                relaxationResolution = 32,
                jitter = 1f,
            };

            try
            {
                Assert.That(node.Execute(), Is.True);

                Assert.That(node.pointCount, Is.EqualTo(16));
                Assert.That(node.points, Has.Count.EqualTo(16));
                Assert.That(node.output, Is.Not.Null);
                Assert.That(node.output.width, Is.EqualTo(256));
                Assert.That(node.output.height, Is.EqualTo(256));
                Assert.That(node.GetCoordinatesText(), Does.StartWith("000: ("));

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
        public void SameSettingsGenerateSameRelaxedPointSet()
        {
            List<Vector2> first = GeneratePoints(seed: 91);
            List<Vector2> second = GeneratePoints(seed: 91);

            Assert.That(second, Has.Count.EqualTo(first.Count));
            for (int i = 0; i < first.Count; i++)
            {
                Assert.That(second[i].x, Is.EqualTo(first[i].x).Within(0.000001f));
                Assert.That(second[i].y, Is.EqualTo(first[i].y).Within(0.000001f));
            }
        }

        static List<Vector2> GeneratePoints(int seed)
        {
            var node = new TestableLloydRelaxedPointsNode
            {
                seed = seed,
                numberOfPoints = 12,
                relaxationIterations = 6,
                relaxationResolution = 48,
                jitter = 0.85f,
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

        class TestableLloydRelaxedPointsNode : LloydRelaxedPointsNode
        {
            public bool Execute() => base.ProcessNode(null);

            public void Cleanup() => base.Disable();
        }
    }
}
