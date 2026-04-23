using System;

using UnityEngine;

namespace AhahGames.GenesisNoise
{
    public static class TypeCasting
    {
        public static Type GetObjectType(object obj)
        {
            if (obj == null) return null;
            if (obj is bool) return typeof(bool);
            if (obj is float) return typeof(float);
            if (obj is Vector2) return typeof(Vector2);
            if (obj is Vector3) return typeof(Vector3);
            if (obj is Vector4) return typeof(Vector4);
            if (obj is Quaternion) return typeof(Quaternion);
            if (obj is Vector2Int) return typeof(Vector2Int);
            if (obj is Vector3Int) return typeof(Vector3Int);
            if (obj is Color) return typeof(Color);
            if (obj is string) return typeof(string);
            return null;
        }

        public static bool ToBool(object obj)
        {
            if (obj == null) return false;
            if (obj is bool) return (bool)obj;
            if (obj is float)
            {
                float v = (float)obj;
                if (v == 0) return false;
                return true;
            }
            if (obj is int)
            {
                int v = (int)obj;
                if (v == 0) return false;
                return true;
            }
            if (obj is Vector2)
            {
                Vector2 v = (Vector2)obj;
                if (v == Vector2.zero) return false;
                return true;
            }
            if (obj is Vector3)
            {
                Vector3 v = (Vector3)obj;
                if (v == Vector3.zero) return false;
                return true;
            }
            if (obj is Vector4)
            {
                Vector4 v = (Vector4)obj;
                if (v == Vector4.zero) return false;
                return true;
            }
            if (obj is Vector2Int)
            {
                Vector2Int v = (Vector2Int)obj;
                if (v == Vector2Int.zero) return false;
                return true;
            }
            if (obj is Vector3Int)
            {
                Vector3Int v = (Vector3Int)obj;
                if (v == Vector3Int.zero) return false;
                return true;
            }
            if (obj is Color)
            {
                Color v = (Color)obj;
                if (v == Color.black) return false;
                return true;
            }
            if (obj is Quaternion)
            {
                Quaternion v = (Quaternion)obj;
                if (v == Quaternion.identity) return false;
                return true;
            }
            if (obj is string)
            {
                if (string.IsNullOrEmpty(obj.ToString())) return false;
                return true;
            }
            return false;
        }

        public static int ToInt(object obj)
        {
            if (obj == null) return 0;
            if (obj is int) return (int)obj;
            if (obj is float) return (int)((float)obj);
            if (obj is Vector2) { return (int)((Vector2)obj).x; }
            if (obj is Vector3) { return (int)((Vector3)obj).x; }
            if (obj is Vector4) { return (int)((Vector4)obj).x; }
            if (obj is Vector2Int) { return (int)((Vector2Int)obj).x; }
            if (obj is Vector3Int) { return (int)((Vector3Int)obj).x; }
            if (obj is Color) { return (int)((Color)obj).r; }
            if (obj is Quaternion) { return (int)((Quaternion)obj).w; }
            if (obj is string)
            {
                int v;
                if (int.TryParse((string)obj, out v))
                    return v;
                return 0;
            }

            return 0;
        }

        public static float ToFloat(object obj)
        {
            if (obj == null) return 0.0f;
            if (obj is int) return (float)obj;
            if (obj is float) return ((float)obj);
            if (obj is Vector2) { return ((Vector2)obj).x; }
            if (obj is Vector3) { return ((Vector3)obj).x; }
            if (obj is Vector4) { return ((Vector4)obj).x; }
            if (obj is Vector2Int) { return ((Vector2Int)obj).x; }
            if (obj is Vector3Int) { return ((Vector3Int)obj).x; }
            if (obj is Color) { return ((Color)obj).r; }
            if (obj is Quaternion) { return ((Quaternion)obj).w; }
            if (obj is string)
            {
                float v;
                if (float.TryParse((string)obj, out v))
                    return v;
                return 0.0f;
            }

            return 0.0f;
        }

        public static Vector2 ToVector2(object obj)
        {
            if (obj == null) return Vector2.zero;
            if (obj is int) return new Vector2((int)obj, 0);
            if (obj is float) return new Vector2((float)obj, 0);
            if (obj is Vector2) return (Vector2)obj;
            if (obj is Vector3) return new Vector2(((Vector3)obj).x, ((Vector3)obj).y);
            if (obj is Vector4) return new Vector2(((Vector3)obj).x, ((Vector3)obj).y);
            if (obj is Vector2Int) return new Vector2(((Vector2Int)obj).x, ((Vector2Int)obj).y);
            if (obj is Vector3Int) return new Vector2(((Vector2Int)obj).x, ((Vector2Int)obj).y);
            if (obj is Color) return new Vector2(((Color)obj).r, ((Color)obj).g);
            if (obj is Quaternion) return new Vector2(((Quaternion)obj).x, ((Quaternion)obj).y);

            if (obj is string)
            {
                float v1 = 0; float v2 = 0;
                string s = (string)obj;
                if (s.Contains(","))
                {
                    string[] substrings = s.Split(',');
                    float.TryParse(substrings[0], out v1);
                    if (substrings.Length > 1)
                        float.TryParse((substrings[1]), out v2);
                    return new Vector2(v1, v2);
                }
                float.TryParse(s, out v1);
                return new Vector2(v1, v2);
            }

            return Vector2.zero;
        }

        public static Vector3 ToVector3(object obj)
        {
            if (obj == null) return Vector3.zero;
            if (obj is int) return new Vector3((int)obj, 0, 0);
            if (obj is float) return new Vector3((float)obj, 0, 0);
            if (obj is Vector2) return new Vector3(((Vector2)obj).x, ((Vector2)obj).y, 0);
            if (obj is Vector3) return (Vector3)obj;
            if (obj is Vector4) return new Vector3(((Vector4)obj).x, ((Vector4)obj).y, ((Vector4)obj).z);
            if (obj is Vector2Int) return new Vector3(((Vector2Int)obj).x, ((Vector2Int)obj).y);
            if (obj is Vector3Int) return new Vector3(((Vector3Int)obj).x, ((Vector3Int)obj).y, ((Vector3Int)obj).z);
            if (obj is Color) return new Vector3(((Color)obj).r, ((Color)obj).g, ((Color)obj).b);
            if (obj is Quaternion) return new Vector3(((Quaternion)obj).x, ((Quaternion)obj).y, ((Quaternion)obj).z);

            if (obj is string)
            {
                float v1 = 0; float v2 = 0; float v3 = 0;
                string s = (string)obj;
                if (s.Contains(","))
                {
                    string[] substrings = s.Split(',');
                    float.TryParse(substrings[0], out v1);
                    if (substrings.Length > 1)
                        float.TryParse((substrings[1]), out v2);
                    if (substrings.Length > 2)
                        float.TryParse((substrings[2]), out v3);
                    return new Vector3(v1, v2, v3);
                }
                float.TryParse(s, out v1);
                return new Vector3(v1, v2, v3);
            }

            return Vector3.zero;
        }

        public static Vector4 ToVector4(object obj)
        {
            if (obj == null) return Vector4.zero;
            if (obj is int) return new Vector4((int)obj, 0, 0, 0);
            if (obj is float) return new Vector4((float)obj, 0, 0, 0);
            if (obj is Vector2) return new Vector4(((Vector2)obj).x, ((Vector2)obj).y, 0);
            if (obj is Vector3) return new Vector4(((Vector3)obj).x, ((Vector3)obj).y, ((Vector3)obj).z, 0.0f);
            if (obj is Vector4) return (Vector4)obj;
            if (obj is Vector2Int) return new Vector4(((Vector2Int)obj).x, ((Vector2Int)obj).y, 0, 0);
            if (obj is Vector3Int) return new Vector4(((Vector3Int)obj).x, ((Vector3Int)obj).y, ((Vector3Int)obj).z, 0);
            if (obj is Color) return new Vector4(((Color)obj).r, ((Color)obj).g, ((Color)obj).b, ((Color)obj).a);
            if (obj is Quaternion) return new Vector4(((Quaternion)obj).x, ((Quaternion)obj).y, ((Quaternion)obj).z, ((Quaternion)obj).w);

            if (obj is string)
            {
                float v1 = 0; float v2 = 0; float v3 = 0; float v4 = 0;
                string s = (string)obj;
                if (s.Contains(","))
                {
                    string[] substrings = s.Split(',');
                    float.TryParse(substrings[0], out v1);
                    if (substrings.Length > 1)
                        float.TryParse((substrings[1]), out v2);
                    if (substrings.Length > 2)
                        float.TryParse((substrings[2]), out v3);
                    if (substrings.Length > 3)
                        float.TryParse((substrings[3]), out v4);

                    return new Vector4(v1, v2, v3, v4);
                }
                float.TryParse(s, out v1);
                return new Vector4(v1, v2, v3, v4);
            }

            return Vector4.zero;
        }

        public static Vector2Int ToVector2Int(object obj)
        {
            if (obj == null) return Vector2Int.zero;
            if (obj is int) return new Vector2Int((int)obj, 0);
            if (obj is float) return new Vector2Int(Mathf.RoundToInt((float)obj), 0);
            if (obj is Vector2) return new Vector2Int(
                Mathf.RoundToInt(((Vector2)obj).x),
                Mathf.RoundToInt(((Vector2)obj).y));
            if (obj is Vector3) return new Vector2Int(
                Mathf.RoundToInt(((Vector3)obj).x),
                Mathf.RoundToInt(((Vector3)obj).y));
            if (obj is Vector4) return new Vector2Int(
                            Mathf.RoundToInt(((Vector2)obj).x),
                            Mathf.RoundToInt(((Vector2)obj).y));

            if (obj is Vector2Int) return ((Vector2Int)obj);
            if (obj is Vector3Int) return new Vector2Int(((Vector2Int)obj).x, ((Vector2Int)obj).y);
            if (obj is Color) return new Vector2Int(
                Mathf.RoundToInt(((Color)obj).r),
                Mathf.RoundToInt(((Color)obj).g));
            if (obj is Quaternion) return new Vector2Int(
                Mathf.RoundToInt(((Quaternion)obj).x),
                Mathf.RoundToInt(((Quaternion)obj).y));
            if (obj is string)
            {
                int v1 = 0; int v2 = 0;
                string s = (string)obj;
                if (s.Contains(","))
                {
                    string[] substrings = s.Split(',');
                    int.TryParse(substrings[0], out v1);
                    if (substrings.Length > 1)
                        int.TryParse((substrings[1]), out v2);
                    return new Vector2Int(v1, v2);
                }
                int.TryParse(s, out v1);
                return new Vector2Int(v1, v2);
            }

            return Vector2Int.zero;
        }

        public static Vector3Int ToVector3Int(object obj)
        {
            if (obj == null) return Vector3Int.zero;
            if (obj is int) return new Vector3Int((int)obj, 0);
            if (obj is float) return new Vector3Int(Mathf.RoundToInt((float)obj), 0);
            if (obj is Vector2) return new Vector3Int(
                Mathf.RoundToInt(((Vector3)obj).x),
                Mathf.RoundToInt(((Vector3)obj).y),
                0);
            if (obj is Vector3) return new Vector3Int(
                Mathf.RoundToInt(((Vector3)obj).x),
                Mathf.RoundToInt(((Vector3)obj).y),
                Mathf.RoundToInt(((Vector3)obj).z));
            if (obj is Vector4) return new Vector3Int(
                            Mathf.RoundToInt(((Vector4)obj).x),
                            Mathf.RoundToInt(((Vector4)obj).y),
                            Mathf.RoundToInt(((Vector4)obj).z));

            if (obj is Vector2Int) return new Vector3Int(((Vector2Int)obj).x, ((Vector2Int)obj).y);
            if (obj is Vector3Int) return ((Vector3Int)obj);
            if (obj is Color) return new Vector3Int(
                Mathf.RoundToInt(((Color)obj).r),
                Mathf.RoundToInt(((Color)obj).g),
                Mathf.RoundToInt(((Color)obj).b));
            if (obj is Quaternion) return new Vector3Int(
                Mathf.RoundToInt(((Quaternion)obj).x),
                Mathf.RoundToInt(((Quaternion)obj).y),
                Mathf.RoundToInt(((Quaternion)obj).z));
            if (obj is string)
            {
                int v1 = 0; int v2 = 0; int v3 = 0;
                string s = (string)obj;
                if (s.Contains(","))
                {
                    string[] substrings = s.Split(',');
                    int.TryParse(substrings[0], out v1);
                    if (substrings.Length > 1)
                        int.TryParse((substrings[1]), out v2);
                    if (substrings.Length > 2)
                        int.TryParse((substrings[2]), out v3);
                    return new Vector3Int(v1, v2, v3);
                }
                int.TryParse(s, out v1);
                return new Vector3Int(v1, v2, v3);
            }

            return Vector3Int.zero;
        }

        public static Color ToColor(object obj)
        {
            if (obj == null) return Color.black;
            if (obj is int) return new Color((int)obj, 0, 0, 0);
            if (obj is float) return new Color((float)obj, 0, 0, 0);
            if (obj is Vector2) return new Color(((Vector2)obj).x, ((Vector2)obj).y, 0);
            if (obj is Vector3) return new Color(((Vector3)obj).x, ((Vector3)obj).y, ((Vector3)obj).z, 0.0f);
            if (obj is Vector4) return new Color(((Vector4)obj).x, ((Vector4)obj).y, ((Vector4)obj).z, ((Vector4)obj).w);
            if (obj is Vector2Int) return new Color(((Vector2Int)obj).x, ((Vector2Int)obj).y, 0, 0);
            if (obj is Vector3Int) return new Color(((Vector3Int)obj).x, ((Vector3Int)obj).y, ((Vector3Int)obj).z, 0);
            if (obj is Color) return new Color(((Color)obj).r, ((Color)obj).g, ((Color)obj).b, ((Color)obj).a);
            if (obj is Quaternion) return new Color(((Quaternion)obj).x, ((Quaternion)obj).y, ((Quaternion)obj).z, ((Quaternion)obj).w);

            if (obj is string)
            {
                float v1 = 0; float v2 = 0; float v3 = 0; float v4 = 0;
                string s = (string)obj;
                if (s.Contains(","))
                {
                    string[] substrings = s.Split(',');
                    float.TryParse(substrings[0], out v1);
                    if (substrings.Length > 1)
                        float.TryParse((substrings[1]), out v2);
                    if (substrings.Length > 2)
                        float.TryParse((substrings[2]), out v3);
                    if (substrings.Length > 3)
                        float.TryParse((substrings[3]), out v4);

                    return new Vector4(v1, v2, v3, v4);
                }
                float.TryParse(s, out v1);
                return new Vector4(v1, v2, v3, v4);
            }

            return Vector4.zero;
        }

        public static Quaternion ToQuaternion(object obj)
        {
            if (obj == null) return Quaternion.identity;
            if (obj is int) return new Quaternion((int)obj, 0, 0, 0);
            if (obj is float) return new Quaternion((float)obj, 0, 0, 0);
            if (obj is Vector2) return new Quaternion(((Vector2)obj).x, ((Vector2)obj).y, 0, 0);
            if (obj is Vector3) return new Quaternion(((Vector3)obj).x, ((Vector3)obj).y, ((Vector3)obj).z, 0.0f);
            if (obj is Vector4) return new Quaternion(((Vector4)obj).x, ((Vector4)obj).y, ((Vector4)obj).z, ((Vector4)obj).w);
            if (obj is Vector2Int) return new Quaternion(((Vector2Int)obj).x, ((Vector2Int)obj).y, 0, 0);
            if (obj is Vector3Int) return new Quaternion(((Vector3Int)obj).x, ((Vector3Int)obj).y, ((Vector3Int)obj).z, 0);
            if (obj is Color) return new Quaternion(((Color)obj).r, ((Color)obj).g, ((Color)obj).b, ((Color)obj).a);
            if (obj is Quaternion) return new Quaternion(((Quaternion)obj).x, ((Quaternion)obj).y, ((Quaternion)obj).z, ((Quaternion)obj).w);

            if (obj is string)
            {
                float v1 = 0; float v2 = 0; float v3 = 0; float v4 = 0;
                string s = (string)obj;
                if (s.Contains(","))
                {
                    string[] substrings = s.Split(',');
                    float.TryParse(substrings[0], out v1);
                    if (substrings.Length > 1)
                        float.TryParse((substrings[1]), out v2);
                    if (substrings.Length > 2)
                        float.TryParse((substrings[2]), out v3);
                    if (substrings.Length > 3)
                        float.TryParse((substrings[3]), out v4);

                    return new Quaternion(v1, v2, v3, v4);
                }
                float.TryParse(s, out v1);
                return new Quaternion(v1, v2, v3, v4);
            }

            return Quaternion.identity;
        }

        public static string ToString(object obj)
        {
            string s = string.Empty;
            if (obj == null)
                return s;
            try
            {
                s = obj.ToString();
            }
            catch
            {
            }

            return s;
        }
    }

}