using System;

using Unity.Mathematics;

using UnityEngine;

namespace AhahGames.GenesisNoise.Utility
{
    public static class MathA
    {
        #region GetMathType
        public static Type GetMathType(object inputa, object inputb)
        {
            if (inputa.GetType() == typeof(Texture2D) || inputb.GetType() == typeof(Texture2D))
                return typeof(Texture2D);
            if (inputa.GetType() == typeof(AnimationCurve) || inputb.GetType() == typeof(AnimationCurve))
                return typeof(AnimationCurve);
            if (inputa.GetType() == typeof(string) || inputb.GetType() == typeof(string))
                return typeof(string);

            if (inputa.GetType() == typeof(Quaternion) || inputb.GetType() == typeof(Quaternion))
                return typeof(Quaternion);
            if (inputa.GetType() == typeof(Color) || inputb.GetType() == typeof(Color))
                return typeof(Color);
            if (inputa.GetType() == typeof(Vector4) || inputb.GetType() == typeof(Vector4))
                return typeof(Vector4);
            if (inputa.GetType() == typeof(Vector3) || inputb.GetType() == typeof(Vector3))
                return typeof(Vector3);
            if (inputa.GetType() == typeof(Vector3Int) || inputb.GetType() == typeof(Vector3Int))
                return typeof(Vector3Int);
            if (inputa.GetType() == typeof(Vector2) || inputb.GetType() == typeof(Vector2))
                return typeof(Vector2);
            if (inputa.GetType() == typeof(float) || inputb.GetType() == typeof(float))
                return typeof(float);
            if (inputa.GetType() == typeof(int) || inputb.GetType() == typeof(int))
                return typeof(int);
            if (inputa.GetType() == typeof(bool) || inputb.GetType() == typeof(bool))
                return typeof(bool);
            return null;
        }

        #endregion
        #region Add
        public static object Add(object a, object b)
        {
            if (a is int)
            {
                if (b is int)
                    return Add((int)a, (int)b);
                if (b is float)
                    return Add((int)a, (float)b);
                if (b is Vector2)
                    return Add((int)a, (Vector2)b);
                if (b is Vector3)
                    return Add((int)a, (Vector3)b);
                if (b is Vector4)
                    return Add((int)a, (Vector4)b);
                if (b is Vector3Int)
                    return Add((int)a, (Vector3Int)b);
                if (b is Quaternion)
                    return Add((int)a, (Quaternion)b);
                if (b is Vector2Int)
                    return Add((int)a, (Vector2Int)b);
                if (b is Color)
                    return Add((int)a, (Color)b);
                if (b is bool)
                    return Add((int)a, (bool)b);
            }
            if (a is float)
            {
                if (b is int)
                    return Add((float)a, (int)b);
                if (b is float)
                    return Add((float)a, (float)b);
                if (b is Vector2)
                    return Add((float)a, (Vector2)b);
                if (b is Vector3)
                    return Add((float)a, (Vector3)b);
                if (b is Vector4)
                    return Add((float)a, (Vector4)b);
                if (b is Vector3Int)
                    return Add((float)a, (Vector3Int)b);
                if (b is Quaternion)
                    return Add((float)a, (Quaternion)b);
                if (b is Vector2Int)
                    return Add((float)a, (Vector2Int)b);
                if (b is Color)
                    return Add((float)a, (Color)b);
                if (b is bool)
                    return Add((float)a, (bool)b);
            }

            if (a is Vector2 i)
            {
                if (b is int)
                    return Add(i, (int)b);
                if (b is float)
                    return Add(i, (float)b);
                if (b is Vector2)
                    return Add(i, (Vector2)b);
                if (b is Vector3)
                    return Add(i, (Vector3)b);
                if (b is Vector4)
                    return Add(i, (Vector4)b);
                if (b is Vector3Int)
                    return Add(i, (Vector3Int)b);
                if (b is Quaternion)
                    return Add(i, (Quaternion)b);
                if (b is Vector2Int)
                    return Add(i, (Vector2Int)b);
                if (b is Color)
                    return Add(i, (Color)b);
                if (b is bool)
                    return Add(i, (bool)b);
            }

            if (a is Vector3 j)
            {
                if (b is int)
                    return Add(j, (int)b);
                if (b is float)
                    return Add(j, (float)b);
                if (b is Vector2)
                    return Add(j, (Vector2)b);
                if (b is Vector3)
                    return Add(j, (Vector3)b);
                if (b is Vector4)
                    return Add(j, (Vector4)b);
                if (b is Vector3Int)
                    return Add(j, (Vector3Int)b);
                if (b is Quaternion)
                    return Add(j, (Quaternion)b);
                if (b is Vector2Int)
                    return Add(j, (Vector2Int)b);
                if (b is Color)
                    return Add(j, (Color)b);
                if (b is bool)
                    return Add(j, (bool)b);
            }

            if (a is Vector4 k)
            {
                if (b is int)
                    return Add(k, (int)b);
                if (b is float)
                    return Add(k, (float)b);
                if (b is Vector2)
                    return Add(k, (Vector2)b);
                if (b is Vector3)
                    return Add(k, (Vector3)b);
                if (b is Vector4)
                    return Add(k, (Vector4)b);
                if (b is Vector3Int)
                    return Add(k, (Vector3Int)b);
                if (b is Quaternion)
                    return Add(k, (Quaternion)b);
                if (b is Vector2Int)
                    return Add(k, (Vector2Int)b);
                if (b is Color)
                    return Add(k, (Color)b);
                if (b is bool)
                    return Add(k, (bool)b);
            }

            if (a is Vector2Int l)
            {
                if (b is int)
                    return Add(l, (int)b);
                if (b is float)
                    return Add(l, (float)b);
                if (b is Vector2)
                    return Add(l, (Vector2)b);
                if (b is Vector3)
                    return Add(l, (Vector3)b);
                if (b is Vector4)
                    return Add(l, (Vector4)b);
                if (b is Vector3Int)
                    return Add(l, (Vector3Int)b);
                if (b is Quaternion)
                    return Add(l, (Quaternion)b);
                if (b is Vector2Int)
                    return Add(l, (Vector2Int)b);
                if (b is Color)
                    return Add(l, (Color)b);
                if (b is bool)
                    return Add(l, (bool)b);
            }

            if (a is Vector3Int m)
            {
                if (b is int)
                    return Add(m, (int)b);
                if (b is float)
                    return Add(m, (float)b);
                if (b is Vector2)
                    return Add(m, (Vector2)b);
                if (b is Vector3)
                    return Add(m, (Vector3)b);
                if (b is Vector4)
                    return Add(m, (Vector4)b);
                if (b is Vector3Int)
                    return Add(m, (Vector3Int)b);
                if (b is Quaternion)
                    return Add(m, (Quaternion)b);
                if (b is Vector2Int)
                    return Add(m, (Vector2Int)b);
                if (b is Color)
                    return Add(m, (Color)b);
                if (b is bool)
                    return Add(m, (bool)b);
            }

            if (a is Color n)
            {
                if (b is int)
                    return Add(n, (int)b);
                if (b is float)
                    return Add(n, (float)b);
                if (b is Vector2)
                    return Add(n, (Vector2)b);
                if (b is Vector3)
                    return Add(n, (Vector3)b);
                if (b is Vector4)
                    return Add(n, (Vector4)b);
                if (b is Vector3Int)
                    return Add(n, (Vector3Int)b);
                if (b is Quaternion)
                    return Add(n, (Quaternion)b);
                if (b is Vector2Int)
                    return Add(n, (Vector2Int)b);
                if (b is Color)
                    return Add(n, (Color)b);
                if (b is bool)
                    return Add(n, (bool)b);
            }

            if (a is string o)
            {
                if (b is int)
                    return Add(o, (int)b);
                if (b is float)
                    return Add(o, (float)b);
                if (b is Vector2)
                    return Add(o, (Vector2)b);
                if (b is Vector3)
                    return Add(o, (Vector3)b);
                if (b is Vector4)
                    return Add(o, (Vector4)b);
                if (b is Vector3Int)
                    return Add(o, (Vector3Int)b);
                if (b is Quaternion)
                    return Add(o, (Quaternion)b);
                if (b is Vector2Int)
                    return Add(o, (Vector2Int)b);
                if (b is Color)
                    return Add(o, (Color)b);
                if (b is bool)
                    return Add(o, (bool)b);
            }

            if (a is bool p)
            {
                if (b is int)
                    return Add(p, (int)b);
                if (b is float)
                    return Add(p, (float)b);
                if (b is Vector2)
                    return Add(p, (Vector2)b);
                if (b is Vector3)
                    return Add(p, (Vector3)b);
                if (b is Vector4)
                    return Add(p, (Vector4)b);
                if (b is Vector3Int)
                    return Add(p, (Vector3Int)b);
                if (b is Quaternion)
                    return Add(p, (Quaternion)b);
                if (b is Vector2Int)
                    return Add(p, (Vector2Int)b);
                if (b is Color)
                    return Add(p, (Color)b);
                if (b is bool)
                    return Add(p, (bool)b);
            }

            if (a is Quaternion q)
            {
                if (b is int)
                    return Add(q, (int)b);
                if (b is float)
                    return Add(q, (float)b);
                if (b is Vector2)
                    return Add(q, (Vector2)b);
                if (b is Vector3)
                    return Add(q, (Vector3)b);
                if (b is Vector4)
                    return Add(q, (Vector4)b);
                if (b is Vector3Int)
                    return Add(q, (Vector3Int)b);
                if (b is Quaternion)
                    return Add(q, (Quaternion)b);
                if (b is Vector2Int)
                    return Add(q, (Vector2Int)b);
                if (b is Color)
                    return Add(q, (Color)b);
                if (b is bool)
                    return Add(q, (bool)b);
            }
            if (a is Texture2D)
            {
                if (b == null)
                    return a;
                if (b is int)
                    return Add((Texture2D)a, (int)b);
                if (b is float)
                    return Add((Texture2D)a, (float)b);
                if (b is Vector2)
                    return Add((Texture2D)a, (Vector2)b);
                if (b is Vector3)
                    return Add((Texture2D)a, (Vector3)b);
                if (b is Vector4)
                    return Add((Texture2D)a, (Vector4)b);
                if (b is Vector2Int)
                    return Add((Texture2D)a, (Vector2Int)b);
                if (b is Vector3Int)
                    return Add((Texture2D)a, (Vector2Int)b);
                if (b is AnimationCurve)
                    return Add((Texture2D)a, (AnimationCurve)b);
            }
            if (b is Texture2D)
            {
                if (a == null)
                    return b;
                if (a is int)
                    return Add((Texture2D)b, (int)a);
                if (a is float)
                    return Add((Texture2D)b, (float)a);
                if (a is Vector2)
                    return Add((Texture2D)b, (Vector2)a);
                if (a is Vector3)
                    return Add((Texture2D)b, (Vector3)a);
                if (a is Vector4)
                    return Add((Texture2D)b, (Vector4)a);
                if (a is Vector2Int)
                    return Add((Texture2D)b, (Vector2Int)a);
                if (a is Vector3Int)
                    return Add((Texture2D)b, (Vector2Int)a);
                if (a is AnimationCurve)
                    return Add((Texture2D)b, (AnimationCurve)a);
            }
            if (a is AnimationCurve)
            {
                if (b == null)
                    return a;
                if (b is int)
                    return Add((AnimationCurve)a, (int)b);
                if (b is float)
                    return Add((AnimationCurve)a, (float)b);
                if (b is Vector2)
                    return Add((AnimationCurve)a, (Vector2)b);
                if (b is Vector3)
                    return Add((AnimationCurve)a, (Vector3)b);
                if (b is Vector4)
                    return Add((AnimationCurve)a, (Vector4)b);
                if (b is Vector2Int)
                    return Add((AnimationCurve)a, (Vector2Int)b);
                if (b is Vector3Int)
                    return Add((AnimationCurve)a, (Vector2Int)b);
                if (b is AnimationCurve)
                    return Add((AnimationCurve)a, (AnimationCurve)b);
            }
            if (b is AnimationCurve)
            {
                if (a == null)
                    return b;
                if (a is int)
                    return Add((AnimationCurve)b, (int)a);
                if (a is float)
                    return Add((AnimationCurve)b, (float)a);
                if (a is Vector2)
                    return Add((AnimationCurve)b, (Vector2)a);
                if (a is Vector3)
                    return Add((AnimationCurve)b, (Vector3)a);
                if (a is Vector4)
                    return Add((AnimationCurve)b, (Vector4)a);
                if (a is Vector2Int)
                    return Add((AnimationCurve)b, (Vector2Int)a);
                if (a is Vector3Int)
                    return Add((AnimationCurve)b, (Vector2Int)a);
                if (a is AnimationCurve)
                    return Add((AnimationCurve)b, (AnimationCurve)a);
            }


            if (a == null && b != null)
            {
                return b;
            }
            if (b == null && a != null)
            {
                return a;
            }
            return null;
        }

        public static int Add(int a, int b)
        {
            return a + b;
        }

        public static int Add(int a, bool b)
        {
            if (b)
                return a + 1;
            else return a;
        }

        public static int Add(bool b, int a)
        {
            if (b)
                return a + 1;
            else return a;
        }

        public static float Add(int a, float b)
        {
            return a + b;
        }

        public static float Add(float b, int a)
        {
            return a + b;
        }

        public static float Add(float a, float b)
        {
            return a + b;
        }

        public static float Add(float a, bool b)
        {
            if (b)
                return a + 1;
            else return a;
        }

        public static float Add(bool b, float a)
        {
            if (b)
                return a + 1;
            else return a;
        }

        public static Vector2 Add(Vector2 a, int b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Add(int a, Vector2 b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Add(Vector2 a, float b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Add(float b, Vector2 a)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Add(Vector2 a, Vector2 b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Add(Vector2 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector2(a.x + v, a.y + v);
        }

        public static Vector2 Add(bool b, Vector2 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector2(a.x + v, a.y + v);
        }

        public static Vector2 Add(Vector2 a, Vector2Int b)
        {
            return mathx.add(a, new int2(b.x, b.y));
        }

        public static Vector2 Add(Vector2Int a, Vector2 b)
        {
            return mathx.add(new int2(a.x, a.y), b);
        }

        public static Vector2Int Add(Vector2Int a, int b)
        {
            int2 v = mathx.add(new int2(a.x, a.y), b);
            return new Vector2Int(v.x, v.y);
        }

        public static Vector2Int Add(int a, Vector2Int b)
        {
            int2 v = mathx.add(a, new int2(b.x, b.y));
            return new Vector2Int(v.x, v.y);
        }

        public static Vector2Int Add(Vector2Int a, Vector2Int b)
        {
            int2 v = mathx.add(new int2(a.x, a.y), new int2(b.x, b.y));
            return new Vector2Int(v.x, v.y);
        }

        public static Vector3 Add(Vector3 a, int b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Add(int a, Vector3 b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Add(Vector3 a, float b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Add(float a, Vector3 b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Add(Vector3 a, Vector2 b)
        {
            return new Vector3(
                a.x + b.x,
                a.y + b.y,
                a.z
                );
        }

        public static Vector3 Add(Vector2 b, Vector3 a)
        {
            return new Vector3(
                a.x + b.x,
                a.y + b.y,
                a.z
                );
        }

        public static Vector3 Add(Vector3 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector3(
                a.x + v,
                a.y + v,
                a.z + v);
        }

        public static Vector3 Add(bool b, Vector3 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector3(
                a.x + v,
                a.y + v,
                a.z + v);
        }

        public static Vector3 Add(Vector3 a, Vector2Int b)
        {
            return new Vector3
                (
                    a.x + b.x,
                    a.y + b.y,
                    a.z
                );
        }

        public static Vector3 Add(Vector2Int b, Vector3 a)
        {
            return new Vector3
                (
                    a.x + b.x,
                    a.y + b.y,
                    a.z
                );
        }

        public static Vector3 Add(Vector3 a, Vector3 b)
        {
            return a + b;
        }

        public static Vector3Int Add(Vector3Int a, int b)
        {
            int3 v = new(a.x, a.y, a.z);
            v += b;
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Add(int b, Vector3Int a)
        {
            int3 v = new(a.x, a.y, a.z);
            v += b;
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Add(Vector3Int a, Vector3Int b)
        {
            return a + b;
        }

        public static Vector3Int Add(Vector3Int a, float b)
        {
            int3 v = new(a.x, a.y, a.z);
            v += Mathf.RoundToInt(b);
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Add(float b, Vector3Int a)
        {
            int3 v = new(a.x, a.y, a.z);
            v += Mathf.RoundToInt(b);
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Add(Vector3Int a, Vector2Int b)
        {
            return new Vector3Int(
                a.x + b.x,
                a.y + b.y,
                a.z);
        }

        public static Vector3Int Add(Vector2Int b, Vector3Int a)
        {
            return new Vector3Int(
                a.x + b.x,
                a.y + b.y,
                a.z);
        }

        public static Vector3Int Add(Vector3Int a, Vector2 b)
        {
            return new Vector3Int(
                a.x + Mathf.RoundToInt(b.x),
                a.y + Mathf.RoundToInt(b.y),
                a.z);
        }
        public static Vector3Int Add(Vector2 b, Vector3Int a)
        {
            return new Vector3Int(
                a.x + Mathf.RoundToInt(b.x),
                a.y + Mathf.RoundToInt(b.y),
                a.z);
        }

        public static Vector3Int Add(Vector3Int a, Vector3 b)
        {
            return new Vector3Int(
                a.x + Mathf.RoundToInt(b.x),
                a.y + Mathf.RoundToInt(b.y),
                a.z + Mathf.RoundToInt(b.z));
        }

        public static Vector3Int Add(Vector3 b, Vector3Int a)
        {
            return new Vector3Int(
                a.x + Mathf.RoundToInt(b.x),
                a.y + Mathf.RoundToInt(b.y),
                a.z + Mathf.RoundToInt(b.z));
        }

        public static Vector4 Add(Vector4 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector4(a.x + v, a.y + v, a.z + v, a.w + v);
        }

        public static Vector4 Add(bool b, Vector4 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector4(a.x + v, a.y + v, a.z + v, a.w + v);
        }

        public static Vector4 Add(Vector4 a, int b)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Add(int a, Vector4 b)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Add(Vector4 a, float b)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Add(float b, Vector4 a)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Add(Vector4 a, Vector2 b)
        {
            return new Vector4(
                a.x + b.x,
                a.y + b.y,
                a.z,
                a.w);
        }

        public static Vector4 Add(Vector2 b, Vector4 a)
        {
            return new Vector4(
                a.x + b.x,
                a.y + b.y,
                a.z,
                a.w);
        }

        public static Vector4 Add(Vector4 a, Vector2Int b)
        {
            return new Vector4(
                a.x + b.x,
                a.y + b.y,
                a.z,
                a.w);
        }

        public static Vector4 Add(Vector2Int b, Vector4 a)
        {
            return new Vector4(
                a.x + b.x,
                a.y + b.y,
                a.z,
                a.w);
        }

        public static Vector4 Add(Vector4 a, Vector3Int b)
        {
            return new Vector4(
                a.x + b.x,
                a.y + b.y,
                a.z + b.z,
                a.w);
        }

        public static Vector4 Add(Vector3Int b, Vector4 a)
        {
            return new Vector4(
                a.x + b.x,
                a.y + b.y,
                a.z + b.z,
                a.w);
        }

        public static Vector4 Add(Vector4 a, Vector4 b)
        {
            return a + b;
        }

        public static Vector4 Add(Vector4 a, Vector3 b)
        {
            return new Vector4(
                a.x + b.x,
                a.y + b.y,
                a.z + b.z,
                a.w
                );
        }

        public static Vector4 Add(Vector3 b, Vector4 a)
        {
            return new Vector4(
                a.x + b.x,
                a.y + b.y,
                a.z + b.z,
                a.w
                );
        }

        public static bool Add(bool a, bool b)
        {
            return (a || b);
        }

        public static Color Add(Color a, int b)
        {
            Vector4 c = Add(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Add(int b, Color a)
        {
            Vector4 c = Add(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Add(Color a, float b)
        {
            Vector4 c = Add(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Add(float b, Color a)
        {
            Vector4 c = Add(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Add(Color a, Vector2 b)
        {
            return new Color(a.r + b.x, a.g + b.y, a.b, a.a);
        }

        public static Color Add(Vector2 b, Color a)
        {
            return new Color(a.r + b.x, a.g + b.y, a.b, a.a);
        }

        public static Color Add(Color a, Vector2Int b)
        {
            Vector4 c = Add(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Add(Vector2Int b, Color a)
        {
            Vector4 c = Add(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Add(Color a, Vector3 b)
        {
            return new Color(
                a.r + b.x,
                a.g + b.y,
                a.b + b.z,
                a.a);
        }

        public static Color Add(Vector3 b, Color a)
        {
            return new Color(
                a.r + b.x,
                a.g + b.y,
                a.b + b.z,
                a.a);
        }

        public static Color Add(Color a, Vector3Int b)
        {
            return new Color(
                a.r + b.x,
                a.g + b.y,
                a.b + b.z,
                a.a);
        }

        public static Color Add(Vector3Int b, Color a)
        {
            return new Color(
                a.r + b.x,
                a.g + b.y,
                a.b + b.z,
                a.a);
        }

        public static Color Add(Color a, Vector4 b)
        {
            return new Color(
                a.r + b.x,
                a.g + b.y,
                a.b + b.z,
                a.a + b.w);
        }

        public static Color Add(Vector4 b, Color a)
        {
            return new Color(
                a.r + b.x,
                a.g + b.y,
                a.b + b.z,
                a.a + b.w);
        }

        public static string Add(string a, int b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(int a, string b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(string a, float b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(float a, string b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(string a, Vector2 b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(Vector2 a, string b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(string a, Vector2Int b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(Vector2Int a, string b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(string a, Vector3 b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(Vector3 a, string b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(string a, Vector3Int b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(Vector3Int a, string b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(string a, Vector4 b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(Vector4 a, string b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(string a, Quaternion b)
        {
            return a.ToString() + b.ToString();
        }

        public static string Add(Quaternion a, string b)
        {
            return a.ToString() + b.ToString();
        }

        public static Quaternion Add(Quaternion a, int b)
        {
            return new Quaternion(
                a.x + b,
                a.y + b,
                a.z + b,
                a.w + b);
        }

        public static Quaternion Add(int b, Quaternion a)
        {
            return new Quaternion(
                a.x + b,
                a.y + b,
                a.z + b,
                a.w + b);
        }
        public static Quaternion Add(Quaternion a, float b)
        {
            return new Quaternion(
                a.x + b,
                a.y + b,
                a.z + b,
                a.w + b);
        }

        public static Quaternion Add(float b, Quaternion a)
        {
            return new Quaternion(
                a.x + b,
                a.y + b,
                a.z + b,
                a.w + b);
        }

        public static Quaternion Add(Quaternion a, Vector2 b)
        {
            return new Quaternion(
                a.x + b.x,
                a.y + b.y,
                a.z + 0,
                a.w + 0);
        }

        public static Quaternion Add(Vector2 b, Quaternion a)
        {
            return new Quaternion(
                a.x + b.x,
                a.y + b.y,
                a.z + 0,
                a.w + 0);
        }

        public static Quaternion Add(Quaternion a, Vector2Int b)
        {
            return new Quaternion(
                a.x + b.x,
                a.y + b.y,
                a.z + 0,
                a.w + 0);
        }

        public static Quaternion Add(Vector2Int b, Quaternion a)
        {
            return new Quaternion(
                a.x + b.x,
                a.y + b.y,
                a.z + 0,
                a.w + 0);
        }

        public static Quaternion Add(Quaternion a, Vector3 b)
        {
            return new Quaternion(
                a.x + b.x,
                a.y + b.y,
                a.z + b.z,
                a.w + 0);
        }

        public static Quaternion Add(Vector3 b, Quaternion a)
        {
            return new Quaternion(
                a.x + b.x,
                a.y + b.y,
                a.z + b.z,
                a.w + 0);
        }

        public static Quaternion Add(Quaternion a, Vector3Int b)
        {
            return new Quaternion(
                a.x + b.x,
                a.y + b.y,
                a.z + b.z,
                a.w + 0);
        }

        public static Quaternion Add(Vector3Int b, Quaternion a)
        {
            return new Quaternion(
                a.x + b.x,
                a.y + b.y,
                a.z + b.z,
                a.w + 0);
        }

        public static Quaternion Add(Quaternion a, Vector4 b)
        {
            return new Quaternion(
                a.x + b.x,
                a.y + b.y,
                a.z + b.z,
                a.w + b.w);
        }

        public static Quaternion Add(Vector4 b, Quaternion a)
        {
            return new Quaternion(
                a.x + b.x,
                a.y + b.y,
                a.z + b.z,
                a.w + b.w);
        }

        public static Quaternion Add(Quaternion a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Quaternion(
                a.x + v,
                a.y + v,
                a.z + v,
                a.w + v);
        }

        public static Quaternion Add(bool b, Quaternion a)
        {
            int v = 0;
            if (b)
                v++;
            return new Quaternion(
                a.x + v,
                a.y + v,
                a.z + v,
                a.w + v);
        }

        public static Quaternion Add(Quaternion a, Color b)
        {
            return new Quaternion(
                a.x + b.r,
                a.y + b.g,
                a.z + b.b,
                a.w + b.a);
        }

        public static Quaternion Add(Color a, Quaternion b)
        {
            return new Quaternion(
                a.r + b.x,
                a.g + b.y,
                a.b + b.z,
                a.a + b.w);
        }

        public static Quaternion Add(Quaternion a, Quaternion b)
        {
            return new Quaternion(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);
        }

        public static Color Add(Color a, Color b)
        {
            Color c = a + b;
            if (c.g > 1)
                c.g = 1;
            if (c.r > 1)
                c.r = 1;
            if (c.b > 1)
                c.b = 1;
            if (c.a > 1)
                c.a = 1;
            return c;
        }

        private static Texture2D copyTexture(Texture2D original)
        {
            RenderTexture tmp = RenderTexture.GetTemporary(
                    original.width,
                    original.height,
                    0,
                    RenderTextureFormat.Default,
                    RenderTextureReadWrite.Linear);


            // Blit the pixels on texture to the RenderTexture
            Graphics.Blit(original, tmp);


            // Backup the currently set RenderTexture
            RenderTexture previous = RenderTexture.active;


            // Set the current RenderTexture to the temporary one we created
            RenderTexture.active = tmp;


            // Create a new readable Texture2D to copy the pixels to it
            Texture2D myTexture2D = new(original.width, original.height);


            // Copy the pixels from the RenderTexture to the new Texture
            myTexture2D.ReadPixels(new Rect(0, 0, tmp.width, tmp.height), 0, 0);
            myTexture2D.Apply();


            // Reset the active RenderTexture
            RenderTexture.active = previous;


            // Release the temporary RenderTexture
            RenderTexture.ReleaseTemporary(tmp);
            return myTexture2D;
        }

        public static Texture2D Add(Texture2D a, float b)
        {
            Texture2D ret = copyTexture(a);
            Color[] pixels = ret.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r + b, c.g + b, c.b + b, c.a + b);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(float b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r + b, c.g + b, c.b + b, c.a + b);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(Texture2D a, int b)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r + b, c.g + b, c.b + b, c.a + b);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(int b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r + b, c.g + b, c.b + b, c.a + b);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(Texture2D a, Vector2 b)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r + b.x, c.g + b.y, c.b, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(Vector2 b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r + b.x, c.g + b.y, c.b, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(Texture2D a, Vector2Int b)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r + b.x, c.g + b.y, c.b, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(Vector2Int b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r + b.x, c.g + b.y, c.b, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(Texture2D a, Vector3 b)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r + b.x, c.g + b.y, c.b + b.z, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(Vector3 b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r + b.x, c.g + b.y, c.b + b.z, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(Texture2D a, Vector3Int b)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r + b.x, c.g + b.y, c.b + b.z, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(Vector3Int b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r + b.x, c.g + b.y, c.b + b.z, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(Texture2D a, Vector4 b)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r + b.x, c.g + b.y, c.b + b.z, c.a + b.w);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(Vector4 b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r + b.x, c.g + b.y, c.b + b.z, c.a + b.w);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(Texture2D a, AnimationCurve b)
        {
            Texture2D ret = new(a.width, a.height);
            float cptr = 1.0f / ((float)a.width * a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                float vAdd = b.Evaluate(i * cptr);
                outpixels[i] = new Color(c.r + vAdd, c.g + vAdd, c.b + vAdd, c.a);
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(AnimationCurve b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            float cptr = 1.0f / ((float)a.width * a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                float vAdd = b.Evaluate(i * cptr);
                outpixels[i] = new Color(c.r + vAdd, c.g + vAdd, c.b + vAdd, c.a);
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Add(Texture2D a, Color b)
        {
            return Add(a, new Vector4(b.r, b.g, b.b, b.a));
        }

        public static Texture2D Add(Color b, Texture2D a)
        {
            return Add(a, new Vector4(b.r, b.g, b.b, b.a));
        }

        public static AnimationCurve Add(AnimationCurve a, int b)
        {
            AnimationCurve ret = new(a.keys);
            for (int i = 0; i < ret.keys.Length; i++)
                ret.keys[i].value += b;
            return ret;
        }

        public static AnimationCurve Add(AnimationCurve a, float b)
        {
            AnimationCurve ret = new();
            for (int i = 0; i < a.keys.Length; i++)
                ret.AddKey(a.keys[i].time, a.keys[i].value + b);
            return ret;
        }

        public static AnimationCurve Add(int b, AnimationCurve a)
        {
            AnimationCurve ret = new();
            for (int i = 0; i < a.keys.Length; i++)
                ret.AddKey(a.keys[i].time, a.keys[i].value + b);
            return ret;
        }

        public static AnimationCurve Add(float b, AnimationCurve a)
        {
            AnimationCurve ret = new();
            for (int i = 0; i < a.keys.Length; i++)
                ret.AddKey(a.keys[i].time, a.keys[i].value + b);
            return ret;
        }

        public static AnimationCurve Add(AnimationCurve a, string b)
        {
            return a;
        }

        public static AnimationCurve Add(string b, AnimationCurve a)
        {
            return a;
        }

        public static AnimationCurve Add(AnimationCurve a, AnimationCurve b)
        {
            AnimationCurve ret = new();
            for (int i = 0; i < a.keys.Length; i++)
            {
                bool found = false;
                for (int j = 0; j < b.keys.Length; j++)
                {
                    if (a.keys[i].time == b.keys[j].time)
                    {
                        ret.AddKey(a.keys[i].time, a.keys[i].value + b.keys[i].value);
                        found = true;
                    }
                }
                if (!found)
                    ret.AddKey(a.keys[i]);
            }

            // Now we need to add missing b keys
            for (int i = 0; i < b.keys.Length; i++)
            {
                bool found = false;
                for (int j = 0; j < ret.keys.Length; j++)
                {
                    if (b.keys[i].time == ret.keys[j].time)
                    {
                        found = true;
                        break;
                    }
                }
                if (!found)
                    ret.AddKey(b.keys[i]);
            }
            return ret;
        }

        public static AnimationCurve Add(AnimationCurve a, Vector2 b)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time + b.x, kf.value + b.y);
            return ret;
        }

        public static AnimationCurve Add(Vector2 b, AnimationCurve a)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time + b.x, kf.value + b.y);
            return ret;
        }

        public static AnimationCurve Add(AnimationCurve a, Vector3 b)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time + b.x, kf.value + b.y);
            return ret;
        }

        public static AnimationCurve Add(Vector3 b, AnimationCurve a)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time + b.x, kf.value + b.y);
            return ret;
        }

        public static AnimationCurve Add(AnimationCurve a, Vector4 b)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time + b.x, kf.value + b.y);
            return ret;
        }

        public static AnimationCurve Add(Vector4 b, AnimationCurve a)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time + b.x, kf.value + b.y);
            return ret;
        }

        public static AnimationCurve Add(AnimationCurve a, Vector2Int b)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time + b.x, kf.value + b.y);
            return ret;
        }

        public static AnimationCurve Add(Vector2Int b, AnimationCurve a)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time + b.x, kf.value + b.y);
            return ret;
        }

        public static AnimationCurve Add(AnimationCurve a, Vector3Int b)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time + b.x, kf.value + b.y);
            return ret;
        }

        public static AnimationCurve Add(Vector3Int b, AnimationCurve a)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time + b.x, kf.value + b.y);
            return ret;
        }
        #endregion

        #region Subtract
        public static object Subtract(object a, object b)
        {
            if (a is Texture2D)
            {
                if (b == null)
                    return a;
                if (b is int)
                    return Subtract((Texture2D)a, (int)b);
                if (b is float)
                    return Subtract((Texture2D)a, (float)b);
                if (b is Vector2)
                    return Subtract((Texture2D)a, (Vector2)b);
                if (b is Vector3)
                    return Subtract((Texture2D)a, (Vector3)b);
                if (b is Vector4)
                    return Subtract((Texture2D)a, (Vector4)b);
                if (b is Vector2Int)
                    return Subtract((Texture2D)a, (Vector2Int)b);
                if (b is Vector3Int)
                    return Subtract((Texture2D)a, (Vector2Int)b);
                if (b is AnimationCurve)
                    return Subtract((Texture2D)a, (AnimationCurve)b);
            }
            if (b is Texture2D)
            {
                if (a == null)
                    return b;
                if (a is int)
                    return Subtract((Texture2D)b, (int)a);
                if (a is float)
                    return Subtract((Texture2D)b, (float)a);
                if (a is Vector2)
                    return Subtract((Texture2D)b, (Vector2)a);
                if (a is Vector3)
                    return Subtract((Texture2D)b, (Vector3)a);
                if (a is Vector4)
                    return Subtract((Texture2D)b, (Vector4)a);
                if (a is Vector2Int)
                    return Subtract((Texture2D)b, (Vector2Int)a);
                if (a is Vector3Int)
                    return Subtract((Texture2D)b, (Vector2Int)a);
                if (a is AnimationCurve)
                    return Subtract((Texture2D)b, (AnimationCurve)a);
            }
            if (a is AnimationCurve)
            {
                if (b == null)
                    return a;
                if (b is int)
                    return Subtract((AnimationCurve)a, (int)(b));
                if (b is float)
                    return Subtract((AnimationCurve)a, (float)b);
                if (b is Vector2)
                    return Subtract((AnimationCurve)a, (Vector2)b);
                if (b is Vector3)
                    return Subtract((AnimationCurve)a, (Vector3)b);
                if (b is Vector4)
                    return Subtract((AnimationCurve)a, (Vector4)b);
                if (b is Vector2Int)
                    return Subtract((AnimationCurve)a, (Vector2Int)b);
                if (b is Vector3Int)
                    return Subtract((AnimationCurve)a, (Vector2Int)b);
                if (b is AnimationCurve)
                    return Subtract((AnimationCurve)a, (AnimationCurve)b);
            }
            if (b is AnimationCurve)
            {
                if (a == null)
                    return b;
                if (a is int)
                    return Subtract((AnimationCurve)b, (int)a);
                if (a is float)
                    return Subtract((AnimationCurve)b, (float)a);
                if (a is Vector2)
                    return Subtract((AnimationCurve)b, (Vector2)a);
                if (a is Vector3)
                    return Subtract((AnimationCurve)b, (Vector3)a);
                if (a is Vector4)
                    return Subtract((AnimationCurve)b, (Vector4)a);
                if (a is Vector2Int)
                    return Subtract((AnimationCurve)b, (Vector2Int)a);
                if (a is Vector3Int)
                    return Subtract((AnimationCurve)b, (Vector2Int)a);
                if (a is AnimationCurve)
                    return Subtract((AnimationCurve)b, (AnimationCurve)a);
            }


            if (a is int)
            {
                if (b is int)
                    return Subtract((int)a, (int)b);
                if (b is float)
                    return Subtract((int)a, (float)b);
                if (b is Vector2)
                    return Subtract((int)a, (Vector2)b);
                if (b is Vector3)
                    return Subtract((int)a, (Vector3)b);
                if (b is Vector4)
                    return Subtract((int)a, (Vector4)b);
                if (b is Vector3Int)
                    return Subtract((int)a, (Vector3Int)b);
                if (b is Quaternion)
                    return Subtract((int)a, (Quaternion)b);
                if (b is Vector2Int)
                    return Subtract((int)a, (Vector2Int)b);
                if (b is Color)
                    return Subtract((int)a, (Color)b);
                if (b is bool)
                    return Subtract((int)a, (bool)b);
            }
            if (a is float)
            {
                if (b is int)
                    return Subtract((float)a, (int)b);
                if (b is float)
                    return Subtract((float)a, (float)b);
                if (b is Vector2)
                    return Subtract((float)a, (Vector2)b);
                if (b is Vector3)
                    return Subtract((float)a, (Vector3)b);
                if (b is Vector4)
                    return Subtract((float)a, (Vector4)b);
                if (b is Vector3Int)
                    return Subtract((float)a, (Vector3Int)b);
                if (b is Quaternion)
                    return Subtract((float)a, (Quaternion)b);
                if (b is Vector2Int)
                    return Subtract((float)a, (Vector2Int)b);
                if (b is Color)
                    return Subtract((float)a, (Color)b);
                if (b is bool)
                    return Subtract((float)a, (bool)b);
            }

            if (a is Vector2 i)
            {
                if (b is int)
                    return Subtract(i, (int)b);
                if (b is float)
                    return Subtract(i, (float)b);
                if (b is Vector2)
                    return Subtract(i, (Vector2)b);
                if (b is Vector3)
                    return Subtract(i, (Vector3)b);
                if (b is Vector4)
                    return Subtract(i, (Vector4)b);
                if (b is Vector3Int)
                    return Subtract(i, (Vector3Int)b);
                if (b is Quaternion)
                    return Subtract(i, (Quaternion)b);
                if (b is Vector2Int)
                    return Subtract(i, (Vector2Int)b);
                if (b is Color)
                    return Subtract(i, (Color)b);
                if (b is bool)
                    return Subtract(i, (bool)b);
            }

            if (a is Vector3 j)
            {
                if (b is int)
                    return Subtract(j, (int)b);
                if (b is float)
                    return Subtract(j, (float)b);
                if (b is Vector2)
                    return Subtract(j, (Vector2)b);
                if (b is Vector3)
                    return Subtract(j, (Vector3)b);
                if (b is Vector4)
                    return Subtract(j, (Vector4)b);
                if (b is Vector3Int)
                    return Subtract(j, (Vector3Int)b);
                if (b is Quaternion)
                    return Subtract(j, (Quaternion)b);
                if (b is Vector2Int)
                    return Subtract(j, (Vector2Int)b);
                if (b is Color)
                    return Subtract(j, (Color)b);
                if (b is bool)
                    return Subtract(j, (bool)b);
            }

            if (a is Vector4 k)
            {
                if (b is int)
                    return Subtract(k, (int)b);
                if (b is float)
                    return Subtract(k, (float)b);
                if (b is Vector2)
                    return Subtract(k, (Vector2)b);
                if (b is Vector3)
                    return Subtract(k, (Vector3)b);
                if (b is Vector4)
                    return Subtract(k, (Vector4)b);
                if (b is Vector3Int)
                    return Subtract(k, (Vector3Int)b);
                if (b is Quaternion)
                    return Subtract(k, (Quaternion)b);
                if (b is Vector2Int)
                    return Subtract(k, (Vector2Int)b);
                if (b is Color)
                    return Subtract(k, (Color)b);
                if (b is bool)
                    return Subtract(k, (bool)b);
            }

            if (a is Vector2Int l)
            {
                if (b is int)
                    return Subtract(l, (int)b);
                if (b is float)
                    return Subtract(l, (float)b);
                if (b is Vector2)
                    return Subtract(l, (Vector2)b);
                if (b is Vector3)
                    return Subtract(l, (Vector3)b);
                if (b is Vector4)
                    return Subtract(l, (Vector4)b);
                if (b is Vector3Int)
                    return Subtract(l, (Vector3Int)b);
                if (b is Quaternion)
                    return Subtract(l, (Quaternion)b);
                if (b is Vector2Int)
                    return Subtract(l, (Vector2Int)b);
                if (b is Color)
                    return Subtract(l, (Color)b);
                if (b is bool)
                    return Subtract(l, (bool)b);
            }

            if (a is Vector3Int m)
            {
                if (b is int)
                    return Subtract(m, (int)b);
                if (b is float)
                    return Subtract(m, (float)b);
                if (b is Vector2)
                    return Subtract(m, (Vector2)b);
                if (b is Vector3)
                    return Subtract(m, (Vector3)b);
                if (b is Vector4)
                    return Subtract(m, (Vector4)b);
                if (b is Vector3Int)
                    return Subtract(m, (Vector3Int)b);
                if (b is Quaternion)
                    return Subtract(m, (Quaternion)b);
                if (b is Vector2Int)
                    return Subtract(m, (Vector2Int)b);
                if (b is Color)
                    return Subtract(m, (Color)b);
                if (b is bool)
                    return Subtract(m, (bool)b);
            }

            if (a is Color n)
            {
                if (b is int)
                    return Subtract(n, (int)b);
                if (b is float)
                    return Subtract(n, (float)b);
                if (b is Vector2)
                    return Subtract(n, (Vector2)b);
                if (b is Vector3)
                    return Subtract(n, (Vector3)b);
                if (b is Vector4)
                    return Subtract(n, (Vector4)b);
                if (b is Vector3Int)
                    return Subtract(n, (Vector3Int)b);
                if (b is Quaternion)
                    return Subtract(n, (Quaternion)b);
                if (b is Vector2Int)
                    return Subtract(n, (Vector2Int)b);
                if (b is Color)
                    return Subtract(n, (Color)b);
                if (b is bool)
                    return Subtract(n, (bool)b);
            }

            if (a is string o)
            {
                if (b is int)
                    return Subtract(o, (int)b);
                if (b is float)
                    return Subtract(o, (float)b);
                if (b is Vector2)
                    return Subtract(o, (Vector2)b);
                if (b is Vector3)
                    return Subtract(o, (Vector3)b);
                if (b is Vector4)
                    return Subtract(o, (Vector4)b);
                if (b is Vector3Int)
                    return Subtract(o, (Vector3Int)b);
                if (b is Quaternion)
                    return Subtract(o, (Quaternion)b);
                if (b is Vector2Int)
                    return Subtract(o, (Vector2Int)b);
                if (b is Color)
                    return Subtract(o, (Color)b);
                if (b is bool)
                    return Subtract(o, (bool)b);
            }

            if (a is bool p)
            {
                if (b is int)
                    return Subtract(p, (int)b);
                if (b is float)
                    return Subtract(p, (float)b);
                if (b is Vector2)
                    return Subtract(p, (Vector2)b);
                if (b is Vector3)
                    return Subtract(p, (Vector3)b);
                if (b is Vector4)
                    return Subtract(p, (Vector4)b);
                if (b is Vector3Int)
                    return Subtract(p, (Vector3Int)b);
                if (b is Quaternion)
                    return Subtract(p, (Quaternion)b);
                if (b is Vector2Int)
                    return Subtract(p, (Vector2Int)b);
                if (b is Color)
                    return Subtract(p, (Color)b);
                if (b is bool)
                    return Subtract(p, (bool)b);
            }

            if (a is Quaternion q)
            {
                if (b is int)
                    return Subtract(q, (int)b);
                if (b is float)
                    return Subtract(q, (float)b);
                if (b is Vector2)
                    return Subtract(q, (Vector2)b);
                if (b is Vector3)
                    return Subtract(q, (Vector3)b);
                if (b is Vector4)
                    return Subtract(q, (Vector4)b);
                if (b is Vector3Int)
                    return Subtract(q, (Vector3Int)b);
                if (b is Quaternion)
                    return Subtract(q, (Quaternion)b);
                if (b is Vector2Int)
                    return Subtract(q, (Vector2Int)b);
                if (b is Color)
                    return Subtract(q, (Color)b);
                if (b is bool)
                    return Subtract(q, (bool)b);
            }

            if (b == null && a != null)
                return b;
            if (a == null && b != null)
                return b;


            return null;
        }

        public static int Subtract(int a, int b)
        {
            return a - b;
        }

        public static int Subtract(int a, bool b)
        {
            if (b)
                return a - 1;
            else return a;
        }

        public static int Subtract(bool b, int a)
        {
            if (b)
                return a - 1;
            else return a;
        }

        public static float Subtract(int a, float b)
        {
            return a - b;
        }

        public static float Subtract(float b, int a)
        {
            return a - b;
        }

        public static float Subtract(float a, float b)
        {
            return a - b;
        }

        public static float Subtract(float a, bool b)
        {
            if (b)
                return a + 1;
            else return a;
        }

        public static float Subtract(bool b, float a)
        {
            if (b)
                return a - 1;
            else return a;
        }

        public static Vector2 Subtract(Vector2 a, int b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Subtract(int a, Vector2 b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Subtract(Vector2 a, float b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Subtract(float b, Vector2 a)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Subtract(Vector2 a, Vector2 b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Subtract(Vector2 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector2(a.x - v, a.y - v);
        }

        public static Vector2 Subtract(bool b, Vector2 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector2(a.x - v, a.y - v);
        }

        public static Vector2 Subtract(Vector2 a, Vector2Int b)
        {
            return mathx.add(a, new int2(b.x, b.y));
        }

        public static Vector2 Subtract(Vector2Int a, Vector2 b)
        {
            return mathx.add(new int2(a.x, a.y), b);
        }

        public static Vector2Int Subtract(Vector2Int a, int b)
        {
            int2 v = mathx.add(new int2(a.x, a.y), b);
            return new Vector2Int(v.x, v.y);
        }

        public static Vector2Int Subtract(int a, Vector2Int b)
        {
            int2 v = mathx.add(a, new int2(b.x, b.y));
            return new Vector2Int(v.x, v.y);
        }

        public static Vector2Int Subtract(Vector2Int a, Vector2Int b)
        {
            int2 v = mathx.add(new int2(a.x, a.y), new int2(b.x, b.y));
            return new Vector2Int(v.x, v.y);
        }

        public static Vector3 Subtract(Vector3 a, int b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Subtract(int a, Vector3 b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Subtract(Vector3 a, float b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Subtract(float a, Vector3 b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Subtract(Vector3 a, Vector2 b)
        {
            return new Vector3(
                a.x - b.x,
                a.y - b.y,
                a.z
                );
        }

        public static Vector3 Subtract(Vector2 b, Vector3 a)
        {
            return new Vector3(
                a.x - b.x,
                a.y - b.y,
                a.z
                );
        }

        public static Vector3 Subtract(Vector3 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector3(
                a.x - v,
                a.y - v,
                a.z - v);
        }

        public static Vector3 Subtract(bool b, Vector3 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector3(
                a.x - v,
                a.y - v,
                a.z - v);
        }

        public static Vector3 Subtract(Vector3 a, Vector2Int b)
        {
            return new Vector3
                (
                    a.x - b.x,
                    a.y - b.y,
                    a.z
                );
        }

        public static Vector3 Subtract(Vector2Int b, Vector3 a)
        {
            return new Vector3
                (
                    a.x - b.x,
                    a.y - b.y,
                    a.z
                );
        }

        public static Vector3 Subtract(Vector3 a, Vector3 b)
        {
            return a - b;
        }

        public static Vector3Int Subtract(Vector3Int a, int b)
        {
            int3 v = new(a.x, a.y, a.z);
            v -= b;
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Subtract(int b, Vector3Int a)
        {
            int3 v = new(a.x, a.y, a.z);
            v -= b;
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Subtract(Vector3Int a, Vector3Int b)
        {
            return a - b;
        }

        public static Vector3Int Subtract(Vector3Int a, float b)
        {
            int3 v = new(a.x, a.y, a.z);
            v -= Mathf.RoundToInt(b);
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Subtract(float b, Vector3Int a)
        {
            int3 v = new(a.x, a.y, a.z);
            v -= Mathf.RoundToInt(b);
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Subtract(Vector3Int a, Vector2Int b)
        {
            return new Vector3Int(
                a.x - b.x,
                a.y - b.y,
                a.z);
        }

        public static Vector3Int Subtract(Vector2Int b, Vector3Int a)
        {
            return new Vector3Int(
                a.x - b.x,
                a.y - b.y,
                a.z);
        }

        public static Vector3Int Subtract(Vector3Int a, Vector2 b)
        {
            return new Vector3Int(
                a.x - Mathf.RoundToInt(b.x),
                a.y - Mathf.RoundToInt(b.y),
                a.z);
        }
        public static Vector3Int Subtract(Vector2 b, Vector3Int a)
        {
            return new Vector3Int(
                a.x - Mathf.RoundToInt(b.x),
                a.y - Mathf.RoundToInt(b.y),
                a.z);
        }

        public static Vector3Int Subtract(Vector3Int a, Vector3 b)
        {
            return new Vector3Int(
                a.x - Mathf.RoundToInt(b.x),
                a.y - Mathf.RoundToInt(b.y),
                a.z - Mathf.RoundToInt(b.z));
        }

        public static Vector3Int Subtract(Vector3 b, Vector3Int a)
        {
            return new Vector3Int(
                a.x - Mathf.RoundToInt(b.x),
                a.y - Mathf.RoundToInt(b.y),
                a.z - Mathf.RoundToInt(b.z));
        }

        public static Vector4 Subtract(Vector4 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector4(a.x - v, a.y - v, a.z - v, a.w - v);
        }

        public static Vector4 Subtract(bool b, Vector4 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector4(a.x - v, a.y - v, a.z - v, a.w - v);
        }

        public static Vector4 Subtract(Vector4 a, int b)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Subtract(int a, Vector4 b)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Subtract(Vector4 a, float b)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Subtract(float b, Vector4 a)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Subtract(Vector4 a, Vector2 b)
        {
            return new Vector4(
                a.x - b.x,
                a.y - b.y,
                a.z,
                a.w);
        }

        public static Vector4 Subtract(Vector2 b, Vector4 a)
        {
            return new Vector4(
                a.x - b.x,
                a.y - b.y,
                a.z,
                a.w);
        }

        public static Vector4 Subtract(Vector4 a, Vector2Int b)
        {
            return new Vector4(
                a.x - b.x,
                a.y - b.y,
                a.z,
                a.w);
        }

        public static Vector4 Subtract(Vector2Int b, Vector4 a)
        {
            return new Vector4(
                a.x - b.x,
                a.y - b.y,
                a.z,
                a.w);
        }

        public static Vector4 Subtract(Vector4 a, Vector3Int b)
        {
            return new Vector4(
                a.x - b.x,
                a.y - b.y,
                a.z - b.z,
                a.w);
        }

        public static Vector4 Subtract(Vector3Int b, Vector4 a)
        {
            return new Vector4(
                a.x - b.x,
                a.y - b.y,
                a.z - b.z,
                a.w);
        }

        public static Vector4 Subtract(Vector4 a, Vector4 b)
        {
            return a - b;
        }

        public static Vector4 Subtract(Vector4 a, Vector3 b)
        {
            return new Vector4(
                a.x - b.x,
                a.y - b.y,
                a.z - b.z,
                a.w
                );
        }

        public static Vector4 Subtract(Vector3 b, Vector4 a)
        {
            return new Vector4(
                a.x - b.x,
                a.y - b.y,
                a.z - b.z,
                a.w
                );
        }

        public static bool Subtract(bool a, bool b)
        {
            return (a || b);
        }

        public static Color Subtract(Color a, int b)
        {
            Vector4 c = Subtract(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Subtract(int b, Color a)
        {
            Vector4 c = Subtract(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Subtract(Color a, float b)
        {
            Vector4 c = Subtract(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Subtract(float b, Color a)
        {
            Vector4 c = Subtract(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Subtract(Color a, Vector2 b)
        {
            return new Color(a.r - b.x, a.g - b.y, a.b, a.a);
        }

        public static Color Subtract(Vector2 b, Color a)
        {
            return new Color(a.r - b.x, a.g - b.y, a.b, a.a);
        }

        public static Color Subtract(Color a, Vector2Int b)
        {
            Vector4 c = Subtract(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Subtract(Vector2Int b, Color a)
        {
            Vector4 c = Subtract(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Subtract(Color a, Vector3 b)
        {
            return new Color(
                a.r - b.x,
                a.g - b.y,
                a.b - b.z,
                a.a);
        }

        public static Color Subtract(Vector3 b, Color a)
        {
            return new Color(
                a.r - b.x,
                a.g - b.y,
                a.b - b.z,
                a.a);
        }

        public static Color Subtract(Color a, Vector3Int b)
        {
            return new Color(
                a.r - b.x,
                a.g - b.y,
                a.b - b.z,
                a.a);
        }

        public static Color Subtract(Vector3Int b, Color a)
        {
            return new Color(
                a.r - b.x,
                a.g - b.y,
                a.b - b.z,
                a.a);
        }

        public static Color Subtract(Color a, Vector4 b)
        {
            return new Color(
                a.r - b.x,
                a.g - b.y,
                a.b - b.z,
                a.a - b.w);
        }

        public static Color Subtract(Vector4 b, Color a)
        {
            return new Color(
                a.r - b.x,
                a.g - b.y,
                a.b - b.z,
                a.a - b.w);
        }

        public static Quaternion Subtract(Quaternion a, int b)
        {
            return new Quaternion(
                a.x - b,
                a.y - b,
                a.z - b,
                a.w - b);
        }

        public static Quaternion Subtract(int b, Quaternion a)
        {
            return new Quaternion(
                a.x - b,
                a.y - b,
                a.z - b,
                a.w - b);
        }
        public static Quaternion Subtract(Quaternion a, float b)
        {
            return new Quaternion(
                a.x - b,
                a.y - b,
                a.z - b,
                a.w - b);
        }

        public static Quaternion Subtract(float b, Quaternion a)
        {
            return new Quaternion(
                a.x - b,
                a.y - b,
                a.z - b,
                a.w - b);
        }

        public static Quaternion Subtract(Quaternion a, Vector2 b)
        {
            return new Quaternion(
                a.x - b.x,
                a.y - b.y,
                a.z - 0,
                a.w - 0);
        }

        public static Quaternion Subtract(Vector2 b, Quaternion a)
        {
            return new Quaternion(
                a.x - b.x,
                a.y - b.y,
                a.z - 0,
                a.w - 0);
        }

        public static Quaternion Subtract(Quaternion a, Vector2Int b)
        {
            return new Quaternion(
                a.x - b.x,
                a.y - b.y,
                a.z - 0,
                a.w - 0);
        }

        public static Quaternion Subtract(Vector2Int b, Quaternion a)
        {
            return new Quaternion(
                a.x - b.x,
                a.y - b.y,
                a.z - 0,
                a.w - 0);
        }

        public static Quaternion Subtract(Quaternion a, Vector3 b)
        {
            return new Quaternion(
                a.x - b.x,
                a.y - b.y,
                a.z - b.z,
                a.w - 0);
        }

        public static Quaternion Subtract(Vector3 b, Quaternion a)
        {
            return new Quaternion(
                a.x - b.x,
                a.y - b.y,
                a.z - b.z,
                a.w - 0);
        }

        public static Quaternion Subtract(Quaternion a, Vector3Int b)
        {
            return new Quaternion(
                a.x - b.x,
                a.y - b.y,
                a.z - b.z,
                a.w - 0);
        }

        public static Quaternion Subtract(Vector3Int b, Quaternion a)
        {
            return new Quaternion(
                a.x - b.x,
                a.y - b.y,
                a.z - b.z,
                a.w - 0);
        }

        public static Quaternion Subtract(Quaternion a, Vector4 b)
        {
            return new Quaternion(
                a.x - b.x,
                a.y - b.y,
                a.z - b.z,
                a.w - b.w);
        }

        public static Quaternion Subtract(Vector4 b, Quaternion a)
        {
            return new Quaternion(
                a.x - b.x,
                a.y - b.y,
                a.z - b.z,
                a.w - b.w);
        }

        public static Quaternion Subtract(Quaternion a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Quaternion(
                a.x - v,
                a.y - v,
                a.z - v,
                a.w - v);
        }

        public static Quaternion Subtract(bool b, Quaternion a)
        {
            int v = 0;
            if (b)
                v++;
            return new Quaternion(
                a.x - v,
                a.y - v,
                a.z - v,
                a.w - v);
        }

        public static Quaternion Subtract(Quaternion a, Color b)
        {
            return new Quaternion(
                a.x - b.r,
                a.y - b.g,
                a.z - b.b,
                a.w - b.a);
        }

        public static Quaternion Subtract(Color a, Quaternion b)
        {
            return new Quaternion(
                a.r - b.x,
                a.g - b.y,
                a.b - b.z,
                a.a - b.w);
        }

        public static Color Subtract(Color a, Color b)
        {
            Color c = a - b;
            if (c.g > 1)
                c.g = 1;
            if (c.r > 1)
                c.r = 1;
            if (c.b > 1)
                c.b = 1;
            if (c.a > 1)
                c.a = 1;
            return c;
        }

        public static Texture2D Subtract(Texture2D a, float b)
        {
            Texture2D ret = copyTexture(a);
            Color[] pixels = ret.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r - b, c.g - b, c.b - b, c.a - b);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(float b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r - b, c.g - b, c.b + b, c.a + b);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(Texture2D a, int b)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r - b, c.g - b, c.b - b, c.a - b);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(int b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r - b, c.g - b, c.b - b, c.a - b);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(Texture2D a, Vector2 b)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r - b.x, c.g - b.y, c.b, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(Vector2 b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r - b.x, c.g - b.y, c.b, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(Texture2D a, Vector2Int b)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r - b.x, c.g - b.y, c.b, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(Vector2Int b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r - b.x, c.g - b.y, c.b, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(Texture2D a, Vector3 b)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r - b.x, c.g - b.y, c.b - b.z, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(Vector3 b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r - b.x, c.g - b.y, c.b - b.z, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(Texture2D a, Vector3Int b)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r - b.x, c.g - b.y, c.b - b.z, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(Vector3Int b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r - b.x, c.g - b.y, c.b - b.z, c.a);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(Texture2D a, Vector4 b)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r - b.x, c.g - b.y, c.b - b.z, c.a - b.w);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(Vector4 b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                outpixels[i] = new Color(c.r - b.x, c.g - b.y, c.b - b.z, c.a - b.w);
                i++;
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(Texture2D a, AnimationCurve b)
        {
            Texture2D ret = new(a.width, a.height);
            float cptr = 1.0f / ((float)a.width * a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                float vAdd = b.Evaluate(i * cptr);
                outpixels[i] = new Color(c.r - vAdd, c.g - vAdd, c.b - vAdd, c.a);
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(AnimationCurve b, Texture2D a)
        {
            Texture2D ret = new(a.width, a.height);
            float cptr = 1.0f / ((float)a.width * a.height);
            Color[] pixels = a.GetPixels();
            Color[] outpixels = new Color[pixels.Length];
            int i = 0;
            foreach (Color c in pixels)
            {
                float vAdd = b.Evaluate(i * cptr);
                outpixels[i] = new Color(c.r - vAdd, c.g - vAdd, c.b - vAdd, c.a);
            }
            ret.SetPixels(outpixels);
            ret.Apply();
            return ret;
        }

        public static Texture2D Subtract(Texture2D a, Color b)
        {
            return Add(a, new Vector4(b.r, b.g, b.b, b.a));
        }

        public static Texture2D Subtract(Color b, Texture2D a)
        {
            return Add(a, new Vector4(b.r, b.g, b.b, b.a));
        }

        public static AnimationCurve Subtract(AnimationCurve a, int b)
        {
            AnimationCurve ret = new(a.keys);
            for (int i = 0; i < ret.keys.Length; i++)
                ret.keys[i].value -= b;
            return ret;
        }

        public static AnimationCurve Subtract(AnimationCurve a, float b)
        {
            AnimationCurve ret = new();
            for (int i = 0; i < a.keys.Length; i++)
                ret.AddKey(a.keys[i].time, a.keys[i].value - b);
            return ret;
        }

        public static AnimationCurve Subtract(int b, AnimationCurve a)
        {
            AnimationCurve ret = new();
            for (int i = 0; i < a.keys.Length; i++)
                ret.AddKey(a.keys[i].time, a.keys[i].value - b);
            return ret;
        }

        public static AnimationCurve Subtract(float b, AnimationCurve a)
        {
            AnimationCurve ret = new();
            for (int i = 0; i < a.keys.Length; i++)
                ret.AddKey(a.keys[i].time, a.keys[i].value - b);
            return ret;
        }

        public static AnimationCurve Subtract(AnimationCurve a, string b)
        {
            return a;
        }

        public static AnimationCurve Subtract(string b, AnimationCurve a)
        {
            return a;
        }

        public static AnimationCurve Subtract(AnimationCurve a, AnimationCurve b)
        {
            AnimationCurve ret = new();
            for (int i = 0; i < a.keys.Length; i++)
            {
                bool found = false;
                for (int j = 0; j < b.keys.Length; j++)
                {
                    if (a.keys[i].time == b.keys[j].time)
                    {
                        ret.AddKey(a.keys[i].time, a.keys[i].value - b.keys[i].value);
                        found = true;
                    }
                }
                if (!found)
                    ret.AddKey(a.keys[i]);
            }

            // Now we need to add missing b keys
            for (int i = 0; i < b.keys.Length; i++)
            {
                bool found = false;
                for (int j = 0; j < ret.keys.Length; j++)
                {
                    if (b.keys[i].time == ret.keys[j].time)
                    {
                        found = true;
                        break;
                    }
                }
                if (!found)
                    ret.AddKey(b.keys[i]);
            }
            return ret;
        }

        public static AnimationCurve Subtract(AnimationCurve a, Vector2 b)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time - b.x, kf.value - b.y);
            return ret;
        }

        public static AnimationCurve Subtract(Vector2 b, AnimationCurve a)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time - b.x, kf.value - b.y);
            return ret;
        }

        public static AnimationCurve Subtract(AnimationCurve a, Vector3 b)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time - b.x, kf.value - b.y);
            return ret;
        }

        public static AnimationCurve Subtract(Vector3 b, AnimationCurve a)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time - b.x, kf.value - b.y);
            return ret;
        }

        public static AnimationCurve Subtract(AnimationCurve a, Vector4 b)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time - b.x, kf.value - b.y);
            return ret;
        }

        public static AnimationCurve Subtract(Vector4 b, AnimationCurve a)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time - b.x, kf.value - b.y);
            return ret;
        }

        public static AnimationCurve Subtract(AnimationCurve a, Vector2Int b)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time - b.x, kf.value - b.y);
            return ret;
        }

        public static AnimationCurve Subtract(Vector2Int b, AnimationCurve a)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time - b.x, kf.value - b.y);
            return ret;
        }

        public static AnimationCurve Subtract(AnimationCurve a, Vector3Int b)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time - b.x, kf.value - b.y);
            return ret;
        }

        public static AnimationCurve Subtract(Vector3Int b, AnimationCurve a)
        {
            AnimationCurve ret = new();
            foreach (Keyframe kf in a.keys)
                ret.AddKey(kf.time - b.x, kf.value - b.y);
            return ret;
        }
        #endregion

        #region Multiply
        public static object Multiply(object a, object b)
        {
            if (a is int)
            {
                if (b is int)
                    return Multiply((int)a, (int)b);
                if (b is float)
                    return Multiply((int)a, (float)b);
                if (b is Vector2)
                    return Multiply((int)a, (Vector2)b);
                if (b is Vector3)
                    return Multiply((int)a, (Vector3)b);
                if (b is Vector4)
                    return Multiply((int)a, (Vector4)b);
                if (b is Vector3Int)
                    return Multiply((int)a, (Vector3Int)b);
                if (b is Quaternion)
                    return Multiply((int)a, (Quaternion)b);
                if (b is Vector2Int)
                    return Multiply((int)a, (Vector2Int)b);
                if (b is Color)
                    return Multiply((int)a, (Color)b);
                if (b is bool)
                    return Multiply((int)a, (bool)b);
            }
            if (a is float)
            {
                if (b is int)
                    return Multiply((float)a, (int)b);
                if (b is float)
                    return Multiply((float)a, (float)b);
                if (b is Vector2)
                    return Multiply((float)a, (Vector2)b);
                if (b is Vector3)
                    return Multiply((float)a, (Vector3)b);
                if (b is Vector4)
                    return Multiply((float)a, (Vector4)b);
                if (b is Vector3Int)
                    return Multiply((float)a, (Vector3Int)b);
                if (b is Quaternion)
                    return Multiply((float)a, (Quaternion)b);
                if (b is Vector2Int)
                    return Multiply((float)a, (Vector2Int)b);
                if (b is Color)
                    return Multiply((float)a, (Color)b);
                if (b is bool)
                    return Multiply((float)a, (bool)b);
            }

            if (a is Vector2 i)
            {
                if (b is int)
                    return Multiply(i, (int)b);
                if (b is float)
                    return Multiply(i, (float)b);
                if (b is Vector2)
                    return Multiply(i, (Vector2)b);
                if (b is Vector3)
                    return Multiply(i, (Vector3)b);
                if (b is Vector4)
                    return Multiply(i, (Vector4)b);
                if (b is Vector3Int)
                    return Multiply(i, (Vector3Int)b);
                if (b is Quaternion)
                    return Multiply(i, (Quaternion)b);
                if (b is Vector2Int)
                    return Multiply(i, (Vector2Int)b);
                if (b is Color)
                    return Multiply(i, (Color)b);
                if (b is bool)
                    return Multiply(i, (bool)b);
            }

            if (a is Vector3 j)
            {
                if (b is int)
                    return Multiply(j, (int)b);
                if (b is float)
                    return Multiply(j, (float)b);
                if (b is Vector2)
                    return Multiply(j, (Vector2)b);
                if (b is Vector3)
                    return Multiply(j, (Vector3)b);
                if (b is Vector4)
                    return Multiply(j, (Vector4)b);
                if (b is Vector3Int)
                    return Multiply(j, (Vector3Int)b);
                if (b is Quaternion)
                    return Multiply(j, (Quaternion)b);
                if (b is Vector2Int)
                    return Multiply(j, (Vector2Int)b);
                if (b is Color)
                    return Multiply(j, (Color)b);
                if (b is bool)
                    return Multiply(j, (bool)b);
            }

            if (a is Vector4 k)
            {
                if (b is int)
                    return Multiply(k, (int)b);
                if (b is float)
                    return Multiply(k, (float)b);
                if (b is Vector2)
                    return Multiply(k, (Vector2)b);
                if (b is Vector3)
                    return Multiply(k, (Vector3)b);
                if (b is Vector4)
                    return Multiply(k, (Vector4)b);
                if (b is Vector3Int)
                    return Multiply(k, (Vector3Int)b);
                if (b is Quaternion)
                    return Multiply(k, (Quaternion)b);
                if (b is Vector2Int)
                    return Multiply(k, (Vector2Int)b);
                if (b is Color)
                    return Multiply(k, (Color)b);
                if (b is bool)
                    return Multiply(k, (bool)b);
            }

            if (a is Vector2Int l)
            {
                if (b is int)
                    return Multiply(l, (int)b);
                if (b is float)
                    return Multiply(l, (float)b);
                if (b is Vector2)
                    return Multiply(l, (Vector2)b);
                if (b is Vector3)
                    return Multiply(l, (Vector3)b);
                if (b is Vector4)
                    return Multiply(l, (Vector4)b);
                if (b is Vector3Int)
                    return Multiply(l, (Vector3Int)b);
                if (b is Quaternion)
                    return Multiply(l, (Quaternion)b);
                if (b is Vector2Int)
                    return Multiply(l, (Vector2Int)b);
                if (b is Color)
                    return Multiply(l, (Color)b);
                if (b is bool)
                    return Multiply(l, (bool)b);
            }

            if (a is Vector3Int m)
            {
                if (b is int)
                    return Multiply(m, (int)b);
                if (b is float)
                    return Multiply(m, (float)b);
                if (b is Vector2)
                    return Multiply(m, (Vector2)b);
                if (b is Vector3)
                    return Multiply(m, (Vector3)b);
                if (b is Vector4)
                    return Multiply(m, (Vector4)b);
                if (b is Vector3Int)
                    return Multiply(m, (Vector3Int)b);
                if (b is Quaternion)
                    return Multiply(m, (Quaternion)b);
                if (b is Vector2Int)
                    return Multiply(m, (Vector2Int)b);
                if (b is Color)
                    return Multiply(m, (Color)b);
                if (b is bool)
                    return Multiply(m, (bool)b);
            }

            if (a is Color n)
            {
                if (b is int)
                    return Multiply(n, (int)b);
                if (b is float)
                    return Multiply(n, (float)b);
                if (b is Vector2)
                    return Multiply(n, (Vector2)b);
                if (b is Vector3)
                    return Multiply(n, (Vector3)b);
                if (b is Vector4)
                    return Multiply(n, (Vector4)b);
                if (b is Vector3Int)
                    return Multiply(n, (Vector3Int)b);
                if (b is Quaternion)
                    return Multiply(n, (Quaternion)b);
                if (b is Vector2Int)
                    return Multiply(n, (Vector2Int)b);
                if (b is Color)
                    return Multiply(n, (Color)b);
                if (b is bool)
                    return Multiply(n, (bool)b);
            }

            if (a is string o)
            {
                if (b is int)
                    return Multiply(o, (int)b);
                if (b is float)
                    return Multiply(o, (float)b);
                if (b is Vector2)
                    return Multiply(o, (Vector2)b);
                if (b is Vector3)
                    return Multiply(o, (Vector3)b);
                if (b is Vector4)
                    return Multiply(o, (Vector4)b);
                if (b is Vector3Int)
                    return Multiply(o, (Vector3Int)b);
                if (b is Quaternion)
                    return Multiply(o, (Quaternion)b);
                if (b is Vector2Int)
                    return Multiply(o, (Vector2Int)b);
                if (b is Color)
                    return Multiply(o, (Color)b);
                if (b is bool)
                    return Multiply(o, (bool)b);
            }

            if (a is bool p)
            {
                if (b is int)
                    return Multiply(p, (int)b);
                if (b is float)
                    return Multiply(p, (float)b);
                if (b is Vector2)
                    return Multiply(p, (Vector2)b);
                if (b is Vector3)
                    return Multiply(p, (Vector3)b);
                if (b is Vector4)
                    return Multiply(p, (Vector4)b);
                if (b is Vector3Int)
                    return Multiply(p, (Vector3Int)b);
                if (b is Quaternion)
                    return Multiply(p, (Quaternion)b);
                if (b is Vector2Int)
                    return Multiply(p, (Vector2Int)b);
                if (b is Color)
                    return Multiply(p, (Color)b);
                if (b is bool)
                    return Multiply(p, (bool)b);
            }

            if (a is Quaternion q)
            {
                if (b is int)
                    return Multiply(q, (int)b);
                if (b is float)
                    return Multiply(q, (float)b);
                if (b is Vector2)
                    return Multiply(q, (Vector2)b);
                if (b is Vector3)
                    return Multiply(q, (Vector3)b);
                if (b is Vector4)
                    return Multiply(q, (Vector4)b);
                if (b is Vector3Int)
                    return Multiply(q, (Vector3Int)b);
                if (b is Quaternion)
                    return Multiply(q, (Quaternion)b);
                if (b is Vector2Int)
                    return Multiply(q, (Vector2Int)b);
                if (b is Color)
                    return Multiply(q, (Color)b);
                if (b is bool)
                    return Multiply(q, (bool)b);
            }
            return null;
        }

        public static int Multiply(int a, int b)
        {
            return a * b;
        }

        public static int Multiply(int a, bool b)
        {
            if (b)
                return a * 1;
            else return a;
        }

        public static int Multiply(bool b, int a)
        {
            if (b)
                return a * 1;
            else return a;
        }

        public static float Multiply(int a, float b)
        {
            return a * b;
        }

        public static float Multiply(float b, int a)
        {
            return a * b;
        }

        public static float Multiply(float a, float b)
        {
            return a * b;
        }

        public static float Multiply(float a, bool b)
        {
            if (b)
                return a + 1;
            else return a;
        }

        public static float Multiply(bool b, float a)
        {
            if (b)
                return a * 1;
            else return a;
        }

        public static Vector2 Multiply(Vector2 a, int b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Multiply(int a, Vector2 b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Multiply(Vector2 a, float b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Multiply(float b, Vector2 a)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Multiply(Vector2 a, Vector2 b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Multiply(Vector2 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector2(a.x * v, a.y * v);
        }

        public static Vector2 Multiply(bool b, Vector2 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector2(a.x * v, a.y * v);
        }

        public static Vector2 Multiply(Vector2 a, Vector2Int b)
        {
            return mathx.add(a, new int2(b.x, b.y));
        }

        public static Vector2 Multiply(Vector2Int a, Vector2 b)
        {
            return mathx.add(new int2(a.x, a.y), b);
        }

        public static Vector2Int Multiply(Vector2Int a, int b)
        {
            int2 v = mathx.add(new int2(a.x, a.y), b);
            return new Vector2Int(v.x, v.y);
        }

        public static Vector2Int Multiply(int a, Vector2Int b)
        {
            int2 v = mathx.add(a, new int2(b.x, b.y));
            return new Vector2Int(v.x, v.y);
        }

        public static Vector2Int Multiply(Vector2Int a, Vector2Int b)
        {
            int2 v = mathx.add(new int2(a.x, a.y), new int2(b.x, b.y));
            return new Vector2Int(v.x, v.y);
        }

        public static Vector3 Multiply(Vector3 a, int b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Multiply(int a, Vector3 b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Multiply(Vector3 a, float b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Multiply(float a, Vector3 b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Multiply(Vector3 a, Vector2 b)
        {
            return new Vector3(
                a.x * b.x,
                a.y * b.y,
                a.z
                );
        }

        public static Vector3 Multiply(Vector2 b, Vector3 a)
        {
            return new Vector3(
                a.x * b.x,
                a.y * b.y,
                a.z
                );
        }

        public static Vector3 Multiply(Vector3 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector3(
                a.x * v,
                a.y * v,
                a.z * v);
        }

        public static Vector3 Multiply(bool b, Vector3 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector3(
                a.x * v,
                a.y * v,
                a.z * v);
        }

        public static Vector3 Multiply(Vector3 a, Vector2Int b)
        {
            return new Vector3
                (
                    a.x * b.x,
                    a.y * b.y,
                    a.z
                );
        }

        public static Vector3 Multiply(Vector2Int b, Vector3 a)
        {
            return new Vector3
                (
                    a.x * b.x,
                    a.y * b.y,
                    a.z
                );
        }

        public static Vector3 Multiply(Vector3 a, Vector3 b)
        {
            return mathx.mult(a, b);
        }

        public static Vector3Int Multiply(Vector3Int a, int b)
        {
            int3 v = new(a.x, a.y, a.z);
            v *= b;
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Multiply(int b, Vector3Int a)
        {
            int3 v = new(a.x, a.y, a.z);
            v *= b;
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Multiply(Vector3Int a, Vector3Int b)
        {
            return a * b;
        }

        public static Vector3Int Multiply(Vector3Int a, float b)
        {
            int3 v = new(a.x, a.y, a.z);
            v *= Mathf.RoundToInt(b);
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Multiply(float b, Vector3Int a)
        {
            int3 v = new(a.x, a.y, a.z);
            v *= Mathf.RoundToInt(b);
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Multiply(Vector3Int a, Vector2Int b)
        {
            return new Vector3Int(
                a.x * b.x,
                a.y * b.y,
                a.z);
        }

        public static Vector3Int Multiply(Vector2Int b, Vector3Int a)
        {
            return new Vector3Int(
                a.x * b.x,
                a.y * b.y,
                a.z);
        }

        public static Vector3Int Multiply(Vector3Int a, Vector2 b)
        {
            return new Vector3Int(
                a.x * Mathf.RoundToInt(b.x),
                a.y * Mathf.RoundToInt(b.y),
                a.z);
        }
        public static Vector3Int Multiply(Vector2 b, Vector3Int a)
        {
            return new Vector3Int(
                a.x * Mathf.RoundToInt(b.x),
                a.y * Mathf.RoundToInt(b.y),
                a.z);
        }

        public static Vector3Int Multiply(Vector3Int a, Vector3 b)
        {
            return new Vector3Int(
                a.x * Mathf.RoundToInt(b.x),
                a.y * Mathf.RoundToInt(b.y),
                a.z * Mathf.RoundToInt(b.z));
        }

        public static Vector3Int Multiply(Vector3 b, Vector3Int a)
        {
            return new Vector3Int(
                a.x * Mathf.RoundToInt(b.x),
                a.y * Mathf.RoundToInt(b.y),
                a.z * Mathf.RoundToInt(b.z));
        }

        public static Vector4 Multiply(Vector4 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector4(a.x * v, a.y * v, a.z * v, a.w * v);
        }

        public static Vector4 Multiply(bool b, Vector4 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector4(a.x * v, a.y * v, a.z * v, a.w * v);
        }

        public static Vector4 Multiply(Vector4 a, int b)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Multiply(int a, Vector4 b)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Multiply(Vector4 a, float b)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Multiply(float b, Vector4 a)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Multiply(Vector4 a, Vector2 b)
        {
            return new Vector4(
                a.x * b.x,
                a.y * b.y,
                a.z,
                a.w);
        }

        public static Vector4 Multiply(Vector2 b, Vector4 a)
        {
            return new Vector4(
                a.x * b.x,
                a.y * b.y,
                a.z,
                a.w);
        }

        public static Vector4 Multiply(Vector4 a, Vector2Int b)
        {
            return new Vector4(
                a.x * b.x,
                a.y * b.y,
                a.z,
                a.w);
        }

        public static Vector4 Multiply(Vector2Int b, Vector4 a)
        {
            return new Vector4(
                a.x * b.x,
                a.y * b.y,
                a.z,
                a.w);
        }

        public static Vector4 Multiply(Vector4 a, Vector3Int b)
        {
            return new Vector4(
                a.x * b.x,
                a.y * b.y,
                a.z * b.z,
                a.w);
        }

        public static Vector4 Multiply(Vector3Int b, Vector4 a)
        {
            return new Vector4(
                a.x * b.x,
                a.y * b.y,
                a.z * b.z,
                a.w);
        }

        public static Vector4 Multiply(Vector4 a, Vector4 b)
        {
            return mathx.mult(a, b);
        }

        public static Vector4 Multiply(Vector4 a, Vector3 b)
        {
            return new Vector4(
                a.x * b.x,
                a.y * b.y,
                a.z * b.z,
                a.w
                );
        }

        public static Vector4 Multiply(Vector3 b, Vector4 a)
        {
            return new Vector4(
                a.x * b.x,
                a.y * b.y,
                a.z * b.z,
                a.w
                );
        }

        public static bool Multiply(bool a, bool b)
        {
            return (a || b);
        }

        public static Color Multiply(Color a, int b)
        {
            Vector4 c = Multiply(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Multiply(int b, Color a)
        {
            Vector4 c = Multiply(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Multiply(Color a, float b)
        {
            Vector4 c = Multiply(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Multiply(float b, Color a)
        {
            Vector4 c = Multiply(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Multiply(Color a, Vector2 b)
        {
            return new Color(a.r * b.x, a.g * b.y, a.b, a.a);
        }

        public static Color Multiply(Vector2 b, Color a)
        {
            return new Color(a.r * b.x, a.g * b.y, a.b, a.a);
        }

        public static Color Multiply(Color a, Vector2Int b)
        {
            Vector4 c = Multiply(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Multiply(Vector2Int b, Color a)
        {
            Vector4 c = Multiply(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Multiply(Color a, Vector3 b)
        {
            return new Color(
                a.r * b.x,
                a.g * b.y,
                a.b * b.z,
                a.a);
        }

        public static Color Multiply(Vector3 b, Color a)
        {
            return new Color(
                a.r * b.x,
                a.g * b.y,
                a.b * b.z,
                a.a);
        }

        public static Color Multiply(Color a, Vector3Int b)
        {
            return new Color(
                a.r * b.x,
                a.g * b.y,
                a.b * b.z,
                a.a);
        }

        public static Color Multiply(Vector3Int b, Color a)
        {
            return new Color(
                a.r * b.x,
                a.g * b.y,
                a.b * b.z,
                a.a);
        }

        public static Color Multiply(Color a, Vector4 b)
        {
            return new Color(
                a.r * b.x,
                a.g * b.y,
                a.b * b.z,
                a.a * b.w);
        }

        public static Color Multiply(Vector4 b, Color a)
        {
            return new Color(
                a.r * b.x,
                a.g * b.y,
                a.b * b.z,
                a.a * b.w);
        }

        public static Quaternion Multiply(Quaternion a, int b)
        {
            return new Quaternion(
                a.x * b,
                a.y * b,
                a.z * b,
                a.w * b);
        }

        public static Quaternion Multiply(int b, Quaternion a)
        {
            return new Quaternion(
                a.x * b,
                a.y * b,
                a.z * b,
                a.w * b);
        }
        public static Quaternion Multiply(Quaternion a, float b)
        {
            return new Quaternion(
                a.x * b,
                a.y * b,
                a.z * b,
                a.w * b);
        }

        public static Quaternion Multiply(float b, Quaternion a)
        {
            return new Quaternion(
                a.x * b,
                a.y * b,
                a.z * b,
                a.w * b);
        }

        public static Quaternion Multiply(Quaternion a, Vector2 b)
        {
            return new Quaternion(
                a.x * b.x,
                a.y * b.y,
                a.z * 0,
                a.w * 0);
        }

        public static Quaternion Multiply(Vector2 b, Quaternion a)
        {
            return new Quaternion(
                a.x * b.x,
                a.y * b.y,
                a.z * 0,
                a.w * 0);
        }

        public static Quaternion Multiply(Quaternion a, Vector2Int b)
        {
            return new Quaternion(
                a.x * b.x,
                a.y * b.y,
                a.z * 0,
                a.w * 0);
        }

        public static Quaternion Multiply(Vector2Int b, Quaternion a)
        {
            return new Quaternion(
                a.x * b.x,
                a.y * b.y,
                a.z * 0,
                a.w * 0);
        }

        public static Quaternion Multiply(Quaternion a, Vector3 b)
        {
            return new Quaternion(
                a.x * b.x,
                a.y * b.y,
                a.z * b.z,
                a.w * 0);
        }

        public static Quaternion Multiply(Vector3 b, Quaternion a)
        {
            return new Quaternion(
                a.x * b.x,
                a.y * b.y,
                a.z * b.z,
                a.w * 0);
        }

        public static Quaternion Multiply(Quaternion a, Vector3Int b)
        {
            return new Quaternion(
                a.x * b.x,
                a.y * b.y,
                a.z * b.z,
                a.w * 0);
        }

        public static Quaternion Multiply(Vector3Int b, Quaternion a)
        {
            return new Quaternion(
                a.x * b.x,
                a.y * b.y,
                a.z * b.z,
                a.w * 0);
        }

        public static Quaternion Multiply(Quaternion a, Vector4 b)
        {
            return new Quaternion(
                a.x * b.x,
                a.y * b.y,
                a.z * b.z,
                a.w * b.w);
        }

        public static Quaternion Multiply(Vector4 b, Quaternion a)
        {
            return new Quaternion(
                a.x * b.x,
                a.y * b.y,
                a.z * b.z,
                a.w * b.w);
        }

        public static Quaternion Multiply(Quaternion a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Quaternion(
                a.x * v,
                a.y * v,
                a.z * v,
                a.w * v);
        }

        public static Quaternion Multiply(bool b, Quaternion a)
        {
            int v = 0;
            if (b)
                v++;
            return new Quaternion(
                a.x * v,
                a.y * v,
                a.z * v,
                a.w * v);
        }

        public static Quaternion Multiply(Quaternion a, Color b)
        {
            return new Quaternion(
                a.x * b.r,
                a.y * b.g,
                a.z * b.b,
                a.w * b.a);
        }

        public static Quaternion Multiply(Color a, Quaternion b)
        {
            return new Quaternion(
                a.r * b.x,
                a.g * b.y,
                a.b * b.z,
                a.a * b.w);
        }

        public static Color Multiply(Color a, Color b)
        {
            Color c = a * b;
            if (c.g > 1)
                c.g = 1;
            if (c.r > 1)
                c.r = 1;
            if (c.b > 1)
                c.b = 1;
            if (c.a > 1)
                c.a = 1;
            return c;
        }
        #endregion

        #region Divide
        public static object Divide(object a, object b)
        {
            if ((b is int && (int)b == 0) || (b is float && (float)b == 0))
                return null;

            if (a is int)
            {
                if (b is int)
                    return Divide((int)a, (int)b);
                if (b is float)
                    return Divide((int)a, (float)b);
                if (b is Vector2)
                    return Divide((int)a, (Vector2)b);
                if (b is Vector3)
                    return Divide((int)a, (Vector3)b);
                if (b is Vector4)
                    return Divide((int)a, (Vector4)b);
                if (b is Vector3Int)
                    return Divide((int)a, (Vector3Int)b);
                if (b is Quaternion)
                    return Divide((int)a, (Quaternion)b);
                if (b is Vector2Int)
                    return Divide((int)a, (Vector2Int)b);
                if (b is Color)
                    return Divide((int)a, (Color)b);
                if (b is bool)
                    return Divide((int)a, (bool)b);
            }
            if (a is float)
            {
                if (b is int)
                    return Divide((float)a, (int)b);
                if (b is float)
                    return Divide((float)a, (float)b);
                if (b is Vector2)
                    return Divide((float)a, (Vector2)b);
                if (b is Vector3)
                    return Divide((float)a, (Vector3)b);
                if (b is Vector4)
                    return Divide((float)a, (Vector4)b);
                if (b is Vector3Int)
                    return Divide((float)a, (Vector3Int)b);
                if (b is Quaternion)
                    return Divide((float)a, (Quaternion)b);
                if (b is Vector2Int)
                    return Divide((float)a, (Vector2Int)b);
                if (b is Color)
                    return Divide((float)a, (Color)b);
                if (b is bool)
                    return Divide((float)a, (bool)b);
            }

            if (a is Vector2 i)
            {
                if (b is int)
                    return Divide(i, (int)b);
                if (b is float)
                    return Divide(i, (float)b);
                if (b is Vector2)
                    return Divide(i, (Vector2)b);
                if (b is Vector3)
                    return Divide(i, (Vector3)b);
                if (b is Vector4)
                    return Divide(i, (Vector4)b);
                if (b is Vector3Int)
                    return Divide(i, (Vector3Int)b);
                if (b is Quaternion)
                    return Divide(i, (Quaternion)b);
                if (b is Vector2Int)
                    return Divide(i, (Vector2Int)b);
                if (b is Color)
                    return Divide(i, (Color)b);
                if (b is bool)
                    return Divide(i, (bool)b);
            }

            if (a is Vector3 j)
            {
                if (b is int)
                    return Divide(j, (int)b);
                if (b is float)
                    return Divide(j, (float)b);
                if (b is Vector2)
                    return Divide(j, (Vector2)b);
                if (b is Vector3)
                    return Divide(j, (Vector3)b);
                if (b is Vector4)
                    return Divide(j, (Vector4)b);
                if (b is Vector3Int)
                    return Divide(j, (Vector3Int)b);
                if (b is Quaternion)
                    return Divide(j, (Quaternion)b);
                if (b is Vector2Int)
                    return Divide(j, (Vector2Int)b);
                if (b is Color)
                    return Divide(j, (Color)b);
                if (b is bool)
                    return Divide(j, (bool)b);
            }

            if (a is Vector4 k)
            {
                if (b is int)
                    return Divide(k, (int)b);
                if (b is float)
                    return Divide(k, (float)b);
                if (b is Vector2)
                    return Divide(k, (Vector2)b);
                if (b is Vector3)
                    return Divide(k, (Vector3)b);
                if (b is Vector4)
                    return Divide(k, (Vector4)b);
                if (b is Vector3Int)
                    return Divide(k, (Vector3Int)b);
                if (b is Quaternion)
                    return Divide(k, (Quaternion)b);
                if (b is Vector2Int)
                    return Divide(k, (Vector2Int)b);
                if (b is Color)
                    return Divide(k, (Color)b);
                if (b is bool)
                    return Divide(k, (bool)b);
            }

            if (a is Vector2Int l)
            {
                if (b is int)
                    return Divide(l, (int)b);
                if (b is float)
                    return Divide(l, (float)b);
                if (b is Vector2)
                    return Divide(l, (Vector2)b);
                if (b is Vector3)
                    return Divide(l, (Vector3)b);
                if (b is Vector4)
                    return Divide(l, (Vector4)b);
                if (b is Vector3Int)
                    return Divide(l, (Vector3Int)b);
                if (b is Quaternion)
                    return Divide(l, (Quaternion)b);
                if (b is Vector2Int)
                    return Divide(l, (Vector2Int)b);
                if (b is Color)
                    return Divide(l, (Color)b);
                if (b is bool)
                    return Divide(l, (bool)b);
            }

            if (a is Vector3Int m)
            {
                if (b is int)
                    return Divide(m, (int)b);
                if (b is float)
                    return Divide(m, (float)b);
                if (b is Vector2)
                    return Divide(m, (Vector2)b);
                if (b is Vector3)
                    return Divide(m, (Vector3)b);
                if (b is Vector4)
                    return Divide(m, (Vector4)b);
                if (b is Vector3Int)
                    return Divide(m, (Vector3Int)b);
                if (b is Quaternion)
                    return Divide(m, (Quaternion)b);
                if (b is Vector2Int)
                    return Divide(m, (Vector2Int)b);
                if (b is Color)
                    return Divide(m, (Color)b);
                if (b is bool)
                    return Divide(m, (bool)b);
            }

            if (a is Color n)
            {
                if (b is int)
                    return Divide(n, (int)b);
                if (b is float)
                    return Divide(n, (float)b);
                if (b is Vector2)
                    return Divide(n, (Vector2)b);
                if (b is Vector3)
                    return Divide(n, (Vector3)b);
                if (b is Vector4)
                    return Divide(n, (Vector4)b);
                if (b is Vector3Int)
                    return Divide(n, (Vector3Int)b);
                if (b is Quaternion)
                    return Divide(n, (Quaternion)b);
                if (b is Vector2Int)
                    return Divide(n, (Vector2Int)b);
                if (b is Color)
                    return Divide(n, (Color)b);
                if (b is bool)
                    return Divide(n, (bool)b);
            }

            if (a is string o)
            {
                if (b is int)
                    return Divide(o, (int)b);
                if (b is float)
                    return Divide(o, (float)b);
                if (b is Vector2)
                    return Divide(o, (Vector2)b);
                if (b is Vector3)
                    return Divide(o, (Vector3)b);
                if (b is Vector4)
                    return Divide(o, (Vector4)b);
                if (b is Vector3Int)
                    return Divide(o, (Vector3Int)b);
                if (b is Quaternion)
                    return Divide(o, (Quaternion)b);
                if (b is Vector2Int)
                    return Divide(o, (Vector2Int)b);
                if (b is Color)
                    return Divide(o, (Color)b);
                if (b is bool)
                    return Divide(o, (bool)b);
            }

            if (a is bool p)
            {
                if (b is int)
                    return Divide(p, (int)b);
                if (b is float)
                    return Divide(p, (float)b);
                if (b is Vector2)
                    return Divide(p, (Vector2)b);
                if (b is Vector3)
                    return Divide(p, (Vector3)b);
                if (b is Vector4)
                    return Divide(p, (Vector4)b);
                if (b is Vector3Int)
                    return Divide(p, (Vector3Int)b);
                if (b is Quaternion)
                    return Divide(p, (Quaternion)b);
                if (b is Vector2Int)
                    return Divide(p, (Vector2Int)b);
                if (b is Color)
                    return Divide(p, (Color)b);
                if (b is bool)
                    return Divide(p, (bool)b);
            }

            if (a is Quaternion q)
            {
                if (b is int)
                    return Divide(q, (int)b);
                if (b is float)
                    return Divide(q, (float)b);
                if (b is Vector2)
                    return Divide(q, (Vector2)b);
                if (b is Vector3)
                    return Divide(q, (Vector3)b);
                if (b is Vector4)
                    return Divide(q, (Vector4)b);
                if (b is Vector3Int)
                    return Divide(q, (Vector3Int)b);
                if (b is Quaternion)
                    return Divide(q, (Quaternion)b);
                if (b is Vector2Int)
                    return Divide(q, (Vector2Int)b);
                if (b is Color)
                    return Divide(q, (Color)b);
                if (b is bool)
                    return Divide(q, (bool)b);
            }
            return null;
        }

        public static int Divide(int a, int b)
        {
            return a / b;
        }

        public static int Divide(int a, bool b)
        {
            if (b)
                return a / 1;
            else return a;
        }

        public static int Divide(bool b, int a)
        {
            if (b)
                return a / 1;
            else return a;
        }

        public static float Divide(int a, float b)
        {
            return a / b;
        }

        public static float Divide(float b, int a)
        {
            return a / b;
        }

        public static float Divide(float a, float b)
        {
            return a / b;
        }

        public static float Divide(float a, bool b)
        {
            if (b)
                return a + 1;
            else return a;
        }

        public static float Divide(bool b, float a)
        {
            if (b)
                return a / 1;
            else return a;
        }

        public static Vector2 Divide(Vector2 a, int b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Divide(int a, Vector2 b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Divide(Vector2 a, float b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Divide(float b, Vector2 a)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Divide(Vector2 a, Vector2 b)
        {
            return mathx.add(a, b);
        }

        public static Vector2 Divide(Vector2 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector2(a.x / v, a.y / v);
        }

        public static Vector2 Divide(bool b, Vector2 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector2(a.x / v, a.y / v);
        }

        public static Vector2 Divide(Vector2 a, Vector2Int b)
        {
            return mathx.add(a, new int2(b.x, b.y));
        }

        public static Vector2 Divide(Vector2Int a, Vector2 b)
        {
            return mathx.add(new int2(a.x, a.y), b);
        }

        public static Vector2Int Divide(Vector2Int a, int b)
        {
            int2 v = mathx.add(new int2(a.x, a.y), b);
            return new Vector2Int(v.x, v.y);
        }

        public static Vector2Int Divide(int a, Vector2Int b)
        {
            int2 v = mathx.add(a, new int2(b.x, b.y));
            return new Vector2Int(v.x, v.y);
        }

        public static Vector2Int Divide(Vector2Int a, Vector2Int b)
        {
            int2 v = mathx.add(new int2(a.x, a.y), new int2(b.x, b.y));
            return new Vector2Int(v.x, v.y);
        }

        public static Vector3 Divide(Vector3 a, int b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Divide(int a, Vector3 b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Divide(Vector3 a, float b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Divide(float a, Vector3 b)
        {
            return mathx.add(a, b);
        }

        public static Vector3 Divide(Vector3 a, Vector2 b)
        {
            return new Vector3(
                a.x / b.x,
                a.y / b.y,
                a.z
                );
        }

        public static Vector3 Divide(Vector2 b, Vector3 a)
        {
            return new Vector3(
                a.x / b.x,
                a.y / b.y,
                a.z
                );
        }

        public static Vector3 Divide(Vector3 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector3(
                a.x / v,
                a.y / v,
                a.z / v);
        }

        public static Vector3 Divide(bool b, Vector3 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector3(
                a.x / v,
                a.y / v,
                a.z / v);
        }

        public static Vector3 Divide(Vector3 a, Vector2Int b)
        {
            return new Vector3
                (
                    a.x / b.x,
                    a.y / b.y,
                    a.z
                );
        }

        public static Vector3 Divide(Vector2Int b, Vector3 a)
        {
            return new Vector3
                (
                    a.x / b.x,
                    a.y / b.y,
                    a.z
                );
        }

        public static Vector3 Divide(Vector3 a, Vector3 b)
        {
            return mathx.mult(a, b);
        }

        public static Vector3Int Divide(Vector3Int a, int b)
        {
            int3 v = new(a.x, a.y, a.z);
            v /= b;
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Divide(int b, Vector3Int a)
        {
            int3 v = new(a.x, a.y, a.z);
            v /= b;
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Divide(Vector3Int a, Vector3Int b)
        {
            return new Vector3Int(0, 0, 0);
        }

        public static Vector3Int Divide(Vector3Int a, float b)
        {
            int3 v = new(a.x, a.y, a.z);
            v /= Mathf.RoundToInt(b);
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Divide(float b, Vector3Int a)
        {
            int3 v = new(a.x, a.y, a.z);
            v /= Mathf.RoundToInt(b);
            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Divide(Vector3Int a, Vector2Int b)
        {
            return new Vector3Int(
                a.x / b.x,
                a.y / b.y,
                a.z);
        }

        public static Vector3Int Divide(Vector2Int b, Vector3Int a)
        {
            return new Vector3Int(
                a.x / b.x,
                a.y / b.y,
                a.z);
        }

        public static Vector3Int Divide(Vector3Int a, Vector2 b)
        {
            return new Vector3Int(
                a.x / Mathf.RoundToInt(b.x),
                a.y / Mathf.RoundToInt(b.y),
                a.z);
        }
        public static Vector3Int Divide(Vector2 b, Vector3Int a)
        {
            return new Vector3Int(
                a.x / Mathf.RoundToInt(b.x),
                a.y / Mathf.RoundToInt(b.y),
                a.z);
        }

        public static Vector3Int Divide(Vector3Int a, Vector3 b)
        {
            return new Vector3Int(
                a.x / Mathf.RoundToInt(b.x),
                a.y / Mathf.RoundToInt(b.y),
                a.z / Mathf.RoundToInt(b.z));
        }

        public static Vector3Int Divide(Vector3 b, Vector3Int a)
        {
            return new Vector3Int(
                a.x / Mathf.RoundToInt(b.x),
                a.y / Mathf.RoundToInt(b.y),
                a.z / Mathf.RoundToInt(b.z));
        }

        public static Vector4 Divide(Vector4 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector4(a.x / v, a.y / v, a.z / v, a.w / v);
        }

        public static Vector4 Divide(bool b, Vector4 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector4(a.x / v, a.y / v, a.z / v, a.w / v);
        }

        public static Vector4 Divide(Vector4 a, int b)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Divide(int a, Vector4 b)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Divide(Vector4 a, float b)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Divide(float b, Vector4 a)
        {
            return mathx.add(a, b);
        }

        public static Vector4 Divide(Vector4 a, Vector2 b)
        {
            return new Vector4(
                a.x / b.x,
                a.y / b.y,
                a.z,
                a.w);
        }

        public static Vector4 Divide(Vector2 b, Vector4 a)
        {
            return new Vector4(
                a.x / b.x,
                a.y / b.y,
                a.z,
                a.w);
        }

        public static Vector4 Divide(Vector4 a, Vector2Int b)
        {
            return new Vector4(
                a.x / b.x,
                a.y / b.y,
                a.z,
                a.w);
        }

        public static Vector4 Divide(Vector2Int b, Vector4 a)
        {
            return new Vector4(
                a.x / b.x,
                a.y / b.y,
                a.z,
                a.w);
        }

        public static Vector4 Divide(Vector4 a, Vector3Int b)
        {
            return new Vector4(
                a.x / b.x,
                a.y / b.y,
                a.z / b.z,
                a.w);
        }

        public static Vector4 Divide(Vector3Int b, Vector4 a)
        {
            return new Vector4(
                a.x / b.x,
                a.y / b.y,
                a.z / b.z,
                a.w);
        }

        public static Vector4 Divide(Vector4 a, Vector4 b)
        {
            return mathx.mult(a, b);
        }

        public static Vector4 Divide(Vector4 a, Vector3 b)
        {
            return new Vector4(
                a.x / b.x,
                a.y / b.y,
                a.z / b.z,
                a.w
                );
        }

        public static Vector4 Divide(Vector3 b, Vector4 a)
        {
            return new Vector4(
                a.x / b.x,
                a.y / b.y,
                a.z / b.z,
                a.w
                );
        }

        public static bool Divide(bool a, bool b)
        {
            return (a || b);
        }

        public static Color Divide(Color a, int b)
        {
            Vector4 c = Divide(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Divide(int b, Color a)
        {
            Vector4 c = Divide(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Divide(Color a, float b)
        {
            Vector4 c = Divide(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Divide(float b, Color a)
        {
            Vector4 c = Divide(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Divide(Color a, Vector2 b)
        {
            return new Color(a.r / b.x, a.g / b.y, a.b, a.a);
        }

        public static Color Divide(Vector2 b, Color a)
        {
            return new Color(a.r / b.x, a.g / b.y, a.b, a.a);
        }

        public static Color Divide(Color a, Vector2Int b)
        {
            Vector4 c = Divide(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Divide(Vector2Int b, Color a)
        {
            Vector4 c = Divide(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Divide(Color a, Vector3 b)
        {
            return new Color(
                a.r / b.x,
                a.g / b.y,
                a.b / b.z,
                a.a);
        }

        public static Color Divide(Vector3 b, Color a)
        {
            return new Color(
                a.r / b.x,
                a.g / b.y,
                a.b / b.z,
                a.a);
        }

        public static Color Divide(Color a, Vector3Int b)
        {
            return new Color(
                a.r / b.x,
                a.g / b.y,
                a.b / b.z,
                a.a);
        }

        public static Color Divide(Vector3Int b, Color a)
        {
            return new Color(
                a.r / b.x,
                a.g / b.y,
                a.b / b.z,
                a.a);
        }

        public static Color Divide(Color a, Vector4 b)
        {
            return new Color(
                a.r / b.x,
                a.g / b.y,
                a.b / b.z,
                a.a / b.w);
        }

        public static Color Divide(Vector4 b, Color a)
        {
            return new Color(
                a.r / b.x,
                a.g / b.y,
                a.b / b.z,
                a.a / b.w);
        }

        public static Quaternion Divide(Quaternion a, int b)
        {
            return new Quaternion(
                a.x / b,
                a.y / b,
                a.z / b,
                a.w / b);
        }

        public static Quaternion Divide(int b, Quaternion a)
        {
            return new Quaternion(
                a.x / b,
                a.y / b,
                a.z / b,
                a.w / b);
        }
        public static Quaternion Divide(Quaternion a, float b)
        {
            return new Quaternion(
                a.x / b,
                a.y / b,
                a.z / b,
                a.w / b);
        }

        public static Quaternion Divide(float b, Quaternion a)
        {
            return new Quaternion(
                a.x / b,
                a.y / b,
                a.z / b,
                a.w / b);
        }

        public static Quaternion Divide(Quaternion a, Vector2 b)
        {
            return new Quaternion(
                a.x / b.x,
                a.y / b.y,
                a.z / 0,
                a.w / 0);
        }

        public static Quaternion Divide(Vector2 b, Quaternion a)
        {
            return new Quaternion(
                a.x / b.x,
                a.y / b.y,
                a.z / 0,
                a.w / 0);
        }

        public static Quaternion Divide(Quaternion a, Vector2Int b)
        {
            return new Quaternion(
                a.x / b.x,
                a.y / b.y,
                a.z / 0,
                a.w / 0);
        }

        public static Quaternion Divide(Vector2Int b, Quaternion a)
        {
            return new Quaternion(
                a.x / b.x,
                a.y / b.y,
                a.z / 0,
                a.w / 0);
        }

        public static Quaternion Divide(Quaternion a, Vector3 b)
        {
            return new Quaternion(
                a.x / b.x,
                a.y / b.y,
                a.z / b.z,
                a.w / 0);
        }

        public static Quaternion Divide(Vector3 b, Quaternion a)
        {
            return new Quaternion(
                a.x / b.x,
                a.y / b.y,
                a.z / b.z,
                a.w / 0);
        }

        public static Quaternion Divide(Quaternion a, Vector3Int b)
        {
            return new Quaternion(
                a.x / b.x,
                a.y / b.y,
                a.z / b.z,
                a.w / 0);
        }

        public static Quaternion Divide(Vector3Int b, Quaternion a)
        {
            return new Quaternion(
                a.x / b.x,
                a.y / b.y,
                a.z / b.z,
                a.w / 0);
        }

        public static Quaternion Divide(Quaternion a, Vector4 b)
        {
            return new Quaternion(
                a.x / b.x,
                a.y / b.y,
                a.z / b.z,
                a.w / b.w);
        }

        public static Quaternion Divide(Vector4 b, Quaternion a)
        {
            return new Quaternion(
                a.x / b.x,
                a.y / b.y,
                a.z / b.z,
                a.w / b.w);
        }

        public static Quaternion Divide(Quaternion a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Quaternion(
                a.x / v,
                a.y / v,
                a.z / v,
                a.w / v);
        }

        public static Quaternion Divide(bool b, Quaternion a)
        {
            int v = 0;
            if (b)
                v++;
            return new Quaternion(
                a.x / v,
                a.y / v,
                a.z / v,
                a.w / v);
        }

        public static Quaternion Divide(Quaternion a, Color b)
        {
            return new Quaternion(
                a.x / b.r,
                a.y / b.g,
                a.z / b.b,
                a.w / b.a);
        }

        public static Quaternion Divide(Color a, Quaternion b)
        {
            return new Quaternion(
                a.r / b.x,
                a.g / b.y,
                a.b / b.z,
                a.a / b.w);
        }

        public static Color Divide(Color a, Color b)
        {
            return Color.black;
        }
        #endregion

        #region Pow
        public static object Pow(object a, object b)
        {
            if (a is int)
            {
                if (b is int)
                    return Pow((int)a, (int)b);
                if (b is float)
                    return Pow((int)a, (float)b);
                if (b is Vector2)
                    return Pow((int)a, (Vector2)b);
                if (b is Vector3)
                    return Pow((int)a, (Vector3)b);
                if (b is Vector4)
                    return Pow((int)a, (Vector4)b);
                if (b is Vector3Int)
                    return Pow((int)a, (Vector3Int)b);
                if (b is Quaternion)
                    return Pow((int)a, (Quaternion)b);
                if (b is Vector2Int)
                    return Pow((int)a, (Vector2Int)b);
                if (b is Color)
                    return Pow((int)a, (Color)b);
                if (b is bool)
                    return Pow((int)a, (bool)b);
            }
            if (a is float)
            {
                if (b is int)
                    return Pow((float)a, (int)b);
                if (b is float)
                    return Pow((float)a, (float)b);
                if (b is Vector2)
                    return Pow((float)a, (Vector2)b);
                if (b is Vector3)
                    return Pow((float)a, (Vector3)b);
                if (b is Vector4)
                    return Pow((float)a, (Vector4)b);
                if (b is Vector3Int)
                    return Pow((float)a, (Vector3Int)b);
                if (b is Quaternion)
                    return Pow((float)a, (Quaternion)b);
                if (b is Vector2Int)
                    return Pow((float)a, (Vector2Int)b);
                if (b is Color)
                    return Pow((float)a, (Color)b);
                if (b is bool)
                    return Pow((float)a, (bool)b);
            }

            if (a is Vector2 i)
            {
                if (b is int)
                    return Pow(i, (int)b);
                if (b is float)
                    return Pow(i, (float)b);
                if (b is Vector2)
                    return Pow(i, (Vector2)b);
                if (b is Vector3)
                    return Pow(i, (Vector3)b);
                if (b is Vector4)
                    return Pow(i, (Vector4)b);
                if (b is Vector3Int)
                    return Pow(i, (Vector3Int)b);
                if (b is Quaternion)
                    return Pow(i, (Quaternion)b);
                if (b is Vector2Int)
                    return Pow(i, (Vector2Int)b);
                if (b is Color)
                    return Pow(i, (Color)b);
                if (b is bool)
                    return Pow(i, (bool)b);
            }

            if (a is Vector3 j)
            {
                if (b is int)
                    return Pow(j, (int)b);
                if (b is float)
                    return Pow(j, (float)b);
                if (b is Vector2)
                    return Pow(j, (Vector2)b);
                if (b is Vector3)
                    return Pow(j, (Vector3)b);
                if (b is Vector4)
                    return Pow(j, (Vector4)b);
                if (b is Vector3Int)
                    return Pow(j, (Vector3Int)b);
                if (b is Quaternion)
                    return Pow(j, (Quaternion)b);
                if (b is Vector2Int)
                    return Pow(j, (Vector2Int)b);
                if (b is Color)
                    return Pow(j, (Color)b);
                if (b is bool)
                    return Pow(j, (bool)b);
            }

            if (a is Vector4 k)
            {
                if (b is int)
                    return Pow(k, (int)b);
                if (b is float)
                    return Pow(k, (float)b);
                if (b is Vector2)
                    return Pow(k, (Vector2)b);
                if (b is Vector3)
                    return Pow(k, (Vector3)b);
                if (b is Vector4)
                    return Pow(k, (Vector4)b);
                if (b is Vector3Int)
                    return Pow(k, (Vector3Int)b);
                if (b is Quaternion)
                    return Pow(k, (Quaternion)b);
                if (b is Vector2Int)
                    return Pow(k, (Vector2Int)b);
                if (b is Color)
                    return Pow(k, (Color)b);
                if (b is bool)
                    return Pow(k, (bool)b);
            }

            if (a is Vector2Int l)
            {
                if (b is int)
                    return Pow(l, (int)b);
                if (b is float)
                    return Pow(l, (float)b);
                if (b is Vector2)
                    return Pow(l, (Vector2)b);
                if (b is Vector3)
                    return Pow(l, (Vector3)b);
                if (b is Vector4)
                    return Pow(l, (Vector4)b);
                if (b is Vector3Int)
                    return Pow(l, (Vector3Int)b);
                if (b is Quaternion)
                    return Pow(l, (Quaternion)b);
                if (b is Vector2Int)
                    return Pow(l, (Vector2Int)b);
                if (b is Color)
                    return Pow(l, (Color)b);
                if (b is bool)
                    return Pow(l, (bool)b);
            }

            if (a is Vector3Int m)
            {
                if (b is int)
                    return Pow(m, (int)b);
                if (b is float)
                    return Pow(m, (float)b);
                if (b is Vector2)
                    return Pow(m, (Vector2)b);
                if (b is Vector3)
                    return Pow(m, (Vector3)b);
                if (b is Vector4)
                    return Pow(m, (Vector4)b);
                if (b is Vector3Int)
                    return Pow(m, (Vector3Int)b);
                if (b is Quaternion)
                    return Pow(m, (Quaternion)b);
                if (b is Vector2Int)
                    return Pow(m, (Vector2Int)b);
                if (b is Color)
                    return Pow(m, (Color)b);
                if (b is bool)
                    return Pow(m, (bool)b);
            }

            if (a is Color n)
            {
                if (b is int)
                    return Pow(n, (int)b);
                if (b is float)
                    return Pow(n, (float)b);
                if (b is Vector2)
                    return Pow(n, (Vector2)b);
                if (b is Vector3)
                    return Pow(n, (Vector3)b);
                if (b is Vector4)
                    return Pow(n, (Vector4)b);
                if (b is Vector3Int)
                    return Pow(n, (Vector3Int)b);
                if (b is Quaternion)
                    return Pow(n, (Quaternion)b);
                if (b is Vector2Int)
                    return Pow(n, (Vector2Int)b);
                if (b is Color)
                    return Pow(n, (Color)b);
                if (b is bool)
                    return Pow(n, (bool)b);
            }

            if (a is string o)
            {
                if (b is int)
                    return Pow(o, (int)b);
                if (b is float)
                    return Pow(o, (float)b);
                if (b is Vector2)
                    return Pow(o, (Vector2)b);
                if (b is Vector3)
                    return Pow(o, (Vector3)b);
                if (b is Vector4)
                    return Pow(o, (Vector4)b);
                if (b is Vector3Int)
                    return Pow(o, (Vector3Int)b);
                if (b is Quaternion)
                    return Pow(o, (Quaternion)b);
                if (b is Vector2Int)
                    return Pow(o, (Vector2Int)b);
                if (b is Color)
                    return Pow(o, (Color)b);
                if (b is bool)
                    return Pow(o, (bool)b);
            }

            if (a is bool p)
            {
                if (b is int)
                    return Pow(p, (int)b);
                if (b is float)
                    return Pow(p, (float)b);
                if (b is Vector2)
                    return Pow(p, (Vector2)b);
                if (b is Vector3)
                    return Pow(p, (Vector3)b);
                if (b is Vector4)
                    return Pow(p, (Vector4)b);
                if (b is Vector3Int)
                    return Pow(p, (Vector3Int)b);
                if (b is Quaternion)
                    return Pow(p, (Quaternion)b);
                if (b is Vector2Int)
                    return Pow(p, (Vector2Int)b);
                if (b is Color)
                    return Pow(p, (Color)b);
                if (b is bool)
                    return Pow(p, (bool)b);
            }

            if (a is Quaternion q)
            {
                if (b is int)
                    return Pow(q, (int)b);
                if (b is float)
                    return Pow(q, (float)b);
                if (b is Vector2)
                    return Pow(q, (Vector2)b);
                if (b is Vector3)
                    return Pow(q, (Vector3)b);
                if (b is Vector4)
                    return Pow(q, (Vector4)b);
                if (b is Vector3Int)
                    return Pow(q, (Vector3Int)b);
                if (b is Quaternion)
                    return Pow(q, (Quaternion)b);
                if (b is Vector2Int)
                    return Pow(q, (Vector2Int)b);
                if (b is Color)
                    return Pow(q, (Color)b);
                if (b is bool)
                    return Pow(q, (bool)b);
            }
            return null;
        }

        public static int Pow(int a, int b)
        {
            return (int)mathx.pow(a, b);
        }

        public static int Pow(int a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return (int)mathx.pow(a, v);
        }

        public static int Pow(bool b, int a)
        {
            int v = 0;
            if (b) v++;
            return (int)mathx.pow(v, a);
        }

        public static float Pow(int a, float b)
        {
            return mathx.pow(a, b);
        }

        public static float Pow(float b, int a)
        {
            return mathx.pow(b, a);
        }

        public static float Pow(float a, float b)
        {
            return mathx.pow(a, b);
        }

        public static float Pow(float a, bool b)
        {
            int v = 0;
            if (b) v++;
            return mathx.pow(a, v);
        }

        public static float Pow(bool b, float a)
        {
            int v = 0;
            if (b) v++;
            return mathx.pow(a, v);
        }

        public static Vector2 Pow(Vector2 a, int b)
        {
            return mathx.pow(a, b);
        }

        public static Vector2 Pow(int a, Vector2 b)
        {
            return mathx.pow(a, b);
        }

        public static Vector2 Pow(Vector2 a, float b)
        {
            return mathx.pow(a, b);
        }

        public static Vector2 Pow(float b, Vector2 a)
        {
            return mathx.pow(a, b);
        }

        public static Vector2 Pow(Vector2 a, Vector2 b)
        {
            return mathx.pow(a, b);
        }

        public static Vector2 Pow(Vector2 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector2(math.pow(a.x, v), math.pow(a.y, v));
        }

        public static Vector2 Pow(bool b, Vector2 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector2(math.pow(a.x, v), math.pow(a.y, v));
        }

        public static Vector2 Pow(Vector2 a, Vector2Int b)
        {
            return mathx.pow(a, new int2(b.x, b.y));
        }

        public static Vector2 Pow(Vector2Int a, Vector2 b)
        {
            return mathx.pow(new int2(a.x, a.y), b);
        }

        public static Vector2Int Pow(Vector2Int a, int b)
        {
            Vector2 v = mathx.pow(new int2(a.x, a.y), b);
            return new Vector2Int(Mathf.RoundToInt(v.x), Mathf.RoundToInt(v.y));
        }

        public static Vector2Int Pow(int a, Vector2Int b)
        {
            Vector2 v = mathx.pow(new int2(b.x, b.y), a);
            return new Vector2Int(Mathf.RoundToInt(v.x), Mathf.RoundToInt(v.y));
        }

        public static Vector2Int Pow(Vector2Int a, Vector2Int b)
        {
            Vector2 v = mathx.pow(new int2(a.x, a.y), new int2(b.x, b.y));
            return new Vector2Int(Mathf.RoundToInt(v.x), Mathf.RoundToInt(v.y));
        }

        public static Vector3 Pow(Vector3 a, int b)
        {
            return mathx.pow(a, b);
        }

        public static Vector3 Pow(int a, Vector3 b)
        {
            return mathx.pow(a, b);
        }

        public static Vector3 Pow(Vector3 a, float b)
        {
            return mathx.pow(a, b);
        }

        public static Vector3 Pow(float a, Vector3 b)
        {
            return mathx.pow(a, b);
        }

        public static Vector3 Pow(Vector3 a, Vector2 b)
        {
            return new Vector3(
                Mathf.Pow(a.x, b.x),
                Mathf.Pow(a.y, b.y),
                a.z
                );
        }

        public static Vector3 Pow(Vector2 b, Vector3 a)
        {
            return new Vector3(
                Mathf.Pow(a.x, b.x),
                Mathf.Pow(a.y, b.y),
                a.z
                );
        }

        public static Vector3 Pow(Vector3 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector3(
                Mathf.Pow(a.x, v),
                Mathf.Pow(a.y, v),
                Mathf.Pow(a.z, v));
        }

        public static Vector3 Pow(bool b, Vector3 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector3(
                Mathf.Pow(a.x, v),
                Mathf.Pow(a.y, v),
                Mathf.Pow(a.z, v));
        }

        public static Vector3 Pow(Vector3 a, Vector2Int b)
        {
            return new Vector3
                (
                    Mathf.Pow(a.x, b.x),
                Mathf.Pow(a.y, b.y),
                a.z
                );
        }

        public static Vector3 Pow(Vector2Int b, Vector3 a)
        {
            return new Vector3
                (
                    Mathf.Pow(a.x, b.x),
                Mathf.Pow(a.y, b.y),
                a.z
                );
        }

        public static Vector3 Pow(Vector3 a, Vector3 b)
        {
            return mathx.pow(a, b);
        }

        public static Vector3Int Pow(Vector3Int a, int b)
        {
            int3 v = new((int)Mathf.Pow(a.x, b), (int)Mathf.Pow(a.y, b), (int)Mathf.Pow(a.z, b));

            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Pow(int b, Vector3Int a)
        {
            int3 v = new((int)Mathf.Pow(a.x, b), (int)Mathf.Pow(a.y, b), (int)Mathf.Pow(a.z, b));

            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Pow(Vector3Int a, Vector3Int b)
        {
            return new Vector3Int(0, 0, 0);
        }

        public static Vector3Int Pow(Vector3Int a, float b)
        {
            int3 v = new((int)Mathf.Pow(a.x, b), (int)Mathf.Pow(a.y, b), (int)Mathf.Pow(a.z, b));

            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Pow(float b, Vector3Int a)
        {
            int3 v = new((int)Mathf.Pow(a.x, b), (int)Mathf.Pow(a.y, b), (int)Mathf.Pow(a.z, b));

            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Pow(Vector3Int a, Vector2Int b)
        {
            int3 v = new((int)Mathf.Pow(a.x, b.x), (int)Mathf.Pow(a.y, b.y), a.z);

            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Pow(Vector2Int b, Vector3Int a)
        {
            int3 v = new((int)Mathf.Pow(a.x, b.x), (int)Mathf.Pow(a.y, b.y), a.z);

            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Pow(Vector3Int a, Vector2 b)
        {
            int3 v = new((int)Mathf.Pow(a.x, b.x), (int)Mathf.Pow(a.y, b.y), a.z);

            return new Vector3Int(v.x, v.y, v.z);
        }
        public static Vector3Int Pow(Vector2 b, Vector3Int a)
        {
            int3 v = new((int)Mathf.Pow(a.x, b.x), (int)Mathf.Pow(a.y, b.y), a.z);

            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Pow(Vector3Int a, Vector3 b)
        {
            int3 v = new((int)Mathf.Pow(a.x, b.x), (int)Mathf.Pow(a.y, b.y), (int)Mathf.Pow(a.z, b.z));

            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector3Int Pow(Vector3 b, Vector3Int a)
        {
            int3 v = new((int)Mathf.Pow(a.x, b.x), (int)Mathf.Pow(a.y, b.y), (int)Mathf.Pow(a.z, b.z));

            return new Vector3Int(v.x, v.y, v.z);
        }

        public static Vector4 Pow(Vector4 a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector4(math.pow(a.x, v), math.pow(a.y, v), math.pow(a.z, v), math.pow(a.w, v));
        }

        public static Vector4 Pow(bool b, Vector4 a)
        {
            int v = 0;
            if (b)
                v++;
            return new Vector4(math.pow(a.x, v), math.pow(a.y, v), math.pow(a.z, v), math.pow(a.w, v));
        }

        public static Vector4 Pow(Vector4 a, int b)
        {
            return mathx.pow(a, b);
        }

        public static Vector4 Pow(int a, Vector4 b)
        {
            return mathx.pow(a, b);
        }

        public static Vector4 Pow(Vector4 a, float b)
        {
            return mathx.pow(a, b);
        }

        public static Vector4 Pow(float b, Vector4 a)
        {
            return mathx.pow(a, b);
        }

        public static Vector4 Pow(Vector4 a, Vector2 b)
        {
            return new Vector4(math.pow(a.x, b.x), math.pow(a.y, b.y), a.z, a.w);
        }

        public static Vector4 Pow(Vector2 b, Vector4 a)
        {
            return new Vector4(math.pow(a.x, b.x), math.pow(a.y, b.y), a.z, a.w);
        }

        public static Vector4 Pow(Vector4 a, Vector2Int b)
        {
            return new Vector4(math.pow(a.x, b.x), math.pow(a.y, b.y), a.z, a.w);
        }

        public static Vector4 Pow(Vector2Int b, Vector4 a)
        {
            return new Vector4(math.pow(a.x, b.x), math.pow(a.y, b.y), a.z, a.w);
        }

        public static Vector4 Pow(Vector4 a, Vector3Int b)
        {
            return new Vector4(math.pow(a.x, b.x), math.pow(a.y, b.y), math.pow(a.z, b.z), a.w);
        }

        public static Vector4 Pow(Vector3Int b, Vector4 a)
        {
            return new Vector4(math.pow(a.x, b.x), math.pow(a.y, b.y), math.pow(a.z, b.z), a.w);
        }

        public static Vector4 Pow(Vector4 a, Vector4 b)
        {
            return mathx.pow(a, b);
        }

        public static Vector4 Pow(Vector4 a, Vector3 b)
        {
            return new Vector4(math.pow(a.x, b.x), math.pow(a.y, b.y), math.pow(a.z, b.z), a.w);
        }

        public static Vector4 Pow(Vector3 b, Vector4 a)
        {
            return new Vector4(math.pow(a.x, b.x), math.pow(a.y, b.y), math.pow(a.z, b.z), a.w);
        }

        public static bool Pow(bool a, bool b)
        {
            return (a || b);
        }

        public static Color Pow(Color a, int b)
        {
            Vector4 c = Pow(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Pow(int b, Color a)
        {
            Vector4 c = Pow(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Pow(Color a, float b)
        {
            Vector4 c = Pow(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Pow(float b, Color a)
        {
            Vector4 c = Pow(new Vector4(a.r, a.g, a.b, a.a), b);
            return new Color(c.x, c.y, c.z, c.w);
        }

        public static Color Pow(Color a, Vector2 b)
        {
            return new Vector4(math.pow(a.r, b.x), math.pow(a.g, b.y), a.b, a.a);
        }

        public static Color Pow(Vector2 b, Color a)
        {
            return new Vector4(math.pow(a.r, b.x), math.pow(a.g, b.y), a.b, a.a);
        }

        public static Color Pow(Color a, Vector2Int b)
        {
            return new Vector4(math.pow(a.r, b.x), math.pow(a.g, b.y), a.b, a.a);
        }

        public static Color Pow(Vector2Int b, Color a)
        {
            return new Vector4(math.pow(a.r, b.x), math.pow(a.g, b.y), a.b, a.a);
        }

        public static Color Pow(Color a, Vector3 b)
        {
            return new Vector4(math.pow(a.r, b.x), math.pow(a.g, b.y), math.pow(a.b, b.z), a.a);
        }

        public static Color Pow(Vector3 b, Color a)
        {
            return new Vector4(math.pow(a.r, b.x), math.pow(a.g, b.y), math.pow(a.b, b.z), a.a);
        }

        public static Color Pow(Color a, Vector3Int b)
        {
            return new Vector4(math.pow(a.r, b.x), math.pow(a.g, b.y), math.pow(a.b, b.z), a.a);
        }

        public static Color Pow(Vector3Int b, Color a)
        {
            return new Vector4(math.pow(a.r, b.x), math.pow(a.g, b.y), math.pow(a.b, b.z), a.a);
        }

        public static Color Pow(Color a, Vector4 b)
        {
            return new Vector4(math.pow(a.r, b.x), math.pow(a.g, b.y), math.pow(a.b, b.z), math.pow(a.a, b.w));
        }

        public static Color Pow(Vector4 b, Color a)
        {
            return new Vector4(math.pow(a.r, b.x), math.pow(a.g, b.y), math.pow(a.b, b.z), math.pow(a.a, b.w));
        }

        public static Quaternion Pow(Quaternion a, int b)
        {
            return new Quaternion(mathx.pow(a.x, b), mathx.pow(a.y, b), mathx.pow(a.z, b), mathx.pow(a.w, b));
        }

        public static Quaternion Pow(int b, Quaternion a)
        {
            return new Quaternion(mathx.pow(a.x, b), mathx.pow(a.y, b), mathx.pow(a.z, b), mathx.pow(a.w, b));
        }
        public static Quaternion Pow(Quaternion a, float b)
        {
            return new Quaternion(mathx.pow(a.x, b), mathx.pow(a.y, b), mathx.pow(a.z, b), mathx.pow(a.w, b));
        }

        public static Quaternion Pow(float b, Quaternion a)
        {
            return new Quaternion(mathx.pow(a.x, b), mathx.pow(a.y, b), mathx.pow(a.z, b), mathx.pow(a.w, b));
        }

        public static Quaternion Pow(Quaternion a, Vector2 b)
        {
            return new Quaternion(mathx.pow(a.x, b.x), mathx.pow(a.y, b.y), a.z, a.w);
        }

        public static Quaternion Pow(Vector2 b, Quaternion a)
        {
            return new Quaternion(mathx.pow(a.x, b.x), mathx.pow(a.y, b.y), a.z, a.w);
        }

        public static Quaternion Pow(Quaternion a, Vector2Int b)
        {
            return new Quaternion(mathx.pow(a.x, b.x), mathx.pow(a.y, b.y), a.z, a.w);
        }

        public static Quaternion Pow(Vector2Int b, Quaternion a)
        {
            return new Quaternion(mathx.pow(a.x, b.x), mathx.pow(a.y, b.y), a.z, a.w);
        }

        public static Quaternion Pow(Quaternion a, Vector3 b)
        {
            return new Quaternion(mathx.pow(a.x, b.x), mathx.pow(a.y, b.y), mathx.pow(a.z, b.y), a.w);
        }

        public static Quaternion Pow(Vector3 b, Quaternion a)
        {
            return new Quaternion(mathx.pow(a.x, b.x), mathx.pow(a.y, b.y), mathx.pow(a.z, b.y), a.w);
        }

        public static Quaternion Pow(Quaternion a, Vector3Int b)
        {
            return new Quaternion(mathx.pow(a.x, b.x), mathx.pow(a.y, b.y), mathx.pow(a.z, b.y), a.w);
        }

        public static Quaternion Pow(Vector3Int b, Quaternion a)
        {
            return new Quaternion(mathx.pow(a.x, b.x), mathx.pow(a.y, b.y), mathx.pow(a.z, b.y), a.w);
        }

        public static Quaternion Pow(Quaternion a, Vector4 b)
        {
            return new Quaternion(mathx.pow(a.x, b.x), mathx.pow(a.y, b.y), mathx.pow(a.z, b.y), mathx.pow(a.w, b.w));
        }

        public static Quaternion Pow(Vector4 b, Quaternion a)
        {
            return new Quaternion(mathx.pow(a.x, b.x), mathx.pow(a.y, b.y), mathx.pow(a.z, b.y), mathx.pow(a.w, b.w));
        }

        public static Quaternion Pow(Quaternion a, bool b)
        {
            int v = 0;
            if (b)
                v++;
            return new Quaternion(mathx.pow(a.x, v), mathx.pow(a.y, v), mathx.pow(a.z, v), mathx.pow(a.w, v));
        }

        public static Quaternion Pow(bool b, Quaternion a)
        {
            int v = 0;
            if (b)
                v++;
            return new Quaternion(mathx.pow(a.x, v), mathx.pow(a.y, v), mathx.pow(a.z, v), mathx.pow(a.w, v));
        }

        public static Quaternion Pow(Quaternion a, Color b)
        {
            return new Quaternion(mathx.pow(a.x, b.r), mathx.pow(a.y, b.g), mathx.pow(a.z, b.b), mathx.pow(a.w, b.a));
        }

        public static Quaternion Pow(Color b, Quaternion a)
        {
            return new Quaternion(mathx.pow(a.x, b.r), mathx.pow(a.y, b.g), mathx.pow(a.z, b.b), mathx.pow(a.w, b.a));
        }

        public static Color Pow(Color a, Color b)
        {
            return new Color(mathx.pow(a.r, b.r), mathx.pow(a.g, b.g), mathx.pow(a.b, b.b), mathx.pow(a.a, b.a));
        }
        #endregion

    }
}