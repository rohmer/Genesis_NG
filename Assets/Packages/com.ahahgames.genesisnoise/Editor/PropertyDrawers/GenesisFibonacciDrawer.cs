using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisFibonacciDrawer : GenesisPropertyDrawer
    {
        public enum Fibonacci
        {
            [InspectorName("1")]
            One = 0,
            [InspectorName("2")]
            Two = 1,
            [InspectorName("3")]
            Three = 2,
            [InspectorName("5")]
            Five = 3,
            [InspectorName("8")]
            Eight = 4,
            [InspectorName("13")]
            Thirteen = 5,
            [InspectorName("21")]
            TwentyOne = 6,
            [InspectorName("34")]
            ThirtyFour = 6


        }

        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            EditorGUI.BeginChangeCheck();
            int value = (int)(Fibonacci)EditorGUI.EnumPopup(position, label, (Fibonacci)(int)prop.floatValue);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = (float)value;
        }
    }

}