using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class InlineTextureDrawer : GenesisPropertyDrawer
    {
        bool visibleInInspector = true;

        public InlineTextureDrawer() { }
        public InlineTextureDrawer(string v)
        {
            visibleInInspector = v != "HideInNodeInspector";
        }

        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            if (!visibleInInspector)
                return;

            if (!(prop.textureValue is Texture) && prop.textureValue != null)
                prop.textureValue = null;

            Texture value = (Texture)EditorGUI.ObjectField(position, prop.displayName, prop.textureValue, typeof(Texture), false);

            if (GUI.changed)
                prop.textureValue = value;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
            => visibleInInspector ? base.GetPropertyHeight(prop, label, editor) : -EditorGUIUtility.standardVerticalSpacing;
    }
}