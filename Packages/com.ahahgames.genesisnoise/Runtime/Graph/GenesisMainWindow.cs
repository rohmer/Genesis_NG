using AhahGames.GenesisNoise.Views;

using GraphProcessor;

using System.IO;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.Graph
{
    public class GenesisMainWindow : BaseGraphWindow
    {
        internal static GenesisGraphView view;

        public static GenesisMainWindow Open(GenesisGraph graph)
        {
            // Focus the window if the graph is already opened
            var genesisWindows = Resources.FindObjectsOfTypeAll<GenesisMainWindow>();
            foreach (var genesisWindow in genesisWindows)
            {
                if (genesisWindow.graph == graph)
                {
                    genesisWindow.Show();
                    genesisWindow.Focus();
                    view = (GenesisGraphView)genesisWindow.graphView;
                    return genesisWindow;
                }
            }

            var graphWindow = EditorWindow.CreateWindow<GenesisMainWindow>();
            graphWindow.Show();
            graphWindow.Focus();
            graphWindow.InitializeGraph(graph);
            view = (GenesisGraphView)graphWindow.graphView;
            return graphWindow;
        }

        public GenesisGraphView View { get { return view; } }
        protected new void OnEnable()
        {
            base.OnEnable();
            graphUnloaded += g => GenesisUpdater.Instance.RemoveGraphToProcess(g as GenesisGraph);
        }

        protected override void InitializeWindow(BaseGraph graph)
        {
            if (view != null)
            {
                view.Dispose();
                GenesisUpdater.Instance.RemoveGraphToProcess(view);
            }

            var genesisGraph = (graph as GenesisGraph);
            var fileName = Path.GetFileNameWithoutExtension(genesisGraph.mainAssetPath);
            titleContent = new GUIContent($"{fileName}", GenesisNoiseUtility.icon);

            view = new GenesisGraphView(this);

            rootView.Add(view);
            view.Add(new GenesisToolbar(view));
        }
    }
}