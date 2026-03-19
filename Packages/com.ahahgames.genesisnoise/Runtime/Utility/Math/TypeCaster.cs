using System;

using UnityEngine;
using UnityEngine.Assertions.Must;

namespace AhahGames.GenesisNoise
{
    public static class TypeCaster
    {
        public enum genesisTypes
        {
            BOOL,
            INT,
            FLOAT,
            VECTOR2INT,
            VECTOR2,
            VECTOR3INT,
            VECTOR3,
            COLOR,
            VECTOR4,
            QUATERNION,
            STRING
        }

        public static genesisTypes GetType(object A)
        {
            if(A is bool)
                return genesisTypes.BOOL;
            if(A is int)
                return genesisTypes.INT;
            if (A is float)
                return genesisTypes.FLOAT;
            if (A is Vector2Int)
                return genesisTypes.VECTOR2INT;
            if (A is Vector2)
                return genesisTypes.VECTOR2;
            if (A is Vector3Int)
                return genesisTypes.VECTOR3INT;
            if (A is Vector3)
                return genesisTypes.VECTOR3;
            if (A is Color)
                return genesisTypes.COLOR;
            if (A is Quaternion)
                return genesisTypes.QUATERNION;
            if (A is Vector4)
                return genesisTypes.VECTOR4;
            return genesisTypes.STRING;
        }

        public static Type ToType(genesisTypes t)
        {
            switch(t)
            {
                case genesisTypes.BOOL:
                    return typeof(bool);
                case genesisTypes.QUATERNION:
                    return typeof(Quaternion);
                case genesisTypes.VECTOR4:
                    return typeof(Vector4);
                case genesisTypes.STRING:
                    return typeof(string);
                case genesisTypes.FLOAT:
                    return typeof(float);
                case genesisTypes.VECTOR2:
                    return typeof(Vector2);
                case genesisTypes.VECTOR3:
                    return typeof(Vector3);
                case genesisTypes.VECTOR3INT:
                    return typeof(Vector3Int);
                case genesisTypes.VECTOR2INT:
                    return typeof(Vector2Int);
                case genesisTypes.COLOR:
                    return typeof(Color);
                case genesisTypes.INT:
                    return typeof(int);
            }
            return typeof(string);
        }

        public static Type LargerType(object A, object B)
        {
            genesisTypes aType, bType;
            aType = GetType(A);
            bType = GetType(B);

            if (aType >= bType)
                return ToType(aType);
            return ToType(bType);
        }

        public static int ToInt(object A)
        {
            Type type = A.GetType();
            if (type == typeof(int))
                return (int)A;
            if (type == typeof(float))
                return Mathf.RoundToInt((float)A);
            if (type == typeof(Vector2))
            {
                Vector2 v = (Vector2)A;
                return Mathf.RoundToInt(v.x);
            }
            if (type == typeof(Vector2Int))
            {
                Vector2Int v = (Vector2Int)A;
                return v.x;
            }
            if (type == typeof(Vector3))
            {
                Vector3 v = (Vector3)A;
                return Mathf.RoundToInt(v.x);
            }
            if (type == typeof(Vector3Int))
            {
                Vector3Int v = (Vector3Int)A;
                return Mathf.RoundToInt(v.x);
            }
            if (type == typeof(Vector4))
            {
                Vector4 v = (Vector4)A;
                return Mathf.RoundToInt(v.x);
            }
            if (type == typeof(Quaternion))
            {
                Quaternion v = (Quaternion)A;
                return Mathf.RoundToInt(v.x);
            }
            if (type == typeof(Color))
            {
                Color v = (Color)A;
                return Mathf.RoundToInt(v.r);
            }
            if (type == typeof(string))
            {
                string v = (string)A;
                int result;
                if (Int32.TryParse(v, out result))
                {
                    return result;
                }
                return 0;
            }

            return 0;
        }

        public static bool ToBool(object A)
        {
            Type type = A.GetType();
            if (type == typeof(bool))
                return (bool)A;
            if(type==typeof(string))
            {
                int len = ((string)A).Length;
                if (len > 0)
                    return true;
                return false;
            }
            if(type==typeof(int))
            {
                if ((int)A > 0)
                    return true;
                return false;
            }
            if(type== typeof(float))
            {
                if((float)A > 0) return true;
                return false;
            }
            if(type==typeof(Vector2))
            {
                Vector2 v=(Vector2)A;
                if (v.x > 0 && v.y > 0)
                    return true;
                return false;
            }
            if (type == typeof(Vector2Int))
            {
                Vector2Int v = (Vector2Int)A;
                if (v.x > 0 && v.y > 0)
                    return true;
                return false;
            }
            if (type == typeof(Vector3))
            {
                Vector3 v = (Vector3)A;
                if (v.x > 0 && v.y > 0 && v.z>0)
                    return true;
                return false;
            }
            if (type == typeof(Vector3Int))
            {
                Vector3Int v = (Vector3Int)A;
                if (v.x > 0 && v.y > 0 && v.z > 0)
                    return true;
                return false;
            }
            if (type == typeof(Vector4))
            {
                Vector4 v = (Vector4)A;
                if (v.x > 0 && v.y > 0 && v.z > 0 && v.w>0)
                    return true;
                return false;
            }
            if (type == typeof(Quaternion))
            {
                Quaternion v = (Quaternion)A;
                if (v.x > 0 && v.y > 0 && v.z > 0 && v.w > 0)
                    return true;
                return false;
            }
            if (type == typeof(Color))
            {
                Color v = (Color)A;
                if (v.r > 0 && v.g > 0 && v.b > 0 && v.a > 0)
                    return true;
                return false;
            }

            return false;
        }        

        public static float ToFloat(object A)
        {
            Type type = A.GetType();
            if (type == typeof(int))
            {
                float v=(int)A;
                return v;
            }
            if(type==typeof(bool))
            {
                if ((bool)A == true)
                    return 1;
                return 0;
            }
            if (type == typeof(float))
                return (float)A;
            if (type == typeof(Vector2))
            {
                Vector2 v = (Vector2)A;
                return v.x;
            }
            if (type == typeof(Vector2Int))
            {
                Vector2Int v = (Vector2Int)A;
                return (float)v.x;
            }
            if (type == typeof(Vector3))
            {
                Vector3 v = (Vector3)A;
                return v.x;
            }
            if (type == typeof(Vector3Int))
            {
                Vector3Int v = (Vector3Int)A;
                return (float)v.x;
            }
            if (type == typeof(Vector4))
            {
                Vector4 v = (Vector4)A;
                return v.x;
            }
            if (type == typeof(Quaternion))
            {
                Quaternion v = (Quaternion)A;
                return v.x;
            }
            if (type == typeof(Color))
            {
                Color v = (Color)A;
                return (float)v.r;
            }
            if (type == typeof(string))
            {
                string v = (string)A;
                float result;
                if (float.TryParse(v, out result))
                {
                    return result;
                }
                return 0;
            }

            return 0;
        }

        public static Vector2 ToVector2(object A)
        {
            Type type = A.GetType();
            if (type == typeof(Vector2))
                return (Vector2)A;
            if(type==typeof(bool))
            {
                int v = 0;
                if ((bool)A)
                    v = 1;
                return new Vector2(v, 0);
            }
            if(type==typeof(int))
            {
                int v = ((int)A);
                return new Vector2(v, 0);
            }
            if (type == typeof(float))
            {
                float v = ((float)A);
                return new Vector2(v, 0);
            }
            if(type==typeof(Vector2Int))
            {
                return new Vector2(((Vector2Int)A).x, ((Vector2Int)A).y);
            }
            if (type == typeof(Vector3))
            {
                return new Vector2(((Vector3)A).x, ((Vector3)A).y);
            }
            if (type == typeof(Vector3Int))
            {
                return new Vector2(((Vector3Int)A).x, ((Vector3Int)A).y);
            }
            if (type == typeof(Vector4))
            {
                return new Vector2(((Vector4)A).x, ((Vector4)A).y);
            }
            if (type == typeof(Quaternion))
            {
                return new Vector2(((Quaternion)A).x, ((Quaternion)A).y);
            }
            if (type == typeof(Color))
            {
                return new Vector2(((Color)A).r, ((Color)A).g);
            }
            if(type==typeof(string))
            {
                float v;
                if(float.TryParse((string)A, out v))
                {
                    return new Vector2(v, 0);
                }
                return Vector2.zero;
            }
            return Vector2.zero;
        }

        public static Vector2Int ToVector2Int(object A)
        {
            Type type = A.GetType();
            if (type == typeof(Vector2Int))
                return (Vector2Int)A;
            if (type == typeof(bool))
            {
                int v = 0;
                if ((bool)A)
                    v = 1;
                return new Vector2Int(v, 0);
            }
            if (type == typeof(int))
            {
                int v = ((int)A);
                return new Vector2Int(v, 0);
            }
            if (type == typeof(float))
            {
                float v = ((float)A);
                return new Vector2Int(Mathf.RoundToInt(v), 0);
            }
            if (type == typeof(Vector2Int))
            {
                return new Vector2Int(((Vector2Int)A).x, ((Vector2Int)A).y);
            }
            if (type == typeof(Vector3))
            {
                return new Vector2Int(Mathf.RoundToInt(((Vector3)A).x), Mathf.RoundToInt(((Vector3)A).y));
            }
            if (type == typeof(Vector3Int))
            {
                return new Vector2Int(((Vector3Int)A).x, ((Vector3Int)A).y);
            }
            if (type == typeof(Vector4))
            {
                return new Vector2Int(Mathf.RoundToInt(((Vector4)A).x), Mathf.RoundToInt(((Vector4)A).y));
            }
            if (type == typeof(Quaternion))
            {
                return new Vector2Int(Mathf.RoundToInt(((Quaternion)A).x), Mathf.RoundToInt(((Quaternion)A).y));
            }
            if (type == typeof(Color))
            {
                return new Vector2Int(Mathf.RoundToInt(((Color)A).r), Mathf.RoundToInt(((Color)A).g));
            }
            if (type == typeof(string))
            {
                int v;
                if (int.TryParse((string)A, out v))
                {
                    return new Vector2Int(v, 0);
                }
                return Vector2Int.zero;
            }
            return Vector2Int.zero;
        }

        public static Vector3 ToVector3(object A)
        {
            Type type = A.GetType();
            if (type == typeof(Vector3))
                return (Vector3)A;
            if (type == typeof(bool))
            {
                int v = 0;
                if ((bool)A)
                    v = 1;
                return new Vector3(v, 0);
            }
            if (type == typeof(int))
            {
                int v = ((int)A);
                return new Vector3(v, 0);
            }
            if (type == typeof(float))
            {
                float v = ((float)A);
                return new Vector3(v, 0);
            }
            if (type == typeof(Vector2Int))
            {
                return new Vector3(((Vector2Int)A).x, ((Vector2Int)A).y,0);
            }
            if (type == typeof(Vector3Int))
            {
                return new Vector3(((Vector3Int)A).x, ((Vector3Int)A).y,((Vector3Int)A).z);
            }
            if (type == typeof(Vector4))
            {
                return new Vector3(((Vector4)A).x, ((Vector4)A).y,((Vector4)A).z);
            }
            if (type == typeof(Quaternion))
            {
                return new Vector3(((Quaternion)A).x, ((Quaternion)A).y,((Quaternion)A).z);
            }
            if (type == typeof(Color))
            {
                return new Vector3(((Color)A).r, ((Color)A).g,((Color)A).b);
            }
            if (type == typeof(string))
            {
                float v;
                if (float.TryParse((string)A, out v))
                {
                    return new Vector3(v, 0);
                }
                return Vector3.zero;
            }

            return Vector3.zero;
        }

        public static Vector3Int ToVector3Int(object A)
        {
            Type type = A.GetType();
            if (type == typeof(Vector3Int))
                return (Vector3Int)A;
            if (type == typeof(bool))
            {
                int v = 0;
                if ((bool)A)
                    v = 1;
                return new Vector3Int(v, 0);
            }
            if (type == typeof(int))
            {
                int v = ((int)A);
                return new Vector3Int(v, 0);
            }
            if (type == typeof(float))
            {
                float v = ((float)A);
                return new Vector3Int(Mathf.RoundToInt(v), 0);
            }
            if (type == typeof(Vector2Int))
            {
                return new Vector3Int(((Vector2Int)A).x, ((Vector2Int)A).y);
            }
            if (type == typeof(Vector3))
            {
                return new Vector3Int(
                    Mathf.RoundToInt(((Vector3)A).x),
                    Mathf.RoundToInt(((Vector3)A).y),
                    Mathf.RoundToInt(((Vector3)A).z));
            }
            if (type == typeof(Vector4))
            {
                return new Vector3Int(
                Mathf.RoundToInt(((Vector4)A).x),
                Mathf.RoundToInt(((Vector4)A).y),
                Mathf.RoundToInt(((Vector4)A).z));
            }
            if (type == typeof(Quaternion))
            {
                return new Vector3Int(
                Mathf.RoundToInt(((Quaternion)A).x),
                Mathf.RoundToInt(((Quaternion)A).y),
                Mathf.RoundToInt(((Quaternion)A).z));
            }
            if (type == typeof(Color))
            {
                return new Vector3Int(Mathf.RoundToInt(((Color)A).r), Mathf.RoundToInt(((Color)A).g),Mathf.RoundToInt(((Color)A).b));
            }
            if (type == typeof(string))
            {
                int v;
                if (int.TryParse((string)A, out v))
                {
                    return new Vector3Int(v, 0);
                }
                return Vector3Int.zero;
            }
            return Vector3Int.zero;
        }

        public static Color ToColor(object A)
        {
            Type type = A.GetType();
            if (type == typeof(Color))
                return (Color)A;
            if (type == typeof(bool))
            {
                int v = 0;
                if ((bool)A)
                    v = 1;
                return new Color(v, 0,0);
            }
            if (type == typeof(int))
            {
                int v = ((int)A);
                return new Color(v, 0,0);
            }
            if (type == typeof(float))
            {
                float v = ((float)A);
                return new Color(v, 0,0);
            }
            if (type == typeof(Vector2Int))
            {
                return new Color(((Vector2Int)A).x, ((Vector2Int)A).y, 0);
            }
            if (type == typeof(Vector3Int))
            {
                return new Color(((Vector3Int)A).x, ((Vector3Int)A).y, ((Vector3Int)A).z);
            }
            if (type == typeof(Vector4))
            {
                return new Color(((Vector4)A).x, ((Vector4)A).y, ((Vector4)A).z, ((Vector4)A).w);
            }
            if (type == typeof(Quaternion))
            {
                return new Color(((Quaternion)A).x, ((Quaternion)A).y, ((Quaternion)A).z, ((Quaternion)A).w);
            }
            if (type == typeof(string))
            {
                float v;
                if (float.TryParse((string)A, out v))
                {
                    return new Color(v, 0,0);
                }
                return UnityEngine.Color.black;
            }

            return UnityEngine.Color.black;
        }

        public static Vector4 ToVector4(object A)
        {
            Type type = A.GetType();
            if (type == typeof(Vector4))
                return (Vector4)A;
            if (type == typeof(bool))
            {
                int v = 0;
                if ((bool)A)
                    v = 1;
                return new Vector4(v, 0, 0);
            }
            if(type==typeof(Color))
            {
                Color c = (Color)A;
                return new Vector4(c.r, c.g, c.b, c.a);
            }
            if (type == typeof(int))
            {
                int v = ((int)A);
                return new Vector4(v, 0, 0);
            }
            if (type == typeof(float))
            {
                float v = ((float)A);
                return new Vector4(v, 0, 0);
            }
            if (type == typeof(Vector2Int))
            {
                return new Vector4(((Vector2Int)A).x, ((Vector2Int)A).y, 0);
            }
            if (type == typeof(Vector3Int))
            {
                return new Vector4(((Vector3Int)A).x, ((Vector3Int)A).y, ((Vector3Int)A).z);
            }
            if (type == typeof(Vector4))
            {
                return new Vector4(((Vector4)A).x, ((Vector4)A).y, ((Vector4)A).z, ((Vector4)A).w);
            }
            if (type == typeof(Quaternion))
            {
                return new Vector4(((Quaternion)A).x, ((Quaternion)A).y, ((Quaternion)A).z, ((Quaternion)A).w);
            }
            if (type == typeof(string))
            {
                float v;
                if (float.TryParse((string)A, out v))
                {
                    return new Vector4(v, 0, 0);
                }
                return Vector4.zero;
            }

            return Vector4.zero;
        }

        public static Quaternion ToQuaternion(object A)
        {
            Type type = A.GetType();
            if (type == typeof(Quaternion))
                return (Quaternion)A;
            if (type == typeof(bool))
            {
                int v = 0;
                if ((bool)A)
                    v = 1;
                return new Quaternion(v, 0, 0, 0);
            }
            if (type == typeof(Color))
            {
                Color c = (Color)A;
                return new Quaternion(c.r, c.g, c.b, c.a);
            }
            if (type == typeof(int))
            {
                int v = ((int)A);
                return new Quaternion(v, 0, 0,0);
            }
            if (type == typeof(float))
            {
                float v = ((float)A);
                return new Quaternion(v, 0, 0, 0);
            }
            if (type == typeof(Vector2Int))
            {
                return new Quaternion(((Vector2Int)A).x, ((Vector2Int)A).y, 0, 0);
            }
            if (type == typeof(Vector3Int))
            {
                return new Quaternion(((Vector3Int)A).x, ((Vector3Int)A).y, ((Vector3Int)A).z, 0);
            }
            if (type == typeof(Quaternion))
            {
                return new Quaternion(((Quaternion)A).x, ((Quaternion)A).y, ((Quaternion)A).z, ((Quaternion)A).w);
            }
            if (type == typeof(Quaternion))
            {
                return new Quaternion(((Quaternion)A).x, ((Quaternion)A).y, ((Quaternion)A).z, ((Quaternion)A).w);
            }
            if (type == typeof(string))
            {
                float v;
                if (float.TryParse((string)A, out v))
                {
                    return new Quaternion(v, 0, 0, 0);
                }
                return new Quaternion(0, 0, 0, 0);
            }

            return new Quaternion(0, 0, 0, 0);
        }

        public static string ToString(object A)
        {
            Type type = A.GetType();
            if (type == typeof(string))
                return (string)A;
            if(type==typeof(int))
            {
                return ((int)A).ToString();
            }
            if (type == typeof(float))
            {
                return ((float)A).ToString();
            }
            if (type == typeof(bool))
            {
                return ((bool)A).ToString();
            }
            if (type == typeof(Vector2))
            {
                return ((Vector2)A).ToString();
            }
            if (type == typeof(Vector2Int))
            {
                return ((Vector2Int)A).ToString();
            }
            if (type == typeof(Vector3))
            {
                return ((Vector3)A).ToString();
            }
            if (type == typeof(Vector3Int))
            {
                return ((Vector3Int)A).ToString();
            }
            if (type == typeof(Vector4))
            {
                return ((Vector4)A).ToString();
            }
            if (type == typeof(Quaternion))
            {
                return ((Quaternion)A).ToString();
            }
            if (type == typeof(Color))
            {
                return ((Color)A).ToString();
            }

            return string.Empty;
        }

        public static object ToType(object A, genesisTypes type)
        {
            switch(type)
            {
                case genesisTypes.INT: return ToInt(A);
                case genesisTypes.FLOAT: return ToFloat(A);
                case genesisTypes.BOOL: return ToBool(A);
                case genesisTypes.VECTOR2: return ToVector2(A);
                case genesisTypes.VECTOR2INT: return ToVector2Int(A);
                case genesisTypes.VECTOR3: return ToVector3(A);
                case genesisTypes.VECTOR3INT: return ToVector3Int(A);
                case genesisTypes.COLOR: return ToColor(A);
                case genesisTypes.VECTOR4: return ToVector4(A);
                case genesisTypes.QUATERNION: return ToQuaternion(A);
                case genesisTypes.STRING: return ToString(A);
                default: return string.Empty;
            }

        }
    }
}
