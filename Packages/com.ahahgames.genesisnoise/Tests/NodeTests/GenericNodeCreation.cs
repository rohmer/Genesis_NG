using System;
using System.Collections;
using System.Collections.Generic;

using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Nodes;

using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

namespace AhahGames.GenesisNoise.Tests
{
    /// <summary>
    /// Tests for creating and deleting nodes in general
    /// </summary>
    public class GenericNodeCreation
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
            GenericTestNode testNode = new GenericTestNode();
            testNode.SetCustomName(Guid.NewGuid().ToString());
            testNode.OnNodeCreated();         
            
            Assert.IsNotNull(graph.AddNode(testNode));
            Assert.IsNotNull(graph.nodes.Find(n=>n.GetType() == typeof(GenericTestNode)));    

            graph.RemoveNode(testNode);

        }

        [Test]
        public void Create1000Nodes()
        {
            Dictionary<string, GenericTestNode> nodeList = new Dictionary<string, GenericTestNode>();
            int i;
            for (i = 0; i < 1000; i++)
            {
                GenericTestNode node = new GenericTestNode();
                string name = Guid.NewGuid().ToString();
                node.SetCustomName(name);
                node.OnNodeCreated();
                nodeList.Add(name, node);
            }

            i = 1;
            foreach (var node in nodeList)
            {
                Assert.IsNotNull(graph.AddNode(node.Value));
                Assert.IsNotNull(graph.nodes.Find(n => n.GetCustomName() == node.Key));
                if(graph.nodes.Count!=i)
                    Assert.Fail(string.Format("Expected to have: {0} nodes in the graph, actual {1}",i,graph.nodes.Count));
                i++;
            }

            // Cleanup
            foreach (var node in nodeList)
            {
                graph.RemoveNode(node.Value);
            }
        }
    }
}