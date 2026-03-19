using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisBlurMatrixDrawer : GenesisPropertyDrawer
    {
        public enum BlurMatrixDrawer
        {
            [InspectorName("3")]
            One = 0,
            [InspectorName("5")]
            Two = 1,
            [InspectorName("7")]
            Three = 2,
            [InspectorName("9")]
            Four = 3,
            [InspectorName("11")]
            Five = 4,
            [InspectorName("13")]
            Six = 5,
            [InspectorName("15")]
            Seven = 6,
        }

        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            EditorGUI.BeginChangeCheck();
            int value = (int)(BlurMatrixDrawer)EditorGUI.EnumPopup(position, label, (BlurMatrixDrawer)(int)prop.floatValue);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = (float)value;
        }
    }

}