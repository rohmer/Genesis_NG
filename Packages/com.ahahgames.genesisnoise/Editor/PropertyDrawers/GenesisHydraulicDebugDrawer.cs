using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisHydraulicDebug : GenesisPropertyDrawer
    {
        public enum DebugType
        {
            [InspectorName("Output")]
            Output = 0,
            [InspectorName("Height")]
            Height = 1,
            [InspectorName("Water Depth")]
            Depth = 2,
            [InspectorName("Sediment")]
            Sediment = 3,
            [InspectorName("Velocity Magnitude")]
            Velocity = 4,
            [InspectorName("Flux Vector")]
            Flux = 5,
            [InspectorName("Erosion Amount")]
            Erosion = 6,
            [InspectorName("Capacity")]
            Capacity = 7,
        }

        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            EditorGUI.BeginChangeCheck();
            int value = (int)(DebugType)EditorGUI.EnumPopup(position, label, (DebugType)(int)prop.floatValue);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = (float)value;
        }
    }
}
