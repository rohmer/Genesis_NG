using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisKernelDrawer : GenesisPropertyDrawer
    {
        public enum KernelSize
        {
            [InspectorName("9")]
            Nine = 0,
            [InspectorName("17")]
            Seventeen = 1,
            [InspectorName("27")]
            TwentySeven = 2,
            [InspectorName("63")]
            SixtyThree = 3,
            [InspectorName("81")]
            EightyOne = 4,
            [InspectorName("121")]
            OneTwentyOne = 5,
            [InspectorName("225")]
            TwoTwentyFive = 6
        }

        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            EditorGUI.BeginChangeCheck();
            int value = (int)(KernelSize)EditorGUI.EnumPopup(position, label, (KernelSize)(int)prop.floatValue);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = (float)value;
        }
    }

}