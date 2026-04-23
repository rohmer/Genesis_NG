using AhahGames.GenesisNoise.Views;

using GraphProcessor;

using System.IO;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.Graph
{
    /// <summary>
    /// The view for the GenesisNode.
    /// </summary>
    public class GenesisGraphWindow : BaseGraphWindow
    {
        internal GenesisGraphView view;

        public static GenesisGraphWindow Open(GenesisGraph graph)
        {
            // Focus the window if the graph is already opened
            var genesisWindows = Resources.FindObjectsOfTypeAll<GenesisGraphWindow>();
            foreach (var genesisWindow in genesisWindows)
            {
                if (genesisWindow.graph == graph)
                {
                    genesisWindow.Show();
                    genesisWindow.Focus();
                    return genesisWindow;
                }
            }

            var graphWindow = EditorWindow.CreateWindow<GenesisGraphWindow>();

            graphWindow.Show();
            graphWindow.Focus();

            graphWindow.InitializeGraph(graph);

            return graphWindow;
        }

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

            var genesis = (graph as GenesisGraph);
            var fileName = Path.GetFileNameWithoutExtension(genesis.mainAssetPath);
            titleContent = new GUIContent($"{fileName}", EditorUtilities.windowIcon);

            view = new GenesisGraphView(this);

            rootView.Add(view);

            view.Add(new GenesisToolbar(view));
        }

        protected override void OnDestroy()
        {
            view?.Dispose();
            GenesisUpdater.Instance.RemoveGraphToProcess(view);
        }

        public GenesisGraph GetCurrentGraph() => graph as GenesisGraph;
    }
}