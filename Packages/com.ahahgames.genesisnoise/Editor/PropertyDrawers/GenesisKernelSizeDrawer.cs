using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisKernelSizeDrawer : GenesisPropertyDrawer
    {
        public enum KernelSize
        {
            [InspectorName("3x3")]
            One = 0,
            [InspectorName("5x5")]
            Two = 1,
            [InspectorName("7x7")]
            Three = 2,
            [InspectorName("9x9")]
            Four = 3,
            [InspectorName("11x11")]
            Five = 4
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