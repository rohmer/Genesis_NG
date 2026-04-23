using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisPowerDrawer : GenesisPropertyDrawer
    {
        public enum KernelSize
        {
            [InspectorName("9")]
            One = 0,
            [InspectorName("16")]
            Two = 1,
            [InspectorName("25")]
            Three = 2,
            [InspectorName("36")]
            Four = 3,
            [InspectorName("49")]
            Five = 4,
            [InspectorName("64")]
            Six = 5,
            [InspectorName("81")]
            Seven = 6,
            [InspectorName("100")]
            Eight = 7,
            [InspectorName("121")]
            Nine = 8,
            [InspectorName("144")]
            Ten = 9
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