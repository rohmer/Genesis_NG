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
    public class BoolNodeTests
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
            BoolNode testNode = new BoolNode();
            string name = Guid.NewGuid().ToString();
            testNode.SetCustomName(name);
            testNode.output = true;
            testNode.OnNodeCreated();

            Assert.IsNotNull(graph.AddNode(testNode));
            Assert.IsNotNull(graph.nodes.Find(n => n.GetType() == typeof(BoolNode)));

            testNode.Process();

            BoolNode boolNode = (BoolNode)graph.nodes.Find(n => n.GetCustomName() == name);
            Assert.IsNotNull(boolNode);
            Assert.IsTrue(boolNode.output);

            graph.RemoveNode(testNode);

        }

        [Test]
        public void TestTrueValueBoolNode()
        {
            BoolNode testNode = new BoolNode();
            string name = Guid.NewGuid().ToString();
            testNode.SetCustomName(name);
            testNode.output = true;
            testNode.OnNodeCreated();

            Assert.IsNotNull(graph.AddNode(testNode));
            Assert.IsNotNull(graph.nodes.Find(n => n.GetType() == typeof(BoolNode)));

            testNode.Process();


            BoolNode boolNode = (BoolNode)graph.nodes.Find(n => n.GetCustomName() == name);
            Assert.IsNotNull(boolNode);
            Assert.IsTrue(boolNode.output);
            graph.RemoveNode(testNode);
        }

        [Test]
        public void TestFalseValueBoolNode()
        {
            BoolNode testNode = new BoolNode();
            string name = Guid.NewGuid().ToString();
            testNode.SetCustomName(name);
            testNode.output = false;
            testNode.OnNodeCreated();

            Assert.IsNotNull(graph.AddNode(testNode));
            Assert.IsNotNull(graph.nodes.Find(n => n.GetType() == typeof(BoolNode)));

            testNode.Process();


            BoolNode boolNode = (BoolNode)graph.nodes.Find(n => n.GetCustomName() == name);
            Assert.IsNotNull(boolNode);
            Assert.IsFalse(boolNode.output);
            graph.RemoveNode(testNode);
        }
    }
}