using System;

using UnityEngine;

namespace AhahGames.GenesisNoise.Nodes
{
    static class MathOperationUtility
    {
        public static bool TryPassthroughMissingBinaryInput(object inputA, object inputB, out object output)
        {
            if (inputA == null && inputB == null)
            {
                output = null;
                return true;
            }

            if (inputA == null)
            {
                output = inputB;
                return true;
            }

            if (inputB == null)
            {
                output = inputA;
                return true;
            }

            output = null;
            return false;
        }

        public static object ApplyBinaryOperation(
            object inputA,
            object inputB,
            Func<bool, bool, bool> boolOperation,
            Func<float, float, float> floatOperation,
            Func<int, int, int> intOperation,
            Func<string, string, string> stringOperation = null)
        {
            Type outputType = TypeCaster.LargerType(inputA, inputB);

            if (outputType == typeof(bool))
            {
                return boolOperation(
                    (bool)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.BOOL),
                    (bool)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.BOOL));
            }

            if (outputType == typeof(float))
            {
                return floatOperation(
                    (float)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.FLOAT),
                    (float)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.FLOAT));
            }

            if (outputType == typeof(int))
            {
                return intOperation(
                    (int)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.INT),
                    (int)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.INT));
            }

            if (outputType == typeof(Vector2))
            {
                Vector2 a = (Vector2)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR2);
                Vector2 b = (Vector2)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR2);
                return new Vector2(floatOperation(a.x, b.x), floatOperation(a.y, b.y));
            }

            if (outputType == typeof(Vector3))
            {
                Vector3 a = (Vector3)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR3);
                Vector3 b = (Vector3)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR3);
                return new Vector3(floatOperation(a.x, b.x), floatOperation(a.y, b.y), floatOperation(a.z, b.z));
            }

            if (outputType == typeof(Vector4))
            {
                Vector4 a = (Vector4)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR4);
                Vector4 b = (Vector4)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR4);
                return new Vector4(
                    floatOperation(a.x, b.x),
                    floatOperation(a.y, b.y),
                    floatOperation(a.z, b.z),
                    floatOperation(a.w, b.w));
            }

            if (outputType == typeof(Vector2Int))
            {
                Vector2Int a = (Vector2Int)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR2INT);
                Vector2Int b = (Vector2Int)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR2INT);
                return new Vector2Int(intOperation(a.x, b.x), intOperation(a.y, b.y));
            }

            if (outputType == typeof(Vector3Int))
            {
                Vector3Int a = (Vector3Int)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR3INT);
                Vector3Int b = (Vector3Int)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR3INT);
                return new Vector3Int(intOperation(a.x, b.x), intOperation(a.y, b.y), intOperation(a.z, b.z));
            }

            if (outputType == typeof(Quaternion))
            {
                Quaternion a = (Quaternion)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.QUATERNION);
                Quaternion b = (Quaternion)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.QUATERNION);
                return new Quaternion(
                    floatOperation(a.x, b.x),
                    floatOperation(a.y, b.y),
                    floatOperation(a.z, b.z),
                    floatOperation(a.w, b.w));
            }

            if (outputType == typeof(Color))
            {
                Color a = (Color)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.COLOR);
                Color b = (Color)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.COLOR);
                return new Color(
                    floatOperation(a.r, b.r),
                    floatOperation(a.g, b.g),
                    floatOperation(a.b, b.b),
                    floatOperation(a.a, b.a));
            }

            string stringA = (string)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.STRING);
            string stringB = (string)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.STRING);
            return stringOperation != null ? stringOperation(stringA, stringB) : stringA + stringB;
        }

        public static object ClampValue(object value, object min, object max)
        {
            if (value == null || min == null || max == null)
                return null;

            Type outputType = value.GetType();

            if (outputType == typeof(bool))
                return (bool)TypeCaster.ToType(value, TypeCaster.genesisTypes.BOOL);

            if (outputType == typeof(float))
            {
                return Mathf.Clamp(
                    (float)TypeCaster.ToType(value, TypeCaster.genesisTypes.FLOAT),
                    (float)TypeCaster.ToType(min, TypeCaster.genesisTypes.FLOAT),
                    (float)TypeCaster.ToType(max, TypeCaster.genesisTypes.FLOAT));
            }

            if (outputType == typeof(int))
            {
                return Mathf.Clamp(
                    (int)TypeCaster.ToType(value, TypeCaster.genesisTypes.INT),
                    (int)TypeCaster.ToType(min, TypeCaster.genesisTypes.INT),
                    (int)TypeCaster.ToType(max, TypeCaster.genesisTypes.INT));
            }

            if (outputType == typeof(Vector2))
            {
                Vector2 v = (Vector2)TypeCaster.ToType(value, TypeCaster.genesisTypes.VECTOR2);
                Vector2 minValue = (Vector2)TypeCaster.ToType(min, TypeCaster.genesisTypes.VECTOR2);
                Vector2 maxValue = (Vector2)TypeCaster.ToType(max, TypeCaster.genesisTypes.VECTOR2);
                return new Vector2(
                    Mathf.Clamp(v.x, minValue.x, maxValue.x),
                    Mathf.Clamp(v.y, minValue.y, maxValue.y));
            }

            if (outputType == typeof(Vector3))
            {
                Vector3 v = (Vector3)TypeCaster.ToType(value, TypeCaster.genesisTypes.VECTOR3);
                Vector3 minValue = (Vector3)TypeCaster.ToType(min, TypeCaster.genesisTypes.VECTOR3);
                Vector3 maxValue = (Vector3)TypeCaster.ToType(max, TypeCaster.genesisTypes.VECTOR3);
                return new Vector3(
                    Mathf.Clamp(v.x, minValue.x, maxValue.x),
                    Mathf.Clamp(v.y, minValue.y, maxValue.y),
                    Mathf.Clamp(v.z, minValue.z, maxValue.z));
            }

            if (outputType == typeof(Vector4))
            {
                Vector4 v = (Vector4)TypeCaster.ToType(value, TypeCaster.genesisTypes.VECTOR4);
                Vector4 minValue = (Vector4)TypeCaster.ToType(min, TypeCaster.genesisTypes.VECTOR4);
                Vector4 maxValue = (Vector4)TypeCaster.ToType(max, TypeCaster.genesisTypes.VECTOR4);
                return new Vector4(
                    Mathf.Clamp(v.x, minValue.x, maxValue.x),
                    Mathf.Clamp(v.y, minValue.y, maxValue.y),
                    Mathf.Clamp(v.z, minValue.z, maxValue.z),
                    Mathf.Clamp(v.w, minValue.w, maxValue.w));
            }

            if (outputType == typeof(Vector2Int))
            {
                Vector2Int v = (Vector2Int)TypeCaster.ToType(value, TypeCaster.genesisTypes.VECTOR2INT);
                Vector2Int minValue = (Vector2Int)TypeCaster.ToType(min, TypeCaster.genesisTypes.VECTOR2INT);
                Vector2Int maxValue = (Vector2Int)TypeCaster.ToType(max, TypeCaster.genesisTypes.VECTOR2INT);
                return new Vector2Int(
                    Mathf.Clamp(v.x, minValue.x, maxValue.x),
                    Mathf.Clamp(v.y, minValue.y, maxValue.y));
            }

            if (outputType == typeof(Vector3Int))
            {
                Vector3Int v = (Vector3Int)TypeCaster.ToType(value, TypeCaster.genesisTypes.VECTOR3INT);
                Vector3Int minValue = (Vector3Int)TypeCaster.ToType(min, TypeCaster.genesisTypes.VECTOR3INT);
                Vector3Int maxValue = (Vector3Int)TypeCaster.ToType(max, TypeCaster.genesisTypes.VECTOR3INT);
                return new Vector3Int(
                    Mathf.Clamp(v.x, minValue.x, maxValue.x),
                    Mathf.Clamp(v.y, minValue.y, maxValue.y),
                    Mathf.Clamp(v.z, minValue.z, maxValue.z));
            }

            if (outputType == typeof(Quaternion))
            {
                Quaternion v = (Quaternion)TypeCaster.ToType(value, TypeCaster.genesisTypes.QUATERNION);
                Quaternion minValue = (Quaternion)TypeCaster.ToType(min, TypeCaster.genesisTypes.QUATERNION);
                Quaternion maxValue = (Quaternion)TypeCaster.ToType(max, TypeCaster.genesisTypes.QUATERNION);
                return new Quaternion(
                    Mathf.Clamp(v.x, minValue.x, maxValue.x),
                    Mathf.Clamp(v.y, minValue.y, maxValue.y),
                    Mathf.Clamp(v.z, minValue.z, maxValue.z),
                    Mathf.Clamp(v.w, minValue.w, maxValue.w));
            }

            if (outputType == typeof(Color))
            {
                Color v = (Color)TypeCaster.ToType(value, TypeCaster.genesisTypes.COLOR);
                Color minValue = (Color)TypeCaster.ToType(min, TypeCaster.genesisTypes.COLOR);
                Color maxValue = (Color)TypeCaster.ToType(max, TypeCaster.genesisTypes.COLOR);
                return new Color(
                    Mathf.Clamp(v.r, minValue.r, maxValue.r),
                    Mathf.Clamp(v.g, minValue.g, maxValue.g),
                    Mathf.Clamp(v.b, minValue.b, maxValue.b),
                    Mathf.Clamp(v.a, minValue.a, maxValue.a));
            }

            return (string)TypeCaster.ToType(value, TypeCaster.genesisTypes.STRING);
        }
    }
}
