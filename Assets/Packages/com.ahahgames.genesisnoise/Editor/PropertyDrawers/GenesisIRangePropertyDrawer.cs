using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class IRangeDrawer : GenesisPropertyDrawer
    {
        protected override void DrawerGUI(
            Rect position,
            MaterialProperty prop,
            string label,
            MaterialEditor editor,
            GenesisGraph graph,
            GenesisNodeView nodeView)
        {
            prop.intValue = EditorGUI.IntSlider(position, prop.displayName, prop.intValue, (int)prop.rangeLimits.x, (int)prop.rangeLimits.y);
        }
    }

}