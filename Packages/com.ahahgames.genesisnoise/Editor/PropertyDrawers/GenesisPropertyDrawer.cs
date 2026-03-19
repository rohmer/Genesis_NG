using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using System.Collections.Generic;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisPropertyDrawer : MaterialPropertyDrawer
    {
        class GenesisDrawerInfo
        {
            public GenesisGraph graph;
            public GenesisNodeView nodeView;
        }

        static Dictionary<MaterialEditor, GenesisDrawerInfo> genesisDrawerInfos = new();

        public static void RegisterEditor(MaterialEditor editor, GenesisNodeView nodeView, GenesisGraph graph)
        {
            genesisDrawerInfos[editor] = new GenesisDrawerInfo { graph = graph, nodeView = nodeView };
        }

        public static void UnregisterGraph(GenesisGraph graph)
        {
            try
            {
                foreach (var kp in genesisDrawerInfos)
                {
                    if (kp.Value.graph == graph)
                        genesisDrawerInfos.Remove(kp.Key);
                }
            }
            catch
            {
                //TODO: Figure out why this is throwing
            }
        }

        protected GenesisGraph GetGraph(MaterialEditor editor) => genesisDrawerInfos[editor].graph;
        protected GenesisNodeView GetNodeView(MaterialEditor editor) => genesisDrawerInfos[editor].nodeView;

        public sealed override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            // In case the material is shown in the inspector, the editor will not be linked to a node
            if (!genesisDrawerInfos.ContainsKey(editor))
            {
                DrawerGUI(position, prop, label, editor, null, null);
                return;
            }

            var nodeView = GetNodeView(editor);
            var graph = GetGraph(editor);

            DrawerGUI(position, prop, label, editor, graph, nodeView);
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            if (!genesisDrawerInfos.ContainsKey(editor))
                return base.GetPropertyHeight(prop, label, editor);

            return base.GetPropertyHeight(prop, label, editor);
        }

        protected virtual void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView) { }
    }
}