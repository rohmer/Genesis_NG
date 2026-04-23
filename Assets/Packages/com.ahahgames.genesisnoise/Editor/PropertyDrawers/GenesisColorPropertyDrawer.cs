using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisColorPropertyDrawer : GenesisPropertyDrawer
    {
        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            EditorGUI.BeginChangeCheck();
            Color color = EditorGUI.ColorField(position, label, prop.colorValue);
            if (EditorGUI.EndChangeCheck())
            {
                prop.colorValue = color;
                // Update the node view to reflect the new color             
            }
        }
    }
}