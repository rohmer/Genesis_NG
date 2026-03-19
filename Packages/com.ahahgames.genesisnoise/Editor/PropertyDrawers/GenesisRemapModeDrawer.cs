using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisRemapModeDrawer : GenesisPropertyDrawer
    {
        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            int value = EditorGUI.IntPopup(position, label, (int)prop.floatValue, displayedOptions, optionValues);

            if (GUI.changed)
                prop.floatValue = (float)value;
        }

        static string[] displayedOptions = { "Brightness (Gradient)", "Red Channel (Curve)", "Green Channel (Curve)", "Blue Channel (Curve)", "Alpha Channel (Curve)", "All Channels (4 Curves)", "Brightness (Curve)", "Saturation (Curve)", "Hue (Curve)" };
        static int[] optionValues = { 0, 5, 6, 7, 1, 8, 2, 3, 4 };
    }
}