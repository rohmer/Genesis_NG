using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisChannelMaskDrawer : GenesisPropertyDrawer
    {
        protected override void DrawerGUI(
            Rect position,
            MaterialProperty prop,
            string label,
            MaterialEditor editor, Graph.GenesisGraph graph,
            Views.GenesisNodeView nodeView)
        {
            int value = EditorGUI.MaskField(position, label, (int)prop.floatValue, displayedOptions);

            if (GUI.changed)
            {
                prop.intValue = value;
            }
        }

        static string[] displayedOptions = { "Red", "Green", "Blue", "Alpha" };
    }
}