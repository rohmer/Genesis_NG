using AhahGames.GenesisNoise.Utility;

using GraphProcessor;

using System;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Raises the input to a power.
")]

    [System.Serializable, NodeMenuItem("Function/Math/Pow")]
    public class PowNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;
        [Input(name = "B")]
        public object inputB;

        [Output]
        public object output;
        public override string name => "Pow";
        public override string NodeGroup => "Math";
        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA != null && inputB == null)
            {
                output = inputA;
                return true;
            }
            if (inputA == null && inputB == null)
            {
                output = inputB;
                return true;
            }

            Type outputType = TypeCaster.LargerType(inputA, inputB);

            if (outputType == typeof(bool))
            {
                bool t1 = (bool)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.BOOL);
                bool t2 = (bool)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.BOOL);
                output = t1 && t2;
            }
            if (outputType == typeof(float))
            {
                float t1 = (float)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.FLOAT);
                float t2 = (float)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.FLOAT);
                output = MathF.Pow(t1, t2);
            }
            if (outputType == typeof(int))
            {
                int t1 = (int)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.INT);
                int t2 = (int)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.INT);
                output = (int)MathF.Pow(t1, t2);
            }
            if (outputType == typeof(Vector2))
            {
                Vector2 t1 = (Vector2)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR2);
                Vector2 t2 = (Vector2)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR2);
                output = new Vector2(MathF.Pow(t1.x, t2.x), MathF.Pow(t1.y, t2.y));
            }
            if (outputType == typeof(Vector3))
            {
                Vector3 t1 = (Vector3)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR3);
                Vector3 t2 = (Vector3)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR3);
                output = new Vector3(MathF.Pow(t1.x, t2.x), MathF.Pow(t1.y, t2.y), MathF.Pow(t1.z,t2.z));
            }
            if (outputType == typeof(Vector4))
            {
                Vector4 t1 = (Vector4)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR4);
                Vector4 t2 = (Vector4)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR4);
                output = new Vector4(MathF.Pow(t1.x, t2.x), MathF.Pow(t1.y, t2.y), MathF.Pow(t1.z, t2.z), MathF.Pow(t1.w,t2.w));
            }
            if (outputType == typeof(Vector2Int))
            {
                Vector2Int t1 = (Vector2Int)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR2INT);
                Vector2Int t2 = (Vector2Int)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR2INT);
                output = new Vector2Int((int)MathF.Pow(t1.x, t2.x), (int)MathF.Pow(t1.y, t2.y));
            }
            if (outputType == typeof(Vector3Int))
            {
                Vector3Int t1 = (Vector3Int)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR3INT);
                Vector3Int t2 = (Vector3Int)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR3INT);
                output = new Vector3Int((int)MathF.Pow(t1.x, t2.x), (int)MathF.Pow(t1.y, t2.y),(int)MathF.Pow(t1.z,t2.z));
            }
            if (outputType == typeof(Quaternion))
            {
                Quaternion t1 = (Quaternion)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR3INT);
                Quaternion t2 = (Quaternion)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR3INT);
                Quaternion o;
                o.x = MathF.Pow(t1.x, t2.x);
                o.y = MathF.Pow(t1.y , t2.y);
                o.z = MathF.Pow(t1.z , t2.z);
                o.w = MathF.Pow(t1.w,t2.w);
                output = o;
            }
            if (outputType == typeof(string))
            {
                string t1 = (string)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.STRING);
                string t2 = (string)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.STRING);
                output = t1 + "pow" + t2;
            }
            if (outputType == typeof(Color))
            {
                Color t1 = (Color)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.COLOR);
                Color t2 = (Color)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.COLOR);
                output = new Color(MathF.Pow(t1.r, t2.r), MathF.Pow(t1.g, t2.g), MathF.Pow(t1.b, t2.b), MathF.Pow(t1.a,t2.a));
            }
            return true;
        }
    }
}
