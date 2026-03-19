using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisGrayscaleDrawer : GenesisPropertyDrawer
    {
        public enum GrayscaleAlgorithm
        {
            Luminance = 0,
            Average = 1,
            [InspectorName("Min\\Max Average")]
            MinMaxAvg = 2,
            Desaturation = 3,
            [InspectorName("One Channel")]
            OneChannel = 4,
            [InspectorName("Gamma Corrected")]
            GammaCorrected = 5
        }

        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            EditorGUI.BeginChangeCheck();
            int value = (int)(GrayscaleAlgorithm)EditorGUI.EnumPopup(position, label, (GrayscaleAlgorithm)(int)prop.floatValue);
            if (EditorGUI.EndChangeCheck())
            {
                prop.floatValue = (float)value;
            }
        }
    }
}