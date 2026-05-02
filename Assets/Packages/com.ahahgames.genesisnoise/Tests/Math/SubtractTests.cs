using NUnit.Framework;

using AhahGames.GenesisNoise.Utility;

namespace AhahGames.GenesisNoise.Tests
{
    public class MathSubtractTests
    {
        [Test]
        public void SubtractBoolTest()
        {
            Assert.IsTrue(MathA.Subtract(false, false) == false);
            Assert.IsTrue(MathA.Subtract(false, true) == true);
            Assert.IsTrue(MathA.Subtract(true, true) == true);
        }
    }
}
