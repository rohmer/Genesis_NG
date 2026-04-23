using System.Collections;
using System.Collections.Generic;

using AhahGames.GenesisNoise.Graph;

using NUnit.Framework;

using UnityEngine;
using UnityEditor;
using UnityEngine.TestTools;

namespace AhahGames.GenesisNoise.Tests
{
    public class BaseGraphTests
    {
        GenesisGraph currentGraph = null;
        [Test]
        public void CreateGraphWindow()
        {
            string filename = string.Empty;
            GenesisGraph genesisGraph = TestGraph.CreateTestGraph(ref filename);
            if (genesisGraph == null)
            {
                Assert.Fail(string.Format("Failed to create a genesis graph, file name is/was: {0}", filename));
            }

            Assert.IsFalse(string.IsNullOrEmpty(genesisGraph.Filename));
            // Ok, its created cleanup
            Assert.IsTrue(TestGraph.DeleteTestGraph(genesisGraph));           
        }

        [Test]
        public void DeleteGraphWindow()
        {
            string filename = string.Empty;
            GenesisGraph genesisGraph = TestGraph.CreateTestGraph(ref filename);
            if (genesisGraph == null)
            {
                Assert.Fail(string.Format("Failed to create a genesis graph, file name is/was: {0}", filename));
            }

            Assert.IsFalse(string.IsNullOrEmpty(genesisGraph.Filename));
            // Ok, its created cleanup
            Assert.IsTrue(TestGraph.DeleteTestGraph(genesisGraph));
        }
    }
}