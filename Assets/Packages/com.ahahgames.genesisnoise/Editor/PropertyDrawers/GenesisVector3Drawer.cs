using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisVector3Drawer : GenesisPropertyDrawer
    {
        protected override void DrawerGUI(
            Rect position,
            MaterialProperty prop,
            string label, MaterialEditor editor,
            GenesisGraph graph,
            GenesisNodeView nodeView)
        {
            EditorGUIUtility.wideMode = true;
            Vector3 value = EditorGUI.Vector3Field(position, prop.displayName, prop.vectorValue);

            if (GUI.changed)
                prop.vectorValue = new Vector4(value.x, value.y, value.z, 0);
        }
    }
}