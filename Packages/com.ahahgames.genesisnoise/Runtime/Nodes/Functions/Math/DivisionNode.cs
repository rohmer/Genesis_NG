using AhahGames.GenesisNoise.Utility;

using GraphProcessor;

using System;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Math/Divide")]
    public class DivideNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;
        [Input(name = "B")]
        public object inputB;

        [Output]
        public object output;
        public override string name => "Divide";
        public override string NodeGroup => "Math";
        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA == null || inputB == null)
                return true;
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
                if (t1 && t2)
                    return true;
                return false;
            }
            if (outputType == typeof(float))
            {
                float t1 = (float)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.FLOAT);
                float t2 = (float)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.FLOAT);
                output = t1 / t2;
            }
            if (outputType == typeof(int))
            {
                int t1 = (int)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.INT);
                int t2 = (int)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.INT);
                output = t1 / t2;
            }
            if (outputType == typeof(Vector2))
            {
                Vector2 t1 = (Vector2)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR2);
                Vector2 t2 = (Vector2)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR2);
                output = t1 / t2;
            }
            if (outputType == typeof(Vector3))
            {
                Vector3 t1 = (Vector3)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR3);
                Vector3 t2 = (Vector3)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR3);
                output = new Vector3(t1.x / t2.x, t1.y / t2.y, t1.z / t2.z); 
            }
            if (outputType == typeof(Vector4))
            {
                Vector4 t1 = (Vector4)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR4);
                Vector4 t2 = (Vector4)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR4);
                output = new Vector4(t1.x / t2.x, t1.y / t2.y, t1.z / t2.z,t1.w/t2.w);
            }
            if (outputType == typeof(Vector2Int))
            {
                Vector2Int t1 = (Vector2Int)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR2INT);
                Vector2Int t2 = (Vector2Int)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR2INT);
                output = new Vector2Int(t1.x / t2.x, t1.y / t2.y);
            }
            if (outputType == typeof(Vector3Int))
            {
                Vector3Int t1 = (Vector3Int)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR3INT);
                Vector3Int t2 = (Vector3Int)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR3INT);
                output = new Vector3Int(t1.x/t2.x,t1.y/t2.y,t1.z/t2.z);
            }
            if (outputType == typeof(Quaternion))
            {
                Quaternion t1 = (Quaternion)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.VECTOR3INT);
                Quaternion t2 = (Quaternion)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR3INT);
                Quaternion o;
                o.x = t1.x / t2.x;
                o.y = t1.y / t2.y;
                o.z = t1.z / t2.z;
                o.w = t1.w / t2.w;
                output = o;
            }
            if (outputType == typeof(string))
            {
                string t1 = (string)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.STRING);
                string t2 = (string)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.STRING);
                output = t1 + "/"+ t2;
            }
            if (outputType == typeof(Color))
            {
                Color t1 = (Color)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.COLOR);
                Color t2 = (Color)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.COLOR);
                output = new Color(t1.r/t2.r,t1.g/t2.g,t1.b/t2.b,t1.a/t2.a);
            }
            return true;
        }
    }
}