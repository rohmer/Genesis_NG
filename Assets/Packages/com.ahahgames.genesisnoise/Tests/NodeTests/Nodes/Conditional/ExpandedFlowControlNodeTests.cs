using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using NUnit.Framework;

using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace AhahGames.GenesisNoise.Tests.Nodes.Conditional
{
    public class ExpandedFlowControlNodeTests
    {
        enum SampleLoopState
        {
            Idle,
            Running,
            Done,
        }

        [Test]
        public void WhileStartSkipsInitialIterationUntilConditionIsTrue()
        {
            var node = new WhileStart
            {
                input = "seed",
                condition = false,
                maxIterations = 4,
            };

            node.PrepareLoopStart();

            Assert.That(node.CanEnterLoop(), Is.False);
            Assert.That(node.CurrentLoopValue, Is.EqualTo("seed"));
            Assert.That(node.outputMaxIterations, Is.EqualTo(4));

            node.condition = true;
            node.PrepareLoopStart();

            Assert.That(node.CanEnterLoop(), Is.True);
        }

        [Test]
        public void ForEachStartEnumeratesCollectionItems()
        {
            var node = new ForEachStart
            {
                input = "carry",
                collection = new[] { "alpha", "beta", "gamma" },
            };

            node.PrepareLoopStart();

            Assert.That(node.CanEnterLoop(), Is.True);
            Assert.That(node.outputCount, Is.EqualTo(3));
            Assert.That(node.CurrentLoopValue, Is.EqualTo("carry"));

            InvokeProcessNode(node);
            Assert.That(node.item, Is.EqualTo("alpha"));
            Assert.That(node.index, Is.EqualTo(1));
            Assert.That(node.IsLastIteration(), Is.False);

            InvokeProcessNode(node);
            Assert.That(node.item, Is.EqualTo("beta"));
            Assert.That(node.index, Is.EqualTo(2));
            Assert.That(node.IsLastIteration(), Is.False);

            InvokeProcessNode(node);
            Assert.That(node.item, Is.EqualTo("gamma"));
            Assert.That(node.index, Is.EqualTo(3));
            Assert.That(node.IsLastIteration(), Is.True);
        }

        [Test]
        public void EnumSwitchMatchesCaseLabelsBySelectionText()
        {
            var node = new EnumSwitchNode
            {
                defaultInput = "fallback",
                selection = SampleLoopState.Done,
            };

            node.SetCaseCount(3);
            node.SetCaseLabel(0, "Idle");
            node.SetCaseLabel(1, "Running");
            node.SetCaseLabel(2, "Done");
            node.caseInputs[0] = "idle-value";
            node.caseInputs[1] = "running-value";
            node.caseInputs[2] = "done-value";

            InvokeProcessNode(node);
            Assert.That(node.output, Is.EqualTo("done-value"));

            node.selection = "Missing";
            InvokeProcessNode(node);
            Assert.That(node.output, Is.EqualTo("fallback"));
        }

        [Test]
        public void AggregateEndCollectsAndReducesValues()
        {
            var loopStart = new ForStart
            {
                input = "seed",
                inputCount = 2,
            };
            loopStart.PrepareLoopStart();

            var node = new AggregateEnd
            {
                mode = AggregateEnd.AggregateMode.CollectValues,
            };

            node.PrepareLoopEnd(loopStart);
            node.input = 1;
            InvokeProcessNode(node);
            node.input = 2;
            InvokeProcessNode(node);
            node.FinalIteration();

            Assert.That(node.iterationCount, Is.EqualTo(2));
            Assert.That(node.output, Is.TypeOf<List<object>>());
            Assert.That(((List<object>)node.output).ToArray(), Is.EqualTo(new object[] { 1, 2 }));

            node.mode = AggregateEnd.AggregateMode.CountIterations;
            node.FinalIteration();
            Assert.That(node.output, Is.EqualTo(2));
        }

        [Test]
        public void AggregateEndZeroIterationUsesEmptyOrInitialResult()
        {
            var loopStart = new ForStart
            {
                input = "seed",
                inputCount = 0,
            };
            loopStart.PrepareLoopStart();

            var collectNode = new AggregateEnd
            {
                mode = AggregateEnd.AggregateMode.CollectValues,
            };
            collectNode.ZeroIteration(loopStart);

            Assert.That(collectNode.iterationCount, Is.EqualTo(0));
            Assert.That(collectNode.output, Is.TypeOf<List<object>>());
            Assert.That(((List<object>)collectNode.output), Is.Empty);

            var firstNode = new AggregateEnd
            {
                mode = AggregateEnd.AggregateMode.FirstValue,
            };
            firstNode.ZeroIteration(loopStart);

            Assert.That(firstNode.output, Is.EqualTo("seed"));
        }

        [Test]
        public void BreakAndContinueNodesPreserveInputValue()
        {
            var breakNode = new BreakNode
            {
                input = "break-value",
                condition = true,
            };
            InvokeProcessNode(breakNode);
            Assert.That(breakNode.output, Is.EqualTo("break-value"));

            var continueNode = new ContinueNode
            {
                input = "continue-value",
                condition = true,
            };
            InvokeProcessNode(continueNode);
            Assert.That(continueNode.output, Is.EqualTo("continue-value"));

            var whileEnd = new WhileEnd();
            var menuItems = typeof(WhileEnd).GetCustomAttributes<NodeMenuItemAttribute>().ToArray();
            Assert.That(whileEnd.name, Is.EqualTo("While End"));
            Assert.That(menuItems.Select(m => m.menuTitle), Is.EquivalentTo(new[] { "Conditional/While End" }));
        }

        static void InvokeProcessNode(object node)
        {
            var processNode = node.GetType().GetMethod("ProcessNode", BindingFlags.Instance | BindingFlags.NonPublic);
            processNode.Invoke(node, new object[] { null });
        }
    }
}
