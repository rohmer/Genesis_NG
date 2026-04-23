using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisBoxBlurRadius : GenesisPropertyDrawer
    {
        public enum BoxBlurRadius
        {
            [InspectorName("3x3")]
            Three=1,
            [InspectorName("5x5")]
            Five = 2,
            [InspectorName("7x7")]
            Seven = 3,
            [InspectorName("9x9")]
            Nine = 4,
            [InspectorName("11x11")]
            Eleven = 5,
        }

        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            EditorGUI.BeginChangeCheck();
            int value = (int)(BoxBlurRadius)EditorGUI.EnumPopup(position, label, (BoxBlurRadius)(int)prop.floatValue);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = (float)value;
        }
    }
}
