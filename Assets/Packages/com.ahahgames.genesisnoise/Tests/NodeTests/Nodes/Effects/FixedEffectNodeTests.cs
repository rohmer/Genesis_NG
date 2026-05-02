using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using NUnit.Framework;

using System;
using System.Collections.Generic;
using System.Reflection;

namespace AhahGames.GenesisNoise.Tests.Nodes.Effects
{
    public class FixedEffectNodeTests
    {
        static IEnumerable<TestCaseData> FixedEffectNodes()
        {
            yield return CreateCase<AmbientOcclusionNode>("Ambient Occlusion", "Hidden/Genesis/SmartMaskSuite");
            yield return CreateCase<CavityNode>("Cavity", "Hidden/Genesis/SmartMaskSuite");
            yield return CreateCase<ThicknessNode>("Thickness", "Hidden/Genesis/SmartMaskSuite");
            yield return CreateCase<SmartMaskBuilderNode>("Smart Mask Builder", "Hidden/Genesis/SmartMaskSuite");
            yield return CreateCase<WaterEffectNode>("Water Effect", "Hidden/Genesis/WaterEffect");
            yield return CreateCase<DripFlowNode>("Drip Flow", "Hidden/Genesis/FlowEffectSuite");
            yield return CreateCase<FlowAccumulationNode>("Flow Accumulation", "Hidden/Genesis/FlowEffectSuite");
            yield return CreateCase<WetnessNode>("Wetness", "Hidden/Genesis/FlowEffectSuite");
        }

        static TestCaseData CreateCase<TNode>(string displayName, string shaderName)
            where TNode : FixedNoiseNode, new()
            => new TestCaseData(typeof(TNode), displayName, shaderName)
                .SetName($"{typeof(TNode).Name}_metadata_matches_shader_and_menu_contract");

        [TestCaseSource(nameof(FixedEffectNodes))]
        public void FixedEffectNodeMetadataMatchesShaderAndMenuContract(Type nodeType, string displayName, string shaderName)
        {
            var node = (FixedNoiseNode)Activator.CreateInstance(nodeType);
            var menuItem = nodeType.GetCustomAttribute<NodeMenuItemAttribute>();

            Assert.That(node.name, Is.EqualTo(displayName));
            Assert.That(node.NodeGroup, Is.EqualTo("Effects"));
            Assert.That(node.ShaderName, Is.EqualTo(shaderName));
            Assert.That(node.DisplayMaterialInspector, Is.True);
            Assert.That(node.defaultPreviewChannels, Is.EqualTo(PreviewChannels.RGB));
            Assert.That(menuItem, Is.Not.Null);
            Assert.That(menuItem.menuTitle, Is.EqualTo($"Effects/{displayName}"));
            Assert.That(node.supportedDimensions, Is.EquivalentTo(new[]
            {
                OutputDimension.Texture2D,
                OutputDimension.Texture3D,
                OutputDimension.CubeMap,
            }));
        }
    }
}
