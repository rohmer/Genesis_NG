using AhahGames.GenesisNoise.Nodes;

using NUnit.Framework;

using System.Reflection;

using UnityEngine;

namespace AhahGames.GenesisNoise.Tests.Nodes.Functions
{
    public class MathNodeBehaviorTests
    {
        [Test]
        public void AddNodeBooleanBranchUsesLogicalOr()
        {
            var node = new AddNode
            {
                inputA = false,
                inputB = true,
            };

            InvokeProcessNode(node);
            Assert.That(node.output, Is.EqualTo(true));
        }

        [Test]
        public void ClampNodeWritesClampedVectorOutput()
        {
            var node = new ClampNode
            {
                min = Vector2.zero,
                max = Vector2.one,
                value = new Vector2(2f, -1f),
            };

            InvokeProcessNode(node);
            Assert.That(node.output, Is.EqualTo(new Vector2(1f, 0f)));
        }

        [Test]
        public void MaxNodeUsesMaxForBothVector2Components()
        {
            var node = new MaxNode
            {
                inputA = new Vector2(1f, 5f),
                inputB = new Vector2(2f, 4f),
            };

            InvokeProcessNode(node);
            Assert.That(node.output, Is.EqualTo(new Vector2(2f, 5f)));
        }

        [Test]
        public void MinNodeUsesMinForBothVector2Components()
        {
            var node = new MinNode
            {
                inputA = new Vector2(1f, 5f),
                inputB = new Vector2(2f, 4f),
            };

            InvokeProcessNode(node);
            Assert.That(node.output, Is.EqualTo(new Vector2(1f, 4f)));
        }

        static void InvokeProcessNode(object node)
        {
            MethodInfo processNode = node.GetType().GetMethod("ProcessNode", BindingFlags.Instance | BindingFlags.NonPublic);
            processNode.Invoke(node, new object[] { null });
        }
    }
}
