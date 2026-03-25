using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisGradientTypeDrawer : GenesisPropertyDrawer
    {
        public enum GradientType
        {
            [InspectorName("0->1 ramp")]
            Ramp = 0,
            [InspectorName("Triangle")]
            Triangle = 1,
            [InspectorName("Smooth Mirrored Cosine")]
            Cosine = 2,
            [InspectorName("Radial")]
            Radial = 3,
            [InspectorName("Circular")]
            Circlular = 4,
            [InspectorName("Angular")]
            Angular = 5,
            [InspectorName("Diamond")]
            Diamond = 6,
            [InspectorName("Bilinear")]
            Bilinear = 7,
            [InspectorName("Quad")]
            Quad = 8,
            [InspectorName("Bezier")]
            Bezier = 9,
            [InspectorName("Multi-stop")]
            Multi = 10,
            [InspectorName("Gradient Bands")]
            Bands = 11,
            [InspectorName("Noise Modulation")]
            Noise = 12,
        }

        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            EditorGUI.BeginChangeCheck();
            int value = (int)(GradientType)EditorGUI.EnumPopup(position, label, (GradientType)(int)prop.floatValue);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = (float)value;
        }
    }

}