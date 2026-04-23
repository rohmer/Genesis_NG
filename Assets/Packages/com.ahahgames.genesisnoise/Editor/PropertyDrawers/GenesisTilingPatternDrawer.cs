using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisTilePatternDrawer : GenesisPropertyDrawer
    {
        public enum TilePattern
        {
            [InspectorName("Texture Input")]
            One = 0,
            [InspectorName("Gaussian")]
            Two = 1,
            [InspectorName("Bell")]
            Three = 2,
            [InspectorName("Paraboloid")]
            Four = 3,
            [InspectorName("Disc")]
            Five = 4,
            [InspectorName("Square")]
            Six = 5,
            [InspectorName("Thorn")]
            Seven = 6,
            [InspectorName("Pyramid")]
            Eight = 7,
            [InspectorName("Brick")]
            Nine = 8,
            [InspectorName("Gradiation")]
            Ten = 9
        }

        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            EditorGUI.BeginChangeCheck();
            int value = (int)(TilePattern)EditorGUI.EnumPopup(position, label, (TilePattern)(int)prop.floatValue);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = (float)value;
        }
    }

}