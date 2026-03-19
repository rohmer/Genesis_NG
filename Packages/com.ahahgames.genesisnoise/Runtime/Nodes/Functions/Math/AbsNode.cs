using AhahGames.GenesisNoise.Utility;

using Codice.Client.BaseCommands;

using GraphProcessor;

using System;

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Windows;

using static UnityEditor.Rendering.CameraUI;

namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Math/Abs")]
    public class AbsNode : ConstantNode
    {
        [Input(name = "Input")]
        public object inputA;

        [Output(name = "Output")]
        public object output;
        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA == null)
                return true;

            Type outputType = inputA.GetType();
            if (outputType == typeof(bool))
            {                
                output = (bool)inputA;
            }
            if (outputType == typeof(float))
            {
                output = (float)MathF.Abs((float)inputA);
            }
            if (outputType == typeof(int))
            {
                output = (int)MathF.Abs((int)inputA);
            }
            if (outputType == typeof(Vector2))
            {
                Vector2 i= (Vector2)inputA;
                output = new Vector2(MathF.Abs(i.x), MathF.Abs(i.y));
            }
            if (outputType == typeof(Vector3))
            {
                Vector3 i = (Vector3)inputA;
                output = new Vector3(MathF.Abs(i.x), MathF.Abs(i.y), MathF.Abs(i.z));
            }
            if (outputType == typeof(Vector4))
            {
                Vector4 i = (Vector4)inputA;
                output = new Vector4(MathF.Abs(i.x), MathF.Abs(i.y), MathF.Abs(i.z), MathF.Abs(i.w));
            }
            if (outputType == typeof(Vector2Int))
            {
                Vector2Int i = (Vector2Int)inputA;
                output = new Vector2Int((int)MathF.Abs(i.x), (int)MathF.Abs(i.y));
            }
            if (outputType == typeof(Vector3Int))
            {
                Vector3Int i = (Vector3Int)inputA;
                output = new Vector3Int((int)MathF.Abs(i.x), (int)MathF.Abs(i.y), (int)MathF.Abs(i.z));
            }
            if (outputType == typeof(Quaternion))
            {
                Quaternion i= (Quaternion)inputA;
                Quaternion o;
                o.x = Mathf.Abs(i.x);
                o.y = Mathf.Abs(i.y);
                o.z = Mathf.Abs(i.z);
                o.w = Mathf.Abs(i.w);
                output = o;
            }
            if (outputType == typeof(string))
            {
                string t1 = (string)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.STRING);
                
                output = t1;
            }
            if (outputType == typeof(Color))
            {
                Color t1 = (Color)TypeCaster.ToType(inputA, TypeCaster.genesisTypes.COLOR);

                output = new Color(
                    MathF.Abs(t1.r),
                    MathF.Abs(t1.g),
                    MathF.Abs(t1.b),
                    MathF.Abs(t1.a));
            }
            return true;
        }
    }
}

