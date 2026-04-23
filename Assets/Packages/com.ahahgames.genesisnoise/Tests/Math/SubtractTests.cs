using System.Collections;
using System.Collections.Generic;

using AhahGames.GenesisNoise.Graph;

using NUnit.Framework;

using UnityEngine;
using UnityEditor;
using UnityEngine.TestTools;
using AhahGames.GenesisNoise.Utility;

namespace AhahGames.GenesisNoise.Tests
{
    public class MathSubtractTests
    {
        [Test]
        public void SubtractInt()
        {
            Assert.IsTrue(MathA.Subtract(1, 1) == 0);
            Assert.IsTrue(MathA.Subtract(1, 2.0f) == -1);
            Assert.IsTrue(MathA.Subtract(1, new Vector2(1, 1)) == new Vector2(0, 0));
            Assert.IsTrue(MathA.Subtract(1, new Vector3(1, 1, 2)) == new Vector3(0, 0, 1));
            Assert.IsTrue(MathA.Subtract(1, new Vector4(1, 1, 1, 2)) == new Vector4(0, 0, 0, 1));
            Assert.IsTrue(MathA.Subtract(1, new Vector2Int(1, 1)) == new Vector2Int(0, 0));
            Assert.IsTrue(MathA.Subtract(1, new Vector3Int(1, 1, 2)) == new Vector3Int(0, 0, 1));
            Assert.IsTrue(MathA.Subtract(1, true) == 0);            
        }

        [Test]
        public void SubtractFloat()
        {
            Assert.IsTrue(MathA.Subtract(1.0f, 1) == 2);
            Assert.IsTrue(MathA.Subtract(1.0f, 2.0f) == 3);
            Assert.IsTrue(MathA.Subtract(1.0f, new Vector2(1, 1)) == new Vector2(2, 2));
            Assert.IsTrue(MathA.Subtract(1.0f, new Vector3(1, 1, 2)) == new Vector3(2, 2, 3));
            Assert.IsTrue(MathA.Subtract(1.0f, new Vector4(1, 1, 1, 2)) == new Vector4(2, 2, 2, 3));
            Assert.IsTrue(MathA.Subtract(1.0f, new Vector2Int(1, 1)) == new Vector2Int(2, 2));
            Assert.IsTrue(MathA.Subtract(1.0f, new Vector3Int(1, 1, 2)) == new Vector3Int(2, 2, 3));
            Assert.IsTrue(MathA.Subtract(1.0f, true) == 2);
            Assert.IsTrue(MathA.Subtract(1.0f, new Color(0, 0, 0, 0)) == new Color(1, 1, 1, 1));
            Assert.IsTrue(MathA.Subtract(1.0f, new Quaternion(1, 2, 3, 4)) == new Quaternion(2, 3, 4, 5));
        }

        [Test]
        public void SubtractVector2()
        {
            Vector2 src = new Vector2(1, 2);

            Assert.IsTrue(MathA.Subtract(src, 1) == new Vector2(2, 3));
            Assert.IsTrue(MathA.Subtract(src, 2.0f) == new Vector2(3, 4));
            Assert.IsTrue(MathA.Subtract(src, new Vector2(1, 1)) == new Vector2(2, 3));
            Assert.IsTrue(MathA.Subtract(src, new Vector3(1, 1, 2)) == new Vector3(2, 3, 2));
            Assert.IsTrue(MathA.Subtract(src, new Vector4(1, 1, 1, 2)) == new Vector4(2, 3, 1, 2));
            Assert.IsTrue(MathA.Subtract(src, new Vector2Int(1, 1)) == new Vector2Int(2, 3));
            Assert.IsTrue(MathA.Subtract(src, new Vector3Int(1, 1, 2)) == new Vector3Int(2, 3, 2));
            Assert.IsTrue(MathA.Subtract(src, true) == new Vector2(2, 3));

            Assert.IsTrue(MathA.Subtract(new Vector2(0.1f, 0.1f), new Color(0, 0, 0, 0)) == new Color(0.1f, 0.1f, 0, 0));
            Assert.IsTrue(MathA.Subtract(src, new Quaternion(1, 2, 3, 4)) == new Quaternion(2, 3, 3, 4));
        }

        [Test]
        public void SubtractVector3()
        {
            Vector3 src = new Vector3(1, 2, 3);

            Assert.IsTrue(MathA.Subtract(src, 1) == new Vector3(2, 3, 4));
            Assert.IsTrue(MathA.Subtract(src, 2.0f) == new Vector3(3, 4, 5));
            Assert.IsTrue(MathA.Subtract(src, new Vector2(1, 1)) == new Vector3(2, 3, 3));
            Assert.IsTrue(MathA.Subtract(src, new Vector3(1, 1, 2)) == new Vector3(2, 3, 5));
            Assert.IsTrue(MathA.Subtract(src, new Vector4(1, 1, 1, 2)) == new Vector4(2, 3, 4, 2));
            Assert.IsTrue(MathA.Subtract(src, new Vector2Int(1, 1)) == new Vector3(2, 3, 3));
            Assert.IsTrue(MathA.Subtract(src, new Vector3Int(1, 1, 2)) == new Vector3(2, 3, 5));
            Assert.IsTrue(MathA.Subtract(src, true) == new Vector3(2, 3, 4));

            Assert.IsTrue(MathA.Subtract(new Vector3(0.1f, 0.1f, 0.2f), new Color(0, 0, 0, 0)) == new Color(0.1f, 0.1f, 0.2f, 0));
            Assert.IsTrue(MathA.Subtract(src, new Quaternion(1, 2, 3, 4)) == new Quaternion(2, 4, 6, 4));
        }

        [Test]
        public void SubtractVector4()
        {
            Vector4 src = new Vector4(1, 2, 3, 4);
            Assert.IsTrue(MathA.Subtract(src, 1) == new Vector4(2, 3, 4, 5));
            Assert.IsTrue(MathA.Subtract(src, 2.0f) == new Vector4(3, 4, 5, 6));
            Assert.IsTrue(MathA.Subtract(src, new Vector2(1, 1)) == new Vector4(2, 3, 3, 4));
            Assert.IsTrue(MathA.Subtract(src, new Vector3(1, 1, 2)) == new Vector4(2, 3, 5, 4));
            Assert.IsTrue(MathA.Subtract(src, new Vector4(1, 1, 1, 2)) == new Vector4(2, 3, 4, 6));
            Assert.IsTrue(MathA.Subtract(src, new Vector2Int(1, 1)) == new Vector4(2, 3, 3, 4));
            Assert.IsTrue(MathA.Subtract(src, new Vector3Int(1, 1, 2)) == new Vector4(2, 3, 5, 4));
            Assert.IsTrue(MathA.Subtract(src, true) == new Vector4(2, 3, 4, 5));

            Assert.IsTrue(MathA.Subtract(new Vector4(0.1f, 0.1f, 0.2f, 0.2f), new Color(0, 0, 0, 0)) == new Color(0.1f, 0.1f, 0.2f, 0.2f));
            Assert.IsTrue(MathA.Subtract(src, new Quaternion(1, 2, 3, 4)) == new Quaternion(2, 4, 6, 8));
        }

        [Test]
        public void SubtractVector2Int()
        {
            Vector2Int src = new Vector2Int(1, 2);
            Assert.IsTrue(MathA.Subtract(src, 1) == new Vector2Int(2, 3));
            Assert.IsTrue(MathA.Subtract(src, 2.0f) == new Vector2Int(3, 4));
            Assert.IsTrue(MathA.Subtract(src, new Vector2(1, 1)) == new Vector2Int(2, 3));
            Assert.IsTrue(MathA.Subtract(src, new Vector3(1, 1, 2)) == new Vector3(2, 3, 2));
            Assert.IsTrue(MathA.Subtract(src, new Vector4(1, 1, 1, 2)) == new Vector4(2, 3, 1, 2));
            Assert.IsTrue(MathA.Subtract(src, new Vector2Int(1, 1)) == new Vector2Int(2, 3));
            Assert.IsTrue(MathA.Subtract(src, new Vector3Int(1, 1, 2)) == new Vector3Int(2, 3, 2));
            Assert.IsTrue(MathA.Subtract(src, true) == new Vector2Int(2, 3));

            Assert.IsTrue(MathA.Subtract(new Vector2Int(0, 0), new Color(0.1f, 0.2f, 0.3f, 0.4f)) == new Color(0.1f, 0.2f, 0.3f, 0.4f));
            Assert.IsTrue(MathA.Subtract(src, new Quaternion(1, 2, 3, 4)) == new Quaternion(2, 4, 3, 4));
        }

        [Test]
        public void SubtractVector3Int()
        {
            Vector3Int src = new Vector3Int(1, 2, 3);
            Assert.IsTrue(MathA.Subtract(src, 1) == new Vector3Int(2, 3, 4));
            Assert.IsTrue(MathA.Subtract(src, 2.0f) == new Vector3Int(3, 4, 5));
            Assert.IsTrue(MathA.Subtract(src, new Vector2(1, 1)) == new Vector3Int(2, 3, 3));
            Assert.IsTrue(MathA.Subtract(src, new Vector3(1, 1, 2)) == new Vector3(2, 3, 5));
            Assert.IsTrue(MathA.Subtract(src, new Vector4(1, 1, 1, 2)) == new Vector4(2, 3, 4, 2));
            Assert.IsTrue(MathA.Subtract(src, new Vector2Int(1, 1)) == new Vector3Int(2, 3, 3));
            Assert.IsTrue(MathA.Subtract(src, new Vector3Int(1, 1, 2)) == new Vector3Int(2, 3, 5));
            Assert.IsTrue(MathA.Subtract(src, true) == new Vector3Int(2, 3, 4));
            Assert.IsTrue(MathA.Subtract(new Vector3Int(0, 0, 0), new Color(0.1f, 0.2f, 0.3f, 0.4f)) == new Color(0.1f, 0.2f, 0.3f, 0.4f));
            Assert.IsTrue(MathA.Subtract(src, new Quaternion(1, 2, 3, 4)) == new Quaternion(2, 4, 6, 4));
        }

        [Test]
        public void SubtractBoolTest()
        {
            Assert.IsTrue(MathA.Subtract(false, false) == false);
            Assert.IsTrue(MathA.Subtract(false, true) == true);
            Assert.IsTrue(MathA.Subtract(true, true) == true);
        }

        [Test]
        public void SubtractColorTest()
        {
            Color c = MathA.Subtract(new Color(0, 0, 0, 0), Color.gainsboro);
            Debug.Log(MathA.Subtract(new Color(0.1f, 0.2f, 0.3f), new Color(0.1f, 0.2f, 0.3f)).ToString());
            Assert.IsTrue(MathA.Subtract(new Color(0.1f, 0.2f, 0.3f), new Color(0.1f, 0.2f, 0.3f)) == new Color(0.2f, 0.4f, 0.6f, 1.0f));
        }
    }
}
