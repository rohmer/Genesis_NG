using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using NUnit.Framework;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace AhahGames.GenesisNoise.Tests.Nodes.Generators.Noise
{
    public class FixedNoiseNodeTests
    {
        static IEnumerable<TestCaseData> FixedNoiseNodes()
        {
            yield return CreateCase<WhiteNoise>("White Noise", "Hidden/Genesis/WhiteNoise");
            yield return CreateCase<PinkNoise>("Pink Noise", "Hidden/Genesis/PinkNoise");
            yield return CreateCase<BrownianNoise>("Brownian Noise", "Hidden/Genesis/BrownianNoise");
            yield return CreateCase<BlueNoise>("Blue Noise", "Hidden/Genesis/BlueNoise");
            yield return CreateCase<VioletNoise>("Violet Noise", "Hidden/Genesis/VioletNoise");
            yield return CreateCase<GreyNoise>("Grey Noise", "Hidden/Genesis/GreyNoise");
            yield return CreateCase<VelvetNoise>("Velvet Noise", "Hidden/Genesis/VelvetNoise");
        }

        static TestCaseData CreateCase<TNode>(string displayName, string shaderName)
            where TNode : FixedNoiseNode, new()
            => new TestCaseData(typeof(TNode), displayName, shaderName)
                .SetName($"{typeof(TNode).Name}_metadata_matches_shader_and_menu_contract");

        [TestCaseSource(nameof(FixedNoiseNodes))]
        public void FixedNoiseNodeMetadataMatchesShaderAndMenuContract(Type nodeType, string displayName, string shaderName)
        {
            var node = (FixedNoiseNode)Activator.CreateInstance(nodeType);
            var menuItem = nodeType.GetCustomAttribute<NodeMenuItemAttribute>();

            Assert.That(node.name, Is.EqualTo(displayName));
            Assert.That(node.NodeGroup, Is.EqualTo("Noise"));
            Assert.That(node.ShaderName, Is.EqualTo(shaderName));
            Assert.That(node.DisplayMaterialInspector, Is.True);
            Assert.That(node.defaultPreviewChannels, Is.EqualTo(PreviewChannels.RGB));
            Assert.That(menuItem, Is.Not.Null);
            Assert.That(menuItem.menuTitle, Is.EqualTo($"Generators/Noise/{displayName}"));
            Assert.That(node.supportedDimensions, Is.EquivalentTo(new[]
            {
                OutputDimension.Texture2D,
                OutputDimension.Texture3D,
                OutputDimension.CubeMap,
            }));
        }
    }
}
