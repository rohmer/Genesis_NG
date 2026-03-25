using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisShapeTypeDrawer: GenesisPropertyDrawer
    {
        public enum ShapeType
        {
            [InspectorName("Rectangle")]
            Rectangle = 0,
            [InspectorName("Ellipse")]
            Ellipse = 1,
            [InspectorName("Polygon")]
            Polygon = 2,
            [InspectorName("Rounded Rectangle")]
            RoundRect = 3,
            [InspectorName("Star")]
            Star = 4,
            [InspectorName("Capsule")]
            Capsule = 5,
            [InspectorName("Paraboloid")]
            Paraboloid = 6,
            [InspectorName("Super Ellipse")]
            SuperEllipse = 7,
            [InspectorName("Heart")]
            Heart = 8,
            [InspectorName("Diamond")]
            Diamond = 9,
            [InspectorName("Teardrop")]
            Teardrop=10            
        }

        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            EditorGUI.BeginChangeCheck();
            int value = (int)(ShapeType)EditorGUI.EnumPopup(position, label, (ShapeType)(int)prop.floatValue);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = (float)value;
        }
    }

}