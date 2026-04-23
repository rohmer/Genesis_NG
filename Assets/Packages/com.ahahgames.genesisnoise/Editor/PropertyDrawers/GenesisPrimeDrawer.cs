using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisPrimeDrawer : GenesisPropertyDrawer
    {
        public enum Prime
        {
            [InspectorName("1")]
            One = 0,
            [InspectorName("2")]
            Two = 1,
            [InspectorName("3")]
            Three = 2,
            [InspectorName("5")]
            Five = 3,
            [InspectorName("7")]
            Seven = 4,
            [InspectorName("11")]
            Eleven = 5,
            [InspectorName("13")]
            Thirteen = 6,
            [InspectorName("17")]
            Seventeen = 7,
            [InspectorName("19")]
            Nineteen = 8,
            [InspectorName("23")]
            TwentyThree = 9
        }

        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            EditorGUI.BeginChangeCheck();
            int value = (int)(Prime)EditorGUI.EnumPopup(position, label, (Prime)(int)prop.floatValue);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = (float)value;
        }
    }
}