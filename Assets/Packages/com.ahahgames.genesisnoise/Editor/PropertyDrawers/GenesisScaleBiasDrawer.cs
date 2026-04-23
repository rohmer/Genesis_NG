using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisScaleBiasDrawer : GenesisPropertyDrawer
    {
        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            int value = EditorGUI.IntPopup(position, label, (int)prop.floatValue, displayedOptions, optionValues);

            if (GUI.changed)
                prop.floatValue = (float)value;
        }

        static string[] displayedOptions = { "Scale Bias", "Bias Scale", "×2 -1 ", "×0.5 +0.5", "Scale", "Bias" };
        static int[] optionValues = { 0, 1, 4, 5, 2, 3 };
    }
}