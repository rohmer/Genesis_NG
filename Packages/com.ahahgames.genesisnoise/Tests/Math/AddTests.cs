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
    public class MathAddTests
    {
        [Test]
        public void AddInt()
        {
            Assert.IsTrue(MathA.Add(1, 1) == 2);
            Assert.IsTrue(MathA.Add(1, 2.0f) == 3);
            Assert.IsTrue(MathA.Add(1, new Vector2(1, 1)) == new Vector2(2, 2));
            Assert.IsTrue(MathA.Add(1, new Vector3(1, 1, 2)) == new Vector3(2, 2, 3));
            Assert.IsTrue(MathA.Add(1, new Vector4(1, 1, 1, 2)) == new Vector4(2, 2, 2, 3));
            Assert.IsTrue(MathA.Add(1, new Vector2Int(1, 1)) == new Vector2Int(2, 2));
            Assert.IsTrue(MathA.Add(1, new Vector3Int(1, 1, 2)) == new Vector3Int(2, 2, 3));
            Assert.IsTrue(MathA.Add(1, true) == 2);
            Assert.IsTrue(MathA.Add(1, new Color(0, 0, 0, 0)) == new Color(1, 1, 1, 1));
            Assert.IsTrue(MathA.Add(1, " number") == "1 number");
            Assert.IsTrue(MathA.Add(1, new Quaternion(1, 2, 3, 4)) == new Quaternion(2, 3, 4, 5));
        }

        [Test]
        public void AddFloat()
        {
            Assert.IsTrue(MathA.Add(1.0f, 1) == 2);
            Assert.IsTrue(MathA.Add(1.0f, 2.0f) == 3);
            Assert.IsTrue(MathA.Add(1.0f, new Vector2(1, 1)) == new Vector2(2, 2));
            Assert.IsTrue(MathA.Add(1.0f, new Vector3(1, 1, 2)) == new Vector3(2, 2, 3));
            Assert.IsTrue(MathA.Add(1.0f, new Vector4(1, 1, 1, 2)) == new Vector4(2, 2, 2, 3));
            Assert.IsTrue(MathA.Add(1.0f, new Vector2Int(1, 1)) == new Vector2Int(2, 2));
            Assert.IsTrue(MathA.Add(1.0f, new Vector3Int(1, 1, 2)) == new Vector3Int(2, 2, 3));
            Assert.IsTrue(MathA.Add(1.0f, true) == 2);
            Assert.IsTrue(MathA.Add(1.0f, new Color(0, 0, 0, 0)) == new Color(1, 1, 1, 1));
            Assert.IsTrue(MathA.Add(1.0f, " number") == "1 number");
            Assert.IsTrue(MathA.Add(1.0f, new Quaternion(1, 2, 3, 4)) == new Quaternion(2, 3, 4, 5));
        }

        [Test]
        public void AddVector2()
        {
            Vector2 src = new Vector2(1, 2);

            Assert.IsTrue(MathA.Add(src, 1) == new Vector2(2, 3));
            Assert.IsTrue(MathA.Add(src, 2.0f) == new Vector2(3, 4));
            Assert.IsTrue(MathA.Add(src, new Vector2(1, 1)) == new Vector2(2, 3));
            Assert.IsTrue(MathA.Add(src, new Vector3(1, 1, 2)) == new Vector3(2, 3, 2));
            Assert.IsTrue(MathA.Add(src, new Vector4(1, 1, 1, 2)) == new Vector4(2, 3, 1, 2));
            Assert.IsTrue(MathA.Add(src, new Vector2Int(1, 1)) == new Vector2Int(2, 3));
            Assert.IsTrue(MathA.Add(src, new Vector3Int(1, 1, 2)) == new Vector3Int(2, 3, 2));
            Assert.IsTrue(MathA.Add(src, true) == new Vector2(2, 3));

            Assert.IsTrue(MathA.Add(new Vector2(0.1f, 0.1f), new Color(0, 0, 0, 0)) == new Color(0.1f, 0.1f, 0, 0));
            Debug.Log(MathA.Add(src, " number").ToString());
            Assert.IsTrue(MathA.Add(src, " number") == "(1.00, 2.00) number");
            Assert.IsTrue(MathA.Add(src, new Quaternion(1, 2, 3, 4)) == new Quaternion(2, 3, 3, 4));
        }

        [Test]
        public void AddVector3()
        {
            Vector3 src = new Vector3(1, 2, 3);

            Assert.IsTrue(MathA.Add(src, 1) == new Vector3(2, 3, 4));
            Assert.IsTrue(MathA.Add(src, 2.0f) == new Vector3(3, 4, 5));
            Assert.IsTrue(MathA.Add(src, new Vector2(1, 1)) == new Vector3(2, 3, 3));
            Assert.IsTrue(MathA.Add(src, new Vector3(1, 1, 2)) == new Vector3(2, 3, 5));
            Assert.IsTrue(MathA.Add(src, new Vector4(1, 1, 1, 2)) == new Vector4(2, 3, 4, 2));
            Assert.IsTrue(MathA.Add(src, new Vector2Int(1, 1)) == new Vector3(2, 3, 3));
            Assert.IsTrue(MathA.Add(src, new Vector3Int(1, 1, 2)) == new Vector3(2, 3, 5));
            Assert.IsTrue(MathA.Add(src, true) == new Vector3(2, 3, 4));

            Assert.IsTrue(MathA.Add(new Vector3(0.1f, 0.1f, 0.2f), new Color(0, 0, 0, 0)) == new Color(0.1f, 0.1f, 0.2f, 0));
            Assert.IsTrue(MathA.Add(src, " number") == "(1.00, 2.00, 3.00) number");
            Assert.IsTrue(MathA.Add(src, new Quaternion(1, 2, 3, 4)) == new Quaternion(2, 4, 6, 4));
        }

        [Test]
        public void AddVector4()
        {
            Vector4 src = new Vector4(1, 2, 3, 4);
            Assert.IsTrue(MathA.Add(src, 1) == new Vector4(2, 3, 4, 5));
            Assert.IsTrue(MathA.Add(src, 2.0f) == new Vector4(3, 4, 5, 6));
            Assert.IsTrue(MathA.Add(src, new Vector2(1, 1)) == new Vector4(2, 3, 3, 4));
            Assert.IsTrue(MathA.Add(src, new Vector3(1, 1, 2)) == new Vector4(2, 3, 5, 4));
            Assert.IsTrue(MathA.Add(src, new Vector4(1, 1, 1, 2)) == new Vector4(2, 3, 4, 6));
            Assert.IsTrue(MathA.Add(src, new Vector2Int(1, 1)) == new Vector4(2, 3, 3, 4));
            Assert.IsTrue(MathA.Add(src, new Vector3Int(1, 1, 2)) == new Vector4(2, 3, 5, 4));
            Assert.IsTrue(MathA.Add(src, true) == new Vector4(2, 3, 4, 5));

            Assert.IsTrue(MathA.Add(new Vector4(0.1f, 0.1f, 0.2f, 0.2f), new Color(0, 0, 0, 0)) == new Color(0.1f, 0.1f, 0.2f, 0.2f));
            Assert.IsTrue(MathA.Add(src, " number") == "(1.00, 2.00, 3.00, 4.00) number");
            Assert.IsTrue(MathA.Add(src, new Quaternion(1, 2, 3, 4)) == new Quaternion(2, 4, 6, 8));
        }

        [Test]
        public void AddVector2Int()
        {
            Vector2Int src = new Vector2Int(1, 2);
            Assert.IsTrue(MathA.Add(src, 1) == new Vector2Int(2, 3));
            Assert.IsTrue(MathA.Add(src, 2.0f) == new Vector2Int(3, 4));
            Assert.IsTrue(MathA.Add(src, new Vector2(1, 1)) == new Vector2Int(2, 3));
            Assert.IsTrue(MathA.Add(src, new Vector3(1, 1, 2)) == new Vector3(2, 3, 2));
            Assert.IsTrue(MathA.Add(src, new Vector4(1, 1, 1, 2)) == new Vector4(2, 3, 1, 2));
            Assert.IsTrue(MathA.Add(src, new Vector2Int(1, 1)) == new Vector2Int(2, 3));
            Assert.IsTrue(MathA.Add(src, new Vector3Int(1, 1, 2)) == new Vector3Int(2, 3, 2));
            Assert.IsTrue(MathA.Add(src, true) == new Vector2Int(2, 3));

            Assert.IsTrue(MathA.Add(new Vector2Int(0, 0), new Color(0.1f, 0.2f, 0.3f, 0.4f)) == new Color(0.1f, 0.2f, 0.3f, 0.4f));
            Assert.IsTrue(MathA.Add(src, " number") == "(1, 2) number");
            Assert.IsTrue(MathA.Add(src, new Quaternion(1, 2, 3, 4)) == new Quaternion(2, 4, 3, 4));
        }

        [Test]
        public void AddVector3Int()
        {
            Vector3Int src = new Vector3Int(1, 2, 3);
            Assert.IsTrue(MathA.Add(src, 1) == new Vector3Int(2, 3, 4));
            Assert.IsTrue(MathA.Add(src, 2.0f) == new Vector3Int(3, 4, 5));
            Assert.IsTrue(MathA.Add(src, new Vector2(1, 1)) == new Vector3Int(2, 3, 3));
            Assert.IsTrue(MathA.Add(src, new Vector3(1, 1, 2)) == new Vector3(2, 3, 5));
            Assert.IsTrue(MathA.Add(src, new Vector4(1, 1, 1, 2)) == new Vector4(2, 3, 4, 2));
            Assert.IsTrue(MathA.Add(src, new Vector2Int(1, 1)) == new Vector3Int(2, 3, 3));
            Assert.IsTrue(MathA.Add(src, new Vector3Int(1, 1, 2)) == new Vector3Int(2, 3, 5));
            Assert.IsTrue(MathA.Add(src, true) == new Vector3Int(2, 3, 4));
            Assert.IsTrue(MathA.Add(new Vector3Int(0, 0, 0), new Color(0.1f, 0.2f, 0.3f, 0.4f)) == new Color(0.1f, 0.2f, 0.3f, 0.4f));
            Assert.IsTrue(MathA.Add(src, " number") == "(1, 2, 3) number");
            Assert.IsTrue(MathA.Add(src, new Quaternion(1, 2, 3, 4)) == new Quaternion(2, 4, 6, 4));
        }

        [Test]
        public void AddBoolTest()
        {
            Assert.IsTrue(MathA.Add(false, false) == false);
            Assert.IsTrue(MathA.Add(false, true) == true);
            Assert.IsTrue(MathA.Add(true, true) == true);
        }

        [Test]
        public void AddColorTest()
        {
            Color c = MathA.Add(new Color(0, 0, 0, 0), Color.gainsboro);
            Debug.Log(MathA.Add(new Color(0.1f, 0.2f, 0.3f), new Color(0.1f, 0.2f, 0.3f)).ToString());
            Assert.IsTrue(MathA.Add(new Color(0.1f, 0.2f, 0.3f), new Color(0.1f, 0.2f, 0.3f)) == new Color(0.2f, 0.4f, 0.6f,1.0f));
        }
    }
}
