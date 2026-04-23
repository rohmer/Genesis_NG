using System;
using System.Collections;
using System.Collections.Generic;

using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Nodes;

using NUnit.Framework;

using UnityEngine;
using UnityEngine.TestTools;

namespace AhahGames.GenesisNoise.Tests.Nodes
{
    /// <summary>
    /// Tests for creating and deleting nodes in general
    /// </summary>
    public class ColorNodeTests
    {
        private GenesisGraph graph;  // Graph we will be using

        [SetUp]
        public void setUp()
        {
            string filename = string.Empty;
            graph = TestGraph.CreateTestGraph(ref filename);
            Assert.IsNotNull(graph);
        }

        [TearDown]
        public void tearDown()
        {
            if (graph != null)
            {
                TestGraph.DeleteTestGraph(graph);
            }
        }

        [Test]
        public void CreateAndDeleteNode()
        {
            ColorNode testNode = new ColorNode();
            string name = Guid.NewGuid().ToString();
            testNode.SetCustomName(name);
            testNode.output = Color.antiqueWhite;
            testNode.OnNodeCreated();

            Assert.IsNotNull(graph.AddNode(testNode));
            Assert.IsNotNull(graph.nodes.Find(n => n.GetType() == typeof(ColorNode)));

            testNode.Process();

            ColorNode colorNode = (ColorNode)graph.nodes.Find(n => n.GetCustomName() == name);
            Assert.IsNotNull(colorNode);
            Assert.IsTrue(colorNode.output == Color.antiqueWhite);

            graph.RemoveNode(testNode);

        }

        [Test]
        public void NodeTest500()
        {

        }
    }
        
}