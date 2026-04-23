using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisVector2IDrawer : GenesisPropertyDrawer
    {
        protected override void DrawerGUI(Rect position,
            MaterialProperty prop,
            string label,
            MaterialEditor editor,
            GenesisGraph graph,
            GenesisNodeView nodeView)
        {
            EditorGUIUtility.wideMode = true;
            int x = Mathf.RoundToInt(prop.vectorValue.x);
            int y = Mathf.RoundToInt(prop.vectorValue.y);
            Vector2Int value = new(x, y);
            value = EditorGUI.Vector2IntField(position, label, value);

            if (GUI.changed)
            {
                prop.vectorValue = new Vector4(value.x, value.y, 0, 0);
            }
        }
    }
}