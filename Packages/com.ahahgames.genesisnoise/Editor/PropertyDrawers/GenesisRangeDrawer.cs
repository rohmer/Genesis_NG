using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisRangeDrawer : GenesisPropertyDrawer
    {
        protected override void DrawerGUI(
            Rect position,
            MaterialProperty prop,
            string label,
            MaterialEditor editor,
            GenesisGraph graph,
            GenesisNodeView nodeView)
        {
            prop.floatValue = EditorGUI.Slider(position, prop.displayName, prop.floatValue, prop.rangeLimits.x, prop.rangeLimits.y);
        }
    }

}