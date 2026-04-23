using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisSlopeBlurBlend : GenesisPropertyDrawer
    {
        public enum BlendMode
        {
            Minimum =0,
            Maximum = 1,
            Average = 2
        }
        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            EditorGUI.BeginChangeCheck();
            int value = (int)(BlendMode)EditorGUI.EnumPopup(position, label, (BlendMode)(int)prop.floatValue);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = (float)value;
        }
    }
}
